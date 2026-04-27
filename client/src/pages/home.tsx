import { useRouter } from "next/router";
import { useUser } from "@/hooks/useUser";

export default function HomePage() {
  const router = useRouter();
  const { user, loading, logout } = useUser();

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Navbar */}
      <nav className="bg-white shadow-sm px-8 py-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-full bg-green-600 flex items-center justify-center">
            <svg viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5 text-white">
              <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
            </svg>
          </div>
          <span className="text-green-700 font-bold text-lg">MedDiagnose</span>
        </div>
        <div className="flex items-center gap-4">
          {loading ? (
            <div className="w-24 h-4 bg-gray-100 rounded animate-pulse" />
          ) : user ? (
            <div className="flex items-center gap-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                  <span className="text-green-700 font-bold text-sm">
                    {user.first_name[0]}{user.last_name[0]}
                  </span>
                </div>
                <div className="hidden sm:block text-right">
                  <p className="text-sm font-semibold text-gray-700 leading-tight">{user.first_name} {user.last_name}</p>
                  <p className="text-xs text-gray-400 leading-tight">{user.email}</p>
                </div>
              </div>
              <button
                onClick={logout}
                className="text-sm text-gray-400 hover:text-red-500 transition-colors"
              >
                Logout
              </button>
            </div>
          ) : (
            <button
              onClick={logout}
              className="text-sm text-gray-500 hover:text-red-500 transition-colors"
            >
              Logout
            </button>
          )}
        </div>
      </nav>

      {/* Service bar */}
      <div className="bg-white border-b border-gray-100">
        <div className="max-w-6xl mx-auto flex items-stretch divide-x divide-gray-100 overflow-x-auto">
          {[
            { icon: "🩺", label: "Expert Diagnosis", sub: "Prolog-powered engine", color: "text-green-600" },
            { icon: "💬", label: "Disease Chat", sub: "AI-assisted Q&A", color: "text-blue-600" },
            { icon: "🦠", label: "30+ Diseases", sub: "Tropical & chronic", color: "text-yellow-600" },
            { icon: "⚡", label: "Instant Results", sub: "Real-time analysis", color: "text-green-600" },
          ].map((item) => (
            <div key={item.label} className="flex items-center gap-3 px-6 py-3.5 flex-1 min-w-[160px]">
              <span className="text-xl">{item.icon}</span>
              <div>
                <p className={`text-sm font-bold ${item.color}`}>{item.label}</p>
                <p className="text-xs text-gray-400">{item.sub}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <main className="flex-1 px-4 md:px-10 py-10 max-w-6xl mx-auto w-full">
        {user && (
          <p className="text-gray-700 font-semibold text-lg mb-1">
            Welcome back, <span className="text-green-600">{user.first_name}</span> 👋
          </p>
        )}
        <h2 className="text-gray-500 font-semibold text-xs uppercase tracking-wider mb-5">What would you like to do?</h2>

        {/* Action cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
          {/* General Diagnosis */}
          <button
            onClick={() => router.push("/diagnosis")}
            className="group text-left bg-white rounded-2xl shadow-md hover:shadow-xl transition-all duration-300 border border-transparent hover:border-blue-200 overflow-hidden"
          >
            <div className="bg-blue-600 px-6 pt-8 pb-6 relative">
              <div className="w-14 h-14 rounded-2xl bg-white/20 flex items-center justify-center mb-4">
                <svg viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth={1.8} className="w-8 h-8">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6m-3-3v6M12 21a9 9 0 100-18 9 9 0 000 18z" />
                </svg>
              </div>
              <h3 className="text-white text-xl font-bold">General Diagnosis</h3>
              <p className="text-blue-100 text-sm mt-1">Identify your condition by symptoms</p>
              <div className="absolute top-4 right-4 opacity-10">
                <svg viewBox="0 0 24 24" fill="white" className="w-20 h-20">
                  <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
                </svg>
              </div>
            </div>
            <div className="px-6 py-5">
              <p className="text-gray-500 text-sm leading-relaxed">
                Enter your symptoms, age, and gender — our Prolog-based expert system will suggest possible diseases.
              </p>
              <div className="mt-4 flex items-center gap-2 text-blue-600 font-semibold text-sm group-hover:gap-3 transition-all">
                Start Diagnosis
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                </svg>
              </div>
            </div>
          </button>

          {/* Disease Chat */}
          <button
            onClick={() => router.push("/diseases")}
            className="group text-left bg-white rounded-2xl shadow-md hover:shadow-xl transition-all duration-300 border border-transparent hover:border-green-200 overflow-hidden"
          >
            <div className="bg-green-600 px-6 pt-8 pb-6 relative">
              <div className="w-14 h-14 rounded-2xl bg-white/20 flex items-center justify-center mb-4">
                <svg viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth={1.8} className="w-8 h-8">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
                </svg>
              </div>
              <h3 className="text-white text-xl font-bold">Disease Chat</h3>
              <p className="text-green-100 text-sm mt-1">In-depth chat about a specific disease</p>
              <div className="absolute top-4 right-4 opacity-10">
                <svg viewBox="0 0 24 24" fill="white" className="w-20 h-20">
                  <path d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
                </svg>
              </div>
            </div>
            <div className="px-6 py-5">
              <p className="text-gray-500 text-sm leading-relaxed">
                Choose a disease and chat with our AI assistant to learn about symptoms, causes, treatment, and prevention.
              </p>
              <div className="mt-4 flex items-center gap-2 text-green-600 font-semibold text-sm group-hover:gap-3 transition-all">
                Pick a Disease
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                </svg>
              </div>
            </div>
          </button>
        </div>

        {/* Disclaimer */}
        <div className="bg-yellow-50 border border-yellow-200 rounded-2xl px-6 py-4 flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-yellow-400 flex items-center justify-center flex-shrink-0 mt-0.5">
            <svg viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth={2} className="w-4 h-4">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
            </svg>
          </div>
          <p className="text-yellow-700 text-sm leading-relaxed">
            <strong>Disclaimer:</strong> This system is for educational purposes only. Always consult a qualified healthcare professional for medical advice, diagnosis, or treatment.
          </p>
        </div>
      </main>

      <footer className="text-center py-4 text-gray-400 text-xs border-t border-gray-100">
        &copy; {new Date().getFullYear()} MedDiagnose Expert System
      </footer>
    </div>
  );
}
