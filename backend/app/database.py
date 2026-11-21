
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Membaca konfigurasi dari file .env
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Koneksi MySQL
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    echo=True
)

# Session database
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base untuk model SQLAlchemy
Base = declarative_base()


# Dependency untuk mendapatkan koneksi database
def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()
