'use client';

import { RELEASE_CONFIG } from '@/config/release';
import { X, CheckCircle2, ShieldCheck, Sparkles, AlertCircle } from 'lucide-react';

interface ReleaseNotesModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ReleaseNotesModal({ isOpen, onClose }: ReleaseNotesModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md animate-in fade-in duration-200">
      <div className="relative w-full max-w-2xl glass-card rounded-3xl border border-brand-500/40 p-6 sm:p-8 space-y-6 max-h-[90vh] overflow-y-auto shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-800 pb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl gradient-bg flex items-center justify-center font-bold text-white shadow">
              L
            </div>
            <div>
              <h3 className="text-xl font-extrabold text-white flex items-center gap-2">
                Release Notes — Lifemate v{RELEASE_CONFIG.version}
              </h3>
              <p className="text-xs text-brand-400 font-mono">
                Build #{RELEASE_CONFIG.versionCode} • Released {RELEASE_CONFIG.releaseDate}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            aria-label="Close Modal"
            className="p-2 rounded-xl bg-slate-900 border border-slate-800 text-slate-400 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Release Metadata Summary */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 p-4 rounded-2xl bg-slate-900/80 border border-slate-800 text-xs">
          <div>
            <span className="text-slate-500 block">Version Code</span>
            <span className="font-bold text-white font-mono">{RELEASE_CONFIG.versionCode}</span>
          </div>
          <div>
            <span className="text-slate-500 block">Verified APK Size</span>
            <span className="font-bold text-emerald-400 font-mono">{RELEASE_CONFIG.apkSize}</span>
          </div>
          <div>
            <span className="text-slate-500 block">Min Android</span>
            <span className="font-bold text-slate-200">{RELEASE_CONFIG.minAndroid}</span>
          </div>
          <div>
            <span className="text-slate-500 block">Target Android</span>
            <span className="font-bold text-slate-200">{RELEASE_CONFIG.targetAndroid}</span>
          </div>
        </div>

        {/* Full Changelog Items */}
        <div className="space-y-4">
          <h4 className="text-sm font-bold text-slate-200 uppercase tracking-wider font-mono">
            Changelog & Key Improvements
          </h4>

          <div className="space-y-3">
            {RELEASE_CONFIG.changelog.map((change, idx) => (
              <div key={idx} className="flex items-start gap-3 p-3 rounded-xl bg-slate-900/50 border border-slate-800/80">
                <CheckCircle2 className="w-4 h-4 text-brand-400 flex-shrink-0 mt-0.5" />
                <span className="text-xs text-slate-300 leading-relaxed font-medium">{change}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Security & Verification Disclaimer */}
        <div className="p-4 rounded-2xl bg-brand-950/40 border border-brand-500/30 flex items-start gap-3 text-xs text-slate-300">
          <ShieldCheck className="w-5 h-5 text-brand-400 flex-shrink-0 mt-0.5" />
          <div>
            <span className="font-bold text-white block mb-0.5">Verified Cryptographic Signature</span>
            <span>
              This release binary has been audited for security, zero hardcoded API secrets, and clean ProGuard rules. Verify the SHA-256 hash before installing on un-trusted devices.
            </span>
          </div>
        </div>

        {/* Action Footer */}
        <div className="flex items-center justify-end gap-3 border-t border-slate-800 pt-4">
          <button
            onClick={onClose}
            className="px-5 py-2.5 rounded-xl bg-slate-900 border border-slate-800 text-slate-300 hover:text-white text-xs font-semibold"
          >
            Close Window
          </button>

          <a
            href={RELEASE_CONFIG.apkUrl}
            download
            onClick={onClose}
            className="gradient-bg text-white font-bold text-xs px-6 py-2.5 rounded-xl shadow-lg flex items-center gap-2"
          >
            <span>Download APK ({RELEASE_CONFIG.apkSize})</span>
          </a>
        </div>
      </div>
    </div>
  );
}
