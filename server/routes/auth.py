from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError
from database import get_db
from auth import hash_password, verify_password, create_access_token, decode_access_token
from models import SignupRequest, LoginRequest, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])
bearer = HTTPBearer()


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(bearer)) -> UserResponse:
    try:
        payload = decode_access_token(credentials.credentials)
        user_id = int(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    with get_db() as conn:
        row = conn.execute(
            "SELECT id, first_name, last_name, email FROM users WHERE id = ?", (user_id,)
        ).fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="User not found")

    return UserResponse(id=row["id"], first_name=row["first_name"], last_name=row["last_name"], email=row["email"])


@router.post("/signup", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def signup(body: SignupRequest):
    with get_db() as conn:
        existing = conn.execute(
            "SELECT id FROM users WHERE email = ?", (body.email,)
        ).fetchone()

        if existing:
            raise HTTPException(status_code=400, detail="Email already registered")

        cursor = conn.execute(
            "INSERT INTO users (first_name, last_name, email, hashed_password) VALUES (?, ?, ?, ?)",
            (body.first_name, body.last_name, body.email, hash_password(body.password)),
        )
        return UserResponse(id=cursor.lastrowid, first_name=body.first_name, last_name=body.last_name, email=body.email)


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest):
    with get_db() as conn:
        row = conn.execute(
            "SELECT id, email, hashed_password FROM users WHERE email = ?", (body.email,)
        ).fetchone()

    if not row or not verify_password(body.password, row["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(row["id"]), "email": row["email"]})
    return TokenResponse(access_token=token)


@router.get("/me", response_model=UserResponse)
def me(current_user: UserResponse = Depends(get_current_user)):
    return current_user
