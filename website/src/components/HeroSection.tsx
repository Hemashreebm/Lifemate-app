'use client';

import { useState } from 'react';
import { RELEASE_CONFIG } from '@/config/release';
import { Download, ArrowRight, Sparkles, ShieldCheck, Zap, DollarSign, Award, CheckCircle2 } from 'lucide-react';

export default function HeroSection() {
  const [tilt, setTilt] = useState({ x: 0, y: 0 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;
    setTilt({ x: x * 12, y: -y * 12 });
  };

  const handleMouseLeave = () => {
    setTilt({ x: 0, y: 0 });
  };

  return (
    <section className="relative overflow-hidden pt-12 pb-24 lg:pt-20 lg:pb-32">
      {/* Background Dynamic Ambient Glowing Orbs */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] bg-brand-600/15 blur-[160px] rounded-full pointer-events-none animate-pulse-glow" />
      <div className="absolute top-1/3 right-10 w-[450px] h-[450px] bg-indigo-600/15 blur-[140px] rounded-full pointer-events-none" />
      <div className="absolute bottom-10 left-10 w-[500px] h-[500px] bg-emerald-600/10 blur-[150px] rounded-full pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
        {/* Left Text Column */}
        <div className="lg:col-span-7 space-y-8 text-center lg:text-left">
          {/* Pill Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider shadow-lg">
            <Sparkles className="w-4 h-4 text-brand-400 animate-spin-slow" />
            <span>Lifemate v{RELEASE_CONFIG.version} Official Release</span>
            <span className="w-1.5 h-1.5 rounded-full bg-brand-400" />
            <span className="text-slate-400 font-mono text-[11px] lowercase">build {RELEASE_CONFIG.versionCode}</span>
          </div>

          {/* Main Headline & Tagline */}
          <div className="space-y-4">
            <div className="text-sm sm:text-base font-extrabold text-brand-400 uppercase tracking-widest font-mono">
              "Your Life. One Intelligent Companion."
            </div>
            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold text-white tracking-tight leading-[1.1]">
              The Ultimate <span className="gradient-text">Life Companion</span> for Android
            </h1>
          </div>

          <p className="max-w-2xl mx-auto lg:mx-0 text-lg sm:text-xl text-slate-300 leading-relaxed font-normal">
            Simplify daily life with contextual AI assistance, offline SMS financial tracking, spoken English coaching, verified Indian government scheme matching, and real-time cloud data synchronization.
          </p>

          {/* Primary Action CTA Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
            <a
              href={RELEASE_CONFIG.apkUrl}
              download
              className="gradient-bg text-white font-bold text-base px-8 py-4 rounded-2xl shadow-xl shadow-brand-600/30 hover:shadow-brand-600/50 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-3 w-full sm:w-auto"
            >
              <Download className="w-5 h-5" />
              <span>DOWNLOAD LIFEMATE</span>
              <span className="text-xs bg-white/20 px-2 py-0.5 rounded font-mono font-medium">
                {RELEASE_CONFIG.apkSize}
              </span>
            </a>

            <a
              href="#features"
              className="glass-card hover:bg-slate-800/80 text-slate-200 font-semibold text-base px-8 py-4 rounded-2xl border border-slate-700 hover:border-slate-600 transition-all flex items-center justify-center gap-2 w-full sm:w-auto"
            >
              <span>EXPLORE FEATURES</span>
              <ArrowRight className="w-4 h-4 text-brand-400" />
            </a>
          </div>

          {/* Trust Metrics Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 pt-6 max-w-2xl mx-auto lg:mx-0">
            <div className="glass-card p-3.5 rounded-2xl text-center lg:text-left border border-slate-800/80">
              <div className="text-xl font-bold text-white flex items-center justify-center lg:justify-start gap-1">
                <span>100%</span>
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
              </div>
              <div className="text-[11px] text-slate-400 font-medium">Offline Fallback</div>
            </div>

            <div className="glass-card p-3.5 rounded-2xl text-center lg:text-left border border-slate-800/80">
              <div className="text-xl font-bold text-brand-400">12+</div>
              <div className="text-[11px] text-slate-400 font-medium">Govt Schemes</div>
            </div>

            <div className="glass-card p-3.5 rounded-2xl text-center lg:text-left border border-slate-800/80">
              <div className="text-xl font-bold text-emerald-400">Supabase</div>
              <div className="text-[11px] text-slate-400 font-medium">Cloud Database</div>
            </div>

            <div className="glass-card p-3.5 rounded-2xl text-center lg:text-left border border-slate-800/80">
              <div className="text-xl font-bold text-cyan-400">Gemini AI</div>
              <div className="text-[11px] text-slate-400 font-medium">Edge Proxy</div>
            </div>
          </div>
        </div>

        {/* Right 3D Interactive Smartphone & Glass Stack */}
        <div className="lg:col-span-5 perspective-1000 flex justify-center" onMouseMove={handleMouseMove} onMouseLeave={handleMouseLeave}>
          <div
            className="relative w-full max-w-md preserve-3d transition-transform duration-200 ease-out"
            style={{
              transform: `rotateX(${tilt.y}deg) rotateY(${tilt.x}deg)`,
            }}
          >
            {/* Ambient Shadow Box */}
            <div className="absolute -inset-4 bg-gradient-to-r from-brand-600/30 via-indigo-600/30 to-emerald-600/20 rounded-3xl blur-2xl opacity-60 pointer-events-none" />

            {/* Smartphone Frame Container */}
            <div className="relative glass-card p-4 rounded-[40px] border border-slate-700/80 shadow-2xl bg-slate-950/90 overflow-hidden">
              {/* Phone Top Camera Punchhole Notch */}
              <div className="w-24 h-4 bg-slate-900 rounded-full mx-auto mb-4 border border-slate-800 flex items-center justify-center gap-2">
                <div className="w-2 h-2 rounded-full bg-slate-800" />
                <div className="w-1.5 h-1.5 rounded-full bg-blue-500/80" />
              </div>

              {/* Mobile App UI Screen Mockup */}
              <div className="space-y-4 p-4 rounded-3xl bg-slate-900/90 border border-slate-800/90">
                {/* Header Profile Bar */}
                <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl gradient-bg flex items-center justify-center font-bold text-white text-sm shadow">
                      L
                    </div>
                    <div>
                      <div className="text-xs font-bold text-white">Prashanthi Hema</div>
                      <div className="text-[10px] text-emerald-400 font-medium">Profile 100% Complete</div>
                    </div>
                  </div>
                  <span className="text-[10px] bg-brand-500/20 text-brand-300 px-2 py-0.5 rounded-full border border-brand-500/30 font-semibold">
                    Guest Mode Active
                  </span>
                </div>

                {/* AI Assistant Banner Card */}
                <div className="p-3.5 rounded-2xl bg-gradient-to-br from-brand-900/60 to-purple-950/60 border border-brand-500/30 space-y-2">
                  <div className="flex items-center justify-between text-xs text-brand-300 font-semibold">
                    <span className="flex items-center gap-1.5">
                      <Sparkles className="w-3.5 h-3.5 text-brand-400" />
                      Gemini AI Companion
                    </span>
                    <span className="text-[10px] bg-emerald-500/20 text-emerald-300 px-1.5 py-0.5 rounded">Verified Proxy</span>
                  </div>
                  <p className="text-xs text-slate-200 leading-snug">
                    "Recommended: PM-Kisan Samman Nidhi matches your Farmer profile in Karnataka."
                  </p>
                </div>

                {/* Live Stats Row */}
                <div className="grid grid-cols-2 gap-2.5 text-xs">
                  <div className="p-3 rounded-2xl bg-slate-800/60 border border-slate-700/60 space-y-1">
                    <div className="flex items-center justify-between text-slate-400 text-[10px]">
                      <span>Tasks Reminders</span>
                      <Zap className="w-3 h-3 text-amber-400" />
                    </div>
                    <div className="font-bold text-white text-sm">3 Scheduled</div>
                  </div>

                  <div className="p-3 rounded-2xl bg-slate-800/60 border border-slate-700/60 space-y-1">
                    <div className="flex items-center justify-between text-slate-400 text-[10px]">
                      <span>SMS Expenses</span>
                      <DollarSign className="w-3 h-3 text-emerald-400" />
                    </div>
                    <div className="font-bold text-emerald-400 text-sm">₹1,450 Logged</div>
                  </div>
                </div>

                {/* Spoken English Challenge Card */}
                <div className="p-3 rounded-2xl bg-slate-800/60 border border-slate-700/60 flex items-center justify-between">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-xl bg-indigo-500/20 text-indigo-400 flex items-center justify-center">
                      <Award className="w-4 h-4" />
                    </div>
                    <div>
                      <div className="text-xs font-bold text-white">Daily English Coach</div>
                      <div className="text-[10px] text-slate-400">Streak: 7 Days Challenge</div>
                    </div>
                  </div>
                  <span className="text-xs font-bold text-brand-400 font-mono">Score 98%</span>
                </div>
              </div>
            </div>

            {/* Floating Floating Glass Card 1 (Top Left Overhang) */}
            <div className="absolute -top-6 -left-8 glass-panel p-3 rounded-2xl border border-brand-500/40 shadow-xl hidden sm:flex items-center gap-2.5 backdrop-blur-md animate-float">
              <div className="w-8 h-8 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center">
                <ShieldCheck className="w-4 h-4" />
              </div>
              <div className="text-left">
                <div className="text-xs font-bold text-white">PKCE Auth Security</div>
                <div className="text-[10px] text-slate-400">Zero Keys Embedded</div>
              </div>
            </div>

            {/* Floating Glass Card 2 (Bottom Right Overhang) */}
            <div className="absolute -bottom-6 -right-6 glass-panel p-3 rounded-2xl border border-indigo-500/40 shadow-xl hidden sm:flex items-center gap-2.5 backdrop-blur-md animate-float-delayed">
              <div className="w-8 h-8 rounded-xl bg-indigo-500/20 text-indigo-400 flex items-center justify-center">
                <Sparkles className="w-4 h-4" />
              </div>
              <div className="text-left">
                <div className="text-xs font-bold text-white">Supabase Cloud Sync</div>
                <div className="text-[10px] text-emerald-400">PostgreSQL RLS Active</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
