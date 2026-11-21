
from datetime import date, timedelta
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Subscription
from app.schemas import (
    SubscriptionCreate,
    SubscriptionResponse,
    SubscriptionPaymentUpdate
)
from app.routers.auth import get_current_user


router = APIRouter(
    prefix="/api/subscriptions",
    tags=["Subscriptions"]
)


# Konfigurasi paket (belum menggunakan tabel paket)
PAKET = {
    "Bengkel Care Bulanan": {
        "harga": Decimal("50000"),
        "durasi": 30
    },
    "Bengkel Care Tahunan": {
        "harga": Decimal("500000"),
        "durasi": 365
    }
}


# CREATE: Mengajukan subscription
@router.post("/", response_model=SubscriptionResponse, status_code=201)
def create_subscription(
    data: SubscriptionCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    # Cek apakah masih memiliki subscription aktif atau pending
    existing = db.query(Subscription).filter(
        Subscription.id_user == current_user.id_user,
        Subscription.status.in_(["active", "pending"])
    ).first()

    if existing:
        raise HTTPException(
            status_code=409,
            detail="Masih ada subscription aktif atau menunggu pembayaran"
        )

    paket = PAKET[data.nama_paket]

    subscription = Subscription(
        id_user=current_user.id_user,
        nama_paket=data.nama_paket,
        harga=paket["harga"],
        tanggal_mulai=None,
        tanggal_akhir=None,
        status="pending",
        payment_status="unpaid"
    )

    db.add(subscription)
    db.commit()
    db.refresh(subscription)

    return subscription


# READ: Melihat subscription terbaru
@router.get("/me", response_model=SubscriptionResponse)
def get_my_subscription(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    subscription = db.query(Subscription).filter(
        Subscription.id_user == current_user.id_user
    ).order_by(
        Subscription.created_at.desc()
    ).first()

    if subscription is None:
        raise HTTPException(
            status_code=404,
            detail="Kamu belum memiliki subscription"
        )

    return subscription


# READ: Melihat seluruh riwayat subscription
@router.get("/history", response_model=list[SubscriptionResponse])
def get_subscription_history(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    return db.query(Subscription).filter(
        Subscription.id_user == current_user.id_user
    ).order_by(
        Subscription.created_at.desc()
    ).all()


# ADMIN: Melihat seluruh pengajuan subscription
@router.get("/admin/all", response_model=list[SubscriptionResponse])
def get_all_subscriptions(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    if current_user.role != "admin":
        raise HTTPException(
            status_code=403,
            detail="Akses khusus admin"
        )

    return db.query(Subscription).order_by(
        Subscription.created_at.desc()
    ).all()


# ADMIN: Memverifikasi pembayaran
@router.patch("/{subscription_id}/payment",
              response_model=SubscriptionResponse)
def update_payment(
    subscription_id: int,
    data: SubscriptionPaymentUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    if current_user.role != "admin":
        raise HTTPException(
            status_code=403,
            detail="Akses khusus admin"
        )

    subscription = db.query(Subscription).filter(
        Subscription.id_subscription == subscription_id
    ).first()

    if subscription is None:
        raise HTTPException(
            status_code=404,
            detail="Subscription tidak ditemukan"
        )

    if subscription.status != "pending":
        raise HTTPException(
            status_code=400,
            detail="Subscription ini sudah diproses"
        )

    subscription.payment_status = data.payment_status

    if data.payment_status == "paid":
        paket = PAKET.get(subscription.nama_paket)

        if paket is None:
            raise HTTPException(
                status_code=400,
                detail="Konfigurasi paket tidak ditemukan"
            )

        tanggal_mulai = date.today()

        subscription.status = "active"
        subscription.tanggal_mulai = tanggal_mulai
        subscription.tanggal_akhir = (
            tanggal_mulai + timedelta(days=paket["durasi"])
        )

    else:
        subscription.status = "cancelled"

    db.commit()
    db.refresh(subscription)

    return subscription
