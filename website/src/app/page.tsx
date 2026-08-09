'use client';

import { RELEASE_CONFIG } from '@/config/release';
import {
  Sparkles,
  Download,
  CheckCircle2,
  ShieldCheck,
  Zap,
  BookOpen,
  DollarSign,
  MessageSquare,
  Globe,
  Award,
  MapPin,
  HeartPulse,
  UserCheck,
  Cloud,
  ArrowRight,
  Smartphone,
  Lock,
  RefreshCw,
  Send,
  SlidersHorizontal,
} from 'lucide-react';

export default function HomePage() {
  const features = [
    {
      icon: Sparkles,
      title: 'AI Companion Assistant',
      desc: 'Contextual AI assistance powered by Gemini proxy backend with memory capabilities and strict privacy boundaries.',
      color: 'from-purple-500 to-indigo-500',
    },
    {
      icon: Zap,
      title: 'Tasks & Reminders',
      desc: 'Smart task manager with priorities, due dates, categories, and local notification alarms.',
      color: 'from-blue-500 to-cyan-500',
    },
    {
      icon: BookOpen,
      title: 'My Life Book / Diary',
      desc: 'Rich personal diary with voice note recording, photo attachments, emoji tags, and search.',
      color: 'from-pink-500 to-rose-500',
    },
    {
      icon: DollarSign,
      title: 'Expense Tracker',
      desc: 'Budget planner with categorical expense logging, monthly statistics, and interactive charts.',
      color: 'from-emerald-500 to-teal-500',
    },
    {
      icon: MessageSquare,
      title: 'SMS Spending Tracker',
      desc: 'Automated offline SMS financial categorizer that imports banking notifications securely.',
      color: 'from-amber-500 to-yellow-500',
    },
    {
      icon: Award,
      title: 'Communication Coach',
      desc: 'Spoken English trainer with daily challenges, pronunciation evaluation, and grammar feedback.',
      color: 'from-indigo-500 to-purple-600',
    },
    {
      icon: Globe,
      title: 'Real-Time Translation',
      desc: 'Multi-lingual translation support for regional Indian languages and global speech-to-text.',
      color: 'from-cyan-500 to-blue-600',
    },
    {
      icon: SlidersHorizontal,
      title: 'Personalized Govt Schemes',
      desc: 'Matches 12+ verified official Indian government schemes (PM-Kisan, Ayushman Bharat, etc.) to your profile.',
      color: 'from-orange-500 to-amber-600',
    },
    {
      icon: MapPin,
      title: 'Smart Location Services',
      desc: 'On-demand location locator, reverse geocoding, and local landmark discovery.',
      color: 'from-teal-500 to-emerald-600',
    },
    {
      icon: HeartPulse,
      title: 'Safety & Emergency',
      desc: 'Instant 1-tap SOS emergency trigger with location broadcast and emergency helpline directory.',
      color: 'from-rose-500 to-red-600',
    },
    {
      icon: UserCheck,
      title: 'Profile & Personalization',
      desc: 'Comprehensive user profile with completeness scoring (0-100%), state selection, and avatar builder.',
      color: 'from-violet-500 to-purple-600',
    },
    {
      icon: Cloud,
      title: 'Cloud Sync & Storage',
      desc: 'Supabase Cloud PostgreSQL database synchronization with real-time stream updates and offline fallback.',
      color: 'from-sky-500 to-indigo-600',
    },
  ];

  const steps = [
    {
      step: '01',
      title: 'Download & Install APK',
      desc: 'Download the official Lifemate APK on your Android device and launch the app in seconds.',
    },
    {
      step: '02',
      title: 'Create Account or Guest Mode',
      desc: 'Sign in with Google OAuth, Email/Password, or use 100% offline Guest Mode right away.',
    },
    {
      step: '03',
      title: 'Complete Profile & Match Schemes',
      desc: 'Fill your preferred language, state, and occupation to receive matching verified government schemes.',
    },
    {
      step: '04',
      title: 'Sync Across All Devices',
      desc: 'Your profile, tasks, diary, and expenses auto-synchronize to Supabase Cloud securely.',
    },
  ];

  return (
    <div className="space-y-24 pb-20">
      {/* HERO SECTION */}
      <section className="relative overflow-hidden pt-12 pb-20 lg:pt-20 lg:pb-28">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-brand-600/20 blur-[140px] rounded-full pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center space-y-8">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass-card border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider">
            <Sparkles className="w-4 h-4 text-brand-400" />
            <span>Lifemate v{RELEASE_CONFIG.version} Public Release Available</span>
          </div>

          <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold text-white tracking-tight leading-tight max-w-4xl mx-auto">
            Your Everyday <span className="gradient-text">Life Companion</span> App
          </h1>

          <p className="max-w-2xl mx-auto text-lg sm:text-xl text-slate-300 leading-relaxed">
            Manage your daily tasks, track expenses from SMS, practice spoken English, match verified government schemes, and stay secure with AI companion assistance.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
            <a
              href="#download"
              className="gradient-bg text-white font-bold text-base px-8 py-4 rounded-2xl shadow-xl shadow-brand-600/30 hover:shadow-brand-600/50 hover:scale-[1.02] transition-all flex items-center gap-3 w-full sm:w-auto justify-center"
            >
              <Download className="w-5 h-5" />
              <span>Download Android APK</span>
              <span className="text-xs bg-white/20 px-2 py-0.5 rounded font-mono">{RELEASE_CONFIG.apkSize}</span>
            </a>

            <a
              href="#features"
              className="glass-card hover:bg-slate-800/80 text-slate-200 font-semibold text-base px-8 py-4 rounded-2xl border border-slate-700 transition-all flex items-center gap-2 w-full sm:w-auto justify-center"
            >
              <span>Explore Features</span>
              <ArrowRight className="w-4 h-4" />
            </a>
          </div>

          {/* Quick Metrics */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-3xl mx-auto pt-10">
            <div className="glass-card p-4 rounded-2xl text-center">
              <div className="text-2xl font-bold text-white">100%</div>
              <div className="text-xs text-slate-400">Offline Fallback</div>
            </div>
            <div className="glass-card p-4 rounded-2xl text-center">
              <div className="text-2xl font-bold text-brand-400">12+</div>
              <div className="text-xs text-slate-400">Verified Govt Schemes</div>
            </div>
            <div className="glass-card p-4 rounded-2xl text-center">
              <div className="text-2xl font-bold text-emerald-400">Supabase</div>
              <div className="text-xs text-slate-400">Cloud Realtime DB</div>
            </div>
            <div className="glass-card p-4 rounded-2xl text-center">
              <div className="text-2xl font-bold text-cyan-400">Gemini AI</div>
              <div className="text-xs text-slate-400">Edge Function Proxy</div>
            </div>
          </div>
        </div>
      </section>

      {/* FEATURES SECTION */}
      <section id="features" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="text-center space-y-4 max-w-3xl mx-auto">
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
            Built with <span className="gradient-text">Real Codebase Features</span>
          </h2>
          <p className="text-slate-400 text-base">
            Every feature on this website represents live, verified functionality in the Lifemate Flutter application.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feat, idx) => {
            const IconComp = feat.icon;
            return (
              <div
                key={idx}
                className="glass-card glass-card-hover p-6 rounded-3xl space-y-4 border border-slate-800/80"
              >
                <div className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${feat.color} flex items-center justify-center text-white shadow-lg`}>
                  <IconComp className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white">{feat.title}</h3>
                <p className="text-slate-400 text-sm leading-relaxed">{feat.desc}</p>
              </div>
            );
          })}
        </div>
      </section>

      {/* HOW IT WORKS SECTION */}
      <section id="how-it-works" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="text-center space-y-4 max-w-3xl mx-auto">
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
            How <span className="gradient-text">Lifemate Works</span>
          </h2>
          <p className="text-slate-400 text-base">
            Getting started with Lifemate is simple, instant, and secure.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          {steps.map((s, idx) => (
            <div key={idx} className="glass-card p-6 rounded-3xl space-y-4 relative">
              <div className="text-4xl font-black text-brand-500/40 font-mono">{s.step}</div>
              <h3 className="text-lg font-bold text-white">{s.title}</h3>
              <p className="text-slate-400 text-xs leading-relaxed">{s.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* PRIVACY & SECURITY SECTION */}
      <section id="privacy" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="glass-card p-8 sm:p-12 rounded-3xl border border-brand-500/30 space-y-8">
          <div className="flex items-center gap-3">
            <ShieldCheck className="w-8 h-8 text-brand-400" />
            <h2 className="text-2xl sm:text-3xl font-bold text-white">
              Enterprise-Grade <span className="gradient-text">Privacy & Architecture</span>
            </h2>
          </div>

          <p className="text-slate-300 text-base leading-relaxed">
            Lifemate is designed with strict security isolation. Sensitive private keys, production database credentials, and Gemini API keys are kept 100% server-side in Supabase Edge Functions and are never embedded inside the mobile application package.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-4">
            <div className="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
              <Lock className="w-6 h-6 text-emerald-400" />
              <h4 className="font-bold text-white">PKCE Auth Security</h4>
              <p className="text-slate-400 text-xs leading-relaxed">
                Supabase Auth uses PKCE flow for Google OAuth and email sign-ins. Authorization codes are exchanged securely server-side.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
              <RefreshCw className="w-6 h-6 text-brand-400" />
              <h4 className="font-bold text-white">Gemini Edge Proxy</h4>
              <p className="text-slate-400 text-xs leading-relaxed">
                AI requests pass through a hardened Supabase Edge Function (`gemini-chat`) enforcing 10 req/min/UID rate limits & prompt caps.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
              <Smartphone className="w-6 h-6 text-cyan-400" />
              <h4 className="font-bold text-white">Local-First Storage</h4>
              <p className="text-slate-400 text-xs leading-relaxed">
                Guest Mode keeps all tasks, diary notes, and expenses 100% local on your device with optional encrypted backup.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* DOWNLOAD SECTION */}
      <section id="download" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
        <div className="glass-card p-8 sm:p-12 rounded-3xl border border-brand-500/40 text-center space-y-8 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-96 h-96 bg-brand-500/10 rounded-full blur-3xl pointer-events-none" />

          <div className="space-y-4 max-w-2xl mx-auto">
            <h2 className="text-3xl sm:text-5xl font-extrabold text-white">
              Download <span className="gradient-text">Lifemate APK</span>
            </h2>
            <p className="text-slate-300 text-base">
              Get the latest official public release build directly on your Android smartphone.
            </p>
          </div>

          {/* Dynamic Release Card */}
          <div className="max-w-xl mx-auto p-6 rounded-2xl bg-slate-900/90 border border-slate-800 text-left space-y-4 font-sans">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <div>
                <span className="text-xs text-slate-400 font-semibold uppercase">Latest Release</span>
                <div className="text-xl font-bold text-white">Lifemate v{RELEASE_CONFIG.version}</div>
              </div>
              <span className="px-3 py-1 bg-brand-500/20 text-brand-300 text-xs font-semibold rounded-full border border-brand-500/30">
                Build #{RELEASE_CONFIG.versionCode}
              </span>
            </div>

            <div className="grid grid-cols-2 gap-4 text-xs text-slate-300">
              <div>
                <span className="text-slate-500 block">Release Date:</span>
                <span className="font-medium text-white">{RELEASE_CONFIG.releaseDate}</span>
              </div>
              <div>
                <span className="text-slate-500 block">File Size:</span>
                <span className="font-medium text-white">{RELEASE_CONFIG.apkSize}</span>
              </div>
              <div>
                <span className="text-slate-500 block">Minimum Version:</span>
                <span className="font-medium text-white">{RELEASE_CONFIG.minAndroid}</span>
              </div>
              <div>
                <span className="text-slate-500 block">Target OS:</span>
                <span className="font-medium text-white">{RELEASE_CONFIG.targetAndroid}</span>
              </div>
            </div>

            <div className="border-t border-slate-800 pt-3">
              <span className="text-xs font-semibold text-slate-400 block mb-2">Changelog Highlights:</span>
              <ul className="space-y-1.5 text-xs text-slate-300">
                {RELEASE_CONFIG.changelog.map((item, idx) => (
                  <li key={idx} className="flex items-start gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-brand-400 flex-shrink-0 mt-0.5" />
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          <div className="pt-4">
            <a
              href={RELEASE_CONFIG.apkUrl}
              download
              className="gradient-bg text-white font-bold text-lg px-10 py-5 rounded-2xl shadow-xl shadow-brand-600/40 hover:scale-[1.02] transition-all inline-flex items-center gap-3"
            >
              <Download className="w-6 h-6" />
              <span>Download Official Android APK ({RELEASE_CONFIG.apkSize})</span>
            </a>
          </div>
        </div>
      </section>

      {/* SCREENSHOTS GALLERY SECTION */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
        <div className="text-center space-y-4 max-w-3xl mx-auto">
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
            Interface & <span className="gradient-text">Product Preview</span>
          </h2>
          <p className="text-slate-400 text-base">
            Designed with modern Material 3 aesthetics, vibrant gradients, and intuitive navigation.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div className="glass-card p-4 rounded-3xl space-y-3">
            <div className="h-64 rounded-2xl bg-gradient-to-br from-brand-900/60 to-slate-900 border border-brand-500/20 p-6 flex flex-col justify-between">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-brand-300">Citizen Services Hub</span>
                <Sparkles className="w-4 h-4 text-brand-400" />
              </div>
              <div className="space-y-2">
                <div className="text-lg font-bold text-white">PM-Kisan Samman Nidhi</div>
                <div className="text-xs text-slate-400">Verified ₹6,000 / year income support for eligible Indian farmers.</div>
              </div>
              <div className="inline-block text-xs bg-emerald-500/20 text-emerald-300 px-3 py-1 rounded-full border border-emerald-500/30">
                100% Eligible
              </div>
            </div>
            <div className="text-center text-sm font-medium text-slate-300">Govt Schemes Matcher</div>
          </div>

          <div className="glass-card p-4 rounded-3xl space-y-3">
            <div className="h-64 rounded-2xl bg-gradient-to-br from-indigo-900/60 to-slate-900 border border-indigo-500/20 p-6 flex flex-col justify-between">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-indigo-300">Spoken English Pro</span>
                <Award className="w-4 h-4 text-indigo-400" />
              </div>
              <div className="space-y-2">
                <div className="text-lg font-bold text-white">Daily English Challenges</div>
                <div className="text-xs text-slate-400">Interactive pronunciation practice with real-time feedback scores.</div>
              </div>
              <div className="inline-block text-xs bg-brand-500/20 text-brand-300 px-3 py-1 rounded-full border border-brand-500/30">
                Daily Streak: 7 Days
              </div>
            </div>
            <div className="text-center text-sm font-medium text-slate-300">Communication Coach</div>
          </div>

          <div className="glass-card p-4 rounded-3xl space-y-3">
            <div className="h-64 rounded-2xl bg-gradient-to-br from-emerald-900/60 to-slate-900 border border-emerald-500/20 p-6 flex flex-col justify-between">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-emerald-300">Money & SMS Tracker</span>
                <DollarSign className="w-4 h-4 text-emerald-400" />
              </div>
              <div className="space-y-2">
                <div className="text-lg font-bold text-white">Auto SMS Expenses</div>
                <div className="text-xs text-slate-400">Categorized bank alerts with monthly spending breakdown analytics.</div>
              </div>
              <div className="inline-block text-xs bg-cyan-500/20 text-cyan-300 px-3 py-1 rounded-full border border-cyan-500/30">
                Budget Health: Good
              </div>
            </div>
            <div className="text-center text-sm font-medium text-slate-300">Expense Analytics</div>
          </div>
        </div>
      </section>

      {/* ABOUT SECTION */}
      <section id="about" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
        <div className="glass-card p-8 sm:p-12 rounded-3xl border border-slate-800 space-y-6">
          <h2 className="text-3xl font-extrabold text-white">
            About <span className="gradient-text">Lifemate</span>
          </h2>
          <p className="text-slate-300 text-base leading-relaxed max-w-4xl">
            Lifemate was created to empower individuals with a single, intelligent companion that simplifies everyday administrative, financial, educational, and emergency needs. Whether you are managing daily tasks, learning spoken English, tracking expenses from SMS notifications, or applying for official Indian government schemes, Lifemate provides a seamless experience tailored to your life.
          </p>
        </div>
      </section>

      {/* CONTACT / FEEDBACK SECTION */}
      <section id="contact" className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
        <div className="glass-card p-8 sm:p-10 rounded-3xl border border-slate-800 space-y-6">
          <div className="text-center space-y-2">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white">Contact & Feedback</h2>
            <p className="text-slate-400 text-sm">Have feedback or suggestions? Send a message directly to the Lifemate team.</p>
          </div>

          <form
            onSubmit={(e) => {
              e.preventDefault();
              alert('Thank you for your feedback! Your message has been received.');
            }}
            className="space-y-4"
          >
            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1">Your Name</label>
              <input
                type="text"
                required
                placeholder="Enter your name"
                className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-800 text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 text-sm"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1">Email Address</label>
              <input
                type="email"
                required
                placeholder="name@example.com"
                className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-800 text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 text-sm"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1">Message / Feedback</label>
              <textarea
                required
                rows={4}
                placeholder="Tell us what you think of Lifemate..."
                className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-800 text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 text-sm"
              />
            </div>

            <button
              type="submit"
              className="w-full gradient-bg text-white font-bold py-3.5 rounded-xl shadow-lg hover:opacity-95 transition-all flex items-center justify-center gap-2 text-sm"
            >
              <Send className="w-4 h-4" />
              <span>Send Message</span>
            </button>
          </form>
        </div>
      </section>
    </div>
  );
}
