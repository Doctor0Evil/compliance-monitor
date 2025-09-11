# aurelis/server/main.py
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import asyncio
import json
from typing import Dict, List
import uuid

from ..core import AURELISEngine

app = FastAPI(title="AURELIS API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files
app.mount("/static", StaticFiles(directory="aurelis/dashboard"), name="static")

# Global engine instance
engine = AURELISEngine()

@app.get("/")
async def root():
    return FileResponse("aurelis/dashboard/index.html")

@app.get("/aurelis-data")
async def get_aurelis_data():
    """Get current AURELIS state"""
    return {
        "credit_pool": engine.credit_pool,
        "reserve_pool": engine.reserve_pool,
        "market_data": {k: v.__dict__ for k, v in engine.market_data.items()},
        "allocations": [{
            "user_did": alloc.user_did,
            "amount": alloc.amount,
            "source_asset": alloc.source_asset,
            "market_delta": alloc.market_delta,
            "timestamp": alloc.timestamp.isoformat(),
            "purpose": alloc.purpose
        } for alloc in engine.credit_allocations[-10:]],  # Last 10 allocations
        "distribution": {
            "development": 0.35,
            "research": 0.25,
            "content": 0.20,
            "education": 0.15,
            "grants": 0.05
        }
    }

@app.websocket("/aurelis-data-stream")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time data"""
    await websocket.accept()
    client_id = str(uuid.uuid4())
    
    try:
        # Send initial data
        data = await get_aurelis_data()
        await websocket.send_json(data)
        
        # Keep connection open and send updates
        while True:
            await asyncio.sleep(1)
            data = await get_aurelis_data()
            await websocket.send_json(data)
            
    except WebSocketDisconnect:
        print(f"Client {client_id} disconnected")
    except Exception as e:
        print(f"WebSocket error: {e}")

@app.on_event("startup")
async def startup_event():
    """Start market data ingestion on startup"""
    # Mock data streams (replace with real APIs)
    mock_streams = [
        "https://api.mock.com/market/spx",
        "https://api.mock.com/market/ndx",
        "https://api.mock.com/market/btc"
    ]
    
    # Start ingestion in background
    asyncio.create_task(engine.ingest_market_data(mock_streams))
    
    # Simulate market data for demo
    asyncio.create_task(simulate_market_data())

async def simulate_market_data():
    """Simulate market data for demonstration"""
    symbols = ["SPX", "NDX", "BTC", "ETH", "GOLD"]
    prices = {
        "SPX": 4500.0,
        "NDX": 15000.0,
        "BTC": 50000.0,
        "ETH": 3000.0,
        "GOLD": 1800.0
    }
    
    while True:
        for symbol in symbols:
            # Random price movement
            change = np.random.normal(0, 0.002)  # 0.2% average change
            prices[symbol] *= (1 + change)
            
            # Simulate market data packet
            market_data = {
                "symbol": symbol,
                "price": prices[symbol],
                "change": change * 100,
                "volume": np.random.lognormal(10, 2),
                "timestamp": datetime.now().isoformat()
            }
            
            await engine.process_market_data(market_data)
        
        await asyncio.sleep(2)  # Update every 2 seconds

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
