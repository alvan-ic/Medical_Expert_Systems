import { useRouter } from "next/router";
import { useUser } from "@/hooks/useUser";

const serviceItems = [
  {
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-5 h-5 text-green-600"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M9 12h6m-3-3v6M12 21a9 9 0 100-18 9 9 0 000 18z"
        />
      </svg>
    ),
    label: "Expert Diagnosis",
    sub: "Prolog-powered engine",
    bg: "bg-green-50",
  },
  {
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-5 h-5 text-blue-600"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
        />
      </svg>
    ),
    label: "Disease Chat",
    sub: "AI-assisted Q&A",
    bg: "bg-blue-50",
  },
  {
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-5 h-5 text-amber-600"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
        />
      </svg>
    ),
    label: "30+ Diseases",
    sub: "Tropical & chronic",
    bg: "bg-amber-50",
  },
  {
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-5 h-5 text-emerald-600"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z"
        />
      </svg>
    ),
    label: "Instant Results",
    sub: "Real-time analysis",
    bg: "bg-emerald-50",
  },
];

const quickTips = [
  {
    text: "Be specific with symptoms — include duration and severity for better accuracy.",
  },
  { text: "Use Disease Chat to learn about prevention, not just treatment." },
  {
    text: "Always follow up with a qualified clinician after receiving a result.",
  },
];

export default function HomePage() {
  const router = useRouter();
  const { user, loading, logout } = useUser();

  const initials = user ? `${user.first_name[0]}${user.last_name[0]}` : "?";
  const greeting = () => {
    const h = new Date().getHours();
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    return "Good evening";
  };

  return (
    <div className="min-h-screen bg-[#f4f9f1] flex flex-col font-sans">
      {/* ── NAVBAR ── */}
      <nav className="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-green-100 px-6 md:px-10 py-3.5 flex items-center justify-between shadow-sm">
        <div className="flex items-center gap-2.5">
          <div className="w-9 h-9 rounded-xl bg-green-700 flex items-center justify-center shadow-sm">
            <svg viewBox="0 0 24 24" fill="white" className="w-5 h-5">
              <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
            </svg>
          </div>
          <span className="text-green-800 font-bold text-lg tracking-tight">
            MedDiagnose
          </span>
        </div>

        <div className="flex items-center gap-4">
          {loading ? (
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-gray-100 animate-pulse" />
              <div className="hidden sm:block space-y-1">
                <div className="w-24 h-3 bg-gray-100 rounded animate-pulse" />
                <div className="w-16 h-2.5 bg-gray-100 rounded animate-pulse" />
              </div>
            </div>
          ) : user ? (
            <div className="flex items-center gap-3">
              <div className="hidden sm:block text-right">
                <p className="text-sm font-semibold text-gray-700 leading-tight">
                  {user.first_name} {user.last_name}
                </p>
                <p className="text-xs text-gray-400 leading-tight">
                  {user.email}
                </p>
              </div>
              <div className="w-9 h-9 rounded-full bg-green-100 border-2 border-green-200 flex items-center justify-center">
                <span className="text-green-700 font-bold text-sm">
                  {initials}
                </span>
              </div>
              <button
                onClick={logout}
                className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-red-500 transition-colors border border-gray-200 rounded-full px-3 py-1.5 hover:border-red-200 hover:bg-red-50"
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
          ) : (
            <button
              onClick={logout}
              className="text-sm text-gray-400 hover:text-red-500 transition-colors"
            >
              Logout
            </button>
          )}
        </div>
      </nav>

      {/* ── HERO GREETING BANNER ── */}
      <div className="bg-gradient-to-r from-green-700 to-green-900 px-6 md:px-10 py-10 relative overflow-hidden">
        {/* decorative cross watermark */}
        <div className="absolute right-8 top-1/2 -translate-y-1/2 opacity-[0.06] pointer-events-none">
          <svg viewBox="0 0 24 24" fill="white" className="w-40 h-40">
            <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
          </svg>
        </div>
        <div className="max-w-5xl mx-auto">
          {user ? (
            <>
              <p className="text-green-300 text-sm font-semibold uppercase tracking-widest mb-1">
                {greeting()},
              </p>
              <h1 className="text-white text-3xl md:text-4xl font-extrabold mb-2">
                {user.first_name} {user.last_name} 👋
              </h1>
              <p className="text-green-200/70 text-sm max-w-md">
                Your AI-powered medical expert system is ready. Select an action
                below to get started.
              </p>
            </>
          ) : (
            <>
              <h1 className="text-white text-3xl font-extrabold mb-2">
                Welcome to MedDiagnose
              </h1>
              <p className="text-green-200/70 text-sm">
                Select an action below to get started.
              </p>
            </>
          )}
        </div>
      </div>

      {/* ── SERVICE BAR ── */}
      <div className="bg-white border-b border-gray-100 shadow-sm">
        <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 divide-x divide-gray-100">
          {serviceItems.map((item) => (
            <div key={item.label} className="flex items-center gap-3 px-5 py-4">
              <div
                className={`w-9 h-9 rounded-xl ${item.bg} flex items-center justify-center flex-shrink-0`}
              >
                {item.icon}
              </div>
              <div className="min-w-0">
                <p className="text-sm font-bold text-gray-700 truncate">
                  {item.label}
                </p>
                <p className="text-xs text-gray-400 truncate">{item.sub}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ── MAIN CONTENT ── */}
      <main className="flex-1 px-4 md:px-10 py-10 max-w-5xl mx-auto w-full">
        <p className="text-xs font-bold uppercase tracking-widest text-gray-400 mb-6">
          What would you like to do?
        </p>

        {/* ── ACTION CARDS ── */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
          {/* General Diagnosis */}
          <button
            onClick={() => router.push("/diagnosis")}
            className="group text-left bg-white rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-blue-200 overflow-hidden"
          >
            <div className="bg-gradient-to-br from-blue-600 to-blue-700 px-7 pt-8 pb-7 relative overflow-hidden">
              {/* watermark */}
              <div className="absolute -bottom-4 -right-4 opacity-10 pointer-events-none">
                <svg viewBox="0 0 24 24" fill="white" className="w-28 h-28">
                  <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
                </svg>
              </div>
              {/* badge */}
              <span className="inline-block bg-white/20 text-white text-xs font-semibold px-3 py-1 rounded-full mb-4 backdrop-blur-sm">
                Prolog-Powered
              </span>
              <div className="w-12 h-12 rounded-2xl bg-white/20 flex items-center justify-center mb-4">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="white"
                  strokeWidth={1.8}
                  className="w-7 h-7"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M9 12h6m-3-3v6M12 21a9 9 0 100-18 9 9 0 000 18z"
                  />
                </svg>
              </div>
              <h3 className="text-white text-xl font-extrabold leading-tight">
                General Diagnosis
              </h3>
              <p className="text-blue-100 text-sm mt-1">
                Identify your condition by symptoms
              </p>
            </div>
            <div className="px-7 py-5">
              <p className="text-gray-500 text-sm leading-relaxed">
                Enter your symptoms, age, and gender — our Prolog expert system
                will suggest the most likely diseases with explanations.
              </p>
              <div className="mt-5 flex items-center gap-2 text-blue-600 font-bold text-sm group-hover:gap-3 transition-all duration-200">
                Start Diagnosis
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2.5}
                  className="w-4 h-4"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
                  />
                </svg>
              </div>
            </div>
          </button>

          {/* Disease Chat */}
          <button
            onClick={() => router.push("/diseases")}
            className="group text-left bg-white rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-green-200 overflow-hidden"
          >
            <div className="bg-gradient-to-br from-green-600 to-green-700 px-7 pt-8 pb-7 relative overflow-hidden">
              <div className="absolute -bottom-4 -right-4 opacity-10 pointer-events-none">
                <svg viewBox="0 0 24 24" fill="white" className="w-28 h-28">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
                  />
                </svg>
              </div>
              <span className="inline-block bg-white/20 text-white text-xs font-semibold px-3 py-1 rounded-full mb-4 backdrop-blur-sm">
                AI-Assisted
              </span>
              <div className="w-12 h-12 rounded-2xl bg-white/20 flex items-center justify-center mb-4">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="white"
                  strokeWidth={1.8}
                  className="w-7 h-7"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
                  />
                </svg>
              </div>
              <h3 className="text-white text-xl font-extrabold leading-tight">
                Disease Chat
              </h3>
              <p className="text-green-100 text-sm mt-1">
                In-depth chat about a specific disease
              </p>
            </div>
            <div className="px-7 py-5">
              <p className="text-gray-500 text-sm leading-relaxed">
                Choose any disease and have a detailed AI conversation about its
                symptoms, causes, treatment options, and prevention.
              </p>
              <div className="mt-5 flex items-center gap-2 text-green-600 font-bold text-sm group-hover:gap-3 transition-all duration-200">
                Pick a Disease
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2.5}
                  className="w-4 h-4"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
                  />
                </svg>
              </div>
            </div>
          </button>
        </div>

        {/* ── QUICK STATS ROW ── */}
        <div className="grid grid-cols-3 gap-4 mb-10">
          {[
            {
              num: "30+",
              label: "Diseases",
              color: "text-green-700",
              bg: "bg-green-50 border-green-100",
            },
            {
              num: "150+",
              label: "Symptoms",
              color: "text-blue-700",
              bg: "bg-blue-50 border-blue-100",
            },
            {
              num: "97%",
              label: "Accuracy",
              color: "text-amber-700",
              bg: "bg-amber-50 border-amber-100",
            },
          ].map((s) => (
            <div
              key={s.label}
              className={`${s.bg} border rounded-2xl py-5 flex flex-col items-center justify-center`}
            >
              <span className={`text-2xl font-extrabold ${s.color}`}>
                {s.num}
              </span>
              <span className="text-xs text-gray-500 font-medium mt-0.5">
                {s.label}
              </span>
            </div>
          ))}
        </div>

        {/* ── QUICK TIPS ── */}
        <div className="bg-white border border-gray-100 rounded-2xl p-6 mb-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-7 h-7 rounded-lg bg-green-100 flex items-center justify-center">
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth={2}
                className="w-4 h-4 text-green-700"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M12 18v-5.25m0 0a6.01 6.01 0 001.5-.189m-1.5.189a6.01 6.01 0 01-1.5-.189m3.75 7.478a12.06 12.06 0 01-4.5 0m3.75 2.383a14.406 14.406 0 01-3 0M14.25 18v-.192c0-.983.658-1.823 1.508-2.316a7.5 7.5 0 10-7.517 0c.85.493 1.509 1.333 1.509 2.316V18"
                />
              </svg>
            </div>
            <h3 className="font-bold text-gray-700 text-sm">
              Tips for better results
            </h3>
          </div>
          <ul className="space-y-3">
            {quickTips.map((tip, i) => (
              <li key={i} className="flex items-start gap-2.5">
                <span className="w-5 h-5 rounded-full bg-green-100 text-green-700 text-xs font-bold flex items-center justify-center flex-shrink-0 mt-0.5">
                  {i + 1}
                </span>
                <p className="text-gray-500 text-sm leading-relaxed">
                  {tip.text}
                </p>
              </li>
            ))}
          </ul>
        </div>

        {/* ── DISCLAIMER ── */}
        <div className="bg-amber-50 border border-amber-200 rounded-2xl px-6 py-4 flex items-start gap-3">
          <div className="w-8 h-8 rounded-xl bg-amber-400 flex items-center justify-center flex-shrink-0 mt-0.5">
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
            <strong>Medical Disclaimer:</strong> This system is for educational
            purposes only and does not constitute medical advice. Always consult
            a qualified healthcare professional for diagnosis, treatment, or any
            medical concern.
          </p>
        </div>
      </main>

      {/* ── FOOTER ── */}
      <footer className="bg-white border-t border-gray-100 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          <div className="w-5 h-5 rounded bg-green-700 flex items-center justify-center">
            <svg viewBox="0 0 24 24" fill="white" className="w-3 h-3">
              <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
            </svg>
          </div>
          <span className="text-xs font-semibold text-gray-500">
            MedDiagnose
          </span>
        </div>
        <p className="text-xs text-gray-400">
          &copy; {new Date().getFullYear()} MedDiagnose Expert System &mdash;
          CSC700 Project
        </p>
      </footer>
    </div>
  );
}
