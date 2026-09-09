import sqlite3
from fastapi import APIRouter, Query, Depends
from ..schemas import ConvertRequest, ConvertResponse, TravelBudgetRequest
from ..services import fetch_frankfurter, get_live_rate, get_historical_trends, get_vibe_check_comparisons
from ..crud import log_conversion, get_recent_history
from ..database import get_db

router = APIRouter()

@router.get("/currencies")
async def get_currencies():
    """Fetch available currencies."""
    data = await fetch_frankfurter("/currencies")
    return {"currencies": data}

@router.post("/convert", response_model=ConvertResponse)
async def convert_currency(req: ConvertRequest, db: sqlite3.Connection = Depends(get_db)):
    """Convert amount and log to database."""
    source_curr = req.source.upper()
    target_curr = req.target.upper()
    
    rate = await get_live_rate(source_curr, target_curr)
    converted_amount = round(req.amount * rate, 4)

    # Persist log via CRUD (Dependency Injected)
    log_conversion(db, source_curr, target_curr, req.amount, converted_amount, rate)

    return {
        "source": source_curr,
        "target": target_curr,
        "amount": req.amount,
        "converted_amount": converted_amount,
        "rate": rate
    }

@router.get("/trends")
async def get_trends(
    source: str = Query(..., min_length=3, max_length=3),
    target: str = Query(..., min_length=3, max_length=3)
):
    """Fetch 30-day historical time-series data."""
    trend_data = await get_historical_trends(source.upper(), target.upper())
    return {"trends": trend_data}

@router.post("/travel-budget")
async def calculate_travel_budget(req: TravelBudgetRequest):
    """Vibe Check: Compare a base budget against 5 major currencies."""
    base = req.base_currency.upper()
    results = await get_vibe_check_comparisons(base, req.amount)
    
    return {
        "base_currency": base,
        "base_amount": req.amount,
        "comparisons": results
    }

@router.get("/history")
def get_history(db: sqlite3.Connection = Depends(get_db)):
    """Retrieve recent conversions from SQLite."""
    history = get_recent_history(db, limit=15)
    return {"history": history}
