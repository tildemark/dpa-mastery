import Link from 'next/link';

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
            <span className="version-pill">v1.2</span>
          </div>

          <div className="nav-links">
            <a href="#features">Features</a>
            <a href="#curriculum">Curriculum</a>
            <a href="#downloads">Downloads</a>
            <Link href="/updates" className="nav-updates-link">
              OTA Seeds &amp; API &rarr;
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <header className="hero-section">
        <div className="hero-glow"></div>
        <div className="hero-content">
          <div className="hero-badge">
            <span className="badge-dot"></span>
            <span>Philippine NPC DPO Certification Exam Prep</span>
          </div>

          <h1 className="hero-title">
            Master the Data Privacy Act of 2012 with <span className="gradient-text">Spaced Repetition</span>
          </h1>

          <p className="hero-description">
            The offline-first, SRS-powered study companion for the Philippine National Privacy Commission (NPC) DPO Certification Examination. Lock in RA 10173 concepts permanently.
          </p>

          <div className="hero-cta-group">
            <a href="#downloads" className="btn-primary">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/>
                <line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              Download App Free
            </a>
            <a href="#features" className="btn-secondary">
              Explore SRS Engine
            </a>
          </div>

          {/* Guarantee Badges */}
          <div className="hero-highlights">
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>100% Offline-First</span>
            </div>
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>Zero Tracking / No Telemetry</span>
            </div>
            <div className="highlight-item">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              <span>Comprehensive 7-Module Syllabus</span>
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
            <span className="mockup-title">DPA Mastery Dashboard — SRS Progress &amp; Rank</span>
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
                <span className="stat-sub">1 week • 2 weeks (Unlocks Next Level)</span>
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
              <span className="step-badge">1. Lesson</span>
              <span className="step-time">Instant</span>
              <span className="step-desc">Learn concept</span>
            </div>
            <span className="timeline-arrow">&rarr;</span>
            <div className="timeline-step">
              <span className="step-badge">2. Apprentice</span>
              <span className="step-time">4h – 48h</span>
              <span className="step-desc">Initial recall</span>
            </div>
            <span className="timeline-arrow">&rarr;</span>
            <div className="timeline-step">
              <span className="step-badge">3. Guru</span>
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
            <h3>85% Guru Tier Progression Gating</h3>
            <p>Difficulty levels 1 through 5 unlock sequentially only after demonstrating 85%+ mastery of preceding prerequisite concepts.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon amber">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
              </svg>
            </div>
            <h3>Flexible Cram &amp; Tag Drill Modes</h3>
            <p>Target specific focus areas like "Consent", "Breach Notification", or "DPO Liabilities" outside the strict SRS timer.</p>
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
            <h3>Over-The-Air Question Expansion</h3>
            <p>Automatic background OTA sync pulls newly published practice scenarios, jurisprudence updates, and NPC Circular revisions.</p>
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
          <span className="badge">Get Started</span>
          <h2>Download DPA Mastery</h2>
          <p>Available for Android and Windows Desktop. 100% offline, zero ads, zero subscriptions.</p>
        </div>

        <div className="downloads-grid">
          {/* Android Card */}
          <div className="download-card primary-platform">
            <div className="platform-header">
              <div className="platform-icon android">
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
                <h3>Android</h3>
                <span className="platform-tag">Recommended • APK Direct</span>
              </div>
            </div>
            <p className="platform-desc">Universal ARM64 / x86_64 APK with offline SQLite database and all 7 modules pre-bundled.</p>
            <div className="download-actions">
              <a href="https://github.com/tildemark/dpa-mastery/releases/download/v1.2.0/dpa_mastery_v1.2.0_android.apk" target="_blank" rel="noreferrer" className="btn-download">
                Download APK (.apk) &rarr;
              </a>
              <span className="meta-info">Android 8.0+ (Oreo or later) • v1.2.0</span>
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
            <p className="platform-desc">Native standalone 64-bit desktop executable for intensive study sessions and mock exams.</p>
            <div className="download-actions">
              <a href="https://github.com/tildemark/dpa-mastery/releases/download/v1.2.0/dpa_mastery_v1.2.0_windows_x64.zip" target="_blank" rel="noreferrer" className="btn-download secondary">
                Download for Windows (.zip) &rarr;
              </a>
              <span className="meta-info">Windows 10 / 11 (64-bit) • v1.2.0</span>
            </div>
          </div>

          {/* iOS Card (Coming Soon) */}
          <div className="download-card coming-soon">
            <div className="platform-header">
              <div className="platform-icon apple">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 20.94c1.5 0 2.75 1.06 4 1.06 1.28 0 2.37-1.06 4-1.06 1.83 0 3.72 1.34 3.72 1.34s-2.89-1.63-2.89-4.8c0-3.32 2.73-4.8 2.73-4.8-1.57-2.33-4-2.42-4.88-2.42-2.12 0-3.4 1.25-4.48 1.25-1.12 0-2.65-1.25-4.48-1.25C7.2 10.22 4 12.44 4 16.73c0 4.16 2.57 9.27 5.72 9.27 1.43 0 2.58-.94 4-.94z"/>
                  <path d="M15.5 2c0 1.94-1.39 3.5-3 3.5-.22 0-.44-.02-.65-.08.15-1.78 1.58-3.42 3.65-3.42z"/>
                </svg>
              </div>
              <div>
                <h3>iOS / iPadOS</h3>
                <span className="platform-tag" style={{ color: '#94a3b8' }}>Coming Soon</span>
              </div>
            </div>
            <p className="platform-desc">iOS package and TestFlight beta invitations are currently in preparation.</p>
            <div className="download-actions">
              <button disabled className="btn-download secondary" style={{ opacity: 0.6, cursor: 'not-allowed' }}>
                iOS Build Coming Soon
              </button>
              <span className="meta-info">Requires iOS 15.0 or later</span>
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
              <a href="#curriculum">Curriculum</a>
              <a href="#downloads">Downloads</a>
            </div>
            <div className="footer-column">
              <h5>Developers &amp; OTA</h5>
              <Link href="/updates">Seed Registry</Link>
              <a href="/manifest.json" target="_blank" rel="noreferrer">Manifest JSON</a>
              <a href="https://github.com/tildemark/dpa-mastery" target="_blank" rel="noreferrer">GitHub Repository</a>
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
