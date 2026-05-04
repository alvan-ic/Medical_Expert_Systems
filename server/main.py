from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from models import Symptom, Disease, DiagnosisRequest, DiagnosisResponse, DiseaseResult, SAFE_ATOM
from database import init_db
from prolog_engine import prolog, prolog_lock, load_knowledge_base
from routes.auth import router as auth_router
from routes.chat import router as chat_router
from routes.chat_freetext import router as chat_freetext_router


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(chat_router)
app.include_router(chat_freetext_router)

init_db()
load_knowledge_base()


@app.get("/symptoms", response_model=List[Symptom])
def get_all_symptoms():
    try:
        results = prolog.query("symptom(X)")
        symptoms = []
        for result in results:
            item = result.get("X", "")
            symptoms.append(Symptom(symptom=item.replace("_", " ").title(), slug=item))
        symptoms.sort(key=lambda x: x.symptom)
        return symptoms
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching symptoms: {str(e)}")


@app.get("/diseases", response_model=List[Disease])
def get_all_diseases():
    try:
        results = prolog.query("disease(X)")
        diseases = []
        seen = set()
        for result in results:
            item = result.get("X", "")
            name = item.replace("_", " ").title()
            if name not in seen:
                seen.add(name)
                diseases.append(Disease(disease=name, slug=item))
        diseases.sort(key=lambda x: x.disease)
        return diseases
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching diseases: {str(e)}")


@app.post("/diagnose", response_model=DiagnosisResponse)
def diagnose(request: DiagnosisRequest):
    for s in request.symptoms:
        if not SAFE_ATOM.match(s):
            raise HTTPException(status_code=422, detail=f"Invalid symptom atom: {s}")

    prolog_list = "[" + ",".join(request.symptoms) + "]"

    try:
        with prolog_lock:
            raw = list(prolog.query(
                f"diagnose_result({prolog_list}, Disease, Percentage, Common, Missing)"
            ))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prolog error: {str(e)}")

    diseases = [
        DiseaseResult(
            name=str(r["Disease"]).replace("_", " ").title(),
            slug=str(r["Disease"]).lower().replace(" ", "_"),
            match_percentage=float(r["Percentage"]),
            matching_symptoms=[str(s) for s in r["Common"]],
            missing_symptoms=[str(s) for s in r["Missing"]],
        )
        for r in raw
    ]
    diseases.sort(key=lambda x: x.match_percentage, reverse=True)

    return DiagnosisResponse(
        possible_diseases=diseases,
        total_diseases_checked=len(diseases),
    )
