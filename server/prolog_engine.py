from pyswip import Prolog
import threading

prolog = Prolog()
prolog_lock = threading.Lock()

DISEASE_FILES: dict[str, tuple[str, str]] = {
    "malaria":                 ("engine/chats/malaria.pl",        "chatbot_diagnostic_malaria"),
    "typhoid_fever":           ("engine/chats/typhoid_fever.pl",  "chatbot_diagnostic_typhoid"),
    "cholera":                 ("engine/chats/cholera.pl",         "chatbot_diagnostic_cholera"),
    "tuberculosis":            ("engine/chats/tuberculosis.pl",    "chatbot_diagnostic_tuberculosis"),
    "urinary_tract_infection": ("engine/chats/uti.pl",             "chatbot_diagnostic_uti"),
    "pneumonia":               ("engine/chats/pneumonia.pl",       "chatbot_diagnostic_pneumonia"),
    "hiv_aids":                ("engine/chats/hiv_aids.pl",        "chatbot_diagnostic_hiv_aids"),
    "lassa_fever":             ("engine/chats/lassa_fever.pl",     "chatbot_diagnostic_lassa_fever"),
    "measles":                 ("engine/chats/measles.pl",         "chatbot_diagnostic_measles"),
    "neonatal_sepsis":         ("engine/chats/neonatal_sepsis.pl", "chatbot_diagnostic_neonatal_sepsis"),
    "yellow_fever":            ("engine/chats/yellow_fever.pl",    "chatbot_diagnostic_yellow_fever"),
}

DISEASE_MODULE = {slug: module for slug, (_, module) in DISEASE_FILES.items()}


def load_knowledge_base():
    prolog.consult("engine/diagnosis.pl")
    prolog.consult("engine/symptoms.pl")
    prolog.consult("engine/diseases.pl")
    prolog.consult("engine/chats/malaria.pl")
    # for path, _ in DISEASE_FILES.values():
    #     prolog.consult(path)
