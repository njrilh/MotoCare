
from pydantic import BaseModel, EmailStr, ConfigDict, Field
from datetime import datetime, date
from typing import Optional, Literal
from decimal import Decimal


class AdminBookingStatusUpdate(BaseModel):
    status: Literal[
        "confirmed",
        "in_progress",
        "completed",
        "cancelled"
    ]

# Data untuk registrasi
class RegisterRequest(BaseModel):
    nama: str
    email: EmailStr
    password: str
    no_hp: str | None = None


# Data untuk login
class LoginRequest(BaseModel):
    email: EmailStr
    password: str


# Respons data pengguna
class UserResponse(BaseModel):
    id_user: int
    nama: str
    email: str
    no_hp: str | None
    role: str
    is_active: bool
    created_at: datetime | None

    model_config = ConfigDict(from_attributes=True)


# Respons token JWT
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

class VehicleCreate(BaseModel):
    merk: str = Field(min_length=1, max_length=50)
    model: str = Field(min_length=1, max_length=100)
    nomor_polisi: str = Field(min_length=1, max_length=15)
    tahun: Optional[int] = None

class VehicleUpdate(BaseModel):
    merk: Optional[str] = Field(default=None, max_length=50)
    model: Optional[str] = Field(default=None, max_length=100)
    nomor_polisi: Optional[str] = Field(default=None, max_length=15)
    tahun: Optional[int] = None
    total_km: Optional[int] = Field(default=None, ge=0)

class VehicleResponse(BaseModel):
    id_vehicle: int
    id_user: int
    merk: str
    model: str
    nomor_polisi: str
    tahun: Optional[int]
    total_km: int
    last_service_km: int

    model_config = ConfigDict(from_attributes=True)

class BookingCreate(BaseModel):
    id_vehicle: int
    jenis_servis: str = Field(min_length=1, max_length=100)
    keluhan: Optional[str] = None
    tanggal_booking: datetime
    odometer_km: int = Field(ge=0)
    nama_bengkel: Optional[str] = Field(default=None, max_length=100)
    alamat_bengkel: Optional[str] = None
    biaya_estimasi: Decimal = Field(default=Decimal("0"), ge=0)


class BookingUpdate(BaseModel):
    jenis_servis: Optional[str] = Field(default=None, max_length=100)
    keluhan: Optional[str] = None
    tanggal_booking: Optional[datetime] = None
    odometer_km: Optional[int] = Field(default=None, ge=0)
    nama_bengkel: Optional[str] = Field(default=None, max_length=100)
    alamat_bengkel: Optional[str] = None
    biaya_estimasi: Optional[Decimal] = Field(default=None, ge=0)


class BookingResponse(BaseModel):
    id_booking: int
    id_user: int
    id_vehicle: int
    jenis_servis: str
    keluhan: Optional[str]
    tanggal_booking: datetime
    odometer_km: int
    nama_bengkel: Optional[str]
    alamat_bengkel: Optional[str]
    biaya_estimasi: Decimal
    biaya_final: Decimal
    status: str
    created_at: datetime
    completed_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)

class SubscriptionCreate(BaseModel):
    nama_paket: Literal[
        "Bengkel Care Bulanan",
        "Bengkel Care Tahunan"
    ]


class SubscriptionResponse(BaseModel):
    id_subscription: int
    id_user: int
    nama_paket: str
    harga: Decimal
    tanggal_mulai: Optional[date]
    tanggal_akhir: Optional[date]
    status: str
    payment_status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class SubscriptionPaymentUpdate(BaseModel):
    payment_status: Literal["paid", "failed"]