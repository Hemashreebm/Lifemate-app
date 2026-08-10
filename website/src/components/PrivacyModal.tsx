'use client';

import { X, ShieldCheck, Lock, CheckCircle2, FileText } from 'lucide-react';

interface PrivacyModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function PrivacyModal({ isOpen, onClose }: PrivacyModalProps) {
  if (!isOpen) return null;

  const dataCategories = [
    {
      title: 'User Profile & Personalization Data',
      items: 'Preferred language, state, district, occupation, education status, and age group.',
      purpose: 'Used exclusively to match verified Indian government schemes and personalize AI responses. Never sold or shared.',
    },
    {
      title: 'Tasks & Reminders',
      items: 'Task titles, due dates, priority levels, and category tags.',
      purpose: 'Stored locally on device and synchronized to your personal Supabase Cloud account via Row Level Security (RLS).',
    },
    {
      title: 'My Life Book / Diary Entries',
      items: 'Personal text notes, attached photos, mood tags, and optional voice notes.',
      purpose: 'Encrypted locally on device. Optional cloud synchronization is restricted strictly to your authenticated account.',
    },
    {
      title: 'Expense & Budget Data',
      items: 'Manual expense entries, category totals, and monthly budget limits.',
      purpose: 'Used locally for spending analytics. Raw bank account numbers or credentials are NEVER collected or stored.',
    },
    {
      title: 'SMS Financial Data',
      items: 'Debit alerts and bank SMS notifications received on device.',
      purpose: 'Processed 100% locally on your smartphone via regex parser. Raw SMS messages are NEVER uploaded or stored on cloud servers.',
    },
    {
      title: 'Location & GPS Coordinates',
      items: 'Device latitude, longitude, and reverse geocoded city/state.',
      purpose: 'Used on-demand for local landmark discovery and attached to emergency SMS alerts during 1-tap SOS triggers.',
    },
    {
      title: 'Voice & Speech Input',
      items: 'Audio spoken during Spoken English Coach practice or voice note creation.',
      purpose: 'Processed in real-time on device for speech recognition and pronunciation scoring. Audio files are not retained.',
    },
    {
      title: 'AI Companion Prompts',
      items: 'Text queries sent to the AI companion assistant.',
      purpose: 'Proxied securely through a hardened Supabase Edge Function (`gemini-chat`) without exposing client credentials.',
    },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md animate-in fade-in duration-200">
      <div className="relative w-full max-w-3xl glass-card rounded-3xl border border-brand-500/40 p-6 sm:p-8 space-y-6 max-h-[90vh] overflow-y-auto shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-800 pb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold">
              <ShieldCheck className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-xl font-extrabold text-white">Privacy Policy & Data Handling</h3>
              <p className="text-xs text-slate-400">Lifemate Security Architecture & Privacy Guarantee</p>
            </div>
          </div>
          <button
            onClick={onClose}
            aria-label="Close Privacy Modal"
            className="p-2 rounded-xl bg-slate-900 border border-slate-800 text-slate-400 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Introduction */}
        <p className="text-xs text-slate-300 leading-relaxed">
          Lifemate is built on the principle of minimal data collection and maximum local isolation. We believe your personal diary notes, financial transactions, and companion conversations belong entirely to you.
        </p>

        {/* Categories Breakdown */}
        <div className="space-y-3">
          <h4 className="text-xs font-bold text-slate-200 uppercase tracking-wider font-mono">
            How Data Categories Are Managed:
          </h4>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {dataCategories.map((cat, idx) => (
              <div key={idx} className="p-3.5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-1.5 text-xs">
                <div className="font-bold text-brand-300 flex items-center gap-1.5">
                  <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400 flex-shrink-0" />
                  <span>{cat.title}</span>
                </div>
                <p className="text-slate-400 text-[11px]">
                  <strong className="text-slate-300">Data:</strong> {cat.items}
                </p>
                <p className="text-slate-400 text-[11px]">
                  <strong className="text-slate-300">Purpose:</strong> {cat.purpose}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Security Controls */}
        <div className="p-4 rounded-2xl bg-slate-900/90 border border-slate-800 text-xs space-y-2">
          <h5 className="font-bold text-white flex items-center gap-1.5">
            <Lock className="w-4 h-4 text-emerald-400" />
            User Control & Data Erasure
          </h5>
          <p className="text-slate-300 text-[11px] leading-relaxed">
            You can clear all local application data or delete your Supabase account directly inside the Lifemate Android application settings at any time. Offline Guest Mode operates with 0 cloud transmission.
          </p>
        </div>

        {/* Action Footer */}
        <div className="flex justify-end border-t border-slate-800 pt-4">
          <button
            onClick={onClose}
            className="px-6 py-2.5 rounded-xl gradient-bg text-white font-bold text-xs shadow-lg"
          >
            I Understand
          </button>
        </div>
      </div>
    </div>
  );
}
