from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from decimal import Decimal

class UserProfile(BaseModel):
    id: str
    role: str
    full_name: Optional[str]
    phone: Optional[str]
    address: Optional[str]

class ProductBase(BaseModel):
    name: str
    description: Optional[str]
    price: Decimal
    stock_quantity: int
    unit: str
    category_id: int

class ProductCreate(ProductBase):
    pass

class ProductResponse(ProductBase):
    id: int
    farmer_id: str
    image_url: Optional[str]
    is_available: bool
    created_at: datetime

class OrderItem(BaseModel):
    product_id: int
    quantity: int
    price: Decimal

class OrderCreate(BaseModel):
    items: List[OrderItem]
    shipping_address: str

class OrderResponse(BaseModel):
    id: str
    total_amount: Decimal
    status: str
    created_at: datetime
