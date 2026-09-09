from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import currency, favorites

app = FastAPI(title="Currency Converter API")

# Configure CORS for Vite frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routers
app.include_router(currency.router, prefix="/api")
app.include_router(favorites.router, prefix="/api")

@app.get("/health")
def health_check():
    return {"status": "ok"}
