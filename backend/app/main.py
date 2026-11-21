
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.routers import auth, vehicles
from app.routers import auth, vehicles, bookings
from app.routers import auth, vehicles, bookings, subscriptions

from app.database import engine
from app.routers import auth


app = FastAPI(
    title="MotorCare API",
    description="REST API Aplikasi MotorCare",
    version="1.0.0"
)

app.include_router(auth.router)
app.include_router(vehicles.router)
app.include_router(bookings.router)
app.include_router(subscriptions.router)

# Konfigurasi CORS untuk pengembangan lokal
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Memasukkan router
app.include_router(auth.router)


@app.get("/")
def home():
    return {
        "message": "MotorCare API is running",
        "status": "success"
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "message": "Backend MotorCare aktif"
    }


@app.get("/health/db")
def database_check():
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        return {
            "status": "connected",
            "database": "motorcare"
        }

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=str(error)
        )
