from fastapi import APIRouter
from ..schemas import FavoriteRequest
from ..crud import get_all_favorites, add_favorite_pair, delete_favorite_pair

router = APIRouter(prefix="/favorites", tags=["favorites"])

@router.get("")
def get_favorites():
    """Retrieve user-saved currency pairs."""
    favorites = get_all_favorites()
    return {"favorites": favorites}

@router.post("")
def add_favorite(req: FavoriteRequest):
    """Save a new favorite currency pair."""
    new_id = add_favorite_pair(req.source.upper(), req.target.upper())
    return {"success": True, "id": new_id}

@router.delete("/{favorite_id}")
def delete_favorite(favorite_id: int):
    """Remove a favorite currency pair."""
    delete_favorite_pair(favorite_id)
    return {"success": True}
