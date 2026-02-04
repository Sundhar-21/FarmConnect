from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from backend.core.security import RoleChecker, supabase
from backend.models.schemas import ProductCreate, ProductResponse
from typing import List

router = APIRouter(prefix="/farmer", tags=["Farmer"])
is_farmer = RoleChecker(["farmer"])

@router.post("/products", response_model=ProductResponse)
async def create_product(product: ProductCreate, user: dict = Depends(is_farmer)):
    data = product.dict()
    data["farmer_id"] = user["id"]
    
    result = supabase.table("products").insert(data).execute()
    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create product")
    return result.data[0]

@router.get("/products", response_model=List[ProductResponse])
async def get_my_products(user: dict = Depends(is_farmer)):
    result = supabase.table("products").select("*").eq("farmer_id", user["id"]).execute()
    return result.data

@router.get("/orders")
async def get_farmer_orders(user: dict = Depends(is_farmer)):
    # This would involve joining order_items and products
    result = supabase.table("order_items").select("*, products(*)").eq("farmer_id", user["id"]).execute()
    return result.data
