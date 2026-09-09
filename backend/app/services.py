import httpx
from fastapi import HTTPException
from datetime import datetime, timedelta
from typing import Dict, Any, List
from .config import FRANKFURTER_BASE_URL, TRAVEL_CURRENCIES

async def fetch_frankfurter(endpoint: str, params: Dict[str, Any] = None) -> Dict[str, Any]:
    """Helper method to asynchronously fetch data from the external Frankfurter API."""
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{FRANKFURTER_BASE_URL}{endpoint}", params=params, timeout=10.0)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPStatusError as e:
            if response.status_code == 404:
                raise HTTPException(status_code=400, detail="Currency combination not supported by the provider.")
            raise HTTPException(status_code=response.status_code, detail="External API error")
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail="Currency provider service unavailable")

async def get_live_rate(source: str, target: str) -> float:
    """Fetch the live exchange rate for a specific pair."""
    if source == target:
        return 1.0
    
    data = await fetch_frankfurter("/latest", {"from": source, "to": target})
    rate = data.get("rates", {}).get(target)
    if not rate:
        raise HTTPException(status_code=400, detail="Target currency rate not found")
    return float(rate)

async def get_historical_trends(source: str, target: str, days: int = 30) -> List[Dict[str, Any]]:
    """Fetch time-series trend data formatted for frontend charts."""
    if source == target:
        raise HTTPException(status_code=400, detail="Source and Target must be different for trend data")

    end_date = datetime.utcnow().date()
    start_date = end_date - timedelta(days=days)
    
    endpoint = f"/{start_date.isoformat()}..{end_date.isoformat()}"
    data = await fetch_frankfurter(endpoint, {"from": source, "to": target})
    
    rates = data.get("rates", {})
    
    trend_data = []
    for date_str, rate_dict in rates.items():
        if target in rate_dict:
            trend_data.append({
                "date": date_str,
                "rate": rate_dict[target]
            })
            
    return trend_data

async def get_vibe_check_comparisons(base: str, amount: float) -> List[Dict[str, Any]]:
    """Calculates simultaneous conversions for the travel budget 'vibe check' feature."""
    targets = [curr for curr in TRAVEL_CURRENCIES if curr != base]
    results = []
    
    if base in TRAVEL_CURRENCIES:
        results.append({
            "currency": base,
            "rate": 1.0,
            "equivalent": amount
        })
        
    if targets:
        data = await fetch_frankfurter("/latest", {"from": base, "to": ",".join(targets)})
        rates = data.get("rates", {})
        
        for curr, rate in rates.items():
            results.append({
                "currency": curr,
                "rate": rate,
                "equivalent": round(amount * rate, 2)
            })
            
    results.sort(key=lambda x: x["currency"])
    return results
