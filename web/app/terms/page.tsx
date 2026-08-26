import Link from 'next/link';

export default function TermsPage() {
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
            <Link href="/privacy">Privacy Notice</Link>
          </div>
        </div>
      </nav>

      <main className="legal-container">
        <div className="legal-header">
          <span className="badge">User Agreement</span>
          <h1>Terms of Service</h1>
          <p className="subtitle">Last Updated: August 26, 2026</p>
        </div>

        <div className="legal-card">
          <section className="legal-section">
            <h2>1. Acceptance of Terms</h2>
            <p>
              By downloading, installing, accessing, or using the <strong>DPA Mastery</strong> application (across Android, Windows, iOS, or web platforms), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not install or use the application.
            </p>
          </section>

          <section className="legal-section">
            <h2>2. Purpose &amp; Educational Disclaimer</h2>
            <p>
              <strong>DPA Mastery</strong> is an independent educational and self-study tool designed to assist candidates in preparing for examinations and assessments related to Republic Act No. 10173 (The Data Privacy Act of 2012) and the National Privacy Commission (NPC) frameworks.
            </p>
            <div className="disclaimer-box">
              <strong>Important Notice:</strong> DPA Mastery is <em>not affiliated with, endorsed by, or sponsored by the National Privacy Commission (NPC)</em> or any government entity of the Republic of the Philippines. Completing practice modules within this software does not constitute official certification, accredited continuing professional development (CPD), or legal accreditation.
            </div>
          </section>

          <section className="legal-section">
            <h2>3. No Legal Advice</h2>
            <p>
              The explanations, scenario questions, statutory references, and commentary provided within the app are strictly for general educational purposes. They do not constitute formal legal advice, compliance audits, or binding statutory interpretations. Users requiring official legal counsel regarding data protection compliance should consult a licensed Philippine attorney or a certified Data Protection Officer.
            </p>
          </section>

          <section className="legal-section">
            <h2>4. Intellectual Property &amp; License</h2>
            <p>
              The software code, design system, and Spaced Repetition algorithms are intellectual property of <strong>Alfredo Sanchez Jr.</strong> and contributors. You are granted a personal, revocable, non-exclusive, non-transferable license to use the app for personal, non-commercial study.
            </p>
            <p>
              Statutory provisions of Republic Act No. 10173, its Implementing Rules and Regulations (IRR), and public issuances of the NPC remain in the public domain under Philippine copyright law.
            </p>
          </section>

          <section className="legal-section">
            <h2>5. Disclaimer of Warranties &amp; Limitation of Liability</h2>
            <p>
              The application is provided on an <strong>"AS IS" and "AS AVAILABLE"</strong> basis without warranties of any kind, either express or implied. In no event shall the author or copyright holders be liable for any claim, damages, or other liability arising from the use of or inability to use the software.
            </p>
          </section>

          <section className="legal-section">
            <h2>6. Modifications to Terms</h2>
            <p>
              We reserve the right to modify these Terms of Service as new updates or regulatory provisions are introduced. Continued use of the software constitutes acceptance of any revised terms.
            </p>
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
