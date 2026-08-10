'use client';

import { Download, UserCheck, SlidersHorizontal, Sparkles, ArrowRight } from 'lucide-react';

export default function HowItWorks() {
  const steps = [
    {
      step: '01',
      icon: Download,
      title: 'Download & Install APK',
      desc: 'Download the official Lifemate Android package directly from the Download Center and install it in seconds.',
      badge: 'Step 1',
      color: 'from-brand-500 to-indigo-500',
    },
    {
      step: '02',
      icon: UserCheck,
      title: 'Sign In or Guest Mode',
      desc: 'Sign in securely with Google OAuth, Email/Password, or start immediately in 100% offline Guest Mode.',
      badge: 'Step 2',
      color: 'from-blue-500 to-cyan-500',
    },
    {
      step: '03',
      icon: SlidersHorizontal,
      title: 'Set Language & Profile',
      desc: 'Choose your preferred language (English, Telugu, Kannada, Hindi, Tamil) and set state, district & occupation for scheme matching.',
      badge: 'Step 3',
      color: 'from-amber-500 to-emerald-500',
    },
    {
      step: '04',
      icon: Sparkles,
      title: 'Start Intelligent Companion',
      desc: 'Access your tasks, SMS expense tracker, spoken English coach, verified government schemes, and AI memory assistant.',
      badge: 'Step 4',
      color: 'from-purple-500 to-pink-500',
    },
  ];

  return (
    <section id="how-it-works" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12 scroll-mt-24">
      {/* Section Header */}
      <div className="text-center space-y-4 max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider">
          <Sparkles className="w-4 h-4 text-brand-400" />
          <span>Simple Onboarding Flow</span>
        </div>
        <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
          How <span className="gradient-text">Lifemate Works</span>
        </h2>
        <p className="text-slate-400 text-base leading-relaxed">
          From installation to personalized scheme matching and AI coaching in 4 intuitive steps.
        </p>
      </div>

      {/* 4-Step Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {steps.map((s, idx) => {
          const IconComp = s.icon;
          return (
            <div
              key={idx}
              className="glass-card glass-card-hover p-6 rounded-3xl space-y-5 border border-slate-800/80 relative flex flex-col justify-between"
            >
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-3xl font-black text-slate-700 font-mono tracking-tighter">{s.step}</span>
                  <span className="text-[10px] font-bold uppercase tracking-wider bg-brand-500/20 text-brand-300 px-2.5 py-1 rounded-full border border-brand-500/30">
                    {s.badge}
                  </span>
                </div>

                <div className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${s.color} flex items-center justify-center text-white shadow-lg`}>
                  <IconComp className="w-6 h-6" />
                </div>

                <h3 className="text-lg font-bold text-white leading-snug">{s.title}</h3>
                <p className="text-slate-400 text-xs leading-relaxed">{s.desc}</p>
              </div>

              {idx < steps.length - 1 && (
                <div className="hidden lg:block absolute -right-3 top-1/2 -translate-y-1/2 text-slate-700 z-10">
                  <ArrowRight className="w-5 h-5" />
                </div>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
