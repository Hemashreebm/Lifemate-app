'use client';

import { useState } from 'react';
import { RELEASE_CONFIG } from '@/config/release';
import PrivacyModal from './PrivacyModal';
import ReleaseNotesModal from './ReleaseNotesModal';
import { ShieldCheck, Download, Github, FileText, Lock } from 'lucide-react';

export default function Footer() {
  const [privacyOpen, setPrivacyOpen] = useState(false);
  const [notesOpen, setNotesOpen] = useState(false);

  return (
    <footer className="border-t border-slate-800/80 bg-slate-950/90 py-14 text-slate-400 text-xs">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 grid grid-cols-1 md:grid-cols-4 gap-8">
        {/* Brand & About Column */}
        <div className="space-y-4 md:col-span-2">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl gradient-bg flex items-center justify-center font-bold text-white text-lg shadow-md">
              L
            </div>
            <span className="font-extrabold text-xl text-white tracking-tight">Lifemate</span>
          </div>
          <p className="max-w-md text-slate-400 text-xs leading-relaxed">
            Lifemate is an all-in-one personal companion application designed to simplify tasks, track expenses from SMS, coach spoken English, match verified government schemes, and keep users safe.
          </p>
          <div className="pt-2 flex items-center gap-4 text-xs font-medium">
            <button
              onClick={() => setPrivacyOpen(true)}
              className="text-brand-400 hover:text-brand-300 transition-colors flex items-center gap-1"
            >
              <Lock className="w-3.5 h-3.5" />
              <span>Privacy Policy</span>
            </button>
            <button
              onClick={() => setNotesOpen(true)}
              className="text-brand-400 hover:text-brand-300 transition-colors flex items-center gap-1"
            >
              <FileText className="w-3.5 h-3.5" />
              <span>Release Notes</span>
            </button>
            <a
              href="https://github.com/Hemashreebm/Lifemate-app"
              target="_blank"
              rel="noopener noreferrer"
              className="text-slate-400 hover:text-white transition-colors flex items-center gap-1"
            >
              <Github className="w-3.5 h-3.5" />
              <span>GitHub Codebase</span>
            </a>
          </div>
        </div>

        {/* Navigation Quick Links */}
        <div className="space-y-3">
          <h4 className="font-bold text-white uppercase tracking-wider text-[11px] font-mono">Quick Navigation</h4>
          <ul className="space-y-2 text-xs">
            <li><a href="#features" className="hover:text-brand-400 transition-colors">All Features Grid</a></li>
            <li><a href="#ai-assistant" className="hover:text-brand-400 transition-colors">Gemini AI Assistant</a></li>
            <li><a href="#finance" className="hover:text-brand-400 transition-colors">SMS Expense Tracker</a></li>
            <li><a href="#coach" className="hover:text-brand-400 transition-colors">Spoken English Coach</a></li>
            <li><a href="#security" className="hover:text-brand-400 transition-colors">Security Architecture</a></li>
            <li><a href="#download" className="hover:text-brand-400 transition-colors">Download Center</a></li>
          </ul>
        </div>

        {/* Centralized Release Metadata */}
        <div className="space-y-3">
          <h4 className="font-bold text-white uppercase tracking-wider text-[11px] font-mono">Release Specifications</h4>
          <ul className="space-y-1.5 text-xs font-mono text-slate-400">
            <li className="text-white font-bold">Version: v{RELEASE_CONFIG.version} (Build #{RELEASE_CONFIG.versionCode})</li>
            <li>Release Date: {RELEASE_CONFIG.releaseDate}</li>
            <li>APK Size: {RELEASE_CONFIG.apkSize}</li>
            <li>Target OS: {RELEASE_CONFIG.targetAndroid}</li>
            <li>Min OS: {RELEASE_CONFIG.minAndroid}</li>
            <li>Cloud Backend: Supabase PostgreSQL</li>
            <li>AI Proxy: Gemini Edge Function</li>
          </ul>
        </div>
      </div>

      {/* Copyright Bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 mt-8 border-t border-slate-800/60 flex flex-col sm:flex-row items-center justify-between gap-4 text-[11px] text-slate-500">
        <div>
          © {new Date().getFullYear()} Lifemate App. All rights reserved. Built with Flutter, Supabase & Next.js.
        </div>
        <div className="flex items-center gap-2 text-slate-400 font-mono">
          <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
          <span>SHA-256 Checksum Verified</span>
        </div>
      </div>

      {/* Modals */}
      <PrivacyModal isOpen={privacyOpen} onClose={() => setPrivacyOpen(false)} />
      <ReleaseNotesModal isOpen={notesOpen} onClose={() => setNotesOpen(false)} />
    </footer>
  );
}
