import Link from "next/link";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-blue-50 flex flex-col">
      {/* Navbar */}
      <nav className="flex items-center justify-between px-8 py-4 bg-white shadow-sm">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-full bg-green-600 flex items-center justify-center">
            <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-white" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
            </svg>
          </div>
          <span className="text-green-700 font-bold text-lg tracking-tight">MedDiagnose</span>
        </div>
        <div className="flex gap-3">
          <Link href="/login" className="px-5 py-2 rounded-full border border-green-600 text-green-700 text-sm font-medium hover:bg-green-50 transition-colors">
            Login
          </Link>
          <Link href="/signup" className="px-5 py-2 rounded-full bg-green-600 text-white text-sm font-medium hover:bg-green-700 transition-colors">
            Sign Up
          </Link>
        </div>
      </nav>

      {/* Hero */}
      <main className="flex-1 flex flex-col items-center justify-center px-6 text-center py-20">
        {/* Medical cross icon */}
        <div className="w-24 h-24 rounded-2xl bg-green-600 flex items-center justify-center mb-8 shadow-lg">
          <svg viewBox="0 0 24 24" fill="currentColor" className="w-14 h-14 text-white">
            <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
          </svg>
        </div>

        <p className="text-green-600 font-semibold text-sm uppercase tracking-widest mb-3">
          Welcome to
        </p>
        <h1 className="text-4xl md:text-6xl font-extrabold text-gray-800 leading-tight max-w-3xl mb-6">
          Medical Diagnosis{" "}
          <span className="text-green-600">Expert System</span>
        </h1>
        <p className="text-gray-500 text-lg max-w-xl mb-10 leading-relaxed">
          An intelligent, Prolog-powered system that helps identify diseases
          based on your symptoms and provides in-depth disease-specific guidance.
        </p>

        <div className="flex flex-col sm:flex-row gap-4">
          <Link href="/signup" className="px-8 py-3 rounded-full bg-green-600 text-white font-semibold text-base hover:bg-green-700 transition-colors shadow-md">
            Get Started Free
          </Link>
          <Link href="/login" className="px-8 py-3 rounded-full border-2 border-blue-600 text-blue-700 font-semibold text-base hover:bg-blue-50 transition-colors">
            Login to Account
          </Link>
        </div>

        {/* Feature cards */}
        <div className="mt-20 grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl w-full">
          <div className="bg-white rounded-2xl p-6 shadow-md border-t-4 border-green-500 text-left">
            <div className="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center mb-3">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-6 h-6 text-green-600">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6m-3-3v6M5.25 12a6.75 6.75 0 1113.5 0 6.75 6.75 0 01-13.5 0z" />
              </svg>
            </div>
            <h3 className="font-bold text-gray-800 mb-1">General Diagnosis</h3>
            <p className="text-gray-500 text-sm">Select your symptoms and get an expert diagnosis from our Prolog knowledge base.</p>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-md border-t-4 border-blue-500 text-left">
            <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center mb-3">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-6 h-6 text-blue-600">
                <path strokeLinecap="round" strokeLinejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
              </svg>
            </div>
            <h3 className="font-bold text-gray-800 mb-1">Disease Chat</h3>
            <p className="text-gray-500 text-sm">Have an in-depth conversation about any specific disease with our AI assistant.</p>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-md border-t-4 border-yellow-500 text-left">
            <div className="w-10 h-10 rounded-lg bg-yellow-100 flex items-center justify-center mb-3">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-6 h-6 text-yellow-600">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
              </svg>
            </div>
            <h3 className="font-bold text-gray-800 mb-1">30+ Diseases</h3>
            <p className="text-gray-500 text-sm">Covers malaria, tuberculosis, HIV/AIDS, diabetes, hypertension and many more.</p>
          </div>
        </div>
      </main>

      <footer className="text-center py-6 text-gray-400 text-sm">
        &copy; {new Date().getFullYear()} MedDiagnose Expert System &mdash; CSC700 Project
      </footer>
    </div>
  );
}
