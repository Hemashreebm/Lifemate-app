'use client';

import HeroSection from '@/components/HeroSection';
import DownloadCenter from '@/components/DownloadCenter';
import HowItWorks from '@/components/HowItWorks';
import InterfaceShowcase from '@/components/InterfaceShowcase';
import FeatureGrid from '@/components/FeatureGrid';
import SecuritySection from '@/components/SecuritySection';
import ContactSection from '@/components/ContactSection';

export default function HomePage() {
  return (
    <div className="space-y-24 sm:space-y-32 pb-24">
      {/* 1. HERO SECTION */}
      <HeroSection />

      {/* 2. PREMIUM DOWNLOAD CENTER */}
      <DownloadCenter />

      {/* 3. HOW IT WORKS 4-STEP FLOW */}
      <HowItWorks />

      {/* 4. INTERFACE SHOWCASE (3D PHONE MOCKUP) */}
      <InterfaceShowcase />

      {/* 5. FULL FEATURE PRESENTATION GRID (18 CAPABILITIES) */}
      <FeatureGrid />

      {/* 6. SECURITY & CLOUD ARCHITECTURE */}
      <SecuritySection />

      {/* 7. CONTACT & FEEDBACK FORM */}
      <ContactSection />
    </div>
  );
}
