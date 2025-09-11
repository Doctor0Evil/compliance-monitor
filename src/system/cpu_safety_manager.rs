// src/system/cpu_safety_manager.rs
use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Serialize, Deserialize)]
struct CpuControlConfig {
    max_threads: usize,
    max_cpu_percent: u8,
    allow_kernel_patch: bool,
    allow_user_patch: bool,
    safe_layers: Vec<String>,
    forbidden_layers: Vec<String>,
    allow_interpret: bool,
    allow_program: bool,
    allow_write: bool,
    allow_read: bool,
    // Hard limits on code execution in restricted segments
    max_instructions_permitted: u64,
    max_read_bytes: u64,
    max_write_bytes: u64,
}

// Top-level, patch-friendly safety boundary enforcement logic
fn enforce_cpu_safety(config: &mut CpuControlConfig) {
    config.max_threads = 4;                        // Safe cap: 4 threads
    config.max_cpu_percent = 60;                   // Never exceed 60% overall CPU
    config.allow_kernel_patch = false;             // Never patch/modify kernel or forbidden layers
    config.allow_user_patch = true;                // Only allow patching in user-approved safe layers
    config.forbidden_layers = vec![
        String::from("kernel"),
        String::from("hypervisor"),
        String::from("firmware"),
        String::from("protected-system"),
        String::from("hardware-abstraction"),
        String::from("secure-vm")
    ];
    config.safe_layers = vec![
        String::from("user-space"),
        String::from("application"),
        String::from("sandbox"),
        String::from("testing")
    ];
    config.allow_interpret = true;                 // Allow interpret only in safe/user layers
    config.allow_program = true;
    config.allow_write = true;
    config.allow_read = true;
    config.max_instructions_permitted = 200_000_000; // Soft cap, can be tuned
    config.max_read_bytes = 10_000_000;            // 10MB cap for read ops
    config.max_write_bytes = 2_000_000;            // 2MB cap for writes
}

fn main() {
    let data = fs::read_to_string("cpu_control_config.json").unwrap();
    let mut config: CpuControlConfig = serde_json::from_str(&data).unwrap();

    enforce_cpu_safety(&mut config);

    fs::write("cpu_control_config.json", serde_json::to_string_pretty(&config).unwrap()).unwrap();
}
