import sqlite3
from fastapi import APIRouter, Depends
from ..schemas import FavoriteRequest
from ..crud import get_all_favorites, add_favorite_pair, delete_favorite_pair
from ..database import get_db

router = APIRouter(prefix="/favorites", tags=["favorites"])

@router.get("")
def get_favorites(db: sqlite3.Connection = Depends(get_db)):
    """Retrieve user-saved currency pairs."""
    favorites = get_all_favorites(db)
    return {"favorites": favorites}

@router.post("")
def add_favorite(req: FavoriteRequest, db: sqlite3.Connection = Depends(get_db)):
    """Save a new favorite currency pair."""
    new_id = add_favorite_pair(db, req.source.upper(), req.target.upper())
    return {"success": True, "id": new_id}

@router.delete("/{favorite_id}")
def delete_favorite(favorite_id: int, db: sqlite3.Connection = Depends(get_db)):
    """Remove a favorite currency pair."""
    delete_favorite_pair(db, favorite_id)
    return {"success": True}
