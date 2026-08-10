'use client';

import {
  Sparkles,
  Zap,
  BookOpen,
  DollarSign,
  MessageSquare,
  Award,
  Globe,
  SlidersHorizontal,
  MapPin,
  HeartPulse,
  UserCheck,
  Cloud,
  Lock,
  Mic,
  Scan,
  CheckCircle,
  BellRing,
  Languages,
} from 'lucide-react';

export default function FeatureGrid() {
  const allFeatures = [
    {
      id: 'ai',
      icon: Sparkles,
      title: 'AI Companion Assistant',
      desc: 'Voice & text interaction powered by Gemini Edge proxy. Features companion memory and strict privacy boundaries.',
      benefits: ['Gemini Edge Function proxy', 'Rate-limited (10 req/min/UID)', 'Clear AI vs factual distinction'],
      color: 'from-purple-500 to-indigo-500',
    },
    {
      id: 'journal',
      icon: BookOpen,
      title: 'My Life Book / Memory Journal',
      desc: 'Rich personal diary with voice note recording, photo attachments, emoji mood tags, and instant search.',
      benefits: ['Voice note recording', 'Photo attachments & tags', 'Encrypted local & cloud storage'],
      color: 'from-pink-500 to-rose-500',
    },
    {
      id: 'tasks',
      icon: Zap,
      title: 'Tasks & Reminders',
      desc: 'Smart task manager with priorities, due dates, categories, and local notification alarms.',
      benefits: ['Local alarm notifications', 'Category organization', 'Supabase Cloud sync'],
      color: 'from-blue-500 to-cyan-500',
    },
    {
      id: 'expenses',
      icon: DollarSign,
      title: 'Expense Tracker & Budgets',
      desc: 'Categorical expense logging, monthly spending statistics, income tracking, and budget health checks.',
      benefits: ['Monthly analytics charts', 'Income vs expense balance', 'Strict privacy protection warning'],
      color: 'from-emerald-500 to-teal-500',
    },
    {
      id: 'sms',
      icon: MessageSquare,
      title: 'SMS Spending Tracker',
      desc: 'Automated offline SMS financial categorizer that imports banking notifications securely.',
      benefits: ['100% local regex parsing', 'Debit & UPI notification detection', 'Zero raw SMS transmission'],
      color: 'from-amber-500 to-yellow-500',
    },
    {
      id: 'coach',
      icon: Award,
      title: 'Communication Coach Pro',
      desc: 'Spoken English trainer with daily challenges, pronunciation evaluation, and interview practice scenarios.',
      benefits: ['Real-time speech scoring', 'Daily challenge streak tracking', 'Structured interview prep'],
      color: 'from-indigo-500 to-purple-600',
    },
    {
      id: 'translation',
      icon: Globe,
      title: 'Real-Time Translation',
      desc: 'Multi-lingual speech and text translation for Indian regional languages and global speech-to-text.',
      benefits: ['Regional Indian language support', 'Voice conversation mode', 'Offline translation fallback'],
      color: 'from-cyan-500 to-blue-600',
    },
    {
      id: 'schemes',
      icon: SlidersHorizontal,
      title: 'Government Schemes Matcher',
      desc: 'Matches 12+ verified official Indian government schemes (PM-Kisan, Ayushman Bharat, etc.) to your profile.',
      benefits: ['Profile-based eligibility filter', 'Required document checklists', 'Official portal verification link'],
      color: 'from-orange-500 to-amber-600',
    },
    {
      id: 'safety',
      icon: HeartPulse,
      title: 'Smart Location & Safety SOS',
      desc: 'Instant 1-tap SOS emergency trigger with location coordinate broadcast and emergency helpline directory.',
      benefits: ['GPS coordinate attachment', 'Pre-configured trusted SMS alerts', 'Offline helpline directory'],
      color: 'from-rose-500 to-red-600',
    },
    {
      id: 'location',
      icon: MapPin,
      title: 'Smart Location Services',
      desc: 'On-demand location finder, reverse geocoding, and local landmark discovery.',
      benefits: ['Local GPS positioning', 'Reverse geocoding address finder', 'Nearby service locator'],
      color: 'from-teal-500 to-emerald-600',
    },
    {
      id: 'profile',
      icon: UserCheck,
      title: 'Profile & Personalization',
      desc: 'Comprehensive user profile with completeness scoring (0-100%), state selection, and avatar builder.',
      benefits: ['100% completeness scoring', 'State & district dropdowns', 'Personalized scheme matching'],
      color: 'from-violet-500 to-purple-600',
    },
    {
      id: 'sync',
      icon: Cloud,
      title: 'Cloud Synchronization',
      desc: 'Supabase Cloud PostgreSQL database synchronization with real-time stream updates and offline fallback.',
      benefits: ['Phone -> Cloud -> Device flow', 'Real-time PostgreSQL sync', 'Offline local-first persistence'],
      color: 'from-sky-500 to-indigo-600',
    },
    {
      id: 'security',
      icon: Lock,
      title: 'Secure Architecture',
      desc: 'Row Level Security policies, PKCE auth flow, and Gemini Edge Function proxy key isolation.',
      benefits: ['PostgreSQL RLS protection', 'PKCE OAuth security', 'Zero secrets embedded in client'],
      color: 'from-emerald-600 to-teal-700',
    },
    {
      id: 'voice',
      icon: Mic,
      title: 'Voice Interaction',
      desc: 'Hands-free voice command support powered by Flutter TTS & Speech-to-Text integration.',
      benefits: ['Hands-free voice notes', 'Natural Text-to-Speech playback', 'Voice search support'],
      color: 'from-amber-600 to-orange-600',
    },
    {
      id: 'ocr',
      icon: Scan,
      title: 'OCR Bill Scanner',
      desc: 'Scan receipts and bills using Google ML Kit text recognition to auto-populate expense records.',
      benefits: ['On-device ML Kit OCR', 'Auto amount extraction', 'Receipt photo attachment'],
      color: 'from-cyan-600 to-blue-700',
    },
    {
      id: 'habits',
      icon: CheckCircle,
      title: 'Habit Tracking & Goals',
      desc: 'Track daily habits, long-term goals, streak milestones, and personal productivity metrics.',
      benefits: ['Daily streak counters', 'Goal progress tracking', 'Visual milestone badges'],
      color: 'from-indigo-600 to-violet-700',
    },
    {
      id: 'notifications',
      icon: BellRing,
      title: 'Smart Notifications',
      desc: 'Local notification scheduling for task deadlines, habit reminders, and emergency alerts.',
      benefits: ['Scheduled local alarms', 'Custom notification sounds', 'Do Not Disturb respect'],
      color: 'from-blue-600 to-indigo-700',
    },
    {
      id: 'languages',
      icon: Languages,
      title: 'Onboarding Language Selection',
      desc: 'Prompt for preferred language during onboarding to tailor scheme discovery and coaching.',
      benefits: ['5 Supported Languages', 'Onboarding preference saved', 'Personalized content delivery'],
      color: 'from-purple-600 to-pink-700',
    },
  ];

  return (
    <section id="features" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12 scroll-mt-24">
      {/* Section Header */}
      <div className="text-center space-y-4 max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider">
          <Sparkles className="w-4 h-4 text-brand-400" />
          <span>Full Application Capabilities</span>
        </div>
        <h2 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">
          Complete Feature Presentation — <span className="gradient-text">18 Core Modules</span>
        </h2>
        <p className="text-slate-400 text-base leading-relaxed">
          Every feature detailed below represents live, implemented functionality inside the Lifemate Android application.
        </p>
      </div>

      {/* Grid of 18 Detailed Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {allFeatures.map((feat) => {
          const IconComp = feat.icon;
          return (
            <div
              key={feat.id}
              className="glass-card glass-card-hover p-6 rounded-3xl space-y-4 border border-slate-800/80 flex flex-col justify-between"
            >
              <div className="space-y-3">
                <div className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${feat.color} flex items-center justify-center text-white shadow-lg`}>
                  <IconComp className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-white leading-snug">{feat.title}</h3>
                <p className="text-slate-400 text-xs leading-relaxed">{feat.desc}</p>
              </div>

              <div className="border-t border-slate-800/80 pt-3 space-y-1.5">
                {feat.benefits.map((b, idx) => (
                  <div key={idx} className="flex items-center gap-2 text-[11px] text-slate-300 font-medium">
                    <span className="w-1.5 h-1.5 rounded-full bg-brand-400" />
                    <span>{b}</span>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
