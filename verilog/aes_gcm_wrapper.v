// aes_gcm_wrapper.v
// Byte-stream <-> 128-bit-block AES-GCM wrapper
// - Accepts byte-wise input (in_valid/in_byte/frame_end).
// - Emits byte-wise output (out_valid/out_byte).
// - Supports encrypt (mode=0) and decrypt (mode=1).
// - On encrypt: produces tag_out + tag_valid at frame end.
// - On decrypt: requires tag_in + tag_in_valid after ciphertext; outputs tag_ok when tag verified.
// NOTES:
//  - This wrapper expects a block-mode AES-GCM core with the interface documented below.
//  - For brevity this wrapper pads the last partial block with zeros when necessary.
//  - Replace/adjust sizes if you use a core with different tag/IV widths.

module aes_gcm_wrapper #(
    parameter TAG_WIDTH = 128,
    parameter KEY_WIDTH = 128,
    parameter IV_WIDTH  = 96
)(
    input  wire                 clk,
    input  wire                 rst,

    // control
    input  wire                 mode,        // 0 = encrypt, 1 = decrypt
    input  wire [KEY_WIDTH-1:0] key,
    input  wire [IV_WIDTH-1:0]  iv,

    // Byte-wise application interface (input)
    input  wire                 in_valid,
    input  wire [7:0]           in_byte,
    input  wire                 frame_end,   // assert during cycle that carries last byte
    output reg                  in_ready,

    // Byte-wise application interface (output)
    output reg                  out_valid,
    output reg  [7:0]           out_byte,
    input  wire                 out_ready,

    // Tag interface (encrypt outputs tag_out; decrypt supplies tag_in to verify)
    output reg  [TAG_WIDTH-1:0] tag_out,
    output reg                  tag_valid,
    input  wire [TAG_WIDTH-1:0] tag_in,
    input  wire                 tag_in_valid,
    output reg                  tag_ok,

    // Status
    output reg                  busy
);

    // --- Parameters & local ---
    localparam BLOCK_BYTES = 16;
    localparam BLOCK_BITS  = 128;

    // Block buffers: collect up to 16 bytes
    reg [BLOCK_BITS-1:0] block_buf;
    reg [3:0]            block_cnt; // 0..16
    reg                  block_has_data;
    reg                  block_last_flag;

    // Handshake with AES-GCM core (assumed block streaming)
    reg                  core_in_valid;
    reg  [BLOCK_BITS-1:0] core_in_block;
    reg                  core_in_last;
    wire                 core_in_ready;

    wire                 core_out_valid;
    wire [BLOCK_BITS-1:0] core_out_block;
    wire                 core_out_last;

    wire                 core_tag_valid;
    wire [TAG_WIDTH-1:0] core_tag;
    reg                  core_start;
    reg                  core_mode; // wired from mode
    reg  [KEY_WIDTH-1:0] core_key;
    reg  [IV_WIDTH-1:0]  core_iv;

    // Byte output serialization
    reg [3:0]            out_byte_idx;
    reg [BLOCK_BITS-1:0] out_block_reg;
    reg                  out_block_pending;

    // Simple FSM
    typedef enum reg [2:0] {
        S_IDLE = 3'd0,
        S_ACC  = 3'd1,
        S_SEND = 3'd2,
        S_WAIT = 3'd3,
        S_DRAIN= 3'd4
    } state_t;

    state_t state, next_state;

    // -------------------------------------------------------------------------
    // Expected AES-GCM "block" core interface (example mapping)
    // The wrapper assumes a core with the following signals (names are local):
    //  - Inputs:
    //      core_clk, core_rst
    //      core_start (pulse to start operation)
    //      core_mode  (0=encrypt,1=decrypt)
    //      core_key[127:0], core_iv[95:0]
    //      core_in_valid, core_in_block[127:0], core_in_last
    //  - Outputs:
    //      core_in_ready (ready to accept next block)
    //      core_out_valid, core_out_block[127:0], core_out_last
    //      core_tag_valid, core_tag[127:0]
    //      core_done (optional; tag_valid is used here)
    //
    // You should map these signals to your AES-GCM IP. Many open-source cores
    // provide similar streaming/block interfaces; adapt names as required.
    // -------------------------------------------------------------------------

    // Connect wrapper-local core control registers
    always @(posedge clk) begin
        if (rst) begin
            core_mode <= 1'b0;
            core_key  <= {KEY_WIDTH{1'b0}};
            core_iv   <= {IV_WIDTH{1'b0}};
            core_start <= 1'b0;
        end else begin
            core_mode <= mode;
            core_key  <= key;
            core_iv   <= iv;
            core_start <= 1'b0; // pulsed elsewhere if needed
        end
    end

    // --- Input accumulation (bytes -> 128-bit block) ---
    always @(posedge clk) begin
        if (rst) begin
            block_buf <= {BLOCK_BITS{1'b0}};
            block_cnt <= 4'd0;
            block_has_data <= 1'b0;
            block_last_flag <= 1'b0;
            in_ready <= 1'b1;
        end else begin
            if (in_valid && in_ready) begin
                // shift in byte (big-endian in block_buf: MSB first)
                block_buf <= {block_buf[BLOCK_BITS-9:0], in_byte};
                block_cnt <= block_cnt + 1;
                block_has_data <= 1'b1;
                block_last_flag <= frame_end;
                // if we've filled a block, stop accepting until core takes it
                if (block_cnt == (BLOCK_BYTES - 1)) begin
                    in_ready <= 1'b0;
                end
            end

            // Accept more bytes if not full
            if (!in_valid && !in_ready && block_cnt == 0) begin
                in_ready <= 1'b1;
            end
        end
    end

    // --- FSM next-state logic ---
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (block_has_data) next_state = S_ACC;
            end
            S_ACC: begin
                // if block full OR last flagged, send to core
                if ((block_cnt == BLOCK_BYTES) || (block_last_flag && block_has_data)) begin
                    next_state = S_SEND;
                end
            end
            S_SEND: begin
                if (core_in_ready) next_state = S_WAIT;
            end
            S_WAIT: begin
                if (core_out_valid) next_state = S_DRAIN;
            end
            S_DRAIN: begin
                if (!out_block_pending && !block_has_data) next_state = S_IDLE;
                else if (!out_block_pending && block_has_data) next_state = S_ACC;
            end
            default: next_state = S_IDLE;
        endcase
    end

    // --- FSM sequential ---
    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            core_in_valid <= 1'b0;
            core_in_block <= {BLOCK_BITS{1'b0}};
            core_in_last <= 1'b0;
            out_block_pending <= 1'b0;
            out_block_reg <= {BLOCK_BITS{1'b0}};
            out_byte_idx <= 4'd0;
            out_valid <= 1'b0;
            out_byte <= 8'd0;
            busy <= 1'b0;
            tag_out <= {TAG_WIDTH{1'b0}};
            tag_valid <= 1'b0;
            tag_ok <= 1'b0;
        end else begin
            state <= next_state;
            // default signals
            core_in_valid <= 1'b0;
            core_in_last  <= 1'b0;
            tag_valid <= 1'b0;

            case (next_state)
                S_IDLE: begin
                    busy <= 1'b0;
                    in_ready <= 1'b1;
                end

                S_ACC: begin
                    busy <= 1'b1;
                    in_ready <= (block_cnt < BLOCK_BYTES);
                    // Wait for more bytes or frame_end
                end

                S_SEND: begin
                    // prepare a 128-bit block to send: if last partial block, pad zeros in MSBs
                    // current block_buf contains left-shifted bytes; block_cnt indicates how many bytes
                    // We send the full 128-bit register as-is (bytes aligned MSB-first)
                    core_in_block <= block_buf;
                    core_in_valid <= 1'b1;
                    core_in_last  <= block_last_flag;
                    // mark as consumed
                    block_buf <= {BLOCK_BITS{1'b0}};
                    block_cnt <= 4'd0;
                    block_has_data <= 1'b0;
                    block_last_flag <= 1'b0;
                    in_ready <= 1'b1;
                end

                S_WAIT: begin
                    busy <= 1'b1;
                    // waiting for core_out_valid
                end

                S_DRAIN: begin
                    if (core_out_valid && !out_block_pending) begin
                        out_block_reg <= core_out_block;
                        out_block_pending <= 1'b1;
                        out_byte_idx <= 4'd0; // will output MSB-first
                        // capture tag if core produced one
                        if (core_tag_valid) begin
                            tag_out <= core_tag;
                            tag_valid <= 1'b1;
                        end
                        // On decrypt mode: compare tags if tag_in_valid present
                        if (mode && core_tag_valid && tag_in_valid) begin
                            tag_ok <= (core_tag == tag_in);
                        end
                    end

                    // Output serialization
                    if (out_block_pending) begin
                        if (!out_valid || (out_valid && out_ready)) begin
                            out_valid <= 1'b1;
                            out_byte <= out_block_reg[BLOCK_BITS-1 - (out_byte_idx*8) -: 8];
                            out_byte_idx <= out_byte_idx + 1;
                            if (out_byte_idx == (BLOCK_BYTES - 1)) begin
                                out_block_pending <= 1'b0;
                                out_valid <= 1'b0; // consumed on next cycle if out_ready
                            end
                        end
                    end else begin
                        out_valid <= 1'b0;
                    end
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Hook-up points to the AES-GCM block core
    // Replace `aes_gcm_core` below with the actual core you have and wire ports:
    //  - core_in_valid  <= core_in_valid
    //  - core_in_block  <= core_in_block
    //  - core_in_last   <= core_in_last
    //  - core_in_ready  -> core_in_ready
    //  - core_out_valid -> core_out_valid
    //  - core_out_block -> core_out_block
    //  - core_out_last  -> core_out_last
    //  - core_tag_valid -> core_tag_valid
    //  - core_tag       -> core_tag
    //  - core_start     <= core_start (pulse before first block) -- optional for your IP
    //  - core_mode/key/iv <= core_mode/core_key/core_iv
    // -------------------------------------------------------------------------

    // Mock wires so this file is syntactically self-contained. Replace these when instantiating.
    assign core_in_ready  = 1'b1;
    assign core_out_valid = 1'b0;
    assign core_out_block = {BLOCK_BITS{1'b0}};
    assign core_out_last  = 1'b0;
    assign core_tag_valid = 1'b0;
    assign core_tag       = {TAG_WIDTH{1'b0}};

endmodule
