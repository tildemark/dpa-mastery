import Link from 'next/link';

export default function UpdatesPage() {
  const seedFiles = [
    { name: 'Manifest', path: '/manifest.json', desc: 'OTA seed versions and distribution registry.' },
    { name: 'Module 1: General Provisions & Framework', path: '/seeds/module1.json', desc: 'Constitutional basis, NPC mandate, scope, statutory exclusions.' },
    { name: 'Module 1.01: Extended Framework Practice', path: '/seeds/update_v5_module1_expanded.json', desc: 'Detailed scenarios, NPC jurisdiction, government & BPO exclusions.' },
    { name: 'Module 2: Key Concepts & Definitions', path: '/seeds/module2.json', desc: 'Personal info, sensitive personal info, PIC vs PIP, accountability.' },
    { name: 'Module 3: General Data Privacy Principles', path: '/seeds/module3.json', desc: 'Transparency, Legitimate Purpose, Proportionality in depth.' },
    { name: 'Module 4: Lawful Processing Criteria', path: '/seeds/module4.json', desc: 'Section 12 & 13 lawful criteria and privileged information.' },
    { name: 'Module 5: Data Subject Rights', path: '/seeds/module5.json', desc: 'Rights to be informed, access, object, rectify, erase, data portability.' },
    { name: 'Module 6: Accountability & Penalties', path: '/seeds/module6.json', desc: 'DPO roles, security measures, criminal and administrative liabilities.' },
    { name: 'Module 7: Data Breach Management', path: '/seeds/module7.json', desc: 'Mandatory 72-hour notifications, incident response, NPC reports.' },
    { name: 'Foundational Basics Batch (v10)', path: '/seeds/update_v10_foundational_batch.json', desc: 'Core fundamentals and key baseline questions.' },
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
