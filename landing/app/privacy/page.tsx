import Link from 'next/link';

export default function PrivacyPage() {
  return (
    <div className="legal-page">
      <nav className="navbar">
        <div className="nav-container">
          <Link href="/" className="logo-group" style={{ textDecoration: 'none' }}>
            <div className="logo-icon small">
              <img src="/logo-512.png" alt="DPA Mastery Logo" width={28} height={28} />
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
              All study data generated during your usage—including your spaced repetition stages (Apprentice, Guru, Master, Burned), question tags, daily lesson quotas, and profile settings—is stored locally in a private SQLite database managed directly by your platform environment (Android, Windows Desktop, or Web IndexedDB).
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
              <p>
                <strong>Alfredo Sanchez Jr.</strong><br/>
                Lead Developer, DPA Mastery<br/>
                Website: <a href="https://sanchez.ph" target="_blank" rel="noopener noreferrer" style={{ color: 'var(--primary-light)', textDecoration: 'underline' }}>https://sanchez.ph</a>
              </p>
            </div>
          </section>
        </div>
      </main>

      <footer className="footer-section" style={{ marginTop: '4rem' }}>
        <div className="legal-footer">
          <p>&copy; 2026 <a href="https://sanchez.ph" target="_blank" rel="noopener noreferrer" style={{ color: 'inherit', textDecoration: 'underline' }}>Alfredo Sanchez Jr.</a> &bull; DPA Mastery. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
