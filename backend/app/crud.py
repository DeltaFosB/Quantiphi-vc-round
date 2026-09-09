import sqlite3
from typing import List, Dict, Any
from fastapi import HTTPException

def log_conversion(conn: sqlite3.Connection, source: str, target: str, amount: float, converted_amount: float, rate: float):
    """Log a currency conversion transaction to the database."""
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO conversion_history (source_currency, target_currency, amount, converted_amount, rate)
            VALUES (?, ?, ?, ?, ?)
            """,
            (source, target, amount, converted_amount, rate)
        )
        conn.commit()
    except Exception as e:
        print(f"DB Error while logging conversion: {e}")

def get_recent_history(conn: sqlite3.Connection, limit: int = 15) -> List[Dict[str, Any]]:
    """Retrieve the most recent conversion logs."""
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id, source_currency, target_currency, amount, converted_amount, rate, created_at "
        "FROM conversion_history ORDER BY created_at DESC LIMIT ?",
        (limit,)
    )
    return [dict(row) for row in cursor.fetchall()]

def get_all_favorites(conn: sqlite3.Connection) -> List[Dict[str, Any]]:
    """Retrieve all user-saved currency pairs."""
    cursor = conn.cursor()
    cursor.execute("SELECT id, source_currency, target_currency, created_at FROM favorites ORDER BY id ASC")
    return [dict(row) for row in cursor.fetchall()]

def add_favorite_pair(conn: sqlite3.Connection, source: str, target: str) -> int:
    """Save a new favorite currency pair, raising an error if it exists."""
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO favorites (source_currency, target_currency) VALUES (?, ?)",
            (source, target)
        )
        conn.commit()
        return cursor.lastrowid
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Favorite pair already exists")

def delete_favorite_pair(conn: sqlite3.Connection, favorite_id: int):
    """Remove a favorite currency pair by ID."""
    cursor = conn.cursor()
    cursor.execute("DELETE FROM favorites WHERE id = ?", (favorite_id,))
    conn.commit()
