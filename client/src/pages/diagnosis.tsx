import { useState, useRef, useEffect } from "react";
import { useRouter } from "next/router";
import { useUser } from "@/hooks/useUser";

type ApiSymptom = { symptom: string; slug: string };

type DiseaseResult = {
  name: string;
  slug: string;
  match_percentage: number;
  matching_symptoms: string[];
  missing_symptoms: string[];
};

type DiagnosisApiResponse = {
  possible_diseases: DiseaseResult[];
  total_diseases_checked: number;
};

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

function formatLabel(s: string | undefined | null): string {
  if (!s) return "";
  return s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

function pctRankBg(pct: number) {
  if (pct >= 50) return "bg-green-600";
  if (pct >= 30) return "bg-yellow-500";
  if (pct >= 10) return "bg-orange-400";
  return "bg-gray-400";
}

function pctTextColor(pct: number) {
  if (pct >= 70) return "text-green-600";
  if (pct >= 40) return "text-yellow-500";
  return "text-gray-400";
}

function pctBar(pct: number) {
  if (pct >= 50) return "bg-green-500";
  if (pct >= 30) return "bg-yellow-400";
  if (pct >= 10) return "bg-orange-400";
  return "bg-gray-300";
}

export default function DiagnosisPage() {
  const router = useRouter();
  const { user, logout } = useUser();

  const [apiSymptoms, setApiSymptoms] = useState<ApiSymptom[]>([]);
  const [symptomsLoading, setSymptomsLoading] = useState(true);

  useEffect(() => {
    fetch("http://127.0.0.1:8000/symptoms")
      .then((r) => r.json())
      .then((data: ApiSymptom[]) => setApiSymptoms(data))
      .catch(() => {})
      .finally(() => setSymptomsLoading(false));
  }, []);

  const [tagInput, setTagInput] = useState("");
  const [showDropdown, setShowDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const tagInputRef = useRef<HTMLInputElement>(null);

  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [age, setAge] = useState("");
  const [gender, setGender] = useState("");

  const [results, setResults] = useState<DiagnosisApiResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [showNoMatch, setShowNoMatch] = useState(false);
  const resultsRef = useRef<HTMLDivElement>(null);

  const filteredDropdown = apiSymptoms
    .filter((s) => !selected.has(s.slug) && s.symptom.toLowerCase().includes(tagInput.toLowerCase()))
    .slice(0, 8);

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setShowDropdown(false);
      }
    }
    document.addEventListener("mousedown", onClickOutside);
    return () => document.removeEventListener("mousedown", onClickOutside);
  }, []);

  function addSymptom(slug: string | undefined) {
    if (!slug) return;
    setSelected((prev) => new Set([...prev, slug]));
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
      removeSymptom([...selected].at(-1)!);
    }
    if (e.key === "Enter") {
      e.preventDefault();
      if (filteredDropdown.length > 0) addSymptom(filteredDropdown[0].slug);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (selected.size === 0) { setError("Please add at least one symptom."); return; }
    setError("");
    setLoading(true);
    setResults(null);
    setShowNoMatch(false);
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
      const data: DiagnosisApiResponse = await res.json();
      setResults(data);
      setTimeout(() => resultsRef.current?.scrollIntoView({ behavior: "smooth", block: "start" }), 50);
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
    setShowNoMatch(false);
  }

  const matched = results?.possible_diseases.filter((d) => d.match_percentage > 0) ?? [];
  const noMatch = results?.possible_diseases.filter((d) => d.match_percentage === 0) ?? [];

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
        <div className="flex items-center gap-3">
          {user && (
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-full bg-green-100 flex items-center justify-center">
                <span className="text-green-700 font-bold text-xs">{user.first_name[0]}{user.last_name[0]}</span>
              </div>
              <span className="text-sm text-gray-600 hidden sm:block">{user.first_name} {user.last_name}</span>
            </div>
          )}
          <button onClick={logout} className="text-sm text-gray-400 hover:text-red-500 transition-colors">Logout</button>
        </div>
      </nav>

      <main className="flex-1 px-4 md:px-10 py-8 max-w-5xl mx-auto w-full flex flex-col gap-6">

          <form onSubmit={handleSubmit} className="flex flex-col gap-6">

            {/* Search bar */}
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
                      {[...selected].map((s) => {
                        const label = apiSymptoms.find((a) => a.slug === s)?.symptom ?? formatLabel(s);
                        return (
                          <span key={s} className="flex items-center gap-1 bg-blue-100 text-blue-800 text-xs font-medium rounded-full px-2.5 py-1">
                            {label}
                            <button type="button" onClick={() => removeSymptom(s)} className="text-blue-400 hover:text-blue-600">
                              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} className="w-3 h-3">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </button>
                          </span>
                        );
                      })}
                      <input
                        ref={tagInputRef}
                        type="text"
                        value={tagInput}
                        onChange={(e) => { setTagInput(e.target.value); setShowDropdown(true); }}
                        onFocus={() => setShowDropdown(true)}
                        onKeyDown={handleTagKeyDown}
                        placeholder={symptomsLoading ? "Loading symptoms..." : selected.size === 0 ? "e.g. fever, headache, cough..." : "Add more..."}
                        className="flex-1 min-w-[140px] bg-transparent outline-none text-sm text-gray-700 placeholder-gray-400 py-0.5"
                        disabled={symptomsLoading}
                      />
                    </div>

                    {showDropdown && tagInput && filteredDropdown.length > 0 && (
                      <div className="absolute z-20 top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-lg overflow-hidden">
                        {filteredDropdown.map((s) => (
                          <button
                            key={s.slug}
                            type="button"
                            onMouseDown={(e) => { e.preventDefault(); addSymptom(s.slug); }}
                            className="w-full text-left px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-700 transition-colors flex items-center gap-2"
                          >
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4 text-blue-400 flex-shrink-0">
                              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                            </svg>
                            {s.symptom}
                          </button>
                        ))}
                      </div>
                    )}

                    {showDropdown && tagInput && !symptomsLoading && filteredDropdown.length === 0 && (
                      <div className="absolute z-20 top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-sm px-4 py-3 text-sm text-gray-400">
                        No matching symptoms found.
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

                {/* Submit */}
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

            {/* Browse by category — hidden once results are available */}
            <div className={results ? "hidden" : ""}>
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

          {results && (
          <div ref={resultsRef} className="flex flex-col gap-5">

            {/* Summary header */}
            <div className="bg-white rounded-2xl shadow-md p-5 border-t-4 border-blue-500">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <h2 className="text-xl font-bold text-gray-800">Diagnosis Results</h2>
                  <p className="text-gray-500 text-sm mt-0.5">
                    Based on{" "}
                    <span className="font-semibold text-blue-600">{selected.size} symptom{selected.size !== 1 ? "s" : ""}</span>
                    {age ? <>, age <span className="font-semibold text-blue-600">{age}</span></> : null}
                    {gender ? <>, <span className="font-semibold text-blue-600">{formatLabel(gender)}</span></> : null}
                  </p>
                </div>
                <div className="flex gap-3 text-center">
                  <div className="bg-blue-50 border border-blue-200 rounded-xl px-4 py-2">
                    <p className="text-2xl font-bold text-blue-600">{results.total_diseases_checked}</p>
                    <p className="text-xs text-blue-500 font-medium">Checked</p>
                  </div>
                  <div className="bg-green-50 border border-green-200 rounded-xl px-4 py-2">
                    <p className="text-2xl font-bold text-green-600">{matched.length}</p>
                    <p className="text-xs text-green-500 font-medium">Matched</p>
                  </div>
                </div>
              </div>

              {/* Searched symptoms */}
              <div className="mt-4 flex flex-wrap gap-1.5">
                {[...selected].map((s) => (
                  <span key={s} className="text-xs bg-blue-50 text-blue-700 border border-blue-200 rounded-full px-3 py-1 font-medium">
                    {formatLabel(s)}
                  </span>
                ))}
              </div>
            </div>

            {/* Matched diseases */}
            {matched.length === 0 ? (
              <div className="bg-white rounded-2xl shadow-sm border border-gray-100 text-center py-12 text-gray-400">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-12 h-12 mx-auto mb-3 text-gray-300">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z" />
                </svg>
                <p className="font-medium text-gray-500">No diseases matched your symptoms.</p>
                <p className="text-sm mt-1">Try selecting more symptoms.</p>
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {matched.map((d, i) => (
                  <div key={d.slug} className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6 flex flex-col sm:flex-row gap-6">

                    {/* Left column — rank, name, percentage */}
                    <div className="sm:w-2/5 flex-shrink-0 flex flex-col justify-between gap-4">
                      <div className="flex flex-col gap-2">
                        <div className="flex items-center gap-2">
                          <span className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0 ${pctRankBg(d.match_percentage)}`}>
                            {i + 1}
                          </span>
                          <h3 className="font-bold text-gray-800 text-base leading-snug">{d.name}</h3>
                        </div>
                        <div className={`text-4xl font-extrabold tracking-tight ${pctTextColor(d.match_percentage)}`}>
                          {d.match_percentage.toFixed(0)}
                          <span className="text-xl font-bold ml-0.5">%</span>
                        </div>
                        <p className="text-xs text-gray-400 -mt-1">match probability</p>
                      </div>

                      <div>
                        <div className="w-full bg-gray-100 rounded-full h-2">
                          <div
                            className={`h-2 rounded-full ${pctBar(d.match_percentage)}`}
                            style={{ width: `${d.match_percentage}%` }}
                          />
                        </div>
                        <div className="flex justify-between text-xs text-gray-400 mt-1.5">
                          <span>{d.matching_symptoms.length} found</span>
                          <span>{d.missing_symptoms.length} missing</span>
                        </div>
                      </div>
                    </div>

                    {/* Divider */}
                    <div className="hidden sm:block w-px bg-gray-100 self-stretch" />

                    {/* Right column — symptoms + button */}
                    <div className="flex-1 flex flex-col justify-between gap-4">
                      <div className="flex flex-col gap-3">
                        {/* Matching symptoms */}
                        {d.matching_symptoms.length > 0 && (
                          <div>
                            <p className="text-xs font-semibold text-yellow-600 uppercase tracking-wide mb-1.5">Found</p>
                            <div className="flex flex-wrap gap-1.5">
                              {d.matching_symptoms.map((s) => (
                                <span
                                  key={s}
                                  className="inline-flex items-center gap-1 text-xs bg-yellow-50 text-yellow-700 border border-yellow-200 rounded-full px-3 py-1 font-medium"
                                >
                                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} className="w-3 h-3 flex-shrink-0">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                                  </svg>
                                  {formatLabel(s)}
                                </span>
                              ))}
                            </div>
                          </div>
                        )}

                        {/* Missing symptoms */}
                        {d.missing_symptoms.length > 0 && (
                          <div>
                            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-1.5">Missing</p>
                            <div className="flex flex-wrap gap-1.5">
                              {d.missing_symptoms.map((s) => (
                                <span
                                  key={s}
                                  className="inline-flex items-center gap-1 text-xs bg-gray-100 text-gray-500 border border-gray-200 rounded-full px-3 py-1"
                                >
                                  {formatLabel(s)}
                                </span>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Button */}
                      <div className="flex justify-end">
                        <button
                          type="button"
                          onClick={() => router.push(`/chat/${d.slug}`)}
                          className="inline-flex items-center gap-2 text-sm font-semibold text-white bg-blue-600 hover:bg-blue-700 rounded-xl px-5 py-2.5 transition-colors"
                        >
                          Run Deep Diagnosis
                          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                          </svg>
                        </button>
                      </div>
                    </div>

                  </div>
                ))}

                {/* Legend */}
                <div className="flex items-center gap-5 text-xs text-gray-400 px-1">
                  <span className="flex items-center gap-1.5">
                    <span className="w-3 h-3 rounded-full bg-yellow-400 inline-block" />
                    Symptom found
                  </span>
                  <span className="flex items-center gap-1.5">
                    <span className="w-3 h-3 rounded-full bg-gray-300 inline-block" />
                    Symptom missing
                  </span>
                </div>
              </div>
            )}

            {/* No-match diseases (collapsible) */}
            {noMatch.length > 0 && (
              <div>
                <button
                  type="button"
                  onClick={() => setShowNoMatch((v) => !v)}
                  className="flex items-center gap-2 text-xs text-gray-400 hover:text-gray-600 font-semibold uppercase tracking-wide transition-colors mb-2"
                >
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={2}
                    className={`w-4 h-4 transition-transform ${showNoMatch ? "rotate-90" : ""}`}
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                  </svg>
                  {showNoMatch ? "Hide" : "Show"} {noMatch.length} disease{noMatch.length !== 1 ? "s" : ""} with no symptom match
                </button>

                {showNoMatch && (
                  <div className="flex flex-col gap-2">
                    {noMatch.map((d) => (
                      <div key={d.slug} className="bg-white rounded-xl border border-gray-100 px-4 py-3 opacity-60">
                        <div className="flex items-center justify-between gap-3 mb-2">
                          <div className="flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-gray-200 flex items-center justify-center flex-shrink-0">
                              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-3 h-3 text-gray-400">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </span>
                            <span className="text-sm font-medium text-gray-500">{d.name}</span>
                          </div>
                          <span className="text-xs text-gray-400 bg-gray-100 rounded-full px-2.5 py-0.5">0% match</span>
                        </div>
                        <div className="flex flex-wrap gap-1">
                          {d.missing_symptoms.map((s) => (
                            <span key={s} className="text-xs text-gray-400 bg-gray-50 border border-gray-100 rounded-full px-2 py-0.5">
                              {formatLabel(s)}
                            </span>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Disclaimer */}
            <div className="bg-yellow-50 border border-yellow-200 rounded-xl px-5 py-4 text-sm text-yellow-700">
              <strong>Reminder:</strong> This is an expert system estimate only. Please consult a licensed healthcare provider for an actual diagnosis.
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button
                onClick={reset}
                className="flex-1 py-3 rounded-xl border-2 border-gray-300 text-gray-600 font-semibold hover:bg-gray-50 transition-colors"
              >
                Clear Results
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
