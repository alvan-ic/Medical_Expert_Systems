from pydantic import BaseModel, EmailStr
from typing import List, Optional
import re

SAFE_ATOM = re.compile(r'^[a-z][a-z0-9_]*$')


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


class QuestionFactor(BaseModel):
    factor: str
    label: str

class QuestionsResponse(BaseModel):
    symptoms: List[QuestionFactor]
    risk_factors: List[QuestionFactor]

class AnswerItem(BaseModel):
    factor: str
    response: str  # "yes", "no", "sometimes"
    severity: Optional[int] = 0

    def validate_prolog_safe(self):
        if not SAFE_ATOM.match(self.factor):
            raise ValueError(f"Invalid factor: {self.factor}")
        if self.response not in ("yes", "no", "sometimes"):
            raise ValueError(f"Invalid response: {self.response}")
        if self.severity is not None and not (0 <= self.severity <= 10):
            raise ValueError(f"Severity must be 0–10")

class DiagnoseRequest(BaseModel):
    answers: List[AnswerItem]

class DiagnoseResponse(BaseModel):
    probability: float
    advice: str
    risk_level: str  # "HIGH", "MODERATE", "LOW"


# Chat models
class ChatMessage(BaseModel):
    role: str  # "user" or "assistant"
    content: str

class ChatRequest(BaseModel):
    disease: str
    message: str
    history: List[ChatMessage] = []

class ChatResponse(BaseModel):
    reply: str


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
