import { useRouter } from "next/router";
import { useState, useEffect } from "react";
import { useUser } from "@/hooks/useUser";

type ApiDisease = { disease: string; slug: string };

// Icon / colour metadata keyed by slug — used as an overlay on top of API data
const DISEASE_META: Record<string, { icon: string; color: string; desc: string }> = {
  malaria:                   { icon: "🦟", color: "green",  desc: "Mosquito-borne parasitic infection" },
  tuberculosis:              { icon: "🫁", color: "blue",   desc: "Bacterial lung infection" },
  hiv_aids:                  { icon: "🔬", color: "yellow", desc: "Immune system disease" },
  pneumonia:                 { icon: "💨", color: "blue",   desc: "Lung inflammation" },
  cholera:                   { icon: "💧", color: "green",  desc: "Bacterial waterborne disease" },
  typhoid_fever:             { icon: "🌡️", color: "yellow", desc: "Bacterial food/water infection" },
  diabetes_mellitus_type_2:  { icon: "🩸", color: "yellow", desc: "Chronic metabolic disease" },
  hypertension:              { icon: "❤️", color: "blue",   desc: "High blood pressure" },
  hepatitis_b:               { icon: "🫀", color: "green",  desc: "Viral liver infection" },
  hepatitis_c:               { icon: "🧬", color: "yellow", desc: "Viral liver disease" },
  bacterial_meningitis:      { icon: "🧠", color: "blue",   desc: "Brain membrane infection" },
  asthma:                    { icon: "🌬️", color: "green",  desc: "Chronic airway disease" },
  peptic_ulcer_disease:      { icon: "🫃", color: "yellow", desc: "Stomach lining sores" },
  measles:                   { icon: "🔴", color: "blue",   desc: "Viral childhood disease" },
  urinary_tract_infection:   { icon: "🚰", color: "green",  desc: "Urinary tract infection" },
  yellow_fever:              { icon: "🟡", color: "yellow", desc: "Mosquito-borne viral disease" },
  lassa_fever:               { icon: "🐀", color: "blue",   desc: "Rodent-borne viral disease" },
  sickle_cell_disease:       { icon: "🔴", color: "green",  desc: "Inherited blood disorder" },
  chronic_kidney_disease:    { icon: "🫘", color: "yellow", desc: "Progressive kidney damage" },
  glaucoma:                  { icon: "👁️", color: "blue",   desc: "Eye pressure & vision loss" },
  gastroenteritis:           { icon: "🤢", color: "green",  desc: "Stomach and bowel infection" },
  neonatal_sepsis:           { icon: "👶", color: "yellow", desc: "Newborn bloodstream infection" },
  lymphatic_filariasis:      { icon: "🦷", color: "blue",   desc: "Parasitic lymph system disease" },
  onchocerciasis:            { icon: "🪲", color: "green",  desc: "River blindness disease" },
  river_blindness:           { icon: "🪲", color: "green",  desc: "Blackfly-transmitted parasitic disease" },
  acute_otitis_media:        { icon: "👂", color: "yellow", desc: "Middle ear infection" },
  otitis_media:              { icon: "👂", color: "yellow", desc: "Ear infection" },
  pyelonephritis:            { icon: "🫘", color: "blue",   desc: "Kidney infection" },
  meningococcal_disease:     { icon: "🧠", color: "blue",   desc: "Bacterial meningococcal infection" },
  meningococcal_meningitis:  { icon: "🧠", color: "blue",   desc: "Meningococcal meningitis" },
  acute_angle_closure_glaucoma: { icon: "👁️", color: "blue", desc: "Acute eye pressure emergency" },
};

const COLORS = ["green", "blue", "yellow"] as const;
const DEFAULT_META = (i: number) => ({
  icon: "🏥",
  color: COLORS[i % 3],
  desc: "Medical condition",
});

const colorStyles: Record<string, { card: string; badge: string; icon: string }> = {
  green: {
    card: "border-green-200 hover:border-green-400 hover:bg-green-50",
    badge: "bg-green-100 text-green-700",
    icon: "bg-green-100",
  },
  blue: {
    card: "border-blue-200 hover:border-blue-400 hover:bg-blue-50",
    badge: "bg-blue-100 text-blue-700",
    icon: "bg-blue-100",
  },
  yellow: {
    card: "border-yellow-200 hover:border-yellow-400 hover:bg-yellow-50",
    badge: "bg-yellow-100 text-yellow-700",
    icon: "bg-yellow-100",
  },
};

export default function DiseasesPage() {
  const router = useRouter();
  const { user, logout } = useUser();
  const [search, setSearch] = useState("");
  const [apiDiseases, setApiDiseases] = useState<ApiDisease[]>([]);
  const [loadingDiseases, setLoadingDiseases] = useState(true);

  useEffect(() => {
    fetch("http://127.0.0.1:8000/diseases")
      .then((r) => r.json())
      .then((data: ApiDisease[]) => setApiDiseases(data))
      .catch(() => {})
      .finally(() => setLoadingDiseases(false));
  }, []);

  const filtered = apiDiseases.filter(
    (d) =>
      d.disease.toLowerCase().includes(search.toLowerCase()) ||
      d.slug.replace(/_/g, " ").includes(search.toLowerCase())
  );

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
            <div className="w-8 h-8 rounded-full bg-green-600 flex items-center justify-center">
              <svg viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth={2} className="w-4 h-4">
                <path strokeLinecap="round" strokeLinejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
              </svg>
            </div>
            <span className="text-gray-800 font-bold">Disease Chat</span>
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

      {/* Header */}
      <div className="bg-gradient-to-r from-green-700 to-green-500 text-white px-8 py-8">
        <h1 className="text-2xl font-extrabold mb-1">Select a Disease</h1>
        <p className="text-green-100 text-sm max-w-lg">
          Choose a disease below to start an in-depth chat about its symptoms, causes, treatment and prevention.
        </p>
        {!loadingDiseases && (
          <p className="text-green-200 text-xs mt-2">
            {apiDiseases.length} disease{apiDiseases.length !== 1 ? "s" : ""} available
          </p>
        )}
      </div>

      <main className="flex-1 px-4 md:px-10 py-8 max-w-6xl mx-auto w-full">
        {/* Search */}
        <div className="relative mb-8 max-w-md">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400">
            <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
          </svg>
          <input
            type="text"
            placeholder="Search diseases..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 bg-white focus:outline-none focus:ring-2 focus:ring-green-400 text-sm text-gray-700"
          />
        </div>

        {loadingDiseases ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {Array.from({ length: 12 }).map((_, i) => (
              <div key={i} className="bg-white rounded-2xl border-2 border-gray-100 p-5 animate-pulse">
                <div className="w-12 h-12 rounded-xl bg-gray-100 mb-3" />
                <div className="h-4 bg-gray-100 rounded w-3/4 mb-2" />
                <div className="h-3 bg-gray-100 rounded w-full mb-1" />
                <div className="h-3 bg-gray-100 rounded w-2/3" />
              </div>
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="text-center py-16 text-gray-400">
            <p className="text-lg font-medium">
              {search ? "No diseases match your search." : "No diseases available."}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {filtered.map((disease, i) => {
              const meta = DISEASE_META[disease.slug] ?? DEFAULT_META(i);
              const styles = colorStyles[meta.color];
              return (
                <button
                  key={disease.slug}
                  onClick={() => router.push(`/chat/${disease.slug}`)}
                  className={`text-left bg-white rounded-2xl border-2 p-5 transition-all duration-200 hover:shadow-md ${styles.card} group`}
                >
                  <div className={`w-12 h-12 rounded-xl ${styles.icon} flex items-center justify-center text-2xl mb-3`}>
                    {meta.icon}
                  </div>
                  <h3 className="font-bold text-gray-800 text-sm leading-tight mb-1">{disease.disease}</h3>
                  <p className="text-gray-500 text-xs mb-3">{meta.desc}</p>
                  <div className="flex items-center gap-1 text-xs font-semibold text-green-600 group-hover:gap-2 transition-all">
                    Chat now
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} className="w-3 h-3">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                    </svg>
                  </div>
                </button>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
