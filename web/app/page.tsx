import Link from 'next/link';
import { APP_CONFIG } from './config';
import SampleQuestionDemo from './SampleQuestionDemo';

export default function HomePage() {
  return (
    <div className="landing-wrapper">
      {/* Navigation */}
      <nav className="navbar">
        <div className="nav-container">
          <div className="logo-group">
            <div className="logo-icon">
              <img src="/logo-512.png" alt="DPA Mastery Logo" width={36} height={36} />
            </div>
            <span className="logo-text">DPA Mastery</span>
            <span className="version-pill">{APP_CONFIG.versionPill}</span>
          </div>

          <div className="nav-links">
            <a href="#demo" className="nav-demo-highlight">Try Demo</a>
            <a href="#features">Features</a>
            <a href="#certificates">Certificates</a>
            <a href="#mock-exam">Mock Exam</a>
            <a href="#dlc">DLC Hub</a>
            <a href="#tiers">Tiers</a>
            <a href="#curriculum">Curriculum</a>
            <a href="#downloads">Downloads</a>
            <a href="#sponsor" className="nav-sponsor-btn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
              </svg>
              Sponsor
            </a>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <header className="hero-section">
        <div className="hero-glow"></div>
        <div className="hero-content">
          <div className="hero-badge">
            <span className="badge-dot"></span>
            <span>Philippine NPC DPO Certification Prep • 282 Core + 700+ Expansion Bank</span>
          </div>

          <h1 className="hero-title">
            Master the Data Privacy Act of 2012 with <span className="gradient-text">Spaced Repetition</span>
          </h1>

          <p className="hero-description">
            The offline-first, SRS-powered study companion for the Philippine National Privacy Commission (NPC) DPO Certification Examination. Featuring full timed Mock Exam simulations, DLC Expansion Hub, 5 gated competency tiers, and intelligent Exam Readiness diagnostics.
          </p>

          <div className="hero-cta-group">
            <a href="#downloads" className="btn-primary">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/>
                <line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              Download Native App (v{APP_CONFIG.version})
            </a>
            <a href="#demo" className="btn-secondary">
              ⚡ Try Question Demo
            </a>
            <a href="#dlc" className="btn-secondary" style={{ opacity: 0.85 }}>
              Explore DLCs
            </a>
          </div>

          {/* Guarantee Badges */}
          <div className="hero-highlights">
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>100% Offline SQLite</span>
            </div>
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>Zero Telemetry &bull; Privacy by Design</span>
            </div>
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>Timed DPO Mock Exam Simulation</span>
            </div>
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>DLC Expansion System</span>
            </div>
          </div>
        </div>
      </header>

      {/* App Mockup / Visual Showcase */}
      <section className="mockup-section">
        <div className="mockup-card">
          <div className="mockup-header">
            <div className="mockup-dots">
              <span className="dot red"></span>
              <span className="dot yellow"></span>
              <span className="dot green"></span>
            </div>
            <span className="mockup-title">DPA Mastery Suite — Spaced Repetition, Tier Gating, DPO ACE Mock Exam &amp; DLC Hub</span>
          </div>

          <div style={{ position: 'relative', overflow: 'hidden', borderBottom: '1px solid rgba(255, 255, 255, 0.08)' }}>
            <img
              src="/feature_graphic.png"
              alt="DPA Mastery Feature Graphic"
              width={1024}
              height={500}
              style={{
                width: '100%',
                height: 'auto',
                display: 'block',
                objectFit: 'cover',
              }}
            />
          </div>

          <div className="mockup-body">
            <div className="mockup-stat-grid">
              <div className="mockup-stat-card apprentice">
                <span className="stat-label">Apprentice</span>
                <span className="stat-value">Stages 1–4</span>
                <span className="stat-sub">4h • 8h • 24h • 48h intervals</span>
              </div>
              <div className="mockup-stat-card guru">
                <span className="stat-label">Guru</span>
                <span className="stat-value">Stages 5–6</span>
                <span className="stat-sub">1 week • 2 weeks (Milestone &amp; High-Water Protection)</span>
              </div>
              <div className="mockup-stat-card master">
                <span className="stat-label">Master</span>
                <span className="stat-value">Stage 7</span>
                <span className="stat-sub">1 month review interval</span>
              </div>
              <div className="mockup-stat-card burned">
                <span className="stat-label">Burned</span>
                <span className="stat-value">Stage 8</span>
                <span className="stat-sub">Permanently Mastered</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Interactive Sample Question Demo Section */}
      <SampleQuestionDemo />

      {/* What is SRS Explainer Section */}
      <section className="srs-explainer-section">
        <div className="srs-explainer-card">
          <div className="srs-badge-wrap">
            <span className="badge">Cognitive Science</span>
          </div>
          <h2>What is Spaced Repetition (SRS)?</h2>
          <p className="srs-lead">
            <strong>SRS (Spaced Repetition System)</strong> is an evidence-based learning technique that schedules review sessions at strategically increasing intervals based on the <em>Ebbinghaus Forgetting Curve</em>.
          </p>

          <div className="srs-comparison-grid">
            <div className="srs-box cramming">
              <div className="srs-box-header">
                <span className="box-icon">📉</span>
                <h4>Traditional Cramming</h4>
              </div>
              <p>Studying hundreds of questions in 1–2 days creates rapid short-term memory, but <strong>over 70% is forgotten within 48 hours</strong> due to natural memory decay.</p>
            </div>

            <div className="srs-box srs-active">
              <div className="srs-box-header">
                <span className="box-icon">📈</span>
                <h4>DPA Mastery SRS Engine</h4>
              </div>
              <p>You review a concept right before your brain forgets it (4h &rarr; 8h &rarr; 24h &rarr; 1w &rarr; 1mo). Every successful recall <strong>locks the concept deeper into long-term memory</strong>.</p>
            </div>
          </div>

          <div className="srs-timeline-bar">
            <div className="timeline-step">
              <span className="step-badge">1. Lesson (Available)</span>
              <span className="step-time">Instant</span>
              <span className="step-desc">Concepts &amp; Exam</span>
            </div>
            <span className="timeline-arrow">&rarr;</span>
            <div className="timeline-step">
              <span className="step-badge">2. Apprentice</span>
              <span className="step-time">4h – 48h</span>
              <span className="step-desc">Initial recall</span>
            </div>
            <span className="timeline-arrow">&rarr;</span>
            <div className="timeline-step">
              <span className="step-badge">3. Guru (Milestone Gate)</span>
              <span className="step-time">1 – 2 weeks</span>
              <span className="step-desc">Solid retention</span>
            </div>
            <span className="timeline-arrow">&rarr;</span>
            <div className="timeline-step">
              <span className="step-badge">4. Master &amp; Burned</span>
              <span className="step-time">1 month+</span>
              <span className="step-desc">Permanent memory</span>
            </div>
          </div>
        </div>
      </section>

      {/* Verifiable Certificate Spotlight Section */}
      <section id="certificates" className="curriculum-section" style={{ borderTop: '1px solid rgba(255,255,255,0.06)' }}>
        <div className="section-header">
          <span className="badge" style={{ borderColor: 'rgba(2, 132, 199, 0.4)', color: '#38bdf8', background: 'rgba(2, 132, 199, 0.12)' }}>New in v{APP_CONFIG.version}</span>
          <h2>Verifiable Digital Certificates of Mastery</h2>
          <p>Earn cryptographically authenticated, zero-knowledge certificates when you pass the 50-question DPO simulation. Seamlessly showcase your credentials on LinkedIn, Facebook, and X (Twitter).</p>
        </div>

        <div className="features-grid">
          <div className="feature-card" style={{ border: '1.5px solid rgba(10, 102, 194, 0.4)', background: 'linear-gradient(135deg, rgba(10, 102, 194, 0.08), rgba(15, 23, 42, 0.9))' }}>
            <div className="feature-icon" style={{ background: 'rgba(10, 102, 194, 0.15)', color: '#0A66C2' }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.46 8.76a1.68 1.68 0 1 0 0-3.36 1.68 1.68 0 0 0 0 3.36m1.39 9.74V9.93H5.07v8.57h2.78z"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#0A66C2', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>1-Tap Sync</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Official LinkedIn Org ID: 144796321</span>
            </div>
            <h3>Add to LinkedIn Profile &amp; Feed</h3>
            <p>Direct 1-tap integration pre-populates your official credential name, issuance date, organization ID, and unique cryptographic verification link directly into your LinkedIn profile licenses.</p>
          </div>

          <div className="feature-card" style={{ border: '1.5px solid rgba(24, 119, 242, 0.4)', background: 'linear-gradient(135deg, rgba(24, 119, 242, 0.08), rgba(15, 23, 42, 0.9))' }}>
            <div className="feature-icon" style={{ background: 'rgba(24, 119, 242, 0.15)', color: '#1877F2' }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#1877F2', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>Dynamic OG Previews</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>1200 &times; 630 High-DPI Cards</span>
            </div>
            <h3>Share to Facebook &amp; X (Twitter)</h3>
            <p>Edge-rendered OpenGraph metadata dynamically renders crisp, professional social preview cards displaying your conferral name, honors distinction, and unique serial code whenever shared.</p>
          </div>

          <div className="feature-card" style={{ border: '1.5px solid rgba(16, 185, 129, 0.4)', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.08), rgba(15, 23, 42, 0.9))' }}>
            <div className="feature-icon emerald">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                <path d="M9 12l2 2 4-4"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#10B981', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>Live QR Verification</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Zero-Knowledge Ledger</span>
            </div>
            <h3>QR Code &amp; Public Ledger Registry</h3>
            <p>Every certificate contains a live scannable QR code directing employers and compliance auditors to the public cryptographic verification ledger without requiring any account or login.</p>
          </div>
        </div>

        {/* Action Buttons to Sample Web Certificate & Verify Ledger */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '14px', marginTop: '28px', flexWrap: 'wrap' }}>
          <Link href="/certificate" className="btn-primary" style={{ padding: '10px 20px', fontSize: '13.5px', background: 'linear-gradient(135deg, #0284C7 0%, #0369A1 100%)', borderColor: '#0284C7' }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="8" r="7"/>
              <polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/>
            </svg>
            Preview Live Digital Certificate
          </Link>
          <Link href="/verify" className="btn-secondary" style={{ padding: '10px 20px', fontSize: '13.5px' }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
              <line x1="9" y1="9" x2="9" y2="9.01"/>
              <line x1="15" y1="9" x2="15" y2="9.01"/>
              <line x1="9" y1="15" x2="15" y2="15"/>
            </svg>
            Public Verification Ledger
          </Link>
        </div>
      </section>

      {/* DPO Mock Exam Spotlight Section */}
      <section id="mock-exam" className="curriculum-section" style={{ borderTop: '1px solid rgba(255,255,255,0.06)' }}>
        <div className="section-header">
          <span className="badge" style={{ borderColor: 'rgba(239, 68, 68, 0.4)', color: '#f87171', background: 'rgba(239, 68, 68, 0.12)' }}>New Simulation</span>
          <h2>DPO Certification Mock Exam Simulation</h2>
          <p>Experience realistic, timed NPC DPO ACE Exam conditions with diagnostic performance reports and missed question drills.</p>
        </div>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon rose">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
            </div>
            <h3>60-Minute Countdown Timer</h3>
            <p>Simulates official testing pressure with a persistent live timer, auto-submission safeguard, and full exam state preservation.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon blue">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="3" y="3" width="7" height="7"/>
                <rect x="14" y="3" width="7" height="7"/>
                <rect x="14" y="14" width="7" height="7"/>
                <rect x="3" y="14" width="7" height="7"/>
              </svg>
            </div>
            <h3>50-Question Balanced Jump Grid</h3>
            <p>Proportionately pulls scenario questions across Modules 1–7. Easily flag questions for review and jump across questions with one tap.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon emerald">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                <polyline points="22 4 12 14.01 9 11.01"/>
              </svg>
            </div>
            <h3>Diagnostic Report &amp; 1-Tap Drill</h3>
            <p>Evaluates your readiness against the official 75% passing threshold, highlights weak modules, and lets you immediately drill missed questions in Self-Study mode.</p>
          </div>
        </div>
      </section>

      {/* DLC Expansion Hub Section */}
      <section id="dlc" className="curriculum-section" style={{ borderTop: '1px solid rgba(255,255,255,0.06)' }}>
        <div className="section-header">
          <span className="badge" style={{ borderColor: 'rgba(59, 130, 246, 0.4)', color: '#60a5fa', background: 'rgba(59, 130, 246, 0.12)' }}>DLC Expansion Hub</span>
          <h2>Downloadable Content &amp; Curriculum Expansions</h2>
          <p>Expand your question bank without compromising privacy. Discover specialized packs, modular IRR deep-dives, and massive core expansions.</p>
        </div>

        <div className="features-grid">
          {/* Upcoming 700 Core Expansion Placeholder */}
          <div className="feature-card" style={{ border: '1.5px solid rgba(99, 102, 241, 0.5)', background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.8), rgba(15, 23, 42, 0.9))' }}>
            <div className="feature-icon purple">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#6366F1', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>Upcoming Core Pack</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>~700 Questions &bull; 320 KB</span>
            </div>
            <h3>DPA Mastery 700+ Core Expansion</h3>
            <p>Massive curriculum expansion adding ~700 deep-dive scenario questions across all 7 Modules (Framework, Concepts, Principles, Lawful Criteria, Subject Rights, Penalties, and Breach Management).</p>
          </div>

          {/* DPO Mock Exam DLC */}
          <div className="feature-card" style={{ border: '1.5px solid rgba(16, 185, 129, 0.5)', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.08), rgba(15, 23, 42, 0.9))' }}>
            <div className="feature-icon emerald">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#10B981', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>ACE Exam Suite</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>150 Scenarios &bull; 190 KB</span>
            </div>
            <h3>DPO ACE Mock Exam Suite</h3>
            <p>Comprehensive 150-scenario high-difficulty exam pool. Dynamically generates balanced 50-question randomized mock exams with a 60-min timer, full module diagnostics, and digital certification.</p>
          </div>

          {/* NPC IRR & Circulars DLC */}
          <div className="feature-card">
            <div className="feature-icon amber">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10 9 9 9 8 9"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#F59E0B', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>Advanced</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>120 Questions &bull; 65 KB</span>
            </div>
            <h3>NPC IRR &amp; Landmark Circulars</h3>
            <p>Specialized pack covering the 2016 IRR, NPC Circular 16-01 (Security), 16-03 (Breach Management), 2020-01 (Data Sharing), and 2022-01 (Fines).</p>
          </div>

          {/* Industry Scenarios DLC */}
          <div className="feature-card">
            <div className="feature-icon cyan">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
                <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
              </svg>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span className="badge" style={{ background: '#06B6D4', color: '#fff', fontSize: '11px', padding: '2px 8px' }}>Specialized</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>80 Questions &bull; 48 KB</span>
            </div>
            <h3>Industry Scenarios: Health, Fintech &amp; BPO</h3>
            <p>Real-world case studies covering Telemedicine, BSP/AMLA vs DPA compliance for e-wallets, and BPO cross-border data transfer exemptions under Section 4(g).</p>
          </div>

          {/* Progression Safeguards Feature */}
          <div className="feature-card">
            <div className="feature-icon emerald">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              </svg>
            </div>
            <h3>Progression Protection (Never Re-locks)</h3>
            <p>Persistent high-water mark tracking and absolute Guru milestones guarantee that downloading 700+ new questions will never re-lock your earned difficulty tiers.</p>
          </div>

          {/* Self-Study Expansion Track */}
          <div className="feature-card">
            <div className="feature-icon blue">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
            </div>
            <h3>Self-Study Expansion Track</h3>
            <p>Targeted drilling in Self-Study mode. Filter by installed DLC packs (e.g. <em>DLC: DPO Certification Mock Exam</em>) to practice expansion questions on demand.</p>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="features-section">
        <div className="section-header">
          <span className="badge">Why DPA Mastery</span>
          <h2>Engineered for High-Stakes DPO Certification</h2>
          <p>Traditional cramming fades in 48 hours. Our SRS scientifically schedules recall tests at the exact moment forgetting begins.</p>
        </div>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon purple">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
            </div>
            <h3>Proven 8-Stage SRS</h3>
            <p>Cards progress from Apprentice (1–4) through Guru (5–6), Master (7), and Burned (8) with exponential review timing intervals.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon emerald">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              </svg>
            </div>
            <h3>Review-First Gating &amp; Apprentice Cap</h3>
            <p>Smart review throttling prevents study overload by requiring pending reviews to be cleared before unlocking new lessons.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon blue">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <h3>High-Water Milestone Progression</h3>
            <p>Five structured competency tiers unlock based on absolute Guru milestones and persistent high-water progress protection.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon amber">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
              </svg>
            </div>
            <h3>7-Module Curriculum Mastery</h3>
            <p>Dedicated real-time mastery rings track your progress across each of the 7 NPC examination syllabus modules independently.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon cyan">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
              </svg>
            </div>
            <h3>100% Privacy by Design</h3>
            <p>No account required, no server logins, zero analytics. In full compliance with RA 10173, all user data stays in your local device SQLite database.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon rose">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
              </svg>
            </div>
            <h3>Composite Readiness &amp; Time-to-Exam</h3>
            <p>Weighted score blending Guru+ depth with 7-module syllabus coverage, paired with a real-time completion timeline estimator based on your daily pace.</p>
          </div>
        </div>
      </section>

      {/* Exam Readiness & Timeline Estimator Section */}
      <section className="srs-explainer-section" style={{ borderTop: '1px solid rgba(255,255,255,0.06)' }}>
        <div className="srs-explainer-card" style={{ background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.7), rgba(15, 23, 42, 0.85))' }}>
          <div className="srs-badge-wrap">
            <span className="badge" style={{ borderColor: 'rgba(16, 185, 129, 0.4)', color: '#34d399', background: 'rgba(16, 185, 129, 0.12)' }}>Pace &amp; Timeline Estimator</span>
          </div>
          <h2>How Long Until You Are Exam Ready?</h2>
          <p className="srs-lead">
            DPA Mastery actively estimates your <strong>Exam Readiness Timeline</strong> by combining your current Guru rate with your selected daily study pace.
          </p>

          <div className="srs-comparison-grid">
            <div className="srs-box" style={{ background: 'rgba(99, 102, 241, 0.08)', borderColor: 'rgba(99, 102, 241, 0.25)' }}>
              <div className="srs-box-header">
                <span className="box-icon">⚡</span>
                <h4>Intensive Pace (20 Qs / Day)</h4>
              </div>
              <p>Ideal for candidates testing in <strong>3 to 4 weeks</strong>. Introduces all core questions rapidly while cycling through Apprentice reviews for early Guru lock-in.</p>
            </div>

            <div className="srs-box" style={{ background: 'rgba(16, 185, 129, 0.08)', borderColor: 'rgba(16, 185, 129, 0.25)' }}>
              <div className="srs-box-header">
                <span className="box-icon">🎯</span>
                <h4>Recommended Pace (10 Qs / Day)</h4>
              </div>
              <p>Ideal for working DPOs and privacy practitioners. Achieves <strong>80%+ Exam Readiness in ~5 to 6 weeks</strong> with zero study overload.</p>
            </div>

            <div className="srs-box" style={{ background: 'rgba(14, 165, 233, 0.08)', borderColor: 'rgba(14, 165, 233, 0.25)' }}>
              <div className="srs-box-header">
                <span className="box-icon">🌱</span>
                <h4>Steady Pace (5 Qs / Day)</h4>
              </div>
              <p>Low-pressure mastery in <strong>8 to 10 weeks</strong>. Strengthens foundational retention before progressing to advanced compliance tiers.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Tier Progression Section */}
      <section id="tiers" className="curriculum-section" style={{ borderTop: '1px solid rgba(255,255,255,0.06)' }}>
        <div className="section-header">
          <span className="badge">Competency Roadmap</span>
          <h2>5 Progressive Certification Tiers</h2>
          <p>Structured progression from foundational definitions to edge-case jurisprudential mastery.</p>
        </div>

        <div className="curriculum-list">
          <div className="curriculum-item">
            <span className="module-num" style={{ color: '#5E6AD2' }}>T1</span>
            <div className="module-text">
              <h4>Tier 1: Foundations (43 Questions)</h4>
              <p>Constitutional foundations, statutory definitions, core principles, and basic rights. Always available on Day 1.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num" style={{ color: '#0EA5E9' }}>T2</span>
            <div className="module-text">
              <h4>Tier 2: Compliance Practitioner (60 Questions)</h4>
              <p>Key legal definitions, consent criteria, PIC/PIP duties, and mandatory registration requirements. Unlocks at 35 Gurus or 85% Tier 1.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num" style={{ color: '#10B981' }}>T3</span>
            <div className="module-text">
              <h4>Tier 3: Privacy Specialist (79 Questions)</h4>
              <p>Single-concept application scenarios, legitimate interest assessments, and data sharing agreement protocols. Unlocks at 75 Gurus.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num" style={{ color: '#F59E0B' }}>T4</span>
            <div className="module-text">
              <h4>Tier 4: Lead Privacy Architect (69 Questions)</h4>
              <p>Multi-concept complex scenarios, 72-hour breach containment drills, cross-border data transfer mechanisms, and security governance. Unlocks at 150 Gurus.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num" style={{ color: '#EF4444' }}>T5</span>
            <div className="module-text">
              <h4>Tier 5: Master DPO (31 Questions)</h4>
              <p>Edge cases, statutory exclusions (AMLA, journalism, intelligence), jurisprudence, corporate officer criminal liability, and NPC advisories. Unlocks at 250 Gurus.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Curriculum Overview */}
      <section id="curriculum" className="curriculum-section">
        <div className="section-header">
          <span className="badge">NPC Alignment</span>
          <h2>Comprehensive 7-Module Curriculum</h2>
          <p>Covering every competency tested in the Philippine Data Protection Officer certification.</p>
        </div>

        <div className="curriculum-list">
          <div className="curriculum-item">
            <span className="module-num">01</span>
            <div className="module-text">
              <h4>Module 1: General Provisions &amp; Framework</h4>
              <p>Constitutional foundations, NPC mandate, extraterritorial scope, and statutory exclusions (journalism, research, AMLA).</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num">02</span>
            <div className="module-text">
              <h4>Module 2: Key Concepts &amp; Definitions</h4>
              <p>Personal Info vs. Sensitive Personal Info, PIC vs. PIP distinctions, DPO designations, and accountability mechanisms.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num">03</span>
            <div className="module-text">
              <h4>Module 3: General Data Privacy Principles</h4>
              <p>Core pillars of Transparency, Legitimate Purpose, and Proportionality applied to real-world corporate scenarios.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num">04</span>
            <div className="module-text">
              <h4>Module 4: Lawful Processing Criteria</h4>
              <p>Section 12 &amp; 13 legal bases: Consent validity, contractual necessity, legitimate interest balancing, and vital interests.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num">05</span>
            <div className="module-text">
              <h4>Module 5: Data Subject Rights</h4>
              <p>Rights to be informed, access, object, erasure/blocking, damages, portability, and lodging complaints before the NPC.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num">06</span>
            <div className="module-text">
              <h4>Module 6: Accountability &amp; Penalties</h4>
              <p>Corporate veil piercing (Section 34), criminal penalties, fines, and organizational/physical/technical security measures.</p>
            </div>
          </div>
          <div className="curriculum-item">
            <span className="module-num">07</span>
            <div className="module-text">
              <h4>Module 7: Data Breach Management</h4>
              <p>Mandatory 72-hour NPC breach notification threshold, incident containment, data subject notices, and annual security reporting.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Downloads Section */}
      <section id="downloads" className="downloads-section">
        <div className="section-header">
          <span className="badge" style={{ borderColor: 'rgba(16, 185, 129, 0.4)', color: '#34D399', background: 'rgba(16, 185, 129, 0.1)' }}>100% Offline Study Companion</span>
          <h2>Download DPA Mastery v{APP_CONFIG.version}</h2>
          <p>Study anywhere, anytime with zero internet required. <strong>Install the native Android app to run DPA Mastery completely offline</strong> with full local SQLite persistence, zero ads, and zero subscriptions.</p>
        </div>

        <div className="downloads-grid">
          {/* Android Card */}
          <div className="download-card primary-platform" style={{ borderColor: 'rgba(16, 185, 129, 0.5)', background: 'linear-gradient(180deg, rgba(16, 185, 129, 0.08) 0%, rgba(15, 23, 42, 0.9) 100%)', boxShadow: '0 10px 30px rgba(16, 185, 129, 0.15)' }}>
            <div className="platform-header">
              <div className="platform-icon android" style={{ background: 'rgba(16, 185, 129, 0.2)', color: '#34D399' }}>
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M4 10l0 6" />
                  <path d="M20 10l0 6" />
                  <path d="M7 9h10v8a1 1 0 0 1 -1 1h-8a1 1 0 0 1 -1 -1v-8a5 5 0 0 1 10 0" />
                  <path d="M8 3l1 2" />
                  <path d="M16 3l-1 2" />
                  <path d="M9 12v.01" />
                  <path d="M15 12v.01" />
                </svg>
              </div>
              <div>
                <h3>Android APK</h3>
                <span className="platform-tag" style={{ color: '#34D399' }}>★ Runs 100% Offline • No Internet Needed</span>
              </div>
            </div>
            <p className="platform-desc">
              <strong>Run DPA Mastery anywhere without Wi-Fi or mobile data.</strong> Features offline SQLite database, instant review sessions, spaced repetition scheduling, and full timed DPO Mock Exam simulation.
            </p>
            <div className="download-actions">
              <a href={APP_CONFIG.downloads.androidApk} target="_blank" rel="noreferrer" className="btn-download" style={{ background: 'linear-gradient(135deg, #10B981 0%, #059669 100%)' }}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                  <polyline points="7 10 12 15 17 10"/>
                  <line x1="12" y1="15" x2="12" y2="3"/>
                </svg>
                Download Offline APK (.apk) &rarr;
              </a>
              <span className="meta-info">Android 8.0+ (Oreo or later) • Guaranteed 100% Offline • v{APP_CONFIG.version}</span>
            </div>
          </div>

          {/* Windows Card */}
          <div className="download-card">
            <div className="platform-header">
              <div className="platform-icon windows">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M3 5.5l7.5-1v7.5H3V5.5zm8.5-1.1L21 3v9H11.5V4.4zM3 13h7.5v7.5L3 19.5V13zm8.5 0H21v9l-9.5-1.4V13z" />
                </svg>
              </div>
              <div>
                <h3>Windows</h3>
                <span className="platform-tag">Desktop Edition</span>
              </div>
            </div>
            <p className="platform-desc">Native standalone 64-bit desktop executable for intensive study sessions, timed mock exams, and expansion packs.</p>
            <div className="download-actions">
              <a href={APP_CONFIG.downloads.windowsInstaller} target="_blank" rel="noreferrer" className="btn-download">
                Download Installer (.exe) &rarr;
              </a>
              <a href={APP_CONFIG.downloads.windowsZip} target="_blank" rel="noreferrer" className="btn-download secondary">
                Portable Standalone (.zip)
              </a>
              <span className="meta-info">Windows 10 / 11 (64-bit) • v{APP_CONFIG.version}</span>
            </div>
          </div>

          {/* Web App Card */}
          <div className="download-card" style={{ opacity: 0.8 }}>
            <div className="platform-header">
              <div className="platform-icon" style={{ background: 'rgba(255, 255, 255, 0.05)', color: '#94a3b8' }}>
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10"/>
                  <line x1="2" y1="12" x2="22" y2="12"/>
                  <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                </svg>
              </div>
              <div>
                <h3>Web App</h3>
                <span className="platform-tag" style={{ color: '#94a3b8' }}>In Active Development</span>
              </div>
            </div>
            <p className="platform-desc">Browser edition for online practice and review is currently undergoing optimization for web runtime compatibility.</p>
            <div className="download-actions">
              <button disabled className="btn-download" style={{ background: 'rgba(255, 255, 255, 0.08)', color: '#94a3b8', cursor: 'not-allowed', border: '1px solid rgba(255, 255, 255, 0.1)' }}>
                Web Version Coming Soon
              </button>
              <span className="meta-info">Native Android APK &amp; Windows recommended</span>
            </div>
          </div>
        </div>
      </section>

      {/* Community Support & Sponsor Section */}
      <section id="sponsor" className="sponsor-section">
        <div className="sponsor-card">
          <div className="sponsor-card-glow"></div>
          <div className="sponsor-header">
            <span className="badge" style={{ borderColor: 'rgba(255, 66, 77, 0.4)', color: '#ff424d', background: 'rgba(255, 66, 77, 0.12)' }}>Support Independent Development</span>
            <h2>Support DPA Mastery</h2>
            <p>
              DPA Mastery is 100% free, privacy-first, and ad-free. If this study companion has helped you prepare for your NPC DPO certification or bolster your team's compliance, consider supporting ongoing development.
            </p>
          </div>

          <div className="sponsor-links-grid">
            {/* Patreon */}
            <a href="https://www.patreon.com/c/alfredosanchezjr" target="_blank" rel="noopener noreferrer" className="sponsor-item-card patreon">
              <div className="sponsor-icon-wrap patreon-bg">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M14.82 2.41a6.45 6.45 0 0 0-6.45 6.45c0 3.56 2.89 6.45 6.45 6.45a6.45 6.45 0 0 0 6.45-6.45 6.45 6.45 0 0 0-6.45-6.45zM2.73 21.59h3.76V2.41H2.73v19.18z"/>
                </svg>
              </div>
              <h4>Patreon</h4>
              <p>Monthly support with early DLC pack access, candidate study notes, and credit recognition.</p>
              <span className="sponsor-item-btn">Join on Patreon &rarr;</span>
            </a>

            {/* Buy Me a Coffee */}
            <a href="https://buymeacoffee.com/tildemark" target="_blank" rel="noopener noreferrer" className="sponsor-item-card coffee">
              <div className="sponsor-icon-wrap coffee-bg">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M18 8h1a4 4 0 0 1 0 8h-1"/>
                  <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/>
                  <line x1="6" y1="1" x2="6" y2="4"/>
                  <line x1="10" y1="1" x2="10" y2="4"/>
                  <line x1="14" y1="1" x2="14" y2="4"/>
                </svg>
              </div>
              <h4>Buy Me a Coffee</h4>
              <p>Quick one-time token of appreciation to fuel midnight coding and curriculum expansion.</p>
              <span className="sponsor-item-btn">Buy a Coffee &rarr;</span>
            </a>

            {/* GitHub */}
            <a href="https://github.com/tildemark" target="_blank" rel="noopener noreferrer" className="sponsor-item-card github">
              <div className="sponsor-icon-wrap github-bg">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                  <path fillRule="evenodd" clipRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
                </svg>
              </div>
              <h4>GitHub Profile</h4>
              <p>Star the repo, report questions, submit corrections, or track future releases.</p>
              <span className="sponsor-item-btn">Follow @tildemark &rarr;</span>
            </a>
          </div>

          <div className="sponsor-perks-list">
            <div className="sponsor-perk-item">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>100% Free &amp; Open Learning Core</span>
            </div>
            <div className="sponsor-perk-item">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>Early DLC &amp; Scenario Expansions</span>
            </div>
            <div className="sponsor-perk-item">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>Community Acknowledgement</span>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer-section">
        <div className="footer-content">
          <div className="footer-brand">
            <div className="logo-group">
              <div className="logo-icon small">
                <img src="/logo-512.png" alt="DPA Mastery Logo" width={28} height={28} />
              </div>
              <span className="logo-text">DPA Mastery</span>
            </div>
            <p className="footer-tagline">
              Dedicated offline study platform for aspiring Philippine Data Protection Officers (DPO).
            </p>
          </div>

          <div className="footer-links-grid">
            <div className="footer-column">
              <h5>Navigation</h5>
              <a href="#features">Features</a>
              <a href="#mock-exam">Mock Exam</a>
              <a href="#dlc">DLC Expansion Hub</a>
              <a href="#tiers">Tier Progression</a>
              <a href="#curriculum">Curriculum</a>
              <a href="#downloads">Downloads</a>
            </div>
            <div className="footer-column">
              <h5>Support &amp; Community</h5>
              <a href="https://www.patreon.com/c/alfredosanchezjr" target="_blank" rel="noopener noreferrer">Patreon (@alfredosanchezjr)</a>
              <a href="https://buymeacoffee.com/tildemark" target="_blank" rel="noopener noreferrer">Buy Me a Coffee (@tildemark)</a>
              <a href="https://github.com/tildemark/dpa-mastery" target="_blank" rel="noopener noreferrer">GitHub Repository</a>
              <a href="https://github.com/tildemark/dpa-mastery/releases" target="_blank" rel="noopener noreferrer">Release Notes</a>
            </div>
            <div className="footer-column">
              <h5>Legal &amp; Privacy</h5>
              <Link href="/privacy">Privacy Policy &amp; Notice</Link>
              <Link href="/terms">Terms of Service</Link>
              <span>100% Offline SQLite Storage</span>
              <span>Zero Telemetry / No Tracking</span>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <p>&copy; 2026 <a href="https://sanchez.ph" target="_blank" rel="noopener noreferrer" style={{ color: 'inherit', textDecoration: 'underline' }}>Alfredo Sanchez Jr.</a> &bull; DPA Mastery. All rights reserved.</p>
          <p className="footer-subtext">Not officially affiliated with the National Privacy Commission (NPC). Designed as an educational study aid.</p>
        </div>
      </footer>
    </div>
  );
}

