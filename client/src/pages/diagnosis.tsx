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
  {
    label: "General",
    color: "blue",
    symptoms: [
      "fever",
      "chills",
      "headache",
      "body_pain",
      "fatigue",
      "weakness",
      "nausea",
      "vomiting",
      "weight_loss",
      "night_sweats",
      "sweating",
      "lethargy",
    ],
  },
  {
    label: "Respiratory",
    color: "green",
    symptoms: [
      "cough",
      "persistent_cough",
      "breathlessness",
      "chest_pain",
      "chest_tightness",
      "shortness_of_breath",
      "wheezing",
      "sputum_production",
      "hemoptysis",
      "cough_two_plus_weeks",
    ],
  },
  {
    label: "Gastrointestinal",
    color: "amber",
    symptoms: [
      "diarrhea",
      "abdominal_pain",
      "bloating",
      "constipation",
      "loss_of_appetite",
      "watery_diarrhea",
      "abdominal_cramps",
      "nausea",
      "vomiting",
    ],
  },
  {
    label: "Neurological",
    color: "purple",
    symptoms: [
      "confusion",
      "neck_stiffness",
      "seizures",
      "severe_headache",
      "altered_consciousness",
      "photophobia",
    ],
  },
  {
    label: "Skin & Eyes",
    color: "rose",
    symptoms: [
      "rash",
      "jaundice",
      "itching",
      "blurred_vision",
      "eye_pain",
      "red_eyes",
      "dark_urine",
      "pale_stool",
      "skin_rash",
      "severe_itching",
    ],
  },
  {
    label: "Urinary",
    color: "teal",
    symptoms: [
      "dysuria",
      "urgency",
      "frequency",
      "cloudy_urine",
      "flank_pain",
      "foamy_urine",
    ],
  },
  {
    label: "Metabolic",
    color: "orange",
    symptoms: [
      "excessive_thirst",
      "frequent_urination",
      "excessive_hunger",
      "slow_healing_wounds",
      "tingling_hands_feet",
      "nosebleeds",
      "high_blood_pressure_reading",
      "palpitations",
    ],
  },
];

const groupStyles: Record<
  string,
  { border: string; bg: string; badge: string; check: string; tag: string }
> = {
  blue: {
    border: "border-blue-300",
    bg: "bg-blue-50/60",
    badge: "bg-blue-100 text-blue-700",
    check: "accent-blue-600",
    tag: "bg-blue-100 text-blue-700 border-blue-200",
  },
  green: {
    border: "border-green-300",
    bg: "bg-green-50/60",
    badge: "bg-green-100 text-green-700",
    check: "accent-green-600",
    tag: "bg-green-100 text-green-700 border-green-200",
  },
  amber: {
    border: "border-amber-300",
    bg: "bg-amber-50/60",
    badge: "bg-amber-100 text-amber-700",
    check: "accent-amber-500",
    tag: "bg-amber-100 text-amber-700 border-amber-200",
  },
  purple: {
    border: "border-purple-300",
    bg: "bg-purple-50/60",
    badge: "bg-purple-100 text-purple-700",
    check: "accent-purple-600",
    tag: "bg-purple-100 text-purple-700 border-purple-200",
  },
  rose: {
    border: "border-rose-300",
    bg: "bg-rose-50/60",
    badge: "bg-rose-100 text-rose-700",
    check: "accent-rose-500",
    tag: "bg-rose-100 text-rose-700 border-rose-200",
  },
  teal: {
    border: "border-teal-300",
    bg: "bg-teal-50/60",
    badge: "bg-teal-100 text-teal-700",
    check: "accent-teal-600",
    tag: "bg-teal-100 text-teal-700 border-teal-200",
  },
  orange: {
    border: "border-orange-300",
    bg: "bg-orange-50/60",
    badge: "bg-orange-100 text-orange-700",
    check: "accent-orange-500",
    tag: "bg-orange-100 text-orange-700 border-orange-200",
  },
};

function formatLabel(s: string | undefined | null): string {
  if (!s) return "";
  return s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

function matchTier(pct: number): {
  bar: string;
  text: string;
  badge: string;
  label: string;
} {
  if (pct >= 70)
    return {
      bar: "bg-emerald-500",
      text: "text-emerald-600",
      badge: "bg-emerald-50 border-emerald-200 text-emerald-700",
      label: "High Match",
    };
  if (pct >= 40)
    return {
      bar: "bg-amber-400",
      text: "text-amber-600",
      badge: "bg-amber-50 border-amber-200 text-amber-700",
      label: "Moderate",
    };
  if (pct >= 15)
    return {
      bar: "bg-orange-400",
      text: "text-orange-600",
      badge: "bg-orange-50 border-orange-200 text-orange-700",
      label: "Possible",
    };
  return {
    bar: "bg-gray-300",
    text: "text-gray-400",
    badge: "bg-gray-50 border-gray-200 text-gray-500",
    label: "Low Match",
  };
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
    .filter(
      (s) =>
        !selected.has(s.slug) &&
        s.symptom.toLowerCase().includes(tagInput.toLowerCase()),
    )
    .slice(0, 8);

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(e.target as Node)
      )
        setShowDropdown(false);
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
    setSelected((prev) => {
      const n = new Set(prev);
      n.delete(s);
      return n;
    });
  }

  function toggleCheckbox(s: string) {
    setSelected((prev) => {
      const n = new Set(prev);
      n.has(s) ? n.delete(s) : n.add(s);
      return n;
    });
  }

  function handleTagKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Backspace" && !tagInput && selected.size > 0)
      removeSymptom([...selected].at(-1)!);
    if (e.key === "Enter") {
      e.preventDefault();
      if (filteredDropdown.length > 0) addSymptom(filteredDropdown[0].slug);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (selected.size === 0) {
      setError("Please add at least one symptom.");
      return;
    }
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
      setTimeout(
        () =>
          resultsRef.current?.scrollIntoView({
            behavior: "smooth",
            block: "start",
          }),
        50,
      );
    } catch {
      setError(
        "Could not connect to the diagnosis server. Please ensure it is running on port 8000.",
      );
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

  const matched =
    results?.possible_diseases.filter((d) => d.match_percentage > 0) ?? [];
  const noMatch =
    results?.possible_diseases.filter((d) => d.match_percentage === 0) ?? [];
  const initials = user ? `${user.first_name[0]}${user.last_name[0]}` : "?";

  return (
    <div className="min-h-screen bg-[#f4f9f1] flex flex-col font-sans">
      {/* ── NAVBAR ── */}
      <nav className="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-green-100 px-6 md:px-10 py-3.5 flex items-center justify-between shadow-sm">
        <div className="flex items-center gap-3">
          <button
            onClick={() => router.push("/home")}
            className="w-8 h-8 rounded-lg bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
          >
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              className="w-4 h-4 text-gray-600"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18"
              />
            </svg>
          </button>
          <div className="w-px h-5 bg-gray-200" />
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-blue-600 flex items-center justify-center shadow-sm">
              <svg viewBox="0 0 24 24" fill="white" className="w-4 h-4">
                <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
              </svg>
            </div>
            <span className="text-gray-800 font-bold text-base">
              General Diagnosis
            </span>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {user && (
            <>
              <div className="hidden sm:block text-right">
                <p className="text-sm font-semibold text-gray-700 leading-tight">
                  {user.first_name} {user.last_name}
                </p>
              </div>
              <div className="w-8 h-8 rounded-full bg-green-100 border-2 border-green-200 flex items-center justify-center">
                <span className="text-green-700 font-bold text-xs">
                  {initials}
                </span>
              </div>
            </>
          )}
          <button
            onClick={logout}
            className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-red-500 border border-gray-200 hover:border-red-200 hover:bg-red-50 rounded-full px-3 py-1.5 transition-colors"
          >
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              className="w-3.5 h-3.5"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75"
              />
            </svg>
            Logout
          </button>
        </div>
      </nav>

      {/* ── PAGE HEADER ── */}
      <div className="bg-gradient-to-r from-blue-700 to-blue-900 px-6 md:px-10 py-8 relative overflow-hidden">
        <div className="absolute -right-6 top-1/2 -translate-y-1/2 opacity-[0.07] pointer-events-none">
          <svg viewBox="0 0 24 24" fill="white" className="w-44 h-44">
            <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
          </svg>
        </div>
        <div className="max-w-5xl mx-auto">
          <p className="text-blue-300 text-xs font-bold uppercase tracking-widest mb-1">
            Prolog-Powered
          </p>
          <h1 className="text-white text-2xl md:text-3xl font-extrabold mb-1">
            Symptom Checker
          </h1>
          <p className="text-blue-200/70 text-sm max-w-md">
            Describe your symptoms below and our expert system will suggest
            possible conditions ranked by likelihood.
          </p>
        </div>
      </div>

      <main className="flex-1 px-4 md:px-10 py-8 max-w-5xl mx-auto w-full flex flex-col gap-6">
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {/* ── INPUT CARD ── */}
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="px-6 pt-6 pb-4 border-b border-gray-50">
              <h2 className="text-gray-800 font-bold text-base mb-0.5">
                Enter Your Symptoms
              </h2>
              <p className="text-gray-400 text-xs">
                Search by name or browse by category below. Add age and gender
                for higher accuracy.
              </p>
            </div>

            <div className="px-6 py-5 flex flex-col lg:flex-row gap-4 items-end">
              {/* Symptom tag input */}
              <div className="flex-[3] min-w-0" ref={dropdownRef}>
                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">
                  Symptoms
                  {selected.size > 0 && (
                    <span className="ml-2 bg-blue-100 text-blue-700 text-xs font-bold px-2 py-0.5 rounded-full normal-case tracking-normal">
                      {selected.size} selected
                    </span>
                  )}
                </label>
                <div className="relative">
                  <div
                    className="min-h-[48px] w-full flex flex-wrap gap-1.5 items-center px-3 py-2 rounded-xl border-2 border-gray-200 bg-gray-50 focus-within:border-blue-400 focus-within:bg-white cursor-text transition-colors"
                    onClick={() => tagInputRef.current?.focus()}
                  >
                    {[...selected].map((s) => {
                      const label =
                        apiSymptoms.find((a) => a.slug === s)?.symptom ??
                        formatLabel(s);
                      return (
                        <span
                          key={s}
                          className="flex items-center gap-1 bg-blue-600 text-white text-xs font-semibold rounded-full px-3 py-1"
                        >
                          {label}
                          <button
                            type="button"
                            onClick={() => removeSymptom(s)}
                            className="opacity-70 hover:opacity-100 ml-0.5"
                          >
                            <svg
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth={2.5}
                              className="w-3 h-3"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                d="M6 18L18 6M6 6l12 12"
                              />
                            </svg>
                          </button>
                        </span>
                      );
                    })}
                    <input
                      ref={tagInputRef}
                      type="text"
                      value={tagInput}
                      onChange={(e) => {
                        setTagInput(e.target.value);
                        setShowDropdown(true);
                      }}
                      onFocus={() => setShowDropdown(true)}
                      onKeyDown={handleTagKeyDown}
                      placeholder={
                        symptomsLoading
                          ? "Loading symptoms…"
                          : selected.size === 0
                            ? "Search symptoms e.g. fever, headache…"
                            : "Add more symptoms…"
                      }
                      className="flex-1 min-w-[160px] bg-transparent outline-none text-sm text-gray-700 placeholder-gray-400 py-0.5"
                      disabled={symptomsLoading}
                    />
                    {selected.size > 0 && (
                      <button
                        type="button"
                        onClick={() => setSelected(new Set())}
                        className="text-gray-300 hover:text-red-400 transition-colors ml-1"
                      >
                        <svg
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth={2}
                          className="w-4 h-4"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M6 18L18 6M6 6l12 12"
                          />
                        </svg>
                      </button>
                    )}
                  </div>

                  {showDropdown && tagInput && filteredDropdown.length > 0 && (
                    <div className="absolute z-20 top-full left-0 right-0 mt-1.5 bg-white border border-gray-200 rounded-xl shadow-xl overflow-hidden">
                      {filteredDropdown.map((s, i) => (
                        <button
                          key={s.slug}
                          type="button"
                          onMouseDown={(e) => {
                            e.preventDefault();
                            addSymptom(s.slug);
                          }}
                          className={`w-full text-left px-4 py-3 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-700 transition-colors flex items-center gap-3 ${i > 0 ? "border-t border-gray-50" : ""}`}
                        >
                          <span className="w-6 h-6 rounded-lg bg-blue-100 flex items-center justify-center flex-shrink-0">
                            <svg
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth={2.5}
                              className="w-3.5 h-3.5 text-blue-600"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                d="M12 4.5v15m7.5-7.5h-15"
                              />
                            </svg>
                          </span>
                          {s.symptom}
                        </button>
                      ))}
                    </div>
                  )}

                  {showDropdown &&
                    tagInput &&
                    !symptomsLoading &&
                    filteredDropdown.length === 0 && (
                      <div className="absolute z-20 top-full left-0 right-0 mt-1.5 bg-white border border-gray-200 rounded-xl shadow-sm px-4 py-4 text-sm text-gray-400 flex items-center gap-2">
                        <svg
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth={2}
                          className="w-4 h-4"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z"
                          />
                        </svg>
                        No symptoms found matching &ldquo;{tagInput}&rdquo;
                      </div>
                    )}
                </div>
              </div>

              {/* Age */}
              <div className="lg:w-28 w-full">
                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">
                  Age
                </label>
                <input
                  type="number"
                  min={0}
                  max={120}
                  value={age}
                  onChange={(e) => setAge(e.target.value)}
                  placeholder="e.g. 35"
                  className="w-full px-3 py-3 rounded-xl border-2 border-gray-200 bg-gray-50 focus:outline-none focus:border-blue-400 focus:bg-white text-sm text-gray-800 placeholder-gray-400 h-[48px] transition-colors"
                />
              </div>

              {/* Gender */}
              <div className="lg:w-52 w-full">
                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">
                  Gender
                </label>
                <div className="flex gap-1.5 h-[48px]">
                  {[
                    { label: "Male", icon: "♂" },
                    { label: "Female", icon: "♀" },
                    { label: "Other", icon: "⚥" },
                  ].map((g) => (
                    <button
                      key={g.label}
                      type="button"
                      onClick={() =>
                        setGender(
                          gender === g.label.toLowerCase()
                            ? ""
                            : g.label.toLowerCase(),
                        )
                      }
                      className={`flex-1 rounded-xl border-2 text-xs font-bold transition-all ${
                        gender === g.label.toLowerCase()
                          ? "border-blue-500 bg-blue-600 text-white shadow-sm"
                          : "border-gray-200 bg-gray-50 text-gray-500 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-600"
                      }`}
                    >
                      <span className="block text-base leading-none">
                        {g.icon}
                      </span>
                      <span className="block text-[10px] mt-0.5">
                        {g.label}
                      </span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                className="h-[48px] px-7 rounded-xl bg-blue-600 text-white font-bold text-sm hover:bg-blue-700 active:scale-95 transition-all disabled:opacity-60 flex items-center gap-2 whitespace-nowrap shadow-md shadow-blue-200 flex-shrink-0 w-full lg:w-auto justify-center"
              >
                {loading ? (
                  <>
                    <svg
                      className="animate-spin w-4 h-4"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                      />
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8v8z"
                      />
                    </svg>
                    Analyzing…
                  </>
                ) : (
                  <>
                    <svg
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth={2}
                      className="w-4 h-4"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09z"
                      />
                    </svg>
                    Run Diagnosis
                  </>
                )}
              </button>
            </div>

            {error && (
              <div className="mx-6 mb-5 px-4 py-3 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm flex items-center gap-2">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  className="w-4 h-4 flex-shrink-0"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"
                  />
                </svg>
                {error}
              </div>
            )}
          </div>

          {/* ── BROWSE BY CATEGORY ── */}
          {!results && (
            <div>
              <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span className="flex-1 h-px bg-gray-200" />
                Or browse symptoms by category
                <span className="flex-1 h-px bg-gray-200" />
              </p>
              <div className="flex flex-col gap-3">
                {SYMPTOM_GROUPS.map((group) => {
                  const s = groupStyles[group.color];
                  return (
                    <div
                      key={group.label}
                      className={`rounded-2xl border-l-4 p-5 ${s.border} ${s.bg}`}
                    >
                      <span
                        className={`text-xs font-bold uppercase tracking-widest px-3 py-1 rounded-full ${s.badge} mb-4 inline-block`}
                      >
                        {group.label}
                      </span>
                      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
                        {group.symptoms.map((sym) => (
                          <label
                            key={sym}
                            className={`flex items-center gap-2 cursor-pointer text-sm bg-white rounded-xl px-3 py-2.5 border-2 transition-all select-none ${
                              selected.has(sym)
                                ? `border-current font-semibold ${s.tag} shadow-sm`
                                : "border-transparent text-gray-600 hover:border-gray-200 shadow-sm"
                            }`}
                          >
                            <input
                              type="checkbox"
                              checked={selected.has(sym)}
                              onChange={() => toggleCheckbox(sym)}
                              className={`w-4 h-4 flex-shrink-0 ${s.check}`}
                            />
                            <span className="truncate">{formatLabel(sym)}</span>
                          </label>
                        ))}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </form>

        {/* ── RESULTS ── */}
        {results && (
          <div ref={resultsRef} className="flex flex-col gap-5">
            {/* Summary */}
            <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-5">
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div>
                    <h2 className="text-white text-xl font-extrabold">
                      Diagnosis Results
                    </h2>
                    <p className="text-blue-200 text-sm mt-0.5">
                      Based on{" "}
                      <span className="font-bold text-white">
                        {selected.size} symptom{selected.size !== 1 ? "s" : ""}
                      </span>
                      {age ? (
                        <>
                          , age{" "}
                          <span className="font-bold text-white">{age}</span>
                        </>
                      ) : null}
                      {gender ? (
                        <>
                          ,{" "}
                          <span className="font-bold text-white capitalize">
                            {gender}
                          </span>
                        </>
                      ) : null}
                    </p>
                  </div>
                  <div className="flex gap-3">
                    <div className="text-center bg-white/20 backdrop-blur-sm rounded-xl px-4 py-2.5">
                      <p className="text-2xl font-extrabold text-white leading-none">
                        {results.total_diseases_checked}
                      </p>
                      <p className="text-xs text-blue-200 font-medium mt-0.5">
                        Checked
                      </p>
                    </div>
                    <div className="text-center bg-white/20 backdrop-blur-sm rounded-xl px-4 py-2.5">
                      <p className="text-2xl font-extrabold text-white leading-none">
                        {matched.length}
                      </p>
                      <p className="text-xs text-blue-200 font-medium mt-0.5">
                        Matched
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="px-6 py-4 flex flex-wrap gap-1.5">
                {[...selected].map((s) => (
                  <span
                    key={s}
                    className="text-xs bg-blue-50 text-blue-700 border border-blue-200 rounded-full px-3 py-1 font-medium"
                  >
                    {formatLabel(s)}
                  </span>
                ))}
              </div>
            </div>

            {/* Matched diseases */}
            {matched.length === 0 ? (
              <div className="bg-white rounded-2xl border border-gray-100 text-center py-16">
                <div className="w-14 h-14 rounded-2xl bg-gray-100 flex items-center justify-center mx-auto mb-4">
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={1.5}
                    className="w-7 h-7 text-gray-400"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z"
                    />
                  </svg>
                </div>
                <p className="font-bold text-gray-600 text-base">
                  No diseases matched your symptoms
                </p>
                <p className="text-sm text-gray-400 mt-1">
                  Try selecting more symptoms for a better result.
                </p>
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {matched.map((d, i) => {
                  const tier = matchTier(d.match_percentage);
                  return (
                    <div
                      key={d.slug}
                      className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow"
                    >
                      {/* Card header */}
                      <div className="flex items-center justify-between px-6 py-4 border-b border-gray-50">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-xl bg-blue-600 flex items-center justify-center flex-shrink-0">
                            <span className="text-white text-xs font-extrabold">
                              {i + 1}
                            </span>
                          </div>
                          <div>
                            <h3 className="font-extrabold text-gray-800 text-base">
                              {d.name}
                            </h3>
                            <div className="flex items-center gap-2 mt-0.5">
                              <span
                                className={`text-xs font-bold border rounded-full px-2.5 py-0.5 ${tier.badge}`}
                              >
                                {tier.label}
                              </span>
                              <span className="text-xs text-gray-400">
                                {d.matching_symptoms.length} of{" "}
                                {d.matching_symptoms.length +
                                  d.missing_symptoms.length}{" "}
                                symptoms
                              </span>
                            </div>
                          </div>
                        </div>
                        <div className="text-right flex-shrink-0">
                          <p
                            className={`text-3xl font-extrabold leading-none ${tier.text}`}
                          >
                            {d.match_percentage.toFixed(0)}
                            <span className="text-lg">%</span>
                          </p>
                          <p className="text-xs text-gray-400 mt-0.5">match</p>
                        </div>
                      </div>

                      {/* Progress bar */}
                      <div className="h-1.5 bg-gray-100">
                        <div
                          className={`h-full ${tier.bar} transition-all`}
                          style={{ width: `${d.match_percentage}%` }}
                        />
                      </div>

                      {/* Symptoms */}
                      <div className="px-6 py-4 flex flex-col sm:flex-row gap-4">
                        {d.matching_symptoms.length > 0 && (
                          <div className="flex-1">
                            <p className="text-xs font-bold text-emerald-600 uppercase tracking-wide mb-2 flex items-center gap-1.5">
                              <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                strokeWidth={2.5}
                                className="w-3.5 h-3.5"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  d="M4.5 12.75l6 6 9-13.5"
                                />
                              </svg>
                              Matching symptoms
                            </p>
                            <div className="flex flex-wrap gap-1.5">
                              {d.matching_symptoms.map((s) => (
                                <span
                                  key={s}
                                  className="inline-flex items-center gap-1 text-xs bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-full px-3 py-1 font-medium"
                                >
                                  {formatLabel(s)}
                                </span>
                              ))}
                            </div>
                          </div>
                        )}
                        {d.missing_symptoms.length > 0 && (
                          <div className="flex-1">
                            <p className="text-xs font-bold text-gray-400 uppercase tracking-wide mb-2 flex items-center gap-1.5">
                              <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                strokeWidth={2.5}
                                className="w-3.5 h-3.5"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  d="M6 18L18 6M6 6l12 12"
                                />
                              </svg>
                              Missing symptoms
                            </p>
                            <div className="flex flex-wrap gap-1.5">
                              {d.missing_symptoms.map((s) => (
                                <span
                                  key={s}
                                  className="text-xs bg-gray-100 text-gray-500 border border-gray-200 rounded-full px-3 py-1"
                                >
                                  {formatLabel(s)}
                                </span>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Footer */}
                      <div className="px-6 py-3 bg-gray-50 border-t border-gray-100 flex justify-end">
                        <button
                          type="button"
                          onClick={() => router.push(`/chat/${d.slug}`)}
                          className="inline-flex items-center gap-2 text-sm font-bold text-white bg-blue-600 hover:bg-blue-700 active:scale-95 rounded-xl px-5 py-2 transition-all shadow-sm shadow-blue-200"
                        >
                          <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth={1.8}
                            className="w-4 h-4"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
                            />
                          </svg>
                          Deep Diagnosis Chat
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}

            {/* No-match diseases (collapsible) */}
            {noMatch.length > 0 && (
              <div>
                <button
                  type="button"
                  onClick={() => setShowNoMatch((v) => !v)}
                  className="flex items-center gap-2 text-xs text-gray-400 hover:text-gray-600 font-bold uppercase tracking-wide transition-colors mb-3 w-full"
                >
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={2}
                    className={`w-4 h-4 transition-transform ${showNoMatch ? "rotate-90" : ""}`}
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M8.25 4.5l7.5 7.5-7.5 7.5"
                    />
                  </svg>
                  {showNoMatch ? "Hide" : "Show"} {noMatch.length} unmatched
                  disease{noMatch.length !== 1 ? "s" : ""}
                  <span className="flex-1 h-px bg-gray-200 ml-1" />
                </button>

                {showNoMatch && (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    {noMatch.map((d) => (
                      <div
                        key={d.slug}
                        className="bg-white rounded-xl border border-gray-100 px-4 py-3 opacity-60 flex items-center gap-3"
                      >
                        <span className="w-6 h-6 rounded-lg bg-gray-100 flex items-center justify-center flex-shrink-0">
                          <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth={2}
                            className="w-3 h-3 text-gray-400"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              d="M6 18L18 6M6 6l12 12"
                            />
                          </svg>
                        </span>
                        <span className="text-sm text-gray-500 font-medium">
                          {d.name}
                        </span>
                        <span className="ml-auto text-xs text-gray-400 bg-gray-100 rounded-full px-2 py-0.5 flex-shrink-0">
                          0%
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Disclaimer */}
            <div className="bg-amber-50 border border-amber-200 rounded-2xl px-5 py-4 flex items-start gap-3">
              <div className="w-8 h-8 rounded-xl bg-amber-400 flex items-center justify-center flex-shrink-0">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="white"
                  strokeWidth={2}
                  className="w-4 h-4"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
                  />
                </svg>
              </div>
              <p className="text-amber-800 text-sm leading-relaxed">
                <strong>Medical Reminder:</strong> These results are estimates
                from an expert system only. Please consult a licensed healthcare
                professional for an actual diagnosis and treatment plan.
              </p>
            </div>

            {/* Action buttons */}
            <div className="flex gap-3">
              <button
                onClick={reset}
                className="flex-1 py-3 rounded-xl border-2 border-gray-200 text-gray-600 font-bold hover:bg-gray-50 hover:border-gray-300 transition-colors flex items-center justify-center gap-2"
              >
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  className="w-4 h-4"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182m0-4.991v4.99"
                  />
                </svg>
                New Diagnosis
              </button>
              <button
                onClick={() => router.push("/home")}
                className="flex-1 py-3 rounded-xl bg-green-700 text-white font-bold hover:bg-green-800 transition-colors flex items-center justify-center gap-2 shadow-md shadow-green-200"
              >
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  className="w-4 h-4"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
                  />
                </svg>
                Back to Home
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
