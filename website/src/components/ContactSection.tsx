'use client';

import { useState } from 'react';
import { Send, CheckCircle2, MessageSquare } from 'lucide-react';

export default function ContactSection() {
  const [submitted, setSubmitted] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', message: '' });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name || !form.email || !form.message) return;
    setSubmitted(true);
    setTimeout(() => {
      setForm({ name: '', email: '', message: '' });
      setSubmitted(false);
    }, 5000);
  };

  return (
    <section id="contact" className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8 scroll-mt-24">
      <div className="glass-card p-8 sm:p-10 rounded-3xl border border-slate-800 space-y-6 relative overflow-hidden">
        <div className="text-center space-y-2">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full glass-panel border-brand-500/30 text-brand-300 text-xs font-semibold">
            <MessageSquare className="w-3.5 h-3.5 text-brand-400" />
            <span>Lifemate Team Communication</span>
          </div>
          <h2 className="text-2xl sm:text-4xl font-extrabold text-white">Contact & Feedback</h2>
          <p className="text-slate-400 text-xs sm:text-sm">
            Have questions, feedback, or feature suggestions for the Lifemate team? Send us a direct message.
          </p>
        </div>

        {submitted ? (
          <div className="p-6 rounded-2xl bg-emerald-950/40 border border-emerald-500/40 text-center space-y-2 animate-in fade-in duration-200">
            <CheckCircle2 className="w-10 h-10 text-emerald-400 mx-auto" />
            <h4 className="text-lg font-bold text-white">Thank You for Your Feedback!</h4>
            <p className="text-xs text-slate-300">
              Your message has been received by the Lifemate product team. We appreciate your input!
            </p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">Your Name</label>
                <input
                  type="text"
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  placeholder="Enter your name"
                  className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-800 text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">Email Address</label>
                <input
                  type="email"
                  required
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  placeholder="name@example.com"
                  className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-800 text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 text-xs"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1">Message / Suggestion</label>
              <textarea
                required
                rows={4}
                value={form.message}
                onChange={(e) => setForm({ ...form, message: e.target.value })}
                placeholder="Share your thoughts, report an issue, or request new features..."
                className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-800 text-white placeholder-slate-500 focus:outline-none focus:border-brand-500 text-xs"
              />
            </div>

            <button
              type="submit"
              className="w-full gradient-bg text-white font-bold py-3.5 rounded-xl shadow-lg hover:scale-[1.01] active:scale-[0.99] transition-all flex items-center justify-center gap-2 text-xs uppercase tracking-wider"
            >
              <Send className="w-4 h-4" />
              <span>Send Message to Team</span>
            </button>
          </form>
        )}
      </div>
    </section>
  );
}
