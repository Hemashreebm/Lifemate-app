'use client';

import { ShieldCheck, Lock, RefreshCw, Smartphone, Cloud, ArrowRight, CheckCircle2, Key, Database } from 'lucide-react';

export default function SecuritySection() {
  const syncSteps = [
    { label: 'MOBILE PHONE', desc: 'User Device', icon: Smartphone, color: 'text-brand-400' },
    { label: 'LOCAL DATA', desc: 'SQLite / Offline', icon: Database, color: 'text-emerald-400' },
    { label: 'SECURE SYNC', desc: 'PKCE SSL Proxy', icon: RefreshCw, color: 'text-amber-400' },
    { label: 'CLOUD POSTGRES', desc: 'Supabase RLS', icon: Cloud, color: 'text-cyan-400' },
    { label: 'OTHER DEVICE', desc: 'Synced Account', icon: Smartphone, color: 'text-indigo-400' },
  ];

  return (
    <section id="security" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12 scroll-mt-24">
      {/* Section Header */}
      <div className="text-center space-y-4 max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider">
          <ShieldCheck className="w-4 h-4 text-brand-400" />
          <span>Hardened Cloud Architecture</span>
        </div>
        <h2 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">
          Enterprise Security & <span className="gradient-text">Data Privacy</span>
        </h2>
        <p className="text-slate-400 text-base leading-relaxed">
          Lifemate prioritizes strict user data isolation, cryptographic authorization, and zero client-side API key embedding.
        </p>
      </div>

      {/* Visual Flow Diagram */}
      <div className="glass-card p-6 sm:p-10 rounded-3xl border border-brand-500/30 space-y-8">
        <div className="text-center space-y-2">
          <h3 className="text-xl font-bold text-white">Visual Cloud Synchronization Flow</h3>
          <p className="text-xs text-slate-400">
            End-to-end data pipeline from local device offline storage to cloud PostgreSQL sync.
          </p>
        </div>

        {/* Step Flow Row */}
        <div className="grid grid-cols-1 sm:grid-cols-5 gap-4 items-center">
          {syncSteps.map((s, idx) => {
            const IconComp = s.icon;
            return (
              <div key={idx} className="relative flex flex-col items-center text-center p-4 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
                <div className="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center">
                  <IconComp className={`w-5 h-5 ${s.color}`} />
                </div>
                <div className="font-bold text-xs text-white tracking-tight">{s.label}</div>
                <div className="text-[10px] text-slate-400">{s.desc}</div>

                {idx < syncSteps.length - 1 && (
                  <div className="hidden sm:block absolute -right-3 top-1/2 -translate-y-1/2 text-brand-500/60 z-10">
                    <ArrowRight className="w-4 h-4" />
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* 3 Core Architecture Pillars */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="glass-card p-6 rounded-3xl space-y-4 border border-slate-800/80">
          <div className="w-12 h-12 rounded-2xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center">
            <Lock className="w-6 h-6" />
          </div>
          <h3 className="text-lg font-bold text-white">Supabase PKCE Auth & RLS</h3>
          <p className="text-slate-400 text-xs leading-relaxed">
            All user sessions use PKCE OAuth flow. Database access is strictly governed by PostgreSQL Row Level Security (RLS) policies ensuring users can read/write only their own row data.
          </p>
          <div className="pt-2 border-t border-slate-800/80 text-[11px] text-slate-300 font-medium space-y-1">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
              <span>Row Level Security (RLS) active</span>
            </div>
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
              <span>PKCE Authorization token exchange</span>
            </div>
          </div>
        </div>

        <div className="glass-card p-6 rounded-3xl space-y-4 border border-slate-800/80">
          <div className="w-12 h-12 rounded-2xl bg-brand-500/20 text-brand-400 flex items-center justify-center">
            <RefreshCw className="w-6 h-6" />
          </div>
          <h3 className="text-lg font-bold text-white">Gemini AI Edge Proxy</h3>
          <p className="text-slate-400 text-xs leading-relaxed">
            Gemini API keys are protected inside a Supabase Edge Function proxy (`gemini-chat`). The client never sees the raw API secret. Requests are capped at 10 req/min/UID.
          </p>
          <div className="pt-2 border-t border-slate-800/80 text-[11px] text-slate-300 font-medium space-y-1">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-brand-400" />
              <span>Zero secret keys in client APK or website</span>
            </div>
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-brand-400" />
              <span>Rate limited & prompt size capped</span>
            </div>
          </div>
        </div>

        <div className="glass-card p-6 rounded-3xl space-y-4 border border-slate-800/80">
          <div className="w-12 h-12 rounded-2xl bg-cyan-500/20 text-cyan-400 flex items-center justify-center">
            <Key className="w-6 h-6" />
          </div>
          <h3 className="text-lg font-bold text-white">Local Financial Privacy</h3>
          <p className="text-slate-400 text-xs leading-relaxed">
            The SMS spending tracker operates 100% locally on your device. Raw bank SMS notifications are parsed using local regex patterns and are never uploaded to remote servers.
          </p>
          <div className="pt-2 border-t border-slate-800/80 text-[11px] text-slate-300 font-medium space-y-1">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-cyan-400" />
              <span>100% local regex parsing</span>
            </div>
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-cyan-400" />
              <span>Zero third-party financial tracking</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
