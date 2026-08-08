# Lifemate Official Public Website

The official marketing and public release portal for **Lifemate — Your Everyday Life Companion**. Built using **Next.js 14 (App Router)**, **TypeScript**, and **Tailwind CSS**.

---

## 🚀 Key Features
- **Landing Hero**: Headline, subheadline, dual action buttons (APK Download & Feature Exploration).
- **12 Verified Features**: AI Companion, Tasks, Diary, Expense Tracker, SMS Tracker, English Coach, Regional Translation, Govt Schemes, Smart Location, Emergency SOS, Profile, Cloud Sync.
- **Dynamic Release Configuration**: Centralized single source of truth in `src/config/release.ts` for instant updates.
- **Security & Privacy Architecture**: Clear breakdown of client-side secret isolation, PKCE OAuth, and Gemini Edge Function proxying.
- **SEO & Metadata**: Complete OpenGraph, Twitter Cards, Sitemap, and Robots configuration.

---

## 📦 Vercel Deployment Instructions

### Method 1: Vercel Dashboard (Recommended)
1. Import the Git repository in Vercel.
2. Under **Framework Preset**, select **Next.js**.
3. Under **Root Directory**, enter:
   ```text
   website
   ```
4. Click **Deploy**. Vercel will automatically build and publish the site.

### Method 2: Vercel CLI
```bash
cd website
npx vercel
```

---

## 🛠️ Local Development

### Install Dependencies
```bash
cd website
npm install
```

### Run Local Server
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build Production Bundle
```bash
npm run build
```
