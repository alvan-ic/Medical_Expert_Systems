import { useRouter } from "next/router";
import { useState, useRef, useEffect } from "react";
import { useUser } from "@/hooks/useUser";

type Message = {
  role: "user" | "assistant";
  text: string;
};

const DISEASE_INFO: Record<string, { label: string; icon: string; color: string; intro: string }> = {
  malaria: { label: "Malaria", icon: "🦟", color: "green", intro: "Hello! I'm your Malaria expert. You can ask me about symptoms, causes, treatment, prevention, or anything else about Malaria." },
  tuberculosis: { label: "Tuberculosis", icon: "🫁", color: "blue", intro: "Hi there! I specialize in Tuberculosis (TB). Feel free to ask about TB symptoms, diagnosis, treatment (DOTS), and prevention." },
  hiv_aids: { label: "HIV/AIDS", icon: "🔬", color: "yellow", intro: "Hello! I'm here to help you understand HIV/AIDS — covering transmission, stages, ARV treatment, and living with HIV." },
  pneumonia: { label: "Pneumonia", icon: "💨", color: "blue", intro: "Hi! Ask me anything about Pneumonia — its causes (bacterial, viral, fungal), symptoms, treatment, and prevention." },
  cholera: { label: "Cholera", icon: "💧", color: "green", intro: "Hello! I can answer questions about Cholera — its causes, the role of contaminated water, rehydration therapy, and outbreaks." },
  typhoid_fever: { label: "Typhoid Fever", icon: "🌡️", color: "yellow", intro: "Hi! Ask me about Typhoid Fever — Salmonella typhi, symptoms, antibiotics, and vaccine options." },
  diabetes_mellitus_type_2: { label: "Diabetes (Type 2)", icon: "🩸", color: "yellow", intro: "Hello! I specialize in Type 2 Diabetes. Ask about blood sugar management, insulin resistance, diet, medications, and complications." },
  hypertension: { label: "Hypertension", icon: "❤️", color: "blue", intro: "Hi! Let's talk about Hypertension (high blood pressure) — risk factors, lifestyle changes, medications, and long-term management." },
  hepatitis_b: { label: "Hepatitis B", icon: "🫀", color: "green", intro: "Hello! Ask me about Hepatitis B — vaccination, transmission, liver damage, antiviral treatment, and chronic HBV." },
  hepatitis_c: { label: "Hepatitis C", icon: "🧬", color: "yellow", intro: "Hi! I can help with Hepatitis C — how it spreads, symptoms, direct-acting antivirals, and cure rates." },
  bacterial_meningitis: { label: "Bacterial Meningitis", icon: "🧠", color: "blue", intro: "Hello! I specialize in Bacterial Meningitis — a medical emergency. Ask about signs, lumbar puncture, antibiotics, and vaccines." },
  asthma: { label: "Asthma", icon: "🌬️", color: "green", intro: "Hi! Ask me about Asthma — triggers, inhalers, peak flow monitoring, action plans, and long-term control." },
  peptic_ulcer_disease: { label: "Peptic Ulcer Disease", icon: "🫃", color: "yellow", intro: "Hello! Ask me about Peptic Ulcers — H. pylori infection, NSAID-related ulcers, acid suppression therapy, and diet." },
  measles: { label: "Measles", icon: "🔴", color: "blue", intro: "Hi! I can answer questions about Measles — the MMR vaccine, Koplik's spots, complications, and outbreak control." },
  urinary_tract_infection: { label: "UTI", icon: "🚰", color: "green", intro: "Hello! Ask me about UTIs — symptoms, common bacteria (E. coli), antibiotic treatment, and prevention tips." },
  yellow_fever: { label: "Yellow Fever", icon: "🟡", color: "yellow", intro: "Hi! Let's discuss Yellow Fever — Aedes mosquitoes, hemorrhagic symptoms, the 17D vaccine, and endemic zones." },
  lassa_fever: { label: "Lassa Fever", icon: "🐀", color: "blue", intro: "Hello! I specialize in Lassa Fever — rodent exposure, hemorrhagic symptoms, ribavirin treatment, and isolation protocols." },
  sickle_cell_disease: { label: "Sickle Cell Disease", icon: "🔴", color: "green", intro: "Hi! Ask about Sickle Cell Disease — hemoglobin S, painful crises, hydroxyurea, blood transfusions, and genetic counseling." },
  chronic_kidney_disease: { label: "Chronic Kidney Disease", icon: "🫘", color: "yellow", intro: "Hello! I can help with CKD — GFR stages, dialysis, dietary restrictions, medications, and kidney transplant." },
  glaucoma: { label: "Glaucoma", icon: "👁️", color: "blue", intro: "Hi! Let's talk about Glaucoma — intraocular pressure, optic nerve damage, eye drops, laser treatment, and vision preservation." },
  gastroenteritis: { label: "Gastroenteritis", icon: "🤢", color: "green", intro: "Hello! Ask me about Gastroenteritis — viral vs bacterial causes, ORS, food safety, and when to seek help." },
  neonatal_sepsis: { label: "Neonatal Sepsis", icon: "👶", color: "yellow", intro: "Hi! I specialize in Neonatal Sepsis — a critical newborn condition. Ask about risk factors, signs, IV antibiotics, and NICU care." },
  lymphatic_filariasis: { label: "Lymphatic Filariasis", icon: "🦷", color: "blue", intro: "Hello! Ask me about Lymphatic Filariasis — filarial worms, elephantiasis, MDA treatment programs, and prevention." },
  onchocerciasis: { label: "Onchocerciasis", icon: "🪲", color: "green", intro: "Hi! Let's discuss Onchocerciasis (River Blindness) — blackfly transmission, ivermectin therapy, and eye disease." },
  acute_otitis_media: { label: "Otitis Media", icon: "👂", color: "yellow", intro: "Hello! Ask me about Otitis Media (ear infection) — causes, symptoms in children, antibiotics, and ear tube surgery." },
  pyelonephritis: { label: "Pyelonephritis", icon: "🫘", color: "blue", intro: "Hi! I can answer questions about Pyelonephritis (kidney infection) — symptoms, urine culture, IV antibiotics, and prevention." },
};

const FALLBACK_INFO = {
  label: "Disease",
  icon: "🏥",
  color: "green",
  intro: "Hello! Ask me anything about this condition — symptoms, causes, treatment, and prevention.",
};

const colorStyles: Record<string, { header: string; bubble: string; userBubble: string; button: string; border: string }> = {
  green: {
    header: "from-green-700 to-green-500",
    bubble: "bg-green-50 border border-green-100 text-gray-800",
    userBubble: "bg-green-600 text-white",
    button: "bg-green-600 hover:bg-green-700",
    border: "focus:ring-green-400",
  },
  blue: {
    header: "from-blue-700 to-blue-500",
    bubble: "bg-blue-50 border border-blue-100 text-gray-800",
    userBubble: "bg-blue-600 text-white",
    button: "bg-blue-600 hover:bg-blue-700",
    border: "focus:ring-blue-400",
  },
  yellow: {
    header: "from-yellow-600 to-yellow-400",
    bubble: "bg-yellow-50 border border-yellow-100 text-gray-800",
    userBubble: "bg-yellow-500 text-white",
    button: "bg-yellow-500 hover:bg-yellow-600",
    border: "focus:ring-yellow-400",
  },
};

const SUGGESTED_QUESTIONS = [
  "What are the main symptoms?",
  "How is it diagnosed?",
  "What is the treatment?",
  "How can I prevent it?",
  "What causes this disease?",
  "Who is most at risk?",
];

export default function ChatPage() {
  const router = useRouter();
  const { user, logout } = useUser();
  const { disease } = router.query;
  const info = (typeof disease === "string" && DISEASE_INFO[disease]) ? DISEASE_INFO[disease] : FALLBACK_INFO;
  const styles = colorStyles[info.color];

  const [messages, setMessages] = useState<Message[]>([
    { role: "assistant", text: info.intro },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  async function sendMessage(text: string) {
    if (!text.trim()) return;
    const userMsg: Message = { role: "user", text: text.trim() };
    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setLoading(true);

    try {
      const res = await fetch("http://localhost:8000/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          disease: disease,
          message: text.trim(),
          history: messages.map((m) => ({ role: m.role, content: m.text })),
        }),
      });

      if (!res.ok) throw new Error("Server error");
      const data = await res.json();
      setMessages((prev) => [...prev, { role: "assistant", text: data.reply || "I'm not sure about that. Please try rephrasing your question." }]);
    } catch {
      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          text: "I couldn't reach the server right now. Please make sure the backend is running and try again.",
        },
      ]);
    } finally {
      setLoading(false);
    }
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    sendMessage(input);
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Header */}
      <div className={`bg-gradient-to-r ${styles.header} text-white px-6 py-4 flex items-center gap-4 shadow-md`}>
        <button onClick={() => router.push("/diseases")} className="text-white/70 hover:text-white transition-colors">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-5 h-5">
            <path strokeLinecap="round" strokeLinejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
          </svg>
        </button>
        <div className="w-10 h-10 rounded-xl bg-white/20 flex items-center justify-center text-xl">
          {info.icon}
        </div>
        <div>
          <h1 className="font-bold text-lg leading-tight">{info.label}</h1>
          <p className="text-white/70 text-xs">Medical Expert Chat</p>
        </div>
        <div className="ml-auto flex items-center gap-3">
          <div className="flex items-center gap-1.5">
            <div className="w-2 h-2 rounded-full bg-green-300 animate-pulse" />
            <span className="text-white/80 text-xs">Online</span>
          </div>
          {user && (
            <div className="flex items-center gap-2 border-l border-white/20 pl-3">
              <div className="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center">
                <span className="text-white font-bold text-xs">{user.first_name[0]}{user.last_name[0]}</span>
              </div>
              <span className="text-white/80 text-xs hidden sm:block">{user.first_name}</span>
            </div>
          )}
          <button onClick={logout} className="text-white/60 hover:text-white text-xs transition-colors">
            Logout
          </button>
        </div>
      </div>

      {/* Chat area */}
      <div className="flex-1 overflow-y-auto px-4 md:px-8 py-6 flex flex-col gap-4 max-w-3xl mx-auto w-full">
        {messages.map((msg, i) => (
          <div key={i} className={`flex ${msg.role === "user" ? "justify-end" : "justify-start"}`}>
            {msg.role === "assistant" && (
              <div className="w-8 h-8 rounded-full bg-white border-2 border-gray-200 flex items-center justify-center text-base flex-shrink-0 mr-2 mt-1">
                {info.icon}
              </div>
            )}
            <div
              className={`max-w-[78%] rounded-2xl px-4 py-3 text-sm leading-relaxed shadow-sm ${
                msg.role === "user"
                  ? `${styles.userBubble} rounded-br-sm`
                  : `${styles.bubble} rounded-bl-sm`
              }`}
            >
              {msg.text}
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex justify-start">
            <div className="w-8 h-8 rounded-full bg-white border-2 border-gray-200 flex items-center justify-center text-base flex-shrink-0 mr-2 mt-1">
              {info.icon}
            </div>
            <div className={`${styles.bubble} rounded-2xl rounded-bl-sm px-4 py-3 text-sm shadow-sm flex items-center gap-1.5`}>
              <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce [animation-delay:0ms]" />
              <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce [animation-delay:150ms]" />
              <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce [animation-delay:300ms]" />
            </div>
          </div>
        )}

        <div ref={bottomRef} />
      </div>

      {/* Suggested questions */}
      {messages.length <= 2 && !loading && (
        <div className="px-4 md:px-8 pb-2 max-w-3xl mx-auto w-full">
          <p className="text-xs text-gray-400 mb-2 font-medium">Suggested questions:</p>
          <div className="flex flex-wrap gap-2">
            {SUGGESTED_QUESTIONS.map((q) => (
              <button
                key={q}
                onClick={() => sendMessage(q)}
                className="text-xs bg-white border border-gray-200 text-gray-600 rounded-full px-3 py-1.5 hover:border-green-400 hover:text-green-700 transition-colors"
              >
                {q}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input bar */}
      <div className="bg-white border-t border-gray-100 px-4 md:px-8 py-4">
        <form onSubmit={handleSubmit} className="max-w-3xl mx-auto flex gap-3 items-end">
          <div className="bg-yellow-50 border border-yellow-200 rounded-xl px-3 py-2 text-xs text-yellow-700 hidden md:block flex-shrink-0 max-w-xs">
            <strong>Note:</strong> For educational use only. Always consult a doctor.
          </div>
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={`Ask about ${info.label}...`}
            disabled={loading}
            className={`flex-1 px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 text-sm text-gray-800 focus:outline-none focus:ring-2 ${styles.border} disabled:opacity-60`}
          />
          <button
            type="submit"
            disabled={loading || !input.trim()}
            className={`${styles.button} text-white rounded-xl px-5 py-3 flex items-center gap-2 font-semibold text-sm transition-colors disabled:opacity-50 flex-shrink-0`}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-5 h-5">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5" />
            </svg>
            Send
          </button>
        </form>
      </div>
    </div>
  );
}
