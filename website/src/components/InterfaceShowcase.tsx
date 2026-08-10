'use client';

import { useState } from 'react';
import {
  Sparkles,
  Award,
  DollarSign,
  ShieldCheck,
  HeartPulse,
  CheckCircle2,
  SlidersHorizontal,
  Zap,
  BookOpen,
  Smartphone,
  ChevronRight,
} from 'lucide-react';

export default function InterfaceShowcase() {
  const [activeTab, setActiveTab] = useState<'schemes' | 'english' | 'finance' | 'ai' | 'safety'>('schemes');

  const tabs = [
    { id: 'schemes', label: 'Government Schemes Hub', icon: SlidersHorizontal, color: 'text-amber-400' },
    { id: 'english', label: 'Spoken English Coach', icon: Award, color: 'text-indigo-400' },
    { id: 'finance', label: 'SMS Money Tracker', icon: DollarSign, color: 'text-emerald-400' },
    { id: 'ai', label: 'Gemini AI Companion', icon: Sparkles, color: 'text-purple-400' },
    { id: 'safety', label: 'Emergency & Safety SOS', icon: HeartPulse, color: 'text-rose-400' },
  ];

  return (
    <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
      {/* Section Header */}
      <div className="text-center space-y-4 max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider">
          <Smartphone className="w-4 h-4 text-brand-400" />
          <span>Material 3 Native Android UI Showcase</span>
        </div>
        <h2 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">
          Experience <span className="gradient-text">Lifemate Mobile Interface</span>
        </h2>
        <p className="text-slate-400 text-base leading-relaxed">
          Interactive preview built from live Flutter app screens. Explore how Lifemate organizes personal companion features seamlessly.
        </p>
      </div>

      {/* Tab Selector Bar */}
      <div className="flex items-center justify-start sm:justify-center gap-2 overflow-x-auto pb-2 scrollbar-none">
        {tabs.map((tab) => {
          const IconComp = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`px-4 py-2.5 rounded-2xl text-xs font-bold transition-all flex items-center gap-2 flex-shrink-0 border ${
                isActive
                  ? 'gradient-bg text-white border-brand-500 shadow-lg shadow-brand-600/30 scale-[1.02]'
                  : 'glass-card text-slate-300 border-slate-800 hover:border-slate-700 hover:text-white'
              }`}
            >
              <IconComp className={`w-4 h-4 ${isActive ? 'text-white' : tab.color}`} />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>

      {/* Showcase Stage Container */}
      <div className="glass-card p-6 sm:p-10 rounded-3xl border border-slate-800 relative overflow-hidden grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
        {/* Left Interactive Phone Display */}
        <div className="lg:col-span-6 flex justify-center">
          <div className="w-full max-w-sm glass-card p-4 rounded-[40px] border border-slate-700 shadow-2xl bg-slate-950/95 space-y-4">
            {/* Phone Top Notch */}
            <div className="w-24 h-4 bg-slate-900 rounded-full mx-auto border border-slate-800 flex items-center justify-center gap-2">
              <div className="w-2 h-2 rounded-full bg-slate-800" />
              <div className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
            </div>

            {/* TAB CONTENT MOCKUPS */}

            {/* Tab 1: Schemes Hub */}
            {activeTab === 'schemes' && (
              <div className="space-y-3 animate-in fade-in duration-300">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2.5 text-xs">
                  <div className="font-bold text-white flex items-center gap-1.5">
                    <SlidersHorizontal className="w-4 h-4 text-amber-400" />
                    <span>Citizen Schemes Hub</span>
                  </div>
                  <span className="text-[10px] bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full font-bold">
                    12 Verified Match
                  </span>
                </div>

                <div className="p-3 rounded-2xl bg-slate-900 border border-amber-500/30 space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-extrabold text-white">PM-Kisan Samman Nidhi</span>
                    <span className="text-[10px] bg-amber-500/20 text-amber-300 px-1.5 py-0.5 rounded">Agri Support</span>
                  </div>
                  <p className="text-[11px] text-slate-300 leading-snug">
                    ₹6,000 / year direct income support transferred in 3 equal installments to landholding farmer families.
                  </p>
                  <div className="flex items-center justify-between text-[10px] text-slate-400 border-t border-slate-800/80 pt-1.5">
                    <span>Required: Aadhaar + Land Record</span>
                    <span className="text-emerald-400 font-bold">100% Eligible</span>
                  </div>
                </div>

                <div className="p-3 rounded-2xl bg-slate-900 border border-slate-800 space-y-1.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-extrabold text-white">Ayushman Bharat PM-JAY</span>
                    <span className="text-[10px] bg-emerald-500/20 text-emerald-300 px-1.5 py-0.5 rounded">Healthcare</span>
                  </div>
                  <p className="text-[11px] text-slate-300 leading-snug">
                    ₹5,000,000 / family / year secondary & tertiary hospitalization coverage across empanelled hospitals.
                  </p>
                </div>
              </div>
            )}

            {/* Tab 2: Spoken English */}
            {activeTab === 'english' && (
              <div className="space-y-3 animate-in fade-in duration-300">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2.5 text-xs">
                  <div className="font-bold text-white flex items-center gap-1.5">
                    <Award className="w-4 h-4 text-indigo-400" />
                    <span>Spoken English Coach Pro</span>
                  </div>
                  <span className="text-[10px] bg-indigo-500/20 text-indigo-300 px-2 py-0.5 rounded-full font-bold">
                    Daily Challenge Active
                  </span>
                </div>

                <div className="p-3.5 rounded-2xl bg-gradient-to-br from-indigo-950/80 to-slate-900 border border-indigo-500/40 space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-white">Pronunciation & Pitch Feedback</span>
                    <span className="text-xs font-mono font-bold text-emerald-400">Score: 96%</span>
                  </div>
                  <p className="text-[11px] text-indigo-200 italic">
                    "Could you please guide me to the nearest government service center?"
                  </p>
                  <div className="p-2 rounded-xl bg-slate-950/80 text-[10px] text-slate-300 flex items-center justify-between">
                    <span>Clarity: Excellent</span>
                    <span>Pacing: Natural</span>
                    <span className="text-indigo-400 font-bold">Streak: 🔥 7 Days</span>
                  </div>
                </div>

                <div className="p-3 rounded-2xl bg-slate-900 border border-slate-800 flex items-center justify-between text-xs">
                  <span className="font-semibold text-slate-200">Interview Practice Scenario</span>
                  <span className="text-[10px] bg-brand-500/20 text-brand-300 px-2 py-0.5 rounded">Level 2</span>
                </div>
              </div>
            )}

            {/* Tab 3: SMS Money Tracker */}
            {activeTab === 'finance' && (
              <div className="space-y-3 animate-in fade-in duration-300">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2.5 text-xs">
                  <div className="font-bold text-white flex items-center gap-1.5">
                    <DollarSign className="w-4 h-4 text-emerald-400" />
                    <span>SMS Expense Tracker</span>
                  </div>
                  <span className="text-[10px] bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full font-bold">
                    Offline Local Categorizer
                  </span>
                </div>

                <div className="p-3 rounded-2xl bg-slate-900 border border-emerald-500/30 space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-white">Parsed SMS Alert</span>
                    <span className="text-[10px] text-emerald-400 font-bold">Auto Logged</span>
                  </div>
                  <div className="p-2 rounded-xl bg-slate-950 font-mono text-[10px] text-slate-300">
                    "Rs 450.00 debited from A/C XX4921 via UPI to DMart Groceries on 09-Aug-2026"
                  </div>
                  <div className="flex items-center justify-between text-[10px] text-slate-400">
                    <span>Category: Groceries & Household</span>
                    <span className="text-white font-bold">-₹450.00</span>
                  </div>
                </div>

                <div className="p-3 rounded-2xl bg-slate-900 border border-slate-800 flex items-center justify-between text-xs">
                  <div>
                    <span className="text-[10px] text-slate-400 block">August Spend Total</span>
                    <span className="font-bold text-white text-sm">₹8,420.00</span>
                  </div>
                  <span className="text-[10px] bg-cyan-500/20 text-cyan-300 px-2 py-0.5 rounded font-semibold">
                    Budget Health: Good
                  </span>
                </div>
              </div>
            )}

            {/* Tab 4: Gemini AI */}
            {activeTab === 'ai' && (
              <div className="space-y-3 animate-in fade-in duration-300">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2.5 text-xs">
                  <div className="font-bold text-white flex items-center gap-1.5">
                    <Sparkles className="w-4 h-4 text-purple-400" />
                    <span>Gemini AI Companion</span>
                  </div>
                  <span className="text-[10px] bg-purple-500/20 text-purple-300 px-2 py-0.5 rounded-full font-bold">
                    Edge Proxy Active
                  </span>
                </div>

                <div className="space-y-2 text-xs">
                  <div className="p-2.5 rounded-2xl bg-slate-800/80 text-slate-200 ml-4 border border-slate-700">
                    "Help me prepare documents for agricultural subsidy applications."
                  </div>

                  <div className="p-3 rounded-2xl bg-purple-950/60 border border-purple-500/30 text-purple-100 space-y-1">
                    <div className="flex items-center justify-between text-[10px] text-purple-300 font-bold">
                      <span>Gemini Companion</span>
                      <span>Verified Information</span>
                    </div>
                    <p className="text-[11px] leading-snug">
                      Here are the 4 required documents for PM-Kisan: 1) Aadhaar Card, 2) Land ownership certificate (RTC), 3) Savings Bank Passbook, 4) Active Mobile Number.
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Tab 5: Safety SOS */}
            {activeTab === 'safety' && (
              <div className="space-y-3 animate-in fade-in duration-300">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2.5 text-xs">
                  <div className="font-bold text-white flex items-center gap-1.5">
                    <HeartPulse className="w-4 h-4 text-rose-400" />
                    <span>Safety & Emergency SOS</span>
                  </div>
                  <span className="text-[10px] bg-rose-500/20 text-rose-300 px-2 py-0.5 rounded-full font-bold">
                    1-Tap Emergency
                  </span>
                </div>

                <div className="p-4 rounded-2xl bg-gradient-to-br from-rose-950/80 to-slate-900 border border-rose-500/40 text-center space-y-3">
                  <div className="w-12 h-12 rounded-full bg-rose-600 text-white flex items-center justify-center mx-auto shadow-lg shadow-rose-600/40 animate-pulse">
                    <HeartPulse className="w-6 h-6" />
                  </div>
                  <div className="space-y-1">
                    <div className="text-xs font-extrabold text-white">Emergency Location Broadcast</div>
                    <p className="text-[11px] text-slate-300">
                      Instantly sends GPS coordinates & emergency SMS to pre-configured trusted contacts.
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Feature Highlights Explanation */}
        <div className="lg:col-span-6 space-y-6">
          {activeTab === 'schemes' && (
            <div className="space-y-4">
              <span className="text-xs font-bold text-amber-400 uppercase tracking-widest font-mono">
                Profile-Based Government Scheme Matching
              </span>
              <h3 className="text-2xl sm:text-3xl font-bold text-white">
                Match Verified Indian Government Schemes Instantly
              </h3>
              <p className="text-slate-300 text-sm leading-relaxed">
                Lifemate compares your age, state, district, occupation, education, and income profile against 12+ verified official schemes (PM-Kisan, Ayushman Bharat, PM Mudra Yojana, etc.) with document guidance and application steps.
              </p>
              <div className="space-y-2 text-xs text-slate-300">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <span>Filter by 28 States & 8 Union Territories</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <span>Complete document requirement checklists</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <span>Disclaimer: Users verify final eligibility at official government portals.</span>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'english' && (
            <div className="space-y-4">
              <span className="text-xs font-bold text-indigo-400 uppercase tracking-widest font-mono">
                Spoken English & Communication Coach
              </span>
              <h3 className="text-2xl sm:text-3xl font-bold text-white">
                Daily Conversation & Pronunciation Practice
              </h3>
              <p className="text-slate-300 text-sm leading-relaxed">
                Build confidence with daily interactive English challenges, job interview practice, real-time speech pronunciation evaluation, and streak milestone tracking.
              </p>
              <div className="space-y-2 text-xs text-slate-300">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-indigo-400" />
                  <span>Real-time speech recognition & accuracy scoring</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-indigo-400" />
                  <span>Structured daily communication practice cards</span>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'finance' && (
            <div className="space-y-4">
              <span className="text-xs font-bold text-emerald-400 uppercase tracking-widest font-mono">
                SMS Spending & Expense Tracking
              </span>
              <h3 className="text-2xl sm:text-3xl font-bold text-white">
                Automated Offline Bank SMS Categorizer
              </h3>
              <p className="text-slate-300 text-sm leading-relaxed">
                Track debit alerts, UPI transactions, and merchant spending offline without sharing raw financial data with third-party servers.
              </p>
              <div className="space-y-2 text-xs text-slate-300">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <span>100% local regex parsing on device</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <span>Monthly category analytics & budget health check</span>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'ai' && (
            <div className="space-y-4">
              <span className="text-xs font-bold text-purple-400 uppercase tracking-widest font-mono">
                Secure Gemini AI Assistant
              </span>
              <h3 className="text-2xl sm:text-3xl font-bold text-white">
                Contextual AI with Memory & Privacy Proxy
              </h3>
              <p className="text-slate-300 text-sm leading-relaxed">
                Ask questions, summarize text, and set personal companion memories through a hardened Supabase Edge Function (`gemini-chat`) proxy that protects API secret keys.
              </p>
              <div className="space-y-2 text-xs text-slate-300">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-purple-400" />
                  <span>10 req/min/UID rate limiting & prompt caps</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-purple-400" />
                  <span>Clear distinction between AI responses vs verified official data</span>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'safety' && (
            <div className="space-y-4">
              <span className="text-xs font-bold text-rose-400 uppercase tracking-widest font-mono">
                Emergency & Safety Features
              </span>
              <h3 className="text-2xl sm:text-3xl font-bold text-white">
                1-Tap SOS Emergency Broadcast
              </h3>
              <p className="text-slate-300 text-sm leading-relaxed">
                Instantly trigger SOS emergency broadcasts to pre-configured trusted contacts and access national emergency helpline directories.
              </p>
              <div className="space-y-2 text-xs text-slate-300">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-rose-400" />
                  <span>GPS location coordinate attachment</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-rose-400" />
                  <span>Offline helpline directory access (Police, Women Helpline, Ambulance)</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
