from fastapi import APIRouter
from models import ChatRequest, ChatResponse
from prolog_engine import prolog, prolog_lock, DISEASE_FILES, DISEASE_MODULE
import re

router = APIRouter(tags=["chat-freetext"])
_loaded_modules: set[str] = set()

QUESTION_RE = re.compile(r"Do you have \*\*(.+?)\*\*\?")
SEVERITY_RE = re.compile(r"how severe is \*\*(.+?)\*\*\?", re.IGNORECASE)

DISEASE_LABELS: dict[str, str] = {
    "malaria":                 "Malaria",
    "tuberculosis":            "Tuberculosis",
    "cholera":                 "Cholera",
    "typhoid_fever":           "Typhoid Fever",
    "urinary_tract_infection": "Urinary Tract Infection (UTI)",
    "pneumonia":               "Pneumonia",
    "hiv_aids":                "HIV/AIDS",
    "lassa_fever":             "Lassa Fever",
    "measles":                 "Measles",
    "neonatal_sepsis":         "Neonatal Sepsis",
    "yellow_fever":            "Yellow Fever",
}

TREATMENT_INFO: dict[str, str] = {
    "malaria":                 "Treatment typically involves artemisinin-based combination therapies (ACTs) such as artemether-lumefantrine. Severe cases may require IV artesunate. Always seek medical care for a confirmed diagnosis.",
    "tuberculosis":            "TB is treated with a 6-month course of antibiotics (DOTS regimen): isoniazid, rifampicin, pyrazinamide, and ethambutol. Completing the full course is critical to prevent drug-resistant TB.",
    "cholera":                 "Primary treatment is oral rehydration salts (ORS) to replace lost fluids. Severe cases need IV fluids. Antibiotics (doxycycline or azithromycin) shorten the illness duration.",
    "typhoid_fever":           "Treated with antibiotics such as ciprofloxacin, azithromycin, or ceftriaxone. Rest and adequate hydration are important. Drug resistance is a growing concern.",
    "urinary_tract_infection": "UTIs are treated with antibiotics — commonly trimethoprim-sulfamethoxazole, nitrofurantoin, or ciprofloxacin. Drinking plenty of water helps flush the infection.",
    "pneumonia":               "Bacterial pneumonia is treated with antibiotics (amoxicillin, azithromycin). Viral pneumonia is managed with supportive care. Severe cases may need hospitalization and oxygen therapy.",
    "hiv_aids":                "HIV is managed with antiretroviral therapy (ART), a lifelong combination of drugs that suppress the virus. ART allows people with HIV to live long, healthy lives.",
    "lassa_fever":             "Ribavirin is the primary antiviral treatment, most effective when given early. Supportive care including IV fluids and symptom management is also essential.",
    "measles":                 "There is no specific antiviral treatment. Supportive care includes vitamin A supplements, fever management, and hydration. The MMR vaccine prevents infection.",
    "neonatal_sepsis":         "Treated with IV antibiotics (ampicillin + gentamicin is the standard first-line regimen). Neonates require NICU monitoring. Early treatment is critical for survival.",
    "yellow_fever":            "No specific antiviral treatment exists. Management is supportive: rest, fluids, and pain relief. The 17D vaccine provides lifelong protection.",
}

DIAGNOSIS_INFO: dict[str, str] = {
    "malaria":                 "Diagnosis is confirmed by a rapid diagnostic test (RDT) or blood smear microscopy. PCR tests are used in research settings. A positive test is required before starting antimalarial treatment.",
    "tuberculosis":            "TB is diagnosed by sputum smear microscopy, GeneXpert (Xpert MTB/RIF) PCR test, chest X-ray, and tuberculin skin test (TST) or IGRA blood test.",
    "cholera":                 "Diagnosis is by stool culture or rapid dipstick test. In outbreak settings, clinical diagnosis based on symptoms is often used.",
    "typhoid_fever":           "Confirmed by blood culture (most reliable), Widal test, or bone marrow culture. Stool and urine cultures may also be used.",
    "urinary_tract_infection": "Diagnosed by urine dipstick test (positive for nitrites/leukocytes) and urine culture to identify the bacteria and guide antibiotic choice.",
    "pneumonia":               "Diagnosed by chest X-ray (shows infiltrates), complete blood count, sputum culture, and oxygen saturation measurement.",
    "hiv_aids":                "HIV is diagnosed by ELISA antibody test followed by a confirmatory Western blot. Rapid HIV tests are widely available. CD4 count and viral load are used for monitoring.",
    "lassa_fever":             "Confirmed by RT-PCR detecting Lassa virus RNA, ELISA for antibodies, or virus isolation in BSL-4 labs. Clinical diagnosis is difficult due to non-specific symptoms.",
    "measles":                 "Typically diagnosed clinically by Koplik's spots and the characteristic rash. Confirmed by IgM antibody serology or throat swab PCR.",
    "neonatal_sepsis":         "Diagnosed by blood culture (gold standard), CBC with differential, CRP, procalcitonin, and lumbar puncture if meningitis is suspected.",
    "yellow_fever":            "Diagnosed by serology (IgM antibodies via ELISA), PCR during early illness, or plaque reduction neutralization test (PRNT).",
}


def _ensure_module_loaded(disease: str) -> None:
    if disease not in _loaded_modules:
        file_path, _ = DISEASE_FILES[disease]
        with prolog_lock:
            prolog.consult(file_path)
        _loaded_modules.add(disease)


def _get_factors(module: str) -> list[str]:
    with prolog_lock:
        syms = [str(r["X"]) for r in prolog.query(f"{module}:symptom(X)")]
        risks = [str(r["X"]) for r in prolog.query(f"{module}:risk_factor(X)")]
    return syms + risks


def _get_prevention_tips(module: str) -> list[str]:
    with prolog_lock:
        return [str(r["T"]) for r in prolog.query(f"{module}:prevention_tip(T)")]


def _run_diagnosis(module: str, answers: dict) -> tuple[float, str]:
    with prolog_lock:
        try:
            list(prolog.query(f"retractall({module}:user_data(_, _, _))"))
            for factor, (response, severity) in answers.items():
                list(prolog.query(
                    f"assertz({module}:user_data({factor}, {response}, {severity}))"
                ))
            results = list(prolog.query(
                f"{module}:diagnostic_risk_evaluation_complete(P), {module}:advise(P, A)"
            ))
        finally:
            list(prolog.query(f"retractall({module}:user_data(_, _, _))"))
    if not results:
        return 0.0, "Unable to compute diagnosis."
    return float(results[0]["P"]), str(results[0]["A"])


def _label_to_factor(label: str) -> str:
    return label.lower().replace(" ", "_")


def _make_menu(label: str) -> str:
    return (
        f"Welcome to the **{label}** Diagnostic Chatbot!\n\n"
        f"1. Evaluate symptoms\n"
        f"2. Learn about {label}\n"
        f"3. Prevention tips\n"
        f"4. Generate report\n"
        f"5. Quit"
    )


def _make_question(factor: str) -> str:
    label = factor.replace("_", " ").title()
    return f"Do you have **{label}**? (yes / no / sometimes)"


def _make_severity_question(factor: str) -> str:
    label = factor.replace("_", " ").title()
    return f"On a scale of 1 to 10, how severe is **{label}**? (1 = mild, 10 = most severe)"


def _make_result(label: str, prob: float, advice: str) -> str:
    risk = "HIGH" if prob >= 70 else "MODERATE" if prob >= 40 else "LOW"
    return (
        f"**{label} Diagnostic Report**\n\n"
        f"Estimated Risk: **{prob:.1f}%**\n"
        f"Risk Level: **{risk}**\n"
        f"Advice: {advice}\n\n"
        f"Type **menu** to return to the main menu."
    )


def _find_session_start(history: list) -> int:
    """
    Return the index just after the user's '1' reply to the most recent menu,
    so _extract_answers only sees the current evaluation session.
    """
    n = len(history)
    # Walk backwards to find the last assistant menu message
    for i in range(n - 1, -1, -1):
        if history[i].role == "assistant" and "1. Evaluate symptoms" in history[i].content:
            # Find the user "1" that follows this menu
            j = i + 1
            while j < n and history[j].role != "user":
                j += 1
            if j < n and history[j].content.strip() == "1":
                return j + 1  # evaluation Q&A starts after the "1"
            break  # menu found but no "1" yet — user hasn't started evaluating
    return 0


def _extract_answers(history: list, factors: list[str]) -> dict:
    """
    Reconstruct {factor: (response, severity)} from the current evaluation session only.
    Stops at the first incomplete Q&A exchange (question asked but not fully answered).
    """
    answers: dict = {}
    n = len(history)
    i = _find_session_start(history)  # skip any prior evaluation sessions

    while i < n:
        if history[i].role != "assistant":
            i += 1
            continue

        m = QUESTION_RE.search(history[i].content)
        if not m:
            i += 1
            continue

        factor = _label_to_factor(m.group(1))
        if factor not in factors:
            i += 1
            continue

        # Locate the user's answer
        j = i + 1
        while j < n and history[j].role != "user":
            j += 1
        if j >= n:
            break  # question unanswered

        resp = history[j].content.strip().lower()

        if resp in ("yes", "no"):
            answers[factor] = (resp, 0)
            i = j + 1
            continue

        if resp == "sometimes":
            # Locate the severity question
            k = j + 1
            while k < n and history[k].role != "assistant":
                k += 1
            if k >= n or not SEVERITY_RE.search(history[k].content):
                break  # severity question not yet sent

            # Locate the severity value
            l = k + 1
            while l < n and history[l].role != "user":
                l += 1
            if l >= n:
                break  # severity value not yet given

            try:
                sev = int(history[l].content.strip())
                answers[factor] = ("sometimes", max(1, min(10, sev)))
            except ValueError:
                answers[factor] = ("sometimes", 5)
            i = l + 1
            continue

        # Unrecognised answer — skip
        i = j + 1

    return answers


def _get_state(history: list, factors: list[str]) -> tuple[str, str | None, dict]:
    """
    Returns (state, pending_factor, answers_so_far).

    state values:
      'init'       – no history
      'menu'       – last assistant message is the main menu
      'evaluating' – last assistant message is a yes/no question
      'severity'   – last assistant message is a severity question
      'done'       – last assistant message is a result or info block
    """
    if not history:
        return "init", None, {}

    answers = _extract_answers(history, factors)

    last_ai: str | None = None
    for msg in reversed(history):
        if msg.role == "assistant":
            last_ai = msg.content
            break

    if last_ai is None:
        return "init", None, answers

    if "1. Evaluate symptoms" in last_ai:
        return "menu", None, answers

    ms = SEVERITY_RE.search(last_ai)
    if ms:
        return "severity", _label_to_factor(ms.group(1)), answers

    mq = QUESTION_RE.search(last_ai)
    if mq:
        return "evaluating", _label_to_factor(mq.group(1)), answers

    return "done", None, answers


@router.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    disease = request.disease
    module = DISEASE_MODULE.get(disease)
    label = DISEASE_LABELS.get(disease, disease.replace("_", " ").title())

    if not module:
        return ChatResponse(reply=f"Sorry, I don't have a knowledge base for '{label}' yet.")

    _ensure_module_loaded(disease)
    factors = _get_factors(module)

    msg = request.message.strip().lower()
    history = request.history

    # Empty message (initial page load) or explicit navigation → show menu
    if not msg or msg in ("menu", "restart", "start", "back"):
        return ChatResponse(reply=_make_menu(label))

    state, pending_factor, answers = _get_state(history, factors)

    # ── MENU / INITIAL / POST-RESULT: process numbered option ─────────────────
    if state in ("init", "menu", "done"):
        if msg == "1":
            return ChatResponse(reply=_make_question(factors[0]))

        if msg == "2":
            with prolog_lock:
                syms = [str(r["X"]).replace("_", " ").title()
                        for r in prolog.query(f"{module}:symptom(X)")]
                risks = [str(r["X"]).replace("_", " ").title()
                         for r in prolog.query(f"{module}:risk_factor(X)")]
            reply = (
                f"**{label} — Key Information**\n\n"
                f"**Symptoms ({len(syms)}):**\n" + "\n".join(f"• {s}" for s in syms) +
                f"\n\n**Risk Factors ({len(risks)}):**\n" + "\n".join(f"• {r}" for r in risks) +
                f"\n\nType **menu** to return to the main menu."
            )
            return ChatResponse(reply=reply)

        if msg == "3":
            tips = _get_prevention_tips(module)
            reply = (
                f"**Prevention Tips for {label}:**\n" +
                "\n".join(f"• {t}" for t in tips) +
                f"\n\nType **menu** to return to the main menu."
            )
            return ChatResponse(reply=reply)

        if msg == "4":
            if not answers:
                return ChatResponse(
                    reply="No evaluation data found. Please select **1** to evaluate symptoms first."
                )
            prob, advice = _run_diagnosis(module, answers)
            return ChatResponse(reply=_make_result(label, prob, advice))

        if msg == "5":
            return ChatResponse(
                reply=f"Thank you for using the **{label}** Diagnostic Chatbot. Stay healthy!"
            )

        return ChatResponse(reply=f"Please choose a valid option (1–5).\n\n{_make_menu(label)}")

    # ── SEVERITY: collect 1–10 rating ─────────────────────────────────────────
    if state == "severity":
        try:
            sev = int(msg)
            if not 1 <= sev <= 10:
                return ChatResponse(reply="Please enter a number **between 1 and 10**.")
            answers[pending_factor] = ("sometimes", sev)
        except ValueError:
            return ChatResponse(reply="Please enter a number **between 1 and 10**.")

        next_f = next((f for f in factors if f not in answers), None)
        if next_f:
            return ChatResponse(reply=_make_question(next_f))
        prob, advice = _run_diagnosis(module, answers)
        return ChatResponse(reply=_make_result(label, prob, advice))

    # ── EVALUATING: yes / no / sometimes ──────────────────────────────────────
    if state == "evaluating":
        if msg in ("yes", "no"):
            answers[pending_factor] = (msg, 0)
            next_f = next((f for f in factors if f not in answers), None)
            if next_f:
                return ChatResponse(reply=_make_question(next_f))
            prob, advice = _run_diagnosis(module, answers)
            return ChatResponse(reply=_make_result(label, prob, advice))

        if msg == "sometimes":
            return ChatResponse(reply=_make_severity_question(pending_factor))

        return ChatResponse(reply="Please answer **yes**, **no**, or **sometimes**.")

    return ChatResponse(reply=_make_menu(label))
