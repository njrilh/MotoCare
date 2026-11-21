
from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    Date,
    DateTime,
    Text,
    DECIMAL,
    ForeignKey,
    ForeignKeyConstraint,
    UniqueConstraint,
    Index,
    func
)

from app.database import Base


# ==================================
# 1. MODEL USERS
# ==================================

class User(Base):
    __tablename__ = "users"

    id_user = Column(Integer, primary_key=True, index=True)
    nama = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    no_hp = Column(String(20))

    role = Column(String(20), default="customer")
    is_active = Column(Boolean, default=True)

    created_at = Column(
        DateTime,
        server_default=func.now()
    )


# ==================================
# 2. MODEL VEHICLES
# ==================================

class Vehicle(Base):
    __tablename__ = "vehicles"

    id_vehicle = Column(Integer, primary_key=True, index=True)
    id_user = Column(
        Integer,
        ForeignKey("users.id_user"),
        nullable=False
    )

    merk = Column(String(50), nullable=False)
    model = Column(String(100), nullable=False)
    nomor_polisi = Column(String(15), unique=True, nullable=False)

    tahun = Column(Integer)
    total_km = Column(Integer, default=0)
    last_service_km = Column(Integer, default=0)

    created_at = Column(
        DateTime,
        server_default=func.now()
    )

    __table_args__ = (
        UniqueConstraint(
            "id_vehicle",
            "id_user",
            name="uq_vehicle_owner"
        ),
    )


# ==================================
# 3. MODEL SUBSCRIPTIONS
# ==================================

class Subscription(Base):
    __tablename__ = "subscriptions"

    id_subscription = Column(
        Integer,
        primary_key=True,
        index=True
    )

    id_user = Column(
        Integer,
        ForeignKey("users.id_user"),
        nullable=False
    )

    nama_paket = Column(String(50), nullable=False)
    harga = Column(DECIMAL(12, 2), nullable=False)

    tanggal_mulai = Column(Date)
    tanggal_akhir = Column(Date)

    status = Column(String(20), default="pending")
    payment_status = Column(String(20), default="unpaid")

    created_at = Column(
        DateTime,
        server_default=func.now()
    )


# ==================================
# 4. MODEL SERVICE BOOKINGS
# ==================================

class ServiceBooking(Base):
    __tablename__ = "service_bookings"

    id_booking = Column(Integer, primary_key=True, index=True)

    id_user = Column(
        Integer,
        ForeignKey("users.id_user"),
        nullable=False
    )

    id_vehicle = Column(Integer, nullable=False)

    jenis_servis = Column(String(100), nullable=False)
    keluhan = Column(Text)

    tanggal_booking = Column(DateTime, nullable=False)
    odometer_km = Column(Integer, nullable=False)

    nama_bengkel = Column(String(100))
    alamat_bengkel = Column(Text)

    biaya_estimasi = Column(DECIMAL(12, 2), default=0)
    biaya_final = Column(DECIMAL(12, 2), default=0)

    status = Column(String(20), default="pending")

    created_at = Column(
        DateTime,
        server_default=func.now()
    )

    completed_at = Column(DateTime, nullable=True)

    __table_args__ = (
        ForeignKeyConstraint(
            ["id_vehicle", "id_user"],
            ["vehicles.id_vehicle", "vehicles.id_user"],
            name="fk_booking_vehicle_owner",
            onupdate="CASCADE",
            ondelete="RESTRICT"
        ),

        Index("idx_booking_user", "id_user"),
        Index("idx_booking_vehicle", "id_vehicle"),
        Index("idx_booking_status", "status"),
    )
