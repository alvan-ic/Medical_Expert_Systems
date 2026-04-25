from pyswip import Prolog
from fastapi import FastAPI, HTTPException
from typing import List
from models import Symptom, Disease, DiagnosisRequest, DiseaseResult, DiagnosisResponse
from database import init_db
from routes.auth import router as auth_router


app = FastAPI()
app.include_router(auth_router)

init_db()

prolog = Prolog()
    
#Load the files
prolog.consult("engine/diagnosis.pl")
prolog.consult("engine/symptoms.pl")
prolog.consult("engine/diseases.pl")


@app.get("/symptoms", response_model=List[Symptom])
def get_all_symptoms():
    try:
        
        query = "symptom(X)"
        results = prolog.query(query)
        
        symptoms = []
        for result in results:
            item=result.get("X", "")
            symptom_name = item.replace('_', ' ').title()
            
            symptoms.append(Symptom(symptom=symptom_name, slug=item))
   
        symptoms.sort(key=lambda x: x.symptom)
        
        return symptoms
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching symptoms: {str(e)}")

@app.get("/diseases", response_model=List[Disease])
def get_all_diseases():
    """
    Get all diseases from the Prolog knowledge base
    """
    try:
        # Query all disease facts from Prolog
        query = "disease(X)"
        results = prolog.query(query)
        
        diseases = []
        seen = set()
        
        for result in results:
            item = result.get("X", "")
            disease_name = result.get("X", "").replace('_', ' ').title()
            
            if disease_name not in seen:
                seen.add(disease_name)
                diseases.append(Disease(disease=disease_name, slug=item))
        
        # Sort diseases alphabetically
        diseases.sort(key=lambda x: x.disease)
        return diseases
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching diseases: {str(e)}")


@app.post("/diagnose")
def diagnose(request: DiagnosisRequest):
    """
    Diagnose possible diseases based on provided symptoms.
    Calls Prolog predicate: list_with_details(UserSymptoms, [D|Rest])
    """
    try:
        symptoms_list = request.symptoms
        
        # Convert Python list to Prolog list format
        prolog_list = "[" + ",".join(symptoms_list) + "]"
        prolog_query = f"match(Disease, {prolog_list})"
        
        # Execute the query
        prolog_results = list(prolog.query(prolog_query))
  
        if prolog_results:
            # Assuming your Prolog returns something like {'Disease': 'flu'}
            return {"diseases": prolog_results, "message": "Diagnosis complete"}
        else:
            return {"diseases": [], "message": "No matching disease found"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error during diagnosis: {str(e)}")