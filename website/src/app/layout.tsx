import type { Metadata } from 'next';
import './globals.css';
import { RELEASE_CONFIG } from '@/config/release';

export const metadata: Metadata = {
  title: 'Lifemate — Your Everyday Life Companion',
  description:
    'Lifemate is your all-in-one personal companion app for task management, spoken English coaching, SMS expense tracking, real government scheme matching, AI assistant, and safety tools.',
  keywords: [
    'Lifemate',
    'Life Companion App',
    'Flutter App',
    'Task Manager',
    'Expense Tracker',
    'Spoken English Coach',
    'Government Schemes India',
    'AI Assistant',
    'Supabase Cloud',
  ],
  authors: [{ name: 'Lifemate Team' }],
  openGraph: {
    title: 'Lifemate — Your Everyday Life Companion',
    description:
      'Manage tasks, track money from SMS, practice spoken English, match verified government schemes, and stay secure with AI.',
    url: 'https://lifemate.app',
    siteName: 'Lifemate',
    images: [
      {
        url: 'https://lifemate.app/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Lifemate Companion App',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Lifemate — Your Everyday Life Companion',
    description:
      'All-in-one personal companion app for productivity, money tracking, English learning, and government schemes.',
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
      </head>
      <body className="bg-slate-950 text-slate-100 flex flex-col min-h-screen">
        {/* Navigation Bar */}
        <header className="sticky top-0 z-50 glass-card border-b border-slate-800/80 bg-slate-950/80 backdrop-blur-md">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <a href="#" className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl gradient-bg flex items-center justify-center font-extrabold text-white text-xl shadow-lg shadow-brand-600/30">
                L
              </div>
              <div className="flex flex-col">
                <span className="font-bold text-xl text-white tracking-tight">Lifemate</span>
                <span className="text-[10px] text-brand-400 font-semibold tracking-wider uppercase -mt-1">
                  v{RELEASE_CONFIG.version} Public Release
                </span>
              </div>
            </a>

            <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-300">
              <a href="#features" className="hover:text-brand-400 transition-colors">Features</a>
              <a href="#how-it-works" className="hover:text-brand-400 transition-colors">How It Works</a>
              <a href="#privacy" className="hover:text-brand-400 transition-colors">Privacy & Security</a>
              <a href="#download" className="hover:text-brand-400 transition-colors">Download</a>
              <a href="#about" className="hover:text-brand-400 transition-colors">About</a>
              <a href="#contact" className="hover:text-brand-400 transition-colors">Contact</a>
            </nav>

            <div className="flex items-center gap-4">
              <a
                href="#download"
                className="gradient-bg text-white font-semibold text-sm px-4 py-2 rounded-xl shadow-md hover:shadow-brand-600/40 hover:opacity-95 transition-all flex items-center gap-2"
              >
                <span>Download APK</span>
                <span className="text-xs bg-white/20 px-1.5 py-0.5 rounded font-mono">v{RELEASE_CONFIG.version}</span>
              </a>
            </div>
          </div>
        </header>

        {/* Main Content */}
        <main className="flex-grow">{children}</main>

        {/* Footer */}
        <footer className="border-t border-slate-800 bg-slate-950 py-12 text-slate-400 text-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="space-y-4 md:col-span-2">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg gradient-bg flex items-center justify-center font-bold text-white text-lg">
                  L
                </div>
                <span className="font-bold text-lg text-white">Lifemate</span>
              </div>
              <p className="max-w-md text-slate-400 text-sm leading-relaxed">
                Lifemate is an all-in-one personal companion application designed to simplify tasks, track expenses, coach spoken English, match government schemes, and keep users safe.
              </p>
              <p className="text-xs text-slate-500">
                © {new Date().getFullYear()} Lifemate. All rights reserved. Built with Flutter, Supabase & Next.js.
              </p>
            </div>

            <div>
              <h4 className="font-semibold text-white mb-3">Navigation</h4>
              <ul className="space-y-2 text-sm">
                <li><a href="#features" className="hover:text-brand-400 transition-colors">Features</a></li>
                <li><a href="#how-it-works" className="hover:text-brand-400 transition-colors">How It Works</a></li>
                <li><a href="#privacy" className="hover:text-brand-400 transition-colors">Privacy & Security</a></li>
                <li><a href="#download" className="hover:text-brand-400 transition-colors">Download Android APK</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-semibold text-white mb-3">Release Info</h4>
              <ul className="space-y-2 text-sm font-mono text-slate-400">
                <li>Version: v{RELEASE_CONFIG.version} (Build {RELEASE_CONFIG.versionCode})</li>
                <li>APK Size: {RELEASE_CONFIG.apkSize}</li>
                <li>Target: {RELEASE_CONFIG.targetAndroid}</li>
                <li>Database: Supabase Cloud (PostgreSQL)</li>
                <li>AI Backend: Gemini Edge Function Proxy</li>
              </ul>
            </div>
          </div>
        </footer>
      </body>
    </html>
  );
}
