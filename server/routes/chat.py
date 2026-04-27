from fastapi import APIRouter, HTTPException
from models import (
    QuestionFactor, QuestionsResponse,
    DiagnoseRequest, DiagnoseResponse,
)
from prolog_engine import prolog, prolog_lock, DISEASE_MODULE

router = APIRouter(prefix="/api", tags=["chat"])


@router.get("/{disease}/questions", response_model=QuestionsResponse)
def get_disease_questions(disease: str):
    module = DISEASE_MODULE.get(disease)
    if not module:
        raise HTTPException(status_code=404, detail=f"Unknown disease: {disease}")

    with prolog_lock:
        symptom_results = list(prolog.query(f"{module}:symptom(X)"))
        risk_factor_results = list(prolog.query(f"{module}:risk_factor(X)"))

    symptoms = [
        QuestionFactor(factor=str(r["X"]), label=str(r["X"]).replace("_", " ").title())
        for r in symptom_results
    ]
    risk_factors = [
        QuestionFactor(factor=str(r["X"]), label=str(r["X"]).replace("_", " ").title())
        for r in risk_factor_results
    ]
    return QuestionsResponse(symptoms=symptoms, risk_factors=risk_factors)


@router.post("/{disease}/diagnose", response_model=DiagnoseResponse)
def diagnose_disease(disease: str, request: DiagnoseRequest):
    module = DISEASE_MODULE.get(disease)
    if not module:
        raise HTTPException(status_code=404, detail=f"Unknown disease: {disease}")

    for answer in request.answers:
        try:
            answer.validate_prolog_safe()
        except ValueError as e:
            raise HTTPException(status_code=422, detail=str(e))

    with prolog_lock:
        try:
            list(prolog.query(f"retractall({module}:user_data(_, _, _))"))

            for answer in request.answers:
                severity = answer.severity if answer.severity is not None else 0
                list(prolog.query(
                    f"assertz({module}:user_data({answer.factor}, {answer.response}, {severity}))"
                ))

            results = list(prolog.query(
                f"{module}:diagnostic_risk_evaluation_complete(P), {module}:advise(P, A)"
            ))
        finally:
            list(prolog.query(f"retractall({module}:user_data(_, _, _))"))

    if not results:
        raise HTTPException(status_code=500, detail="Diagnosis computation failed")

    probability = float(results[0]["P"])
    advice = str(results[0]["A"])

    if probability >= 70:
        risk_level = "HIGH"
    elif probability >= 40:
        risk_level = "MODERATE"
    else:
        risk_level = "LOW"

    return DiagnoseResponse(
        probability=round(probability, 1),
        advice=advice,
        risk_level=risk_level,
    )
