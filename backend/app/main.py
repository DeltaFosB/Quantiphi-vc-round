from fastapi import FastAPI, HTTPException, Query, Path
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import httpx
import sqlite3
import os

from .database import get_db_connection

app = FastAPI(title="Currency Converter API")

# Configure CORS for Vite frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

FRANKFURTER_BASE_URL = "https://api.frankfurter.dev/v1"
TRAVEL_CURRENCIES = ["USD", "EUR", "GBP", "JPY", "AUD"]

# --- Pydantic Models ---

class ConvertRequest(BaseModel):
    source: str = Field(..., min_length=3, max_length=3, description="Source currency code (e.g., USD)")
    target: str = Field(..., min_length=3, max_length=3, description="Target currency code (e.g., EUR)")
    amount: float = Field(..., gt=0, description="Amount must be greater than zero")

class TravelBudgetRequest(BaseModel):
    base_currency: str = Field(..., min_length=3, max_length=3)
    amount: float = Field(..., gt=0)

class FavoriteRequest(BaseModel):
    source: str = Field(..., min_length=3, max_length=3)
    target: str = Field(..., min_length=3, max_length=3)

# --- Helper Functions ---

async def fetch_frankfurter(endpoint: str, params: dict = None) -> dict:
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

# --- Endpoints ---

@app.get("/api/currencies")
async def get_currencies():
    """Fetch available currencies from Frankfurter API."""
    data = await fetch_frankfurter("/currencies")
    return {"currencies": data}

@app.post("/api/convert")
async def convert_currency(req: ConvertRequest):
    """Convert amount and log to SQLite database."""
    source_curr = req.source.upper()
    target_curr = req.target.upper()
    
    # Handle same-currency conversion
    if source_curr == target_curr:
        rate = 1.0
    else:
        data = await fetch_frankfurter("/latest", {"from": source_curr, "to": target_curr})
        rate = data.get("rates", {}).get(target_curr)
        if not rate:
            raise HTTPException(status_code=400, detail="Target currency rate not found")

    converted_amount = round(req.amount * rate, 4)

    # Log to SQLite
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO conversion_history (source_currency, target_currency, amount, converted_amount, rate)
            VALUES (?, ?, ?, ?, ?)
            """,
            (source_curr, target_curr, req.amount, converted_amount, rate)
        )
        conn.commit()
    except Exception as e:
        print(f"DB Error: {e}")
    finally:
        if 'conn' in locals():
            conn.close()

    return {
        "source": source_curr,
        "target": target_curr,
        "amount": req.amount,
        "converted_amount": converted_amount,
        "rate": rate
    }

@app.get("/api/trends")
async def get_trends(
    source: str = Query(..., min_length=3, max_length=3),
    target: str = Query(..., min_length=3, max_length=3)
):
    """Fetch 30-day historical time-series data for a currency pair."""
    source_curr = source.upper()
    target_curr = target.upper()
    
    if source_curr == target_curr:
        raise HTTPException(status_code=400, detail="Source and Target must be different for trend data")

    end_date = datetime.utcnow().date()
    start_date = end_date - timedelta(days=30)
    
    endpoint = f"/{start_date.isoformat()}..{end_date.isoformat()}"
    data = await fetch_frankfurter(endpoint, {"from": source_curr, "to": target_curr})
    
    rates = data.get("rates", {})
    
    # Format for Recharts: [{"date": "2023-09-01", "rate": 1.08}, ...]
    trend_data = []
    for date_str, rate_dict in rates.items():
        if target_curr in rate_dict:
            trend_data.append({
                "date": date_str,
                "rate": rate_dict[target_curr]
            })
            
    return {"trends": trend_data}

@app.post("/api/travel-budget")
async def calculate_travel_budget(req: TravelBudgetRequest):
    """Vibe Check: Compare a base budget against 5 major currencies simultaneously."""
    base = req.base_currency.upper()
    
    # Determine targets (exclude base if it's in the travel currencies)
    targets = [curr for curr in TRAVEL_CURRENCIES if curr != base]
    
    results = []
    # If base is in TRAVEL_CURRENCIES, it naturally evaluates to 1.0 against itself
    if base in TRAVEL_CURRENCIES:
        results.append({
            "currency": base,
            "rate": 1.0,
            "equivalent": req.amount
        })
        
    if targets:
        data = await fetch_frankfurter("/latest", {"from": base, "to": ",".join(targets)})
        rates = data.get("rates", {})
        
        for curr, rate in rates.items():
            results.append({
                "currency": curr,
                "rate": rate,
                "equivalent": round(req.amount * rate, 2)
            })
            
    # Sort for consistent UI rendering
    results.sort(key=lambda x: x["currency"])
    
    return {
        "base_currency": base,
        "base_amount": req.amount,
        "comparisons": results
    }

# --- Database State Endpoints ---

@app.get("/api/history")
def get_history():
    """Retrieve recent conversions from SQLite."""
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, source_currency, target_currency, amount, converted_amount, rate, created_at FROM conversion_history ORDER BY created_at DESC LIMIT 15"
        )
        rows = cursor.fetchall()
        return {"history": [dict(row) for row in rows]}
    finally:
        conn.close()

@app.get("/api/favorites")
def get_favorites():
    """Retrieve user-saved currency pairs."""
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, source_currency, target_currency, created_at FROM favorites ORDER BY id ASC")
        rows = cursor.fetchall()
        return {"favorites": [dict(row) for row in rows]}
    finally:
        conn.close()

@app.post("/api/favorites")
def add_favorite(req: FavoriteRequest):
    """Save a new favorite currency pair."""
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO favorites (source_currency, target_currency) VALUES (?, ?)",
            (req.source.upper(), req.target.upper())
        )
        conn.commit()
        return {"success": True, "id": cursor.lastrowid}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Favorite pair already exists")
    finally:
        conn.close()

@app.delete("/api/favorites/{favorite_id}")
def delete_favorite(favorite_id: int):
    """Remove a favorite currency pair."""
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM favorites WHERE id = ?", (favorite_id,))
        conn.commit()
        return {"success": True}
    finally:
        conn.close()
