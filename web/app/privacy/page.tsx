import Link from 'next/link';

export default function PrivacyPage() {
  return (
    <div className="legal-page">
      <nav className="navbar">
        <div className="nav-container">
          <Link href="/" className="logo-group" style={{ textDecoration: 'none' }}>
            <div className="logo-icon small">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              </svg>
            </div>
            <span className="logo-text">DPA Mastery</span>
          </Link>
          <div className="nav-links">
            <Link href="/">&larr; Back to Home</Link>
            <Link href="/terms">Terms of Service</Link>
          </div>
        </div>
      </nav>

      <main className="legal-container">
        <div className="legal-header">
          <span className="badge">Data Privacy Notice</span>
          <h1>Privacy Policy &amp; Notice</h1>
          <p className="subtitle">Effective Date: August 26, 2026 &bull; In compliance with Republic Act No. 10173 (Data Privacy Act of 2012)</p>
        </div>

        <div className="legal-card">
          <section className="legal-section">
            <h2>1. Our Commitment to Privacy by Design</h2>
            <p>
              <strong>DPA Mastery</strong> is built by privacy professionals for privacy professionals. We believe that an educational tool dedicated to the Philippine Data Privacy Act of 2012 (RA 10173) must adhere to the highest standard of <em>Privacy by Design and by Default</em>.
            </p>
            <p>
              The application operates on a <strong>100% offline-first architecture</strong>. We do not collect, process, transmit, or monetize your personal information.
            </p>
          </section>

          <section className="legal-section">
            <h2>2. Information We Do NOT Collect</h2>
            <p>We strictly enforce zero data collection. Specifically:</p>
            <ul>
              <li><strong>No Personal Identification:</strong> No names, email addresses, phone numbers, or social media logins are collected. The display name configured in the app is stored strictly on your local device.</li>
              <li><strong>No Telemetry or Analytics:</strong> We do not employ third-party tracking SDKs, advertising IDs, heatmaps, or behavioral profiling tools (e.g., Google Analytics, Firebase Analytics, Facebook Pixel).</li>
              <li><strong>No Cloud Sync of Quiz Data:</strong> Your SRS review history, flashcard retention scores, mistake counts, and test sessions never leave your physical device.</li>
            </ul>
          </section>

          <section className="legal-section">
            <h2>3. Local Device Storage (SQLite)</h2>
            <p>
              All study data generated during your usage—including your spaced repetition stages (Apprentice, Guru, Master, Burned), question tags, daily lesson quotas, and profile settings—is stored locally in an encrypted/private SQLite database managed directly by your operating system (Android, Windows, or iOS).
            </p>
            <p>
              Uninstalling the application or clearing application data via your device operating system permanently deletes all local records.
            </p>
          </section>

          <section className="legal-section">
            <h2>4. Over-The-Air (OTA) Content Updates</h2>
            <p>
              The app periodically checks for published question updates (OTA seeds) hosted on our static GitHub repository. This process is a standard anonymous HTTP GET request for static JSON files. No user identifiers, device hardware serials, or usage histories are transmitted during this check.
            </p>
          </section>

          <section className="legal-section">
            <h2>5. Data Subject Rights (Section 16, RA 10173)</h2>
            <p>
              Under the Philippine Data Privacy Act of 2012, data subjects are endowed with statutory rights including the Right to be Informed, Right to Access, Right to Object, Right to Erasure or Blocking, and Right to Damages. Because DPA Mastery retains zero personal information on remote servers, you maintain absolute, uninhibited control over your data directly within the app settings.
            </p>
            <p>
              You may reset your progress, delete your profile, or clear all application data at any time via <strong>Study Preferences &rarr; Reset Progress</strong>.
            </p>
          </section>

          <section className="legal-section">
            <h2>6. Contact &amp; Governance</h2>
            <p>
              If you have inquiries regarding this Privacy Notice or our security practices, you may reach out directly to the developer:
            </p>
            <div className="contact-box">
              <strong>Alfredo Sanchez Jr.</strong><br/>
              Lead Developer &bull; DPA Mastery Project<br/>
              Website: <a href="https://sanchez.ph" target="_blank" rel="noreferrer">https://sanchez.ph</a><br/>
              Repository: <a href="https://github.com/tildeapp/dpa-mastery" target="_blank" rel="noreferrer">github.com/tildeapp/dpa-mastery</a>
            </div>
          </section>
        </div>
      </main>

      <footer className="footer-section" style={{ marginTop: '4rem' }}>
        <div className="footer-bottom">
          <p>&copy; 2026 Alfredo Sanchez Jr. &bull; DPA Mastery. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
