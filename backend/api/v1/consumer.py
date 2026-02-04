from fastapi import APIRouter, Depends, HTTPException
from backend.core.security import RoleChecker, supabase
from backend.models.schemas import ProductResponse, OrderCreate
from typing import List, Optional

router = APIRouter(prefix="/consumer", tags=["Consumer"])
is_consumer = RoleChecker(["consumer"])

@router.get("/products", response_model=List[ProductResponse])
async def list_products(
    category_id: Optional[int] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    search: Optional[str] = None
):
    query = supabase.table("products").select("*").eq("is_available", True)
    if category_id:
        query = query.eq("category_id", category_id)
    if min_price:
        query = query.gte("price", min_price)
    if max_price:
        query = query.lte("price", max_price)
    if search:
        query = query.ilike("name", f"%{search}%")
    
    result = query.execute()
    return result.data

@router.post("/orders")
async def create_order(order: OrderCreate, user: dict = Depends(is_consumer)):
    # 1. Start a transaction (handled implicitly by Supabase RPC or multiple calls)
    # This is a simplified version; real-world apps need atomic transactions for stock updates.
    
    total_amount = sum(item.price * item.quantity for item in order.items)
    
    order_data = {
        "user_id": user["id"],
        "total_amount": float(total_amount),
        "shipping_address": order.shipping_address,
        "status": "pending"
    }
    
    order_result = supabase.table("orders").insert(order_data).execute()
    new_order = order_result.data[0]
    
    # 2. Add items
    items_to_insert = []
    for item in order.items:
        # Fetch actual farmer_id for each product (omitted for brevity)
        product = supabase.table("products").select("farmer_id").eq("id", item.product_id).single().execute()
        
        items_to_insert.append({
            "order_id": new_order["id"],
            "product_id": item.product_id,
            "farmer_id": product.data["farmer_id"],
            "quantity": item.quantity,
            "price_at_time_of_order": float(item.price)
        })
    
    supabase.table("order_items").insert(items_to_insert).execute()
    return new_order
