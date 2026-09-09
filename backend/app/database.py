import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "currency_converter.db")

def get_db_connection() -> sqlite3.Connection:
    """Creates and returns a new database connection."""
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

def get_db():
    """Dependency generator for FastAPI dependency injection."""
    conn = get_db_connection()
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    """Initialize the database schema."""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_currency TEXT NOT NULL,
            target_currency TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(source_currency, target_currency)
        )
    """)
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS conversion_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_currency TEXT NOT NULL,
            target_currency TEXT NOT NULL,
            amount REAL NOT NULL,
            converted_amount REAL NOT NULL,
            rate REAL NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    cursor.execute("SELECT COUNT(*) FROM favorites")
    if cursor.fetchone()[0] == 0:
        cursor.executemany(
            "INSERT INTO favorites (source_currency, target_currency) VALUES (?, ?)",
            [("USD", "INR"), ("EUR", "USD"), ("GBP", "USD"), ("USD", "JPY")]
        )
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
