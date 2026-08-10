import type { Metadata } from 'next';
import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { RELEASE_CONFIG } from '@/config/release';

export const metadata: Metadata = {
  title: 'Lifemate — Your Everyday Life Companion',
  description:
    'Lifemate is an all-in-one personal companion app created by Hemashree B M for task management, spoken English coaching, SMS expense tracking, real government scheme matching, AI assistant, and safety tools.',
  keywords: [
    'Lifemate',
    'Hemashree B M',
    'Life Companion App',
    'Flutter App',
    'Task Manager',
    'Expense Tracker',
    'Spoken English Coach',
    'Government Schemes India',
    'AI Assistant',
    'Supabase Cloud',
  ],
  authors: [{ name: 'Hemashree B M' }],
  openGraph: {
    title: 'Lifemate — Your Everyday Life Companion',
    description:
      'Created by Hemashree B M. Manage tasks, track money from SMS, practice spoken English, match verified government schemes, and stay secure with AI.',
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
      'All-in-one personal companion app created by Hemashree B M for productivity, money tracking, English learning, and government schemes.',
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
        <Navbar />
        <main className="flex-grow">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
