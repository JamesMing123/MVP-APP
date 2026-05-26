from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.response import ok
from app.core.security import create_access_token, hash_password, verify_password
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse

router = APIRouter()


@router.post("/register")
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    
    exists = db.query(User).filter(or_(User.email == payload.email, User.username == payload.username)).first()
    if exists:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email or username already exists")

    user = User(
        email=payload.email,
        username=payload.username,
        nickname=payload.nickname,
        password_hash=hash_password(payload.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(str(user.id))
    return ok(TokenResponse(access_token=token).model_dump())


@router.post("/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_access_token(str(user.id))
    return ok(TokenResponse(access_token=token).model_dump())


@router.get("/me")
def me(user: User = Depends(get_current_user)):
    return ok({"id": user.id, "email": user.email, "username": user.username, "nickname": user.nickname, "role": user.role})
