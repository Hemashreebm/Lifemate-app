'use client';

import { useState, useEffect } from 'react';
import { RELEASE_CONFIG } from '@/config/release';
import { Download, Menu, X, Globe } from 'lucide-react';

export const WEBSITE_LANGUAGES = [
  { code: 'en', name: 'English', native: 'English' },
  { code: 'kn', name: 'Kannada', native: 'ಕನ್ನಡ' },
  { code: 'te', name: 'Telugu', native: 'తెలుగు' },
  { code: 'hi', name: 'Hindi', native: 'हिन्दी' },
  { code: 'ta', name: 'Tamil', native: 'தமிழ்' },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [selectedLang, setSelectedLang] = useState('en');

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header
      className={`sticky top-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-slate-950/85 backdrop-blur-xl border-b border-slate-800/90 shadow-2xl shadow-slate-950/50 py-3'
          : 'bg-transparent border-b border-slate-800/40 py-4'
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between">
        {/* Brand Logo & Version */}
        <a href="#" className="flex items-center gap-3 group">
          <div className="w-10 h-10 rounded-xl gradient-bg flex items-center justify-center font-extrabold text-white text-xl shadow-lg shadow-brand-600/30 group-hover:scale-105 transition-transform">
            L
          </div>
          <div className="flex flex-col">
            <span className="font-extrabold text-xl text-white tracking-tight flex items-center gap-1.5">
              Lifemate
              <span className="inline-block w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            </span>
            <span className="text-[10px] text-brand-400 font-semibold tracking-wider uppercase -mt-1">
              v{RELEASE_CONFIG.version} Official Release
            </span>
          </div>
        </a>

        {/* Desktop Navigation Links */}
        <nav className="hidden lg:flex items-center gap-7 text-sm font-medium text-slate-300">
          <a href="#features" className="hover:text-brand-400 transition-colors">
            Features
          </a>
          <a href="#ai-assistant" className="hover:text-brand-400 transition-colors">
            AI Assistant
          </a>
          <a href="#finance" className="hover:text-brand-400 transition-colors">
            Finance & SMS
          </a>
          <a href="#coach" className="hover:text-brand-400 transition-colors">
            Communication
          </a>
          <a href="#security" className="hover:text-brand-400 transition-colors">
            Security & Cloud
          </a>
          <a href="#how-it-works" className="hover:text-brand-400 transition-colors">
            How It Works
          </a>
          <a href="#creator" className="hover:text-brand-400 transition-colors">
            Creator
          </a>
          <a href="#download" className="hover:text-brand-400 transition-colors">
            Download Center
          </a>
        </nav>

        {/* Language Selector & Action Button */}
        <div className="hidden sm:flex items-center gap-3">
          <div className="flex items-center gap-1.5 bg-slate-900/90 border border-slate-800 rounded-xl px-2.5 py-1.5 text-xs text-slate-300">
            <Globe className="w-3.5 h-3.5 text-brand-400" />
            <select
              value={selectedLang}
              onChange={(e) => setSelectedLang(e.target.value)}
              className="bg-transparent text-slate-200 focus:outline-none cursor-pointer"
            >
              {WEBSITE_LANGUAGES.map((l) => (
                <option key={l.code} value={l.code} className="bg-slate-900 text-slate-200">
                  {l.native}
                </option>
              ))}
            </select>
          </div>

          <a
            href={RELEASE_CONFIG.apkUrl}
            download
            className="gradient-bg text-white font-bold text-sm px-5 py-2.5 rounded-xl shadow-lg shadow-brand-600/25 hover:shadow-brand-600/40 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center gap-2"
          >
            <Download className="w-4 h-4" />
            <span>Download App</span>
            <span className="text-[11px] bg-white/20 px-1.5 py-0.5 rounded font-mono font-normal">
              {RELEASE_CONFIG.apkSize}
            </span>
          </a>
        </div>

        {/* Mobile Hamburger Button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          aria-label="Toggle Navigation Menu"
          className="lg:hidden p-2 rounded-xl bg-slate-900 border border-slate-800 text-slate-300 hover:text-white focus:outline-none"
        >
          {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Drawer Menu */}
      {mobileMenuOpen && (
        <div className="lg:hidden bg-slate-950/95 border-b border-slate-800 backdrop-blur-2xl px-4 pt-4 pb-6 space-y-3 animate-in slide-in-from-top duration-200">
          <div className="flex items-center gap-2 pb-2 border-b border-slate-800">
            <Globe className="w-4 h-4 text-brand-400" />
            <span className="text-xs text-slate-400">Language:</span>
            <select
              value={selectedLang}
              onChange={(e) => setSelectedLang(e.target.value)}
              className="bg-slate-900 text-slate-200 text-xs p-1.5 rounded-lg border border-slate-800 focus:outline-none"
            >
              {WEBSITE_LANGUAGES.map((l) => (
                <option key={l.code} value={l.code}>
                  {l.native}
                </option>
              ))}
            </select>
          </div>

          <a href="#features" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            Features Grid
          </a>
          <a href="#ai-assistant" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            AI Assistant
          </a>
          <a href="#finance" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            Finance & SMS Tracker
          </a>
          <a href="#coach" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            Spoken English Coach
          </a>
          <a href="#security" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            Security & Data Isolation
          </a>
          <a href="#how-it-works" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            How It Works
          </a>
          <a href="#creator" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            About the Creator
          </a>
          <a href="#download" onClick={() => setMobileMenuOpen(false)} className="block py-2 text-slate-300 hover:text-white font-medium">
            Download Center
          </a>

          <div className="pt-2 border-t border-slate-800/80">
            <a
              href={RELEASE_CONFIG.apkUrl}
              download
              className="w-full gradient-bg text-white font-bold py-3 rounded-xl shadow-lg flex items-center justify-center gap-2 text-sm"
            >
              <Download className="w-4 h-4" />
              <span>Download Lifemate APK ({RELEASE_CONFIG.apkSize})</span>
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
