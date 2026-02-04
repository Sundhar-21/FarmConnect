from fastapi import APIRouter, Depends, HTTPException
from backend.core.security import RoleChecker, supabase
from typing import List

router = APIRouter(prefix="/admin", tags=["Admin"])
is_admin = RoleChecker(["admin"])

@router.get("/stats")
async def get_stats(user: dict = Depends(is_admin)):
    # Total users
    users_count = supabase.table("profiles").select("count").execute()
    # Total sales
    sales_sum = supabase.table("orders").select("total_amount").execute()
    total_sales = sum(float(o["total_amount"]) for o in sales_sum.data)
    
    return {
        "total_users": users_count.data[0]["count"] if users_count.data else 0,
        "total_sales": total_sales,
        "total_orders": len(sales_sum.data)
    }

@router.get("/users")
async def list_users(user: dict = Depends(is_admin)):
    result = supabase.table("profiles").select("*").execute()
    return result.data

@router.post("/users/{user_id}/block")
async def block_user(user_id: str, block: bool, user: dict = Depends(is_admin)):
    result = supabase.table("profiles").update({"is_blocked": block}).eq("id", user_id).execute()
    return result.data

@router.get("/products")
async def list_all_products(user: dict = Depends(is_admin)):
    result = supabase.table("products").select("*, profiles!farmer_id(full_name)").execute()
    return result.data
