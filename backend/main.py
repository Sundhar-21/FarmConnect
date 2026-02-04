from backend.api.v1 import farmer, consumer, admin

app = FastAPI(title="FarmConnect API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(farmer.router)
app.include_router(consumer.router)
app.include_router(admin.router)

@app.get("/")
async def root():
    return {"message": "Welcome to FarmConnect API"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
