import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import User
from app.schemas.schemas import UserSignup, UserLogin, GuestLogin, UserResponse, Token, UserProfileUpdate
from app.services.auth import verify_password, get_password_hash, create_access_token, get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
def signup(data: UserSignup, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == data.email.lower()).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already registered"
        )
    
    new_user = User(
        name=data.name.strip(),
        email=data.email.lower().strip(),
        hashed_password=get_password_hash(data.password),
        role="user",
        is_guest=False
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    access_token = create_access_token(data={"sub": str(new_user.id), "email": new_user.email})
    return Token(access_token=access_token, token_type="bearer", user=UserResponse.from_orm(new_user))

@router.post("/login", response_model=Token)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email.lower().strip()).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    access_token = create_access_token(data={"sub": str(user.id), "email": user.email})
    return Token(access_token=access_token, token_type="bearer", user=UserResponse.from_orm(user))

@router.post("/guest", response_model=Token)
def guest_login(data: GuestLogin, db: Session = Depends(get_db)):
    # Create an anonymous guest user
    unique_id = uuid.uuid4().hex[:8]
    guest_email = f"guest_{unique_id}@placeprep.local"
    guest_name = data.name or f"Guest_{unique_id}"
    
    guest_user = User(
        name=guest_name,
        email=guest_email,
        hashed_password=None,
        role="guest",
        is_guest=True
    )
    db.add(guest_user)
    db.commit()
    db.refresh(guest_user)
    
    access_token = create_access_token(data={"sub": str(guest_user.id), "email": guest_user.email})
    return Token(access_token=access_token, token_type="bearer", user=UserResponse.from_orm(guest_user))

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return UserResponse.from_orm(current_user)

@router.put("/profile", response_model=UserResponse)
def update_profile(
    data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if data.name is not None:
        current_user.name = data.name.strip()
    if data.college is not None:
        current_user.college = data.college.strip()
    if data.degree is not None:
        current_user.degree = data.degree.strip()
    if data.graduation_year is not None:
        current_user.graduation_year = data.graduation_year.strip()
    if data.avatar is not None:
        current_user.avatar = data.avatar.strip()
        
    db.commit()
    db.refresh(current_user)
    return UserResponse.from_orm(current_user)
