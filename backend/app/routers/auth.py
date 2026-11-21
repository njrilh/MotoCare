
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

bearer_scheme = HTTPBearer()

from app.database import get_db
from app.models import User
from app.schemas import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    UserResponse
)

from app.security import (
    hash_password,
    verify_password,
    create_access_token,
    decode_access_token
)


router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)


oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/auth/login"
)


# ==================================
# MENDAPATKAN USER DARI TOKEN
# ==================================

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    user_id = decode_access_token(token)

    if user_id is None:
        raise HTTPException(
            status_code=401,
            detail="Token tidak valid atau sudah kedaluwarsa"
        )

    user = db.query(User).filter(
        User.id_user == user_id
    ).first()

    if user is None or not user.is_active:
        raise HTTPException(
            status_code=401,
            detail="Pengguna tidak ditemukan atau tidak aktif"
        )

    return user

# ==================================
# REGISTER
# ==================================

@router.post("/register", response_model=UserResponse)
def register(
    data: RegisterRequest,
    db: Session = Depends(get_db)
):
    existing_user = db.query(User).filter(
        User.email == data.email
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Email sudah terdaftar"
        )

    if len(data.password) < 8:
        raise HTTPException(
            status_code=400,
            detail="Password minimal 8 karakter"
        )

    new_user = User(
        nama=data.nama,
        email=data.email,
        password_hash=hash_password(data.password),
        no_hp=data.no_hp,
        role="customer",
        is_active=True
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


# ==================================
# LOGIN
# ==================================

@router.post("/login", response_model=TokenResponse)
def login(
    data: LoginRequest,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(
        User.email == data.email
    ).first()

    if not user or not verify_password(
        data.password,
        user.password_hash
    ):
        raise HTTPException(
            status_code=401,
            detail="Email atau password salah"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=403,
            detail="Akun tidak aktif"
        )

    token = create_access_token(user.id_user)

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": user
    }


# ==================================
# CEK IDENTITAS PENGGUNA
# ==================================

@router.get("/me", response_model=UserResponse)
def get_profile(
    current_user: User = Depends(get_current_user)
):
    return current_user
