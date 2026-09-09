# VibeConvert: Real-Time Currency Converter & Trend Visualizer

A responsive, high-performance web application built for real-time currency conversion, 30-day historical trend analysis, and a specialized "Travel Budget" comparison mode.

## Features

- **Live Conversions:** Fetch real-time exchange rates securely on the server-side without requiring paid API keys.
- **Interactive 30-Day Trends:** Dynamic, responsive line charts powered by Recharts that update instantly when swapping currencies.
- **Favorites & History:** Persistent local caching using SQLite. Save your most-used pairs and simply click them in the sidebar to load them instantly.
- **Travel Budget Mode ("Vibe Check"):** A sleek comparison dashboard that calculates a base budget equivalent across 5 major global currencies (USD, EUR, GBP, JPY, AUD) simultaneously.

## Tech Stack & Best Practices

**Backend:** FastAPI (Python 3), SQLite3, Uvicorn, HTTPX, Pydantic.
- *Architecture:* Clean Architecture with explicitly separated Routers, Services, CRUD layers, and Data Validation Schemas.
- *Best Practices:* Strict Dependency Injection (`Depends()`) for database connection lifecycles and robust `try/except` endpoint error handling.

**Frontend:** React (Vite), Tailwind CSS v4, Lucide React, Recharts.
- *Architecture:* Highly modular components utilizing lifted React state for instant UI reactivity.
- *Design System:* Clean, fintech-inspired aesthetic featuring `animate-in` transitions, active-state micro-interactions, and a fully responsive grid.

## Setup & Installation

### 1. Backend Setup
```bash
cd backend

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the FastAPI server
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```
*The API will be available at `http://127.0.0.1:8000` with interactive Swagger docs at `http://127.0.0.1:8000/docs`.*

### 2. Frontend Setup
Open a new terminal window:
```bash
cd frontend

# Install dependencies
npm install

# Run the Vite development server
npm run dev
```
*The application will be accessible at `http://localhost:5173`.*
