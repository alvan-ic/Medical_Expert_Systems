import { useRouter } from "next/router";
import { useState } from "react";

const DISEASES = [
  { id: "malaria", label: "Malaria", icon: "🦟", color: "green", desc: "Mosquito-borne parasitic infection" },
  { id: "tuberculosis", label: "Tuberculosis", icon: "🫁", color: "blue", desc: "Bacterial lung infection" },
  { id: "hiv_aids", label: "HIV/AIDS", icon: "🔬", color: "yellow", desc: "Immune system disease" },
  { id: "pneumonia", label: "Pneumonia", icon: "💨", color: "blue", desc: "Lung inflammation" },
  { id: "cholera", label: "Cholera", icon: "💧", color: "green", desc: "Bacterial waterborne disease" },
  { id: "typhoid_fever", label: "Typhoid Fever", icon: "🌡️", color: "yellow", desc: "Bacterial food/water infection" },
  { id: "diabetes_mellitus_type_2", label: "Diabetes (Type 2)", icon: "🩸", color: "yellow", desc: "Chronic metabolic disease" },
  { id: "hypertension", label: "Hypertension", icon: "❤️", color: "blue", desc: "High blood pressure" },
  { id: "hepatitis_b", label: "Hepatitis B", icon: "🫀", color: "green", desc: "Viral liver infection" },
  { id: "hepatitis_c", label: "Hepatitis C", icon: "🧬", color: "yellow", desc: "Viral liver disease" },
  { id: "bacterial_meningitis", label: "Bacterial Meningitis", icon: "🧠", color: "blue", desc: "Brain membrane infection" },
  { id: "asthma", label: "Asthma", icon: "🌬️", color: "green", desc: "Chronic airway disease" },
  { id: "peptic_ulcer_disease", label: "Peptic Ulcer", icon: "🫃", color: "yellow", desc: "Stomach lining sores" },
  { id: "measles", label: "Measles", icon: "🔴", color: "blue", desc: "Viral childhood disease" },
  { id: "urinary_tract_infection", label: "UTI", icon: "🚰", color: "green", desc: "Urinary tract infection" },
  { id: "yellow_fever", label: "Yellow Fever", icon: "🟡", color: "yellow", desc: "Mosquito-borne viral disease" },
  { id: "lassa_fever", label: "Lassa Fever", icon: "🐀", color: "blue", desc: "Rodent-borne viral disease" },
  { id: "sickle_cell_disease", label: "Sickle Cell Disease", icon: "🔴", color: "green", desc: "Inherited blood disorder" },
  { id: "chronic_kidney_disease", label: "Chronic Kidney Disease", icon: "🫘", color: "yellow", desc: "Progressive kidney damage" },
  { id: "glaucoma", label: "Glaucoma", icon: "👁️", color: "blue", desc: "Eye pressure & vision loss" },
  { id: "gastroenteritis", label: "Gastroenteritis", icon: "🤢", color: "green", desc: "Stomach and bowel infection" },
  { id: "neonatal_sepsis", label: "Neonatal Sepsis", icon: "👶", color: "yellow", desc: "Newborn bloodstream infection" },
  { id: "lymphatic_filariasis", label: "Lymphatic Filariasis", icon: "🦷", color: "blue", desc: "Parasitic lymph system disease" },
  { id: "onchocerciasis", label: "Onchocerciasis", icon: "🪲", color: "green", desc: "River blindness disease" },
  { id: "acute_otitis_media", label: "Otitis Media", icon: "👂", color: "yellow", desc: "Middle ear infection" },
  { id: "pyelonephritis", label: "Pyelonephritis", icon: "🫘", color: "blue", desc: "Kidney infection" },
];

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
  const [search, setSearch] = useState("");

  const filtered = DISEASES.filter(
    (d) =>
      d.label.toLowerCase().includes(search.toLowerCase()) ||
      d.desc.toLowerCase().includes(search.toLowerCase())
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
      </nav>

      {/* Header */}
      <div className="bg-gradient-to-r from-green-700 to-green-500 text-white px-8 py-8">
        <h1 className="text-2xl font-extrabold mb-1">Select a Disease</h1>
        <p className="text-green-100 text-sm max-w-lg">
          Choose a disease below to start an in-depth chat about its symptoms, causes, treatment and prevention.
        </p>
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

        {filtered.length === 0 ? (
          <div className="text-center py-16 text-gray-400">
            <p className="text-lg font-medium">No diseases match your search.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {filtered.map((disease) => {
              const styles = colorStyles[disease.color];
              return (
                <button
                  key={disease.id}
                  onClick={() => router.push(`/chat/${disease.id}`)}
                  className={`text-left bg-white rounded-2xl border-2 p-5 transition-all duration-200 hover:shadow-md ${styles.card} group`}
                >
                  <div className={`w-12 h-12 rounded-xl ${styles.icon} flex items-center justify-center text-2xl mb-3`}>
                    {disease.icon}
                  </div>
                  <h3 className="font-bold text-gray-800 text-sm leading-tight mb-1">{disease.label}</h3>
                  <p className="text-gray-500 text-xs mb-3">{disease.desc}</p>
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
