from pydantic import BaseModel, Field
from typing import List, Optional

class ConvertRequest(BaseModel):
    source: str = Field(..., min_length=3, max_length=3, description="Source currency code (e.g., USD)")
    target: str = Field(..., min_length=3, max_length=3, description="Target currency code (e.g., EUR)")
    amount: float = Field(..., gt=0, description="Amount must be greater than zero")

class ConvertResponse(BaseModel):
    source: str
    target: str
    amount: float
    converted_amount: float
    rate: float

class TravelBudgetRequest(BaseModel):
    base_currency: str = Field(..., min_length=3, max_length=3)
    amount: float = Field(..., gt=0)

class FavoriteRequest(BaseModel):
    source: str = Field(..., min_length=3, max_length=3)
    target: str = Field(..., min_length=3, max_length=3)
