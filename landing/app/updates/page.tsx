import Link from 'next/link';

export default function UpdatesPage() {
  const seedFiles = [
    { name: 'OTA Manifest Registry', path: '/manifest.json', desc: 'OTA seed versions and distribution registry.' },
    { name: 'Core Question Bank (Master 282 Qs)', path: '/seeds/core_question_bank.json', desc: 'Consolidated master question bank across all 7 DPA modules, scenarios, and foundation sets.' },
    { name: '700+ Core Curriculum Expansion Pack', path: '/seeds/dlc_700_core_expansion.json', desc: 'Comprehensive 700-question DLC expansion covering deep-dive scenarios and compliance rules.' },
  ];

  return (
    <main className="container">
      <nav className="nav-bar">
        <Link href="/" className="nav-back">
          &larr; Back to App Overview
        </Link>
      </nav>

      <header>
        <span className="badge">OTA Feed & Content Seeds</span>
        <h1>Seed Updates & API Registry</h1>
        <p className="subtitle">
          Direct JSON endpoints and seed distribution manifests powering the offline-first DPA Mastery mobile and desktop apps.
        </p>
      </header>

      <section className="grid">
        {seedFiles.map((seed, idx) => (
          <div key={idx} className="card">
            <h3>{seed.name}</h3>
            <p>{seed.desc}</p>
            <a href={seed.path} target="_blank" rel="noreferrer" className="link-btn">
              View JSON Endpoint &rarr;
            </a>
          </div>
        ))}
      </section>

      <footer>
        <p>&copy; 2026 DPA Mastery. Designed for Philippine National Privacy Commission (NPC) DPO Certification.</p>
      </footer>
    </main>
  );
}
