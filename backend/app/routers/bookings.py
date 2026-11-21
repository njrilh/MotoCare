
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Vehicle, ServiceBooking
from app.schemas import (
    BookingCreate,
    BookingUpdate,
    BookingResponse
)
from app.routers.auth import get_current_user


router = APIRouter(
    prefix="/api/bookings",
    tags=["Bookings"]
)


# CREATE: Membuat booking servis
@router.post("/", response_model=BookingResponse, status_code=201)
def create_booking(
    data: BookingCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    # Pastikan kendaraan milik pengguna yang sedang login
    vehicle = db.query(Vehicle).filter(
        Vehicle.id_vehicle == data.id_vehicle,
        Vehicle.id_user == current_user.id_user
    ).first()

    if vehicle is None:
        raise HTTPException(
            status_code=404,
            detail="Kendaraan tidak ditemukan"
        )

    # Pastikan odometer tidak lebih rendah dari data kendaraan
    if data.odometer_km < vehicle.total_km:
        raise HTTPException(
            status_code=400,
            detail="Odometer tidak boleh lebih rendah dari kilometer kendaraan"
        )

    booking = ServiceBooking(
        id_user=current_user.id_user,
        id_vehicle=data.id_vehicle,
        jenis_servis=data.jenis_servis,
        keluhan=data.keluhan,
        tanggal_booking=data.tanggal_booking,
        odometer_km=data.odometer_km,
        nama_bengkel=data.nama_bengkel,
        alamat_bengkel=data.alamat_bengkel,
        biaya_estimasi=data.biaya_estimasi,
        biaya_final=0,
        status="pending"
    )

    # Perbarui kilometer kendaraan jika angkanya lebih tinggi
    if data.odometer_km > vehicle.total_km:
        vehicle.total_km = data.odometer_km

    db.add(booking)
    db.commit()
    db.refresh(booking)

    return booking


# READ: Melihat semua booking milik pengguna
@router.get("/", response_model=list[BookingResponse])
def get_bookings(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    bookings = db.query(ServiceBooking).filter(
        ServiceBooking.id_user == current_user.id_user
    ).order_by(
        ServiceBooking.created_at.desc()
    ).all()

    return bookings


# READ: Melihat detail booking
@router.get("/{booking_id}", response_model=BookingResponse)
def get_booking(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    booking = db.query(ServiceBooking).filter(
        ServiceBooking.id_booking == booking_id,
        ServiceBooking.id_user == current_user.id_user
    ).first()

    if booking is None:
        raise HTTPException(
            status_code=404,
            detail="Booking tidak ditemukan"
        )

    return booking


# UPDATE: Mengubah booking yang masih pending
@router.put("/{booking_id}", response_model=BookingResponse)
def update_booking(
    booking_id: int,
    data: BookingUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    booking = db.query(ServiceBooking).filter(
        ServiceBooking.id_booking == booking_id,
        ServiceBooking.id_user == current_user.id_user
    ).first()

    if booking is None:
        raise HTTPException(
            status_code=404,
            detail="Booking tidak ditemukan"
        )

    if booking.status != "pending":
        raise HTTPException(
            status_code=400,
            detail="Booking hanya bisa diubah selama masih pending"
        )

    update_data = data.model_dump(
        exclude_unset=True,
        exclude_none=True
    )

    # Validasi odometer jika diubah
    if "odometer_km" in update_data:
        vehicle = db.query(Vehicle).filter(
            Vehicle.id_vehicle == booking.id_vehicle,
            Vehicle.id_user == current_user.id_user
        ).first()

        if update_data["odometer_km"] < vehicle.total_km:
            raise HTTPException(
                status_code=400,
                detail="Odometer tidak boleh lebih rendah dari kilometer kendaraan"
            )

        if update_data["odometer_km"] > vehicle.total_km:
            vehicle.total_km = update_data["odometer_km"]

    for key, value in update_data.items():
        setattr(booking, key, value)

    db.commit()
    db.refresh(booking)

    return booking


# CANCEL: Membatalkan booking
@router.patch("/{booking_id}/cancel")
def cancel_booking(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    booking = db.query(ServiceBooking).filter(
        ServiceBooking.id_booking == booking_id,
        ServiceBooking.id_user == current_user.id_user
    ).first()

    if booking is None:
        raise HTTPException(
            status_code=404,
            detail="Booking tidak ditemukan"
        )

    if booking.status != "pending":
        raise HTTPException(
            status_code=400,
            detail="Booking tidak dapat dibatalkan karena sudah diproses"
        )

    booking.status = "cancelled"

    db.commit()

    return {
        "message": "Booking berhasil dibatalkan"
    }
