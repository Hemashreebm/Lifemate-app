'use client';

import { useState } from 'react';
import { RELEASE_CONFIG } from '@/config/release';
import ReleaseNotesModal from './ReleaseNotesModal';
import { Download, Copy, Check, FileText, ShieldCheck, CheckCircle2, AlertCircle, Smartphone } from 'lucide-react';

export default function DownloadCenter() {
  const [copiedSha, setCopiedSha] = useState(false);
  const [downloadState, setDownloadState] = useState<'idle' | 'preparing' | 'started'>('idle');
  const [isNotesOpen, setIsNotesOpen] = useState(false);

  const handleCopySha = () => {
    navigator.clipboard.writeText(RELEASE_CONFIG.sha256Checksum);
    setCopiedSha(true);
    setTimeout(() => setCopiedSha(false), 2500);
  };

  const handleDownloadClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
    setDownloadState('preparing');
    setTimeout(() => {
      setDownloadState('started');
      setTimeout(() => setDownloadState('idle'), 4000);
    }, 800);
  };

  return (
    <section id="download" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8 scroll-mt-24">
      {/* Section Header */}
      <div className="text-center space-y-4 max-w-3xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold uppercase tracking-wider">
          <Smartphone className="w-4 h-4 text-brand-400" />
          <span>Official Public Distribution</span>
        </div>
        <h2 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">
          Download Center — <span className="gradient-text">Lifemate APK</span>
        </h2>
        <p className="text-slate-300 text-base leading-relaxed">
          Download the production release package directly onto your Android device. Verified build with no malware, clean ProGuard rules, and full feature capabilities.
        </p>
      </div>

      {/* Main Download Card Container */}
      <div className="glass-card p-6 sm:p-10 rounded-3xl border border-brand-500/40 relative overflow-hidden space-y-8">
        <div className="absolute top-0 right-0 w-96 h-96 bg-brand-500/10 rounded-full blur-3xl pointer-events-none" />

        {/* Top Info Banner */}
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 border-b border-slate-800 pb-6">
          <div className="space-y-1">
            <div className="flex items-center gap-3">
              <span className="text-2xl font-extrabold text-white">Lifemate Release v{RELEASE_CONFIG.version}</span>
              <span className="px-3 py-1 bg-brand-500/20 text-brand-300 text-xs font-bold rounded-full border border-brand-500/30 font-mono">
                Build #{RELEASE_CONFIG.versionCode}
              </span>
            </div>
            <p className="text-xs text-slate-400">
              Published: <span className="text-slate-200 font-medium">{RELEASE_CONFIG.releaseDate}</span> • Target: <span className="text-slate-200 font-medium">{RELEASE_CONFIG.targetAndroid}</span>
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setIsNotesOpen(true)}
              className="glass-card hover:bg-slate-800 text-slate-200 text-xs font-semibold px-4 py-2.5 rounded-xl border border-slate-700 transition-all flex items-center gap-2"
            >
              <FileText className="w-4 h-4 text-brand-400" />
              <span>VIEW RELEASE NOTES</span>
            </button>
          </div>
        </div>

        {/* Dynamic Specifications Grid */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 p-5 rounded-2xl bg-slate-900/90 border border-slate-800/90 text-xs">
          <div>
            <span className="text-slate-500 block mb-1">Package Name</span>
            <span className="font-mono font-bold text-white">com.lifemate.app</span>
          </div>

          <div>
            <span className="text-slate-500 block mb-1">APK File Size</span>
            <span className="font-mono font-bold text-emerald-400 text-sm">{RELEASE_CONFIG.apkSize}</span>
          </div>

          <div>
            <span className="text-slate-500 block mb-1">Minimum Android</span>
            <span className="font-semibold text-slate-200">{RELEASE_CONFIG.minAndroid}</span>
          </div>

          <div>
            <span className="text-slate-500 block mb-1">Verification Status</span>
            <span className="inline-flex items-center gap-1 text-emerald-400 font-bold">
              <ShieldCheck className="w-3.5 h-3.5" /> Passed Clean
            </span>
          </div>
        </div>

        {/* SHA-256 Checksum Container */}
        <div className="p-4 rounded-2xl bg-slate-900/70 border border-slate-800 space-y-2">
          <div className="flex items-center justify-between text-xs">
            <span className="font-semibold text-slate-400 flex items-center gap-1.5">
              <ShieldCheck className="w-4 h-4 text-brand-400" />
              SHA-256 Checksum Verification
            </span>
            <button
              onClick={handleCopySha}
              className="text-brand-400 hover:text-brand-300 text-xs font-medium flex items-center gap-1 transition-colors"
            >
              {copiedSha ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                  <span className="text-emerald-400 font-bold">Copied to Clipboard!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Checksum</span>
                </>
              )}
            </button>
          </div>
          <div className="p-2.5 rounded-xl bg-slate-950 font-mono text-[11px] text-slate-300 break-all select-all border border-slate-800">
            {RELEASE_CONFIG.sha256Checksum}
          </div>
        </div>

        {/* Changelog Highlights List */}
        <div className="space-y-3">
          <span className="text-xs font-bold text-slate-300 uppercase tracking-wider font-mono">
            Included Capabilities in Build #{RELEASE_CONFIG.versionCode}:
          </span>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
            {RELEASE_CONFIG.changelog.map((item, idx) => (
              <div key={idx} className="flex items-start gap-2.5 text-xs text-slate-300 p-2.5 rounded-xl bg-slate-900/40 border border-slate-800/60">
                <CheckCircle2 className="w-4 h-4 text-brand-400 flex-shrink-0 mt-0.5" />
                <span className="leading-snug">{item}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Direct Download Action Button & Feedback State */}
        <div className="pt-2 text-center space-y-3">
          <a
            href={RELEASE_CONFIG.apkUrl}
            download="app-release.apk"
            onClick={handleDownloadClick}
            className="gradient-bg text-white font-extrabold text-base sm:text-lg px-10 py-5 rounded-2xl shadow-xl shadow-brand-600/40 hover:shadow-brand-600/60 hover:scale-[1.02] active:scale-[0.98] transition-all inline-flex items-center justify-center gap-3 w-full sm:w-auto"
          >
            <Download className="w-6 h-6" />
            <span>
              {downloadState === 'idle' && `DOWNLOAD OFFICIAL APK (${RELEASE_CONFIG.apkSize})`}
              {downloadState === 'preparing' && 'PREPARING DIRECT DOWNLOAD...'}
              {downloadState === 'started' && 'BROWSER DOWNLOAD STARTED!'}
            </span>
          </a>

          {downloadState === 'started' && (
            <p className="text-xs text-emerald-400 font-semibold animate-pulse">
              ✓ Direct APK download initiated! If the download does not start automatically, please verify your browser permissions.
            </p>
          )}

          <p className="text-xs text-slate-400">
            Direct download link targets official GitHub Release tag <code className="font-mono text-brand-300">v{RELEASE_CONFIG.version}-release</code>. No external ad redirects.
          </p>
        </div>
      </div>

      {/* Release Notes Modal */}
      <ReleaseNotesModal isOpen={isNotesOpen} onClose={() => setIsNotesOpen(false)} />
    </section>
  );
}
