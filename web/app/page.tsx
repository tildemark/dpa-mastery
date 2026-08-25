export default function HomePage() {
  const seedFiles = [
    { name: 'Manifest', path: '/manifest.json', desc: 'OTA seed versions and distribution registry.' },
    { name: 'Module 1: General Provisions & Framework', path: '/seeds/module1.json', desc: 'Constitutional basis, NPC mandate, scope, statutory exclusions.' },
    { name: 'Module 2: Key Concepts & Definitions', path: '/seeds/module2.json', desc: 'Personal info, sensitive personal info, PIC vs PIP, accountability.' },
    { name: 'Module 3: General Data Privacy Principles', path: '/seeds/module3.json', desc: 'Transparency, Legitimate Purpose, Proportionality in depth.' },
    { name: 'Module 4: Lawful Processing Criteria', path: '/seeds/module4.json', desc: 'Section 12 & 13 lawful criteria and privileged information.' },
    { name: 'Module 5: Data Subject Rights', path: '/seeds/module5.json', desc: 'Rights to be informed, access, object, rectify, erase, data portability.' },
    { name: 'Module 6: Accountability & Penalties', path: '/seeds/module6.json', desc: 'DPO roles, security measures, criminal and administrative liabilities.' },
    { name: 'Module 7: Data Breach Management', path: '/seeds/module7.json', desc: 'Mandatory 72-hour notifications, incident response, NPC reports.' },
  ];

  return (
    <main className="container">
      <header>
        <span className="badge">DPA Mastery OTA Repository</span>
        <h1>DPA Mastery</h1>
        <p className="subtitle">
          Offline-first WaniKani-style SRS study platform for the Philippine NPC Data Privacy Competency Examination.
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
        <p>&copy; 2026 DPA Mastery. Designed for the Philippine National Privacy Commission DPO Certification.</p>
      </footer>
    </main>
  );
}
