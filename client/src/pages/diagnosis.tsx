import { useState, useRef, useEffect } from "react";
import { useRouter } from "next/router";

const ALL_SYMPTOMS = [
  "fever", "chills", "headache", "body_pain", "fatigue", "weakness", "nausea", "vomiting",
  "weight_loss", "night_sweats", "sweating", "lethargy", "jaundice", "seizures", "confusion",
  "cough", "persistent_cough", "breathlessness", "chest_pain", "chest_tightness",
  "shortness_of_breath", "wheezing", "sputum_production", "hemoptysis", "cough_two_plus_weeks",
  "diarrhea", "abdominal_pain", "bloating", "constipation", "loss_of_appetite",
  "watery_diarrhea", "abdominal_cramps", "sudden_watery_diarrhea", "severe_dehydration",
  "neck_stiffness", "severe_headache", "altered_consciousness", "photophobia",
  "rash", "itching", "blurred_vision", "eye_pain", "red_eyes", "dark_urine", "pale_stool",
  "dysuria", "urgency", "frequency", "cloudy_urine", "flank_pain", "foamy_urine",
  "excessive_thirst", "frequent_urination", "excessive_hunger", "slow_healing_wounds",
  "tingling_hands_feet", "nosebleeds", "high_blood_pressure_reading", "palpitations",
  "swollen_lymph_nodes", "recurrent_infections", "oral_thrush", "chronic_diarrhea",
  "muscle_pain", "back_pain", "bleeding", "anemia", "edema", "dehydration",
  "ear_pain", "reduced_hearing", "ear_discharge", "severe_itching", "skin_rash",
  "recurrent_painful_crises", "hand_foot_swelling", "delayed_growth",
  "peripheral_vision_loss", "gradual_vision_loss", "halos_around_lights",
  "burning_epigastric_pain", "reflux", "nighttime_pain", "epigastric_pain",
  "intermittent_wheeze", "night_cough", "early_morning_cough", "exercise_induced",
  "high_fever", "runny_nose", "red_watery_eyes", "spreading_rash", "maculopapular_rash",
  "poor_feeding", "fast_breathing", "irritability", "hypothermia",
  "chronic_limb_swelling", "scrotal_swelling", "heaviness_of_legs",
  "subcutaneous_nodules", "eye_irritation", "visual_impairment",
];

const SYMPTOM_GROUPS = [
  { label: "General", color: "blue", symptoms: ["fever", "chills", "headache", "body_pain", "fatigue", "weakness", "nausea", "vomiting", "weight_loss", "night_sweats", "sweating", "lethargy"] },
  { label: "Respiratory", color: "green", symptoms: ["cough", "persistent_cough", "breathlessness", "chest_pain", "chest_tightness", "shortness_of_breath", "wheezing", "sputum_production", "hemoptysis", "cough_two_plus_weeks"] },
  { label: "Gastrointestinal", color: "yellow", symptoms: ["diarrhea", "abdominal_pain", "bloating", "constipation", "loss_of_appetite", "watery_diarrhea", "abdominal_cramps", "nausea", "vomiting"] },
  { label: "Neurological", color: "blue", symptoms: ["confusion", "neck_stiffness", "seizures", "severe_headache", "altered_consciousness", "photophobia"] },
  { label: "Skin & Eyes", color: "green", symptoms: ["rash", "jaundice", "itching", "blurred_vision", "eye_pain", "red_eyes", "dark_urine", "pale_stool", "skin_rash", "severe_itching"] },
  { label: "Urinary", color: "yellow", symptoms: ["dysuria", "urgency", "frequency", "cloudy_urine", "flank_pain", "foamy_urine"] },
  { label: "Metabolic", color: "blue", symptoms: ["excessive_thirst", "frequent_urination", "excessive_hunger", "slow_healing_wounds", "tingling_hands_feet", "nosebleeds", "high_blood_pressure_reading", "palpitations"] },
];

const groupBg: Record<string, string> = {
  blue: "border-blue-400 bg-blue-50",
  green: "border-green-400 bg-green-50",
  yellow: "border-yellow-400 bg-yellow-50",
};
const groupBadge: Record<string, string> = {
  blue: "bg-blue-100 text-blue-700",
  green: "bg-green-100 text-green-700",
  yellow: "bg-yellow-100 text-yellow-700",
};
const checkboxAccent: Record<string, string> = {
  blue: "accent-blue-600",
  green: "accent-green-600",
  yellow: "accent-yellow-500",
};

type DiagnosisResult = { disease: string; confidence?: number };

function formatLabel(s: string) {
  return s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

export default function DiagnosisPage() {
  const router = useRouter();

  // Tag search state
  const [tagInput, setTagInput] = useState("");
  const [showDropdown, setShowDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const tagInputRef = useRef<HTMLInputElement>(null);

  // Shared selected symptoms (used by both tag input and checkboxes)
  const [selected, setSelected] = useState<Set<string>>(new Set());

  // Patient info
  const [age, setAge] = useState("");
  const [gender, setGender] = useState("");

  // Results
  const [results, setResults] = useState<DiagnosisResult[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const filteredDropdown = ALL_SYMPTOMS.filter(
    (s) =>
      !selected.has(s) &&
      s.replace(/_/g, " ").includes(tagInput.toLowerCase().replace(/ /g, "_"))
  ).slice(0, 8);

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setShowDropdown(false);
      }
    }
    document.addEventListener("mousedown", onClickOutside);
    return () => document.removeEventListener("mousedown", onClickOutside);
  }, []);

  function addSymptom(s: string) {
    setSelected((prev) => new Set([...prev, s]));
    setTagInput("");
    setShowDropdown(false);
    tagInputRef.current?.focus();
  }

  function removeSymptom(s: string) {
    setSelected((prev) => { const n = new Set(prev); n.delete(s); return n; });
  }

  function toggleCheckbox(s: string) {
    setSelected((prev) => {
      const n = new Set(prev);
      n.has(s) ? n.delete(s) : n.add(s);
      return n;
    });
  }

  function handleTagKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Backspace" && !tagInput && selected.size > 0) {
      const last = [...selected].at(-1)!;
      removeSymptom(last);
    }
    if (e.key === "Enter") {
      e.preventDefault();
      if (filteredDropdown.length > 0) addSymptom(filteredDropdown[0]);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (selected.size === 0) { setError("Please add at least one symptom."); return; }
    setError("");
    setLoading(true);
    setResults(null);
    try {
      const res = await fetch("http://localhost:8000/diagnose", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          symptoms: Array.from(selected),
          age: age ? Number(age) : undefined,
          gender: gender || undefined,
        }),
      });
      if (!res.ok) throw new Error();
      const data = await res.json();
      setResults(data.diseases || []);
    } catch {
      setError("Could not connect to the diagnosis server. Please ensure it is running on port 8000.");
    } finally {
      setLoading(false);
    }
  }

  function reset() {
    setSelected(new Set());
    setAge("");
    setGender("");
    setResults(null);
    setError("");
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Navbar */}
      <nav className="bg-white shadow-sm px-8 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button onClick={() => router.push("/home")} className="text-gray-400 hover:text-gray-600 transition-colors">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-5 h-5">
              <path strokeLinecap="round" strokeLinejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
          </button>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center">
              <svg viewBox="0 0 24 24" fill="currentColor" className="w-4 h-4 text-white">
                <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
              </svg>
            </div>
            <span className="text-gray-800 font-bold">General Diagnosis</span>
          </div>
        </div>
        <button onClick={() => router.push("/home")} className="text-sm text-gray-400 hover:text-gray-600">Home</button>
      </nav>

      <main className="flex-1 px-4 md:px-10 py-8 max-w-5xl mx-auto w-full">

        {!results ? (
          <form onSubmit={handleSubmit} className="flex flex-col gap-6">

            {/* ── Horizontal search bar ── */}
            <div className="bg-white rounded-2xl shadow-md p-5 border border-gray-100">
              <h1 className="text-gray-800 font-bold text-lg mb-1">Symptom Checker</h1>
              <p className="text-gray-400 text-xs mb-4">Type to search symptoms, set your age and gender, then run the diagnosis.</p>

              <div className="flex flex-col lg:flex-row gap-3 items-end">

                {/* Symptom tag input */}
                <div className="flex-[3] min-w-0" ref={dropdownRef}>
                  <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">Symptoms</label>
                  <div className="relative">
                    <div
                      className="min-h-[46px] w-full flex flex-wrap gap-1.5 items-center px-3 py-2 rounded-xl border border-gray-200 bg-gray-50 focus-within:ring-2 focus-within:ring-blue-400 focus-within:border-transparent cursor-text"
                      onClick={() => tagInputRef.current?.focus()}
                    >
                      {[...selected].map((s) => (
                        <span key={s} className="flex items-center gap-1 bg-blue-100 text-blue-800 text-xs font-medium rounded-full px-2.5 py-1">
                          {formatLabel(s)}
                          <button type="button" onClick={() => removeSymptom(s)} className="text-blue-400 hover:text-blue-600">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} className="w-3 h-3">
                              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          </button>
                        </span>
                      ))}
                      <input
                        ref={tagInputRef}
                        type="text"
                        value={tagInput}
                        onChange={(e) => { setTagInput(e.target.value); setShowDropdown(true); }}
                        onFocus={() => setShowDropdown(true)}
                        onKeyDown={handleTagKeyDown}
                        placeholder={selected.size === 0 ? "e.g. fever, headache, cough..." : "Add more..."}
                        className="flex-1 min-w-[140px] bg-transparent outline-none text-sm text-gray-700 placeholder-gray-400 py-0.5"
                      />
                    </div>

                    {showDropdown && tagInput && filteredDropdown.length > 0 && (
                      <div className="absolute z-20 top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-lg overflow-hidden">
                        {filteredDropdown.map((s) => (
                          <button
                            key={s}
                            type="button"
                            onMouseDown={(e) => { e.preventDefault(); addSymptom(s); }}
                            className="w-full text-left px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-700 transition-colors flex items-center gap-2"
                          >
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4 text-blue-400 flex-shrink-0">
                              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                            </svg>
                            {formatLabel(s)}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                  {selected.size > 0 && (
                    <p className="text-xs text-gray-400 mt-1">
                      {selected.size} selected &mdash;{" "}
                      <button type="button" onClick={() => setSelected(new Set())} className="text-red-400 hover:underline">clear all</button>
                    </p>
                  )}
                </div>

                {/* Age */}
                <div className="lg:w-28 w-full">
                  <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">Age (yrs)</label>
                  <input
                    type="number"
                    min={0}
                    max={120}
                    value={age}
                    onChange={(e) => setAge(e.target.value)}
                    placeholder="e.g. 35"
                    className="w-full px-3 py-3 rounded-xl border border-gray-200 bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-400 text-sm text-gray-800 placeholder-gray-400 h-[46px]"
                  />
                </div>

                {/* Gender */}
                <div className="lg:w-52 w-full">
                  <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">Gender</label>
                  <div className="flex gap-1.5 h-[46px]">
                    {["Male", "Female", "Other"].map((g) => (
                      <button
                        key={g}
                        type="button"
                        onClick={() => setGender(gender === g.toLowerCase() ? "" : g.toLowerCase())}
                        className={`flex-1 rounded-xl border-2 text-xs font-semibold transition-all ${
                          gender === g.toLowerCase()
                            ? "border-blue-500 bg-blue-50 text-blue-700"
                            : "border-gray-200 bg-gray-50 text-gray-500 hover:border-blue-300"
                        }`}
                      >
                        {g === "Male" ? "♂ Male" : g === "Female" ? "♀ Female" : "⚥ Other"}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Run Diagnosis button */}
                <div className="flex gap-2 flex-shrink-0">
                  <button
                    type="submit"
                    disabled={loading}
                    className="h-[46px] px-6 rounded-xl bg-blue-600 text-white font-bold text-sm hover:bg-blue-700 transition-colors disabled:opacity-60 flex items-center gap-2 whitespace-nowrap"
                  >
                    {loading ? (
                      <svg className="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z" />
                      </svg>
                    ) : (
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09z" />
                      </svg>
                    )}
                    {loading ? "Analyzing..." : "Run Diagnosis"}
                  </button>
                </div>
              </div>

              {error && (
                <div className="mt-3 px-4 py-3 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm">
                  {error}
                </div>
              )}
            </div>

            {/* ── Browse by category ── */}
            <div>
              <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">Or browse by category</p>
              <div className="flex flex-col gap-4">
                {SYMPTOM_GROUPS.map((group) => (
                  <div key={group.label} className={`rounded-2xl border-l-4 p-4 ${groupBg[group.color]}`}>
                    <span className={`text-xs font-bold uppercase tracking-widest px-2 py-0.5 rounded-full ${groupBadge[group.color]} mb-3 inline-block`}>
                      {group.label}
                    </span>
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
                      {group.symptoms.map((s) => (
                        <label
                          key={s}
                          className={`flex items-center gap-2 cursor-pointer text-sm text-gray-700 bg-white rounded-lg px-3 py-2 border transition-all ${
                            selected.has(s) ? "border-blue-400 shadow-sm font-semibold text-blue-700" : "border-gray-100 hover:border-gray-300"
                          }`}
                        >
                          <input
                            type="checkbox"
                            checked={selected.has(s)}
                            onChange={() => toggleCheckbox(s)}
                            className={`w-4 h-4 ${checkboxAccent[group.color]}`}
                          />
                          {formatLabel(s)}
                        </label>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>

          </form>
        ) : (
          /* ── Results ── */
          <div className="flex flex-col gap-6">
            <div className="bg-white rounded-2xl shadow-md p-6 border-t-4 border-blue-500">
              <h2 className="text-xl font-bold text-gray-800 mb-1">Diagnosis Results</h2>
              <p className="text-gray-500 text-sm mb-4">
                Based on{" "}
                <span className="font-semibold text-blue-600">{selected.size} symptom{selected.size !== 1 ? "s" : ""}</span>
                {age ? <>, age <span className="font-semibold text-blue-600">{age}</span></> : null}
                {gender ? <>, <span className="font-semibold text-blue-600">{formatLabel(gender)}</span></> : null}
              </p>

              <div className="flex flex-wrap gap-2 mb-5">
                {[...selected].map((s) => (
                  <span key={s} className="text-xs bg-blue-50 text-blue-700 border border-blue-200 rounded-full px-3 py-1">
                    {formatLabel(s)}
                  </span>
                ))}
              </div>

              {results.length === 0 ? (
                <div className="text-center py-10 text-gray-400">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-12 h-12 mx-auto mb-3 text-gray-300">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z" />
                  </svg>
                  <p className="font-medium text-gray-500">No matching diseases found.</p>
                  <p className="text-sm mt-1">Try selecting more symptoms.</p>
                </div>
              ) : (
                <div className="flex flex-col gap-3">
                  {results.map((r, i) => (
                    <div
                      key={i}
                      className="flex items-center justify-between bg-gray-50 rounded-xl px-4 py-3.5 border border-gray-100 hover:border-green-200 hover:bg-green-50 transition-colors group"
                    >
                      <div className="flex items-center gap-3">
                        <span className="w-7 h-7 rounded-full bg-blue-100 text-blue-700 text-xs font-bold flex items-center justify-center flex-shrink-0">
                          {i + 1}
                        </span>
                        <span className="font-semibold text-gray-800">{formatLabel(r.disease)}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        {r.confidence != null && (
                          <span className="text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded-full px-3 py-1">
                            {Math.round(r.confidence * 100)}% match
                          </span>
                        )}
                        <button
                          type="button"
                          onClick={() => router.push(`/chat/${r.disease.toLowerCase().replace(/ /g, "_")}`)}
                          className="text-xs text-blue-600 font-semibold opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1"
                        >
                          Chat
                          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-3 h-3">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div className="bg-yellow-50 border border-yellow-200 rounded-xl px-5 py-4 text-sm text-yellow-700">
              <strong>Reminder:</strong> This is an expert system estimate only. Please consult a licensed healthcare provider for an actual diagnosis.
            </div>

            <div className="flex gap-3">
              <button
                onClick={reset}
                className="flex-1 py-3 rounded-xl border-2 border-blue-600 text-blue-700 font-semibold hover:bg-blue-50 transition-colors"
              >
                New Diagnosis
              </button>
              <button
                onClick={() => router.push("/home")}
                className="flex-1 py-3 rounded-xl bg-green-600 text-white font-semibold hover:bg-green-700 transition-colors"
              >
                Back to Home
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
