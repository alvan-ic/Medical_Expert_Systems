from pydantic import BaseModel, EmailStr
from typing import List, Optional


class Symptom(BaseModel):
    symptom: str
    slug: str

class Disease(BaseModel):
    disease: str
    slug: str


class DiagnosisRequest(BaseModel):
    symptoms: List[str]


class DiseaseResult(BaseModel):
    name: str
    slug: str
    match_percentage: float
    matching_symptoms: List[str]
    missing_symptoms: List[str]

class DiagnosisResponse(BaseModel):
    possible_diseases: List[DiseaseResult]
    total_diseases_checked: int


# Auth models
class SignupRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
