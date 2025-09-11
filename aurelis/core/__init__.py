# aurelis/core/__init__.py
import asyncio
import aiohttp
import numpy as np
import pandas as pd
from typing import Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta
import json
import hashlib

@dataclass
class MarketData:
    symbol: str
    price: float
    change: float
    timestamp: datetime
    volume: float
    volatility: float

@dataclass
class CreationCredit:
    user_did: str
    amount: float
    source_asset: str
    market_delta: float
    timestamp: datetime
    expires: datetime
    purpose: str = "creation"

class AURELISEngine:
    def __init__(self):
        self.market_data: Dict[str, MarketData] = {}
        self.credit_pool: float = 0.0
        self.reserve_pool: float = 100000.0  # Initial reserve
        self.last_prices: Dict[str, float] = {}
        self.credit_allocations: List[CreationCredit] = []
        self.volatility_window = 20  # 20-period volatility
        self.smoothing_factor = 0.94  # EWMA factor
        
    async def ingest_market_data(self, data_streams: List[str]):
        """Ingest real-time market data from multiple sources"""
        async with aiohttp.ClientSession() as session:
            while True:
                try:
                    for stream in data_streams:
                        async with session.get(stream) as response:
                            data = await response.json()
                            await self.process_market_data(data)
                    await asyncio.sleep(1)  # Throttle requests
                except Exception as e:
                    print(f"Market data ingestion error: {e}")
                    await asyncio.sleep(5)
    
    async def process_market_data(self, data: dict):
        """Process and smooth market data"""
        symbol = data['symbol']
        current_price = float(data['price'])
        
        # Calculate volatility using EWMA
        if symbol in self.last_prices:
            returns = (current_price - self.last_prices[symbol]) / self.last_prices[symbol]
            if symbol not in self.market_data:
                self.market_data[symbol] = MarketData(
                    symbol=symbol,
                    price=current_price,
                    change=0,
                    timestamp=datetime.now(),
                    volume=0,
                    volatility=0.01  # Initial volatility
                )
            else:
                # Update volatility with EWMA
                old_vol = self.market_data[symbol].volatility
                new_vol = np.sqrt(self.smoothing_factor * old_vol**2 + 
                                (1 - self.smoothing_factor) * returns**2)
                
                self.market_data[symbol] = MarketData(
                    symbol=symbol,
                    price=current_price,
                    change=returns * 100,
                    timestamp=datetime.now(),
                    volume=data.get('volume', 0),
                    volatility=new_vol
                )
                
                # Harvest creation credits
                await self.harvest_credits(symbol, current_price, self.last_prices[symbol])
        
        self.last_prices[symbol] = current_price
    
    async def harvest_credits(self, symbol: str, current_price: float, last_price: float):
        """Harvest creation credits from market movements"""
        delta_pct = (current_price - last_price) / last_price
        volatility = self.market_data[symbol].volatility
        
        # Adaptive harvesting based on volatility
        harvest_ratio = 0.1 * (0.02 / max(volatility, 0.02))  # Scale with volatility
        
        if delta_pct > 0:
            # Gain harvesting
            harvest = delta_pct * harvest_ratio * self.reserve_pool
            self.credit_pool += harvest
            # Add to reserve for stability
            self.reserve_pool += delta_pct * 0.05 * self.reserve_pool
            
            print(f"Harvested {harvest:.2f} CC from {symbol} gain of {delta_pct:.2%}")
            
        elif delta_pct < 0 and self.reserve_pool > 1000:  # Minimum reserve
            # Loss cushioning
            release = min(abs(delta_pct) * harvest_ratio * self.reserve_pool, 
                         self.reserve_pool * 0.2)
            self.credit_pool += release
            self.reserve_pool -= release
            
            print(f"Cushioned {release:.2f} CC from {symbol} loss of {delta_pct:.2%}")
        
        # Distribute credits if pool is sufficient
        if self.credit_pool > 1000:  # Distribution threshold
            await self.distribute_credits()
    
    async def distribute_credits(self):
        """Distribute creation credits ethically"""
        # Calculate daily allocation
        daily_allocation = self.credit_pool * 0.8  # 80% for daily distribution
        self.credit_pool -= daily_allocation
        
        # Get active users (in real implementation, from DB)
        active_users = await self.get_active_users()
        
        # Equal base allocation + merit-based bonus
        base_allocation = daily_allocation * 0.7 / len(active_users)
        merit_allocation = daily_allocation * 0.3
        
        for user in active_users:
            merit_score = await self.calculate_merit_score(user)
            user_allocation = base_allocation + (merit_score * merit_allocation)
            
            credit = CreationCredit(
                user_did=user['did'],
                amount=user_allocation,
                source_asset="Multi-asset",
                market_delta=0,  # Aggregated
                timestamp=datetime.now(),
                expires=datetime.now() + timedelta(days=1),
                purpose=user.get('preferred_purpose', 'creation')
            )
            
            self.credit_allocations.append(credit)
            await self.log_allocation(credit)
            
            print(f"Allocated {user_allocation:.2f} CC to {user['did']}")
    
    async def get_active_users(self) -> List[Dict]:
        """Get active users from database"""
        # Mock implementation - replace with actual DB query
        return [
            {"did": "did:bit:hub:developer_1", "preferred_purpose": "development"},
            {"did": "did:bit:hub:researcher_1", "preferred_purpose": "research"},
            {"did": "did:bit:hub:creator_1", "preferred_purpose": "content"},
            {"did": "did:bit:hub:educator_1", "preferred_purpose": "education"}
        ]
    
    async def calculate_merit_score(self, user: Dict) -> float:
        """Calculate merit-based allocation score"""
        # Mock implementation - replace with actual metrics
        return np.random.uniform(0.5, 1.0)
    
    async def log_allocation(self, credit: CreationCredit):
        """Log allocation to immutable ledger"""
        log_entry = {
            "user_did": credit.user_did,
            "amount": round(credit.amount, 2),
            "source_asset": credit.source_asset,
            market_delta: round(credit.market_delta, 4),
            "timestamp": credit.timestamp.isoformat(),
            "expires": credit.expires.isoformat(),
            "purpose": credit.purpose,
            "hash": self.generate_hash(credit)
        }
        
        # Append to ledger file (replace with decentralized storage)
        with open("aurelis_ledger.jsonl", "a") as f:
            f.write(json.dumps(log_entry) + "\n")
        
        # Anchor to Bit.Hub (mock - implement actual anchoring)
        await self.anchor_to_bithub(log_entry)
    
    def generate_hash(self, credit: CreationCredit) -> str:
        """Generate hash for ledger entry"""
        data = f"{credit.user_did}{credit.amount}{credit.timestamp.isoformat()}"
        return hashlib.sha256(data.encode()).hexdigest()
    
    async def anchor_to_bithub(self, log_entry: dict):
        """Anchor transaction to Bit.Hub ledger"""
        # Mock implementation - replace with actual Bit.Hub API
        print(f"Anchored to Bit.Hub: {log_entry['hash']}")
