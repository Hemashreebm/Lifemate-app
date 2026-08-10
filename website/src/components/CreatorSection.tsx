'use client';

import { Github, Code2, GraduationCap, Cpu, Rocket, Sparkles, Mail, ExternalLink } from 'lucide-react';

export default function CreatorSection() {
  return (
    <section id="creator" className="py-24 relative overflow-hidden bg-slate-950/60">
      {/* Ambient background glows */}
      <div className="absolute top-1/3 left-1/4 w-96 h-96 bg-brand-600/10 rounded-full blur-3xl pointer-events-none animate-pulse-glow" />
      <div className="absolute bottom-1/3 right-1/4 w-96 h-96 bg-violet-600/10 rounded-full blur-3xl pointer-events-none animate-pulse-glow" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/20 text-brand-300 text-xs font-semibold uppercase tracking-wider mb-4">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Meet the Developer</span>
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white tracking-tight">
            About the <span className="gradient-text">Creator</span>
          </h2>
          <p className="mt-4 text-slate-400 text-base sm:text-lg">
            The story and vision behind Lifemate — built independently to bring practical AI, organization, and accessible tools to everyday life.
          </p>
        </div>

        {/* Creator Main Card */}
        <div className="glass-card rounded-3xl p-8 lg:p-12 border border-slate-800/80 shadow-2xl relative overflow-hidden max-w-5xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
            {/* Creator 3D Avatar Area */}
            <div className="lg:col-span-4 flex flex-col items-center text-center">
              <div className="relative group">
                <div className="absolute -inset-1 rounded-3xl gradient-bg blur-lg opacity-70 group-hover:opacity-100 transition-opacity" />
                <div className="relative w-40 h-40 sm:w-48 sm:h-48 rounded-3xl bg-slate-900 border-2 border-brand-400/40 flex flex-col items-center justify-center shadow-2xl overflow-hidden">
                  <div className="w-24 h-24 rounded-2xl gradient-bg flex items-center justify-center text-white font-black text-4xl shadow-xl border border-white/20">
                    HB
                  </div>
                  <span className="text-[11px] font-semibold text-brand-300 tracking-wider uppercase mt-3">
                    Lifemate Lead Architect
                  </span>
                </div>
              </div>

              <h3 className="mt-6 text-2xl font-bold text-white tracking-tight">Hemashree B M</h3>
              <p className="text-xs font-semibold text-brand-400 uppercase tracking-wider mt-1">
                Creator & Developer — Lifemate
              </p>

              {/* Action Buttons */}
              <div className="flex items-center gap-3 mt-6">
                <a
                  href="https://github.com/Hemashreebm"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-800 hover:border-brand-500/50 text-slate-300 hover:text-white text-xs font-semibold flex items-center gap-2 transition-all shadow-md hover:scale-105"
                >
                  <Github className="w-4 h-4 text-brand-400" />
                  <span>GitHub Profile</span>
                </a>
                <a
                  href="https://github.com/Hemashreebm/Lifemate-app"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-4 py-2.5 rounded-xl gradient-bg text-white text-xs font-bold flex items-center gap-2 shadow-lg shadow-brand-600/20 hover:scale-105 transition-all"
                >
                  <Code2 className="w-4 h-4" />
                  <span>Repository</span>
                </a>
              </div>
            </div>

            {/* Creator Story & Details */}
            <div className="lg:col-span-8 space-y-6">
              <blockquote className="text-slate-200 text-lg sm:text-xl font-medium italic border-l-4 border-brand-500 pl-4 py-1">
                &ldquo;Building practical technology that connects engineering, AI, and everyday life.&rdquo;
              </blockquote>

              <p className="text-slate-300 text-sm sm:text-base leading-relaxed">
                <strong className="text-white">Hemashree B M</strong> is a B.Tech Electronics & Communication Engineering student at Alliance University with a passion for embedded systems, intelligent technology, IoT, automation, and sustainable engineering solutions.
              </p>

              <div className="space-y-3">
                <h4 className="text-sm font-bold text-white uppercase tracking-wider text-brand-400">
                  Why I Built Lifemate
                </h4>
                <p className="text-slate-400 text-sm leading-relaxed">
                  Lifemate was created with the goal of bringing everyday planning, personal memories, expense tracking, spoken communication, AI assistance, safety features, and useful government services together into one accessible mobile companion.
                </p>
                <p className="text-slate-400 text-sm leading-relaxed">
                  By combining engineering fundamentals with modern mobile software and AI, Lifemate provides users with a private, responsive, voice-first companion designed for real daily impact.
                </p>
              </div>

              {/* 3 Highlight Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
                <div className="p-4 rounded-2xl bg-slate-900/80 border border-slate-800">
                  <div className="w-8 h-8 rounded-lg bg-brand-500/10 border border-brand-500/20 flex items-center justify-center text-brand-400 mb-2">
                    <GraduationCap className="w-4 h-4" />
                  </div>
                  <h5 className="text-xs font-bold text-white uppercase tracking-wider">Engineering</h5>
                  <p className="text-[11px] text-slate-400 mt-1 leading-snug">
                    B.Tech ECE — Alliance University
                  </p>
                </div>

                <div className="p-4 rounded-2xl bg-slate-900/80 border border-slate-800">
                  <div className="w-8 h-8 rounded-lg bg-violet-500/10 border border-violet-500/20 flex items-center justify-center text-violet-400 mb-2">
                    <Cpu className="w-4 h-4" />
                  </div>
                  <h5 className="text-xs font-bold text-white uppercase tracking-wider">Technology</h5>
                  <p className="text-[11px] text-slate-400 mt-1 leading-snug">
                    Embedded Systems • IoT • AI • Flutter
                  </p>
                </div>

                <div className="p-4 rounded-2xl bg-slate-900/80 border border-slate-800">
                  <div className="w-8 h-8 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400 mb-2">
                    <Rocket className="w-4 h-4" />
                  </div>
                  <h5 className="text-xs font-bold text-white uppercase tracking-wider">Building</h5>
                  <p className="text-[11px] text-slate-400 mt-1 leading-snug">
                    Lifemate • Smart Tech Solutions
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
