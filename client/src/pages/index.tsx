import Link from "next/link";

const stats = [
  { num: "30+", label: "Diseases Covered" },
  { num: "150+", label: "Symptoms Tracked" },
  { num: "97%", label: "Diagnosis Accuracy" },
  { num: "Free", label: "No Credit Card Needed" },
];

const steps = [
  {
    num: "01",
    title: "Create Your Profile",
    desc: "Sign up and set your basic health profile — age, sex, and any pre-existing conditions for better context.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-green-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
        />
      </svg>
    ),
  },
  {
    num: "02",
    title: "Select Symptoms",
    desc: "Choose from 150+ symptoms using our intuitive symptom picker. Add severity levels and duration for precision.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-green-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
        />
      </svg>
    ),
  },
  {
    num: "03",
    title: "Get Your Diagnosis",
    desc: "Our Prolog engine processes your input and returns the most likely diagnoses with confidence scores and next steps.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-green-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
    ),
  },
];

const features = [
  {
    color: "bg-green-100",
    textColor: "text-green-700",
    borderColor: "border-t-green-500",
    title: "General Diagnosis",
    desc: "Select symptoms and let the Prolog knowledge base infer matching conditions ranked by likelihood.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-green-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M9 12h6m-3-3v6M5.25 12a6.75 6.75 0 1113.5 0 6.75 6.75 0 01-13.5 0z"
        />
      </svg>
    ),
  },
  {
    color: "bg-blue-100",
    textColor: "text-blue-700",
    borderColor: "border-t-blue-500",
    title: "Disease Chat",
    desc: "Ask in-depth questions about any specific disease — causes, treatment options, prevention and outlook.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-blue-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
        />
      </svg>
    ),
  },
  {
    color: "bg-yellow-100",
    textColor: "text-yellow-700",
    borderColor: "border-t-yellow-500",
    title: "Risk Alerts",
    desc: "Receive urgent flags when your symptom combination suggests a serious or time-sensitive condition.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-yellow-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
        />
      </svg>
    ),
  },
  {
    color: "bg-rose-100",
    textColor: "text-rose-700",
    borderColor: "border-t-rose-500",
    title: "Diagnosis History",
    desc: "Every session is saved to your profile so you can track changes in your symptoms over time.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-rose-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25z"
        />
      </svg>
    ),
  },
  {
    color: "bg-purple-100",
    textColor: "text-purple-700",
    borderColor: "border-t-purple-500",
    title: "Prolog Engine",
    desc: "Powered by a formal Prolog knowledge base — transparent, auditable rule-based reasoning unlike a black-box AI.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-purple-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5"
        />
      </svg>
    ),
  },
  {
    color: "bg-teal-100",
    textColor: "text-teal-700",
    borderColor: "border-t-teal-500",
    title: "PDF Reports",
    desc: "Export a clean, shareable diagnosis report to show your doctor or save for your own health records.",
    icon: (
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={1.8}
        className="w-6 h-6 text-teal-700"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M10.5 1.5H8.25A2.25 2.25 0 006 3.75v16.5a2.25 2.25 0 002.25 2.25h7.5A2.25 2.25 0 0018 20.25V3.75a2.25 2.25 0 00-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 8.25h3m-3 3.75h3m-3 3.75h3"
        />
      </svg>
    ),
  },
];

const diseases = [
  {
    label: "Malaria",
    style: "bg-amber-900/40 border-amber-700 text-amber-300",
  },
  {
    label: "Tuberculosis",
    style: "bg-teal-900/40 border-teal-700 text-teal-300",
  },
  {
    label: "HIV / AIDS",
    style: "bg-rose-900/40 border-rose-700 text-rose-300",
  },
  { label: "Diabetes", style: "bg-blue-900/40 border-blue-700 text-blue-300" },
  {
    label: "Hypertension",
    style: "bg-green-900/40 border-green-700 text-green-300",
  },
  {
    label: "Typhoid Fever",
    style: "bg-amber-900/40 border-amber-700 text-amber-300",
  },
  { label: "Cholera", style: "bg-teal-900/40 border-teal-700 text-teal-300" },
  {
    label: "Hepatitis B",
    style: "bg-rose-900/40 border-rose-700 text-rose-300",
  },
  { label: "Pneumonia", style: "bg-blue-900/40 border-blue-700 text-blue-300" },
  { label: "Asthma", style: "bg-green-900/40 border-green-700 text-green-300" },
  {
    label: "Dengue Fever",
    style: "bg-amber-900/40 border-amber-700 text-amber-300",
  },
  {
    label: "Meningitis",
    style: "bg-teal-900/40 border-teal-700 text-teal-300",
  },
  {
    label: "Sickle Cell Disease",
    style: "bg-rose-900/40 border-rose-700 text-rose-300",
  },
  {
    label: "Yellow Fever",
    style: "bg-blue-900/40 border-blue-700 text-blue-300",
  },
  {
    label: "COVID-19",
    style: "bg-green-900/40 border-green-700 text-green-300",
  },
  {
    label: "Measles",
    style: "bg-amber-900/40 border-amber-700 text-amber-300",
  },
  {
    label: "Lassa Fever",
    style: "bg-rose-900/40 border-rose-700 text-rose-300",
  },
  { label: "Stroke", style: "bg-blue-900/40 border-blue-700 text-blue-300" },
  { label: "Anemia", style: "bg-teal-900/40 border-teal-700 text-teal-300" },
  {
    label: "And many more…",
    style: "bg-green-900/40 border-green-700 text-green-300",
  },
];

const testimonials = [
  {
    initials: "AO",
    avatarColor: "bg-green-100 text-green-700",
    name: "Adaeze Okonkwo",
    role: "Computer Science Student",
    stars: 5,
    text: "This tool made it so much easier to understand which diseases map to which symptoms. Our CSC700 group used it to validate our Prolog rules — incredible.",
  },
  {
    initials: "DR",
    avatarColor: "bg-blue-100 text-blue-700",
    name: "Dr. Remi Adeyemi",
    role: "General Practitioner, Lagos",
    stars: 5,
    text: "The disease chat feature is brilliant for patient education. I recommend it to final-year medical students as a self-study tool before clinical rotations.",
  },
  {
    initials: "KM",
    avatarColor: "bg-amber-100 text-amber-700",
    name: "Kemi Mahmoud",
    role: "Public Health Researcher",
    stars: 4,
    text: "Finally a diagnosis tool that's transparent about how it reaches conclusions. The Prolog-based logic makes it far more trustworthy than a generic AI chatbot.",
  },
];

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#f7faf4] text-[#1a2e14] font-sans">
      {/* ── NAVBAR ── */}
      <nav className="sticky top-0 z-50 flex items-center justify-between px-8 py-4 bg-white/90 backdrop-blur-md border-b border-green-100 shadow-sm">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-xl bg-green-700 flex items-center justify-center shadow">
            <svg viewBox="0 0 24 24" fill="white" className="w-5 h-5">
              <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
            </svg>
          </div>
          <span className="text-green-800 font-bold text-lg tracking-tight">
            MedDiagnose
          </span>
        </div>
        <div className="flex gap-3">
          <Link
            href="/login"
            className="px-5 py-2 rounded-full border border-green-700 text-green-700 text-sm font-medium hover:bg-green-50 transition-colors"
          >
            Login
          </Link>
          <Link
            href="/signup"
            className="px-5 py-2 rounded-full bg-green-700 text-white text-sm font-medium hover:bg-green-800 transition-colors shadow"
          >
            Sign Up Free
          </Link>
        </div>
      </nav>

      {/* ── HERO ── */}
      <section className="relative flex flex-col items-center text-center px-6 pt-20 pb-16 overflow-hidden">
        {/* subtle radial glow */}
        <div className="absolute -top-32 left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full bg-green-200/40 blur-3xl pointer-events-none" />

        {/* live badge */}

        <h1 className="relative text-5xl md:text-6xl font-extrabold text-gray-900 leading-tight max-w-3xl mb-5">
          Diagnose Smarter with{" "}
          <span className="italic text-green-700">Prolog-Based</span>{" "}
          Intelligence
        </h1>

        <p className="relative text-gray-500 text-lg max-w-xl mb-10 leading-relaxed">
          Enter your symptoms and receive evidence-based disease diagnosis in
          seconds — powered by a structured medical knowledge base covering 30+
          conditions.
        </p>

        <div className="relative flex flex-col sm:flex-row gap-4 mb-14">
          <Link
            href="/signup"
            className="px-8 py-3.5 rounded-full bg-green-700 text-white font-semibold text-base hover:bg-green-800 transition-colors shadow-lg shadow-green-200"
          >
            Start Free Diagnosis
          </Link>
          <Link
            href="/login"
            className="px-8 py-3.5 rounded-full border-2 border-green-700 text-green-700 font-semibold text-base hover:bg-green-50 transition-colors bg-white"
          >
            Login to Account
          </Link>
        </div>

        {/* Stats bar */}
        <div className="relative w-full max-w-2xl grid grid-cols-2 md:grid-cols-4 bg-white rounded-2xl border border-green-100 shadow-md overflow-hidden">
          {stats.map((s, i) => (
            <div
              key={i}
              className={`flex flex-col items-center py-5 px-4 ${i < stats.length - 1 ? "border-r border-green-100" : ""}`}
            >
              <span className="text-3xl font-extrabold text-green-700 leading-none mb-1">
                {s.num}
              </span>
              <span className="text-xs text-gray-500 font-medium text-center">
                {s.label}
              </span>
            </div>
          ))}
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section className="max-w-5xl mx-auto px-6 py-20">
        <p className="text-center text-xs font-bold uppercase tracking-widest text-green-700 mb-2">
          How it works
        </p>
        <h2 className="text-center text-4xl font-extrabold text-gray-900 mb-3">
          Three steps to your diagnosis
        </h2>
        <p className="text-center text-gray-500 max-w-lg mx-auto mb-12 leading-relaxed">
          Our expert system walks you through a structured process to identify
          your condition accurately.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {steps.map((step) => (
            <div
              key={step.num}
              className="bg-white rounded-2xl border border-green-100 p-7 shadow-sm hover:shadow-md transition-shadow"
            >
              <span className="text-5xl font-extrabold text-green-100 leading-none block mb-3">
                {step.num}
              </span>
              <div className="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center mb-4">
                {step.icon}
              </div>
              <h3 className="font-bold text-gray-800 text-lg mb-2">
                {step.title}
              </h3>
              <p className="text-gray-500 text-sm leading-relaxed">
                {step.desc}
              </p>
            </div>
          ))}
        </div>
      </section>

      <div className="max-w-5xl mx-auto px-6">
        <hr className="border-green-100" />
      </div>

      {/* ── FEATURES ── */}
      <section className="max-w-5xl mx-auto px-6 py-20">
        <p className="text-center text-xs font-bold uppercase tracking-widest text-green-700 mb-2">
          Features
        </p>
        <h2 className="text-center text-4xl font-extrabold text-gray-900 mb-3">
          Everything you need to understand your health
        </h2>
        <p className="text-center text-gray-500 max-w-lg mx-auto mb-12 leading-relaxed">
          Built for students, clinicians, and patients who want clarity — not
          just a list of possibilities.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {features.map((f) => (
            <div
              key={f.title}
              className={`bg-white rounded-2xl p-6 shadow-sm border-t-4 ${f.borderColor} hover:shadow-md hover:-translate-y-1 transition-all duration-200`}
            >
              <div
                className={`w-11 h-11 rounded-xl ${f.color} flex items-center justify-center mb-4`}
              >
                {f.icon}
              </div>
              <h3 className="font-bold text-gray-800 text-base mb-2">
                {f.title}
              </h3>
              <p className="text-gray-500 text-sm leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── DISEASE COVERAGE ── */}
      <section className="bg-[#1a2e14] py-20 px-6">
        <div className="max-w-4xl mx-auto text-center">
          <p className="text-xs font-bold uppercase tracking-widest text-green-400 mb-2">
            Disease Coverage
          </p>
          <h2 className="text-4xl font-extrabold text-white mb-3">
            30+ conditions in our knowledge base
          </h2>
          <p className="text-green-300/70 max-w-lg mx-auto mb-10 leading-relaxed">
            From common tropical diseases to chronic conditions — we cover
            Africa&apos;s most prevalent health challenges.
          </p>
          <div className="flex flex-wrap gap-3 justify-center">
            {diseases.map((d) => (
              <span
                key={d.label}
                className={`px-4 py-2 rounded-full border text-sm font-medium ${d.style} hover:scale-105 transition-transform cursor-default`}
              >
                {d.label}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* ── TESTIMONIALS ── */}
      <section className="max-w-5xl mx-auto px-6 py-20">
        <p className="text-center text-xs font-bold uppercase tracking-widest text-green-700 mb-2">
          Testimonials
        </p>
        <h2 className="text-center text-4xl font-extrabold text-gray-900 mb-3">
          Trusted by students &amp; clinicians
        </h2>
        <p className="text-center text-gray-500 max-w-lg mx-auto mb-12 leading-relaxed">
          Hear from the people who use MedDiagnose every day.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {testimonials.map((t) => (
            <div
              key={t.name}
              className="bg-white rounded-2xl border border-green-100 p-6 shadow-sm"
            >
              <div className="text-yellow-400 text-sm tracking-widest mb-3">
                {"★".repeat(t.stars)}
                {"☆".repeat(5 - t.stars)}
              </div>
              <p className="text-gray-600 text-sm leading-relaxed italic mb-5">
                &ldquo;{t.text}&rdquo;
              </p>
              <div className="flex items-center gap-3">
                <div
                  className={`w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold ${t.avatarColor}`}
                >
                  {t.initials}
                </div>
                <div>
                  <p className="text-sm font-semibold text-gray-800">
                    {t.name}
                  </p>
                  <p className="text-xs text-gray-400">{t.role}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* ── CTA BANNER ── */}
      <section className="max-w-5xl mx-auto px-6 pb-20">
        <div className="bg-gradient-to-br from-green-700 to-green-900 rounded-3xl p-12 text-center shadow-xl">
          <h2 className="text-4xl font-extrabold text-white mb-3">
            Start your diagnosis today — it&apos;s free
          </h2>
          <p className="text-green-300 mb-8 text-lg">
            No credit card. No downloads. Just create an account and start
            checking your symptoms in under 2 minutes.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/signup"
              className="px-8 py-3.5 rounded-full bg-white text-green-800 font-bold text-base hover:bg-green-50 transition-colors shadow"
            >
              Create Free Account
            </Link>
            <Link
              href="#how-it-works"
              className="px-8 py-3.5 rounded-full border-2 border-white/50 text-white font-bold text-base hover:bg-white/10 transition-colors"
            >
              Learn How It Works
            </Link>
          </div>
        </div>
      </section>

      {/* ── FOOTER ── */}
      <footer className="bg-[#111e0b] px-8 pt-14 pb-6">
        <div className="max-w-5xl mx-auto">
          <div className="flex flex-col md:flex-row justify-between gap-10 mb-10">
            {/* Brand */}
            <div className="max-w-xs">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-8 h-8 rounded-lg bg-green-700 flex items-center justify-center">
                  <svg viewBox="0 0 24 24" fill="white" className="w-4 h-4">
                    <path d="M10 3H14V10H21V14H14V21H10V14H3V10H10V3Z" />
                  </svg>
                </div>
                <span className="text-green-400 font-bold text-lg">
                  MedDiagnose
                </span>
              </div>
              <p className="text-green-900 text-sm leading-relaxed">
                An intelligent expert system for medical symptom analysis. Built
                as part of the CSC700 course project.
              </p>
            </div>

            {/* Links */}
            <div className="flex gap-16 flex-wrap">
              <div>
                <h5 className="text-green-500 text-xs font-bold uppercase tracking-widest mb-4">
                  Product
                </h5>
                {[
                  "Diagnosis Tool",
                  "Disease Chat",
                  "Disease Library",
                  "PDF Reports",
                ].map((l) => (
                  <Link
                    key={l}
                    href="#"
                    className="block text-green-900 hover:text-green-400 text-sm mb-2 transition-colors"
                  >
                    {l}
                  </Link>
                ))}
              </div>
              <div>
                <h5 className="text-green-500 text-xs font-bold uppercase tracking-widest mb-4">
                  Company
                </h5>
                {["About", "CSC700 Project", "Contact"].map((l) => (
                  <Link
                    key={l}
                    href="#"
                    className="block text-green-900 hover:text-green-400 text-sm mb-2 transition-colors"
                  >
                    {l}
                  </Link>
                ))}
              </div>
              <div>
                <h5 className="text-green-500 text-xs font-bold uppercase tracking-widest mb-4">
                  Legal
                </h5>
                {["Disclaimer", "Privacy Policy"].map((l) => (
                  <Link
                    key={l}
                    href="#"
                    className="block text-green-900 hover:text-green-400 text-sm mb-2 transition-colors"
                  >
                    {l}
                  </Link>
                ))}
              </div>
            </div>
          </div>

          <div className="border-t border-green-900/60 pt-6 text-center text-green-900 text-xs">
            &copy; {new Date().getFullYear()} MedDiagnose Expert System &mdash;
            CSC700 Project &nbsp;&middot;&nbsp; Not a substitute for
            professional medical advice.
          </div>
        </div>
      </footer>
    </div>
  );
}
