from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.database import get_db
from app.models import Vehicle
from app.schemas import (
    VehicleCreate,
    VehicleUpdate,
    VehicleResponse
)
from app.routers.auth import get_current_user


router = APIRouter(
    prefix="/api/vehicles",
    tags=["Vehicles"]
)


# CREATE: Menambahkan kendaraan
@router.post("/", response_model=VehicleResponse, status_code=201)
def create_vehicle(
    data: VehicleCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    vehicle = Vehicle(
        id_user=current_user.id_user,
        merk=data.merk,
        model=data.model,
        nomor_polisi=data.nomor_polisi,
        tahun=data.tahun,
        total_km=0,
        last_service_km=0
    )

    try:
        db.add(vehicle)
        db.commit()
        db.refresh(vehicle)

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="Nomor polisi sudah terdaftar"
        )

    return vehicle


# READ: Melihat semua kendaraan milik pengguna
@router.get("/", response_model=list[VehicleResponse])
def get_vehicles(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    vehicles = db.query(Vehicle).filter(
        Vehicle.id_user == current_user.id_user
    ).all()

    return vehicles


# READ: Melihat detail kendaraan
@router.get("/{vehicle_id}", response_model=VehicleResponse)
def get_vehicle(
    vehicle_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    vehicle = db.query(Vehicle).filter(
        Vehicle.id_vehicle == vehicle_id,
        Vehicle.id_user == current_user.id_user
    ).first()

    if vehicle is None:
        raise HTTPException(
            status_code=404,
            detail="Kendaraan tidak ditemukan"
        )

    return vehicle


# UPDATE: Mengubah data kendaraan
@router.put("/{vehicle_id}", response_model=VehicleResponse)
def update_vehicle(
    vehicle_id: int,
    data: VehicleUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    vehicle = db.query(Vehicle).filter(
        Vehicle.id_vehicle == vehicle_id,
        Vehicle.id_user == current_user.id_user
    ).first()

    if vehicle is None:
        raise HTTPException(
            status_code=404,
            detail="Kendaraan tidak ditemukan"
        )

    update_data = data.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(vehicle, key, value)

    try:
        db.commit()
        db.refresh(vehicle)

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="Nomor polisi sudah digunakan kendaraan lain"
        )

    return vehicle


# DELETE: Menghapus kendaraan
@router.delete("/{vehicle_id}")
def delete_vehicle(
    vehicle_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    vehicle = db.query(Vehicle).filter(
        Vehicle.id_vehicle == vehicle_id,
        Vehicle.id_user == current_user.id_user
    ).first()

    if vehicle is None:
        raise HTTPException(
            status_code=404,
            detail="Kendaraan tidak ditemukan"
        )

    try:
        db.delete(vehicle)
        db.commit()

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="Kendaraan tidak dapat dihapus karena memiliki riwayat booking"
        )

    return {
        "message": "Kendaraan berhasil dihapus"
    }