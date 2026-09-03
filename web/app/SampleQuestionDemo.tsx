'use client';

import { useState } from 'react';

interface QuestionSample {
  id: number;
  module: string;
  moduleNum: string;
  badgeColor: string;
  difficulty: string;
  difficultyLevel: number;
  concept: string;
  question: string;
  options: string[];
  correctAnswer: string;
  citation: string;
  explanation: string;
}

const SAMPLE_QUESTIONS: QuestionSample[] = [
  {
    id: 1,
    module: 'Module 1: Framework & Jurisdiction',
    moduleNum: '01',
    badgeColor: '#6366f1',
    difficulty: 'Tier 1 • Foundations',
    difficultyLevel: 1,
    concept: 'Extraterritorial Scope of RA 10173 (Section 6)',
    question: 'A tech startup registered in Singapore with no physical branch or equipment in the Philippines collects and processes the personal data of Philippine citizens. Under RA 10173, does the National Privacy Commission (NPC) have jurisdiction?',
    options: [
      'No, because the entity maintains no local servers or registered branch inside Philippine territory.',
      'Yes, because RA 10173 explicitly has extraterritorial application when data processing relates to Philippine citizens or residents.',
      'No, the DPA strictly applies only to government entities and domestic Philippine corporations.',
      'Yes, but exclusively if the processing involves national defense or classified state secrets.'
    ],
    correctAnswer: 'Yes, because RA 10173 explicitly has extraterritorial application when data processing relates to Philippine citizens or residents.',
    citation: 'RA 10173 § 6 (Extraterritorial Application)',
    explanation: 'Section 6 of RA 10173 provides extraterritorial effect: it applies to acts or practices engaged in outside the Philippines if they relate to personal information about a Philippine citizen or resident, regardless of where servers or physical offices are located.'
  },
  {
    id: 2,
    module: 'Module 2: Roles & Definitions',
    moduleNum: '02',
    badgeColor: '#0ea5e9',
    difficulty: 'Tier 2 • Practitioner',
    difficultyLevel: 2,
    concept: 'Personal Information Controller (PIC) vs. Processor (PIP)',
    question: 'A retail bank hires an external cloud vendor to host its customer database under strict contract instructions. The vendor unilaterally repurposes customer transaction records to train its proprietary AI credit model. What is the legal consequence?',
    options: [
      'The vendor is praised for data optimization and continues operating solely as a PIP.',
      'The vendor breached its mandate and unlawfully assumed the role of a Personal Information Controller (PIC).',
      'The vendor and the bank automatically become Joint Controllers by operation of law.',
      'The vendor is fully exempt as long as customer names are replaced with random customer IDs.'
    ],
    correctAnswer: 'The vendor breached its mandate and unlawfully assumed the role of a Personal Information Controller (PIC).',
    citation: 'RA 10173 § 3(h), 3(i) & NPC Advisory Opinions',
    explanation: 'A PIP must strictly process personal data solely according to documented instructions and purposes set by the PIC. Determining new purposes or means of processing turns the processor into a PIC acting ultra vires, bearing full direct statutory liability.'
  },
  {
    id: 3,
    module: 'Module 2: Data Classification',
    moduleNum: '02',
    badgeColor: '#06b6d4',
    difficulty: 'Tier 1 • Foundations',
    difficultyLevel: 1,
    concept: 'Sensitive Personal Information (SPI) Classification - Section 3(l)',
    question: 'Under Section 3(l) of Republic Act No. 10173, which of the following is legally classified as Sensitive Personal Information (SPI)?',
    options: [
      'A corporate employee\'s official business email address and office desk extension',
      'Government-issued identification numbers (e.g., SSS, GSIS, TIN, Passport, Driver\'s License)',
      'A customer\'s preferred shipping address and public social media handle',
      'A person\'s job title and department division within a private company'
    ],
    correctAnswer: 'Government-issued identification numbers (e.g., SSS, GSIS, TIN, Passport, Driver\'s License)',
    citation: 'RA 10173 § 3(l)(3) (Government-Issued Identifiers)',
    explanation: 'Government-issued identifiers peculiar to an individual (such as SSS, GSIS, TIN, Passport, and Driver\'s License numbers) are explicitly classified as Sensitive Personal Information under Section 3(l) of RA 10173, requiring heightened statutory safeguards.'
  },
  {
    id: 4,
    module: 'Module 4: Lawful Criteria',
    moduleNum: '04',
    badgeColor: '#10b981',
    difficulty: 'Tier 3 • Privacy Specialist',
    difficultyLevel: 3,
    concept: 'Lawful Processing of Sensitive Personal Information - Section 13(e)',
    question: 'A private hospital processes an unconscious emergency room patient\'s medical history and blood type for urgent life-saving treatment. Under Section 13 of the DPA, what is the lawful basis for processing this SPI without prior consent?',
    options: [
      'Processing is necessary for medical treatment by a medical practitioner bound by professional confidentiality.',
      'The hospital is exempt from the DPA because private healthcare entities are excluded under Section 4.',
      'The hospital must obtain a formal retroactive emergency waiver signed by the NPC within 24 hours.',
      'Processing is only lawful if the patient\'s next of kin publishes a public emergency waiver online.'
    ],
    correctAnswer: 'Processing is necessary for medical treatment by a medical practitioner bound by professional confidentiality.',
    citation: 'RA 10173 § 13(e) (Medical Treatment Exemption)',
    explanation: 'Section 13(e) permits processing Sensitive Personal Information without prior consent when necessary for medical treatment, provided it is carried out by a medical practitioner or treatment institution maintaining professional secrecy and data protection.'
  },
  {
    id: 5,
    module: 'Module 7: Breach Management',
    moduleNum: '07',
    badgeColor: '#ef4444',
    difficulty: 'Tier 4 • Lead Architect',
    difficultyLevel: 4,
    concept: 'Mandatory 72-Hour Breach Notification Protocol (Section 20(f))',
    question: 'An online financial services platform discovers an unauthorized database breach compromising 20,000 users\' passwords, credit card numbers, and government IDs. By what statutory deadline must the PIC report this incident to the NPC and affected data subjects?',
    options: [
      'Within 30 calendar days following the submission of a comprehensive external audit report.',
      'Within 72 hours from the time knowledge of the breach was acquired by the PIC.',
      'Within 7 calendar days only if the affected users reside in Metro Manila.',
      'Breach reporting to the NPC is voluntary and left to internal management discretion.'
    ],
    correctAnswer: 'Within 72 hours from the time knowledge of the breach was acquired by the PIC.',
    citation: 'RA 10173 § 20(f) & NPC Circular 16-03 § 5',
    explanation: 'Under Section 20(f) and NPC Circular 16-03, when sensitive personal information or financial data is reasonably believed to have been breached and presents a real risk of serious harm, the PIC must notify the NPC and data subjects within 72 hours of gaining knowledge.'
  }
];

export default function SampleQuestionDemo() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [showExplanation, setShowExplanation] = useState(false);
  const [mode, setMode] = useState<'practice' | 'concept'>('practice');
  const [score, setScore] = useState<{ correct: number; total: number }>({ correct: 0, total: 0 });
  const [answeredMap, setAnsweredMap] = useState<Record<number, { selected: string; isCorrect: boolean }>>({});

  const currentQ = SAMPLE_QUESTIONS[currentIndex];
  const currentAnswerState = answeredMap[currentQ.id];
  const isAnswered = selectedOption !== null || currentAnswerState !== undefined;

  const handleSelect = (option: string) => {
    if (isAnswered) return;
    const isCorrect = option === currentQ.correctAnswer;
    setSelectedOption(option);
    setShowExplanation(true);
    setAnsweredMap(prev => ({
      ...prev,
      [currentQ.id]: { selected: option, isCorrect }
    }));
    setScore(prev => ({
      correct: prev.correct + (isCorrect ? 1 : 0),
      total: prev.total + 1
    }));
  };

  const handleNext = () => {
    const nextIdx = (currentIndex + 1) % SAMPLE_QUESTIONS.length;
    setCurrentIndex(nextIdx);
    const existing = answeredMap[SAMPLE_QUESTIONS[nextIdx].id];
    if (existing) {
      setSelectedOption(existing.selected);
      setShowExplanation(true);
    } else {
      setSelectedOption(null);
      setShowExplanation(false);
    }
  };

  const handlePrev = () => {
    const prevIdx = (currentIndex - 1 + SAMPLE_QUESTIONS.length) % SAMPLE_QUESTIONS.length;
    setCurrentIndex(prevIdx);
    const existing = answeredMap[SAMPLE_QUESTIONS[prevIdx].id];
    if (existing) {
      setSelectedOption(existing.selected);
      setShowExplanation(true);
    } else {
      setSelectedOption(null);
      setShowExplanation(false);
    }
  };

  const selectQuestionByIdx = (idx: number) => {
    setCurrentIndex(idx);
    const existing = answeredMap[SAMPLE_QUESTIONS[idx].id];
    if (existing) {
      setSelectedOption(existing.selected);
      setShowExplanation(true);
    } else {
      setSelectedOption(null);
      setShowExplanation(false);
    }
  };

  const handleReset = () => {
    setSelectedOption(null);
    setShowExplanation(false);
    setAnsweredMap(prev => {
      const next = { ...prev };
      delete next[currentQ.id];
      return next;
    });
  };

  return (
    <section id="demo" className="demo-section">
      <div className="demo-container">
        {/* Section Header */}
        <div className="section-header" style={{ marginBottom: '2.25rem' }}>
          <div className="demo-pill-badge">
            <span className="demo-badge-dot"></span>
            <span>Interactive Web Preview • 5 High-Yield Questions</span>
          </div>
          <h2 className="demo-title">
            Test Your Knowledge with <span className="gradient-text">Real DPO Exam Scenarios</span>
          </h2>
          <p className="demo-subtitle">
            Experience our 8-stage SRS question engine right on the landing page. Click an answer below to test your recall and view immediate statutory explanations with exact Section citations.
          </p>
        </div>

        {/* Interactive App Container */}
        <div className="demo-card">
          {/* Header Bar */}
          <div className="demo-card-header">
            {/* Tabs / Switcher */}
            <div className="demo-tabs-bar">
              {SAMPLE_QUESTIONS.map((q, idx) => {
                const ans = answeredMap[q.id];
                const active = idx === currentIndex;
                return (
                  <button
                    key={q.id}
                    onClick={() => selectQuestionByIdx(idx)}
                    className={`demo-tab-btn ${active ? 'active' : ''}`}
                  >
                    <span className="demo-tab-module">M{q.moduleNum}</span>
                    <span className="demo-tab-title">{q.module.split(':')[1]?.trim() || q.module}</span>
                    {ans && (
                      <span className={`demo-tab-indicator ${ans.isCorrect ? 'correct' : 'wrong'}`}>
                        {ans.isCorrect ? '✓' : '✗'}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>

            {/* Mode Switcher */}
            <div className="demo-mode-toggle">
              <button
                type="button"
                onClick={() => setMode('practice')}
                className={`demo-mode-btn ${mode === 'practice' ? 'active' : ''}`}
              >
                Exam Practice
              </button>
              <button
                type="button"
                onClick={() => setMode('concept')}
                className={`demo-mode-btn ${mode === 'concept' ? 'active' : ''}`}
              >
                Concept Card
              </button>
            </div>
          </div>

          {/* Question Meta Bar */}
          <div className="demo-meta-bar">
            <div className="demo-meta-left">
              <span className="demo-tag module-tag" style={{ borderColor: currentQ.badgeColor, color: currentQ.badgeColor }}>
                {currentQ.module}
              </span>
              <span className="demo-tag tier-tag">
                {currentQ.difficulty}
              </span>
            </div>

            <div className="demo-meta-right">
              <span className="demo-srs-status">
                <span className="srs-pill apprentice">
                  SRS Stage: Apprentice I
                </span>
              </span>
              <span className="demo-q-count">
                Question {currentIndex + 1} of {SAMPLE_QUESTIONS.length}
              </span>
            </div>
          </div>

          {/* Body Content: Concept vs Practice */}
          <div className="demo-card-body">
            {mode === 'concept' ? (
              <div className="demo-concept-view">
                <div className="demo-concept-header">
                  <div className="concept-icon-badge">💡 High-Yield Concept</div>
                  <h3>{currentQ.concept}</h3>
                </div>
                <div className="demo-concept-body">
                  <p className="concept-lead">{currentQ.explanation}</p>
                  <div className="concept-citation-box">
                    <span className="citation-label">Statutory Reference:</span>
                    <code>{currentQ.citation}</code>
                  </div>
                  <div className="concept-tip-box">
                    <strong>Study Strategy:</strong> In the full DPA Mastery app, concept cards are reviewed in Phase 1 before initiating the examination phase, building solid cognitive pathways before timed retrieval.
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setMode('practice')}
                  className="btn-primary"
                  style={{ marginTop: '1.5rem', alignSelf: 'flex-start', padding: '10px 20px', fontSize: '13.5px' }}
                >
                  Switch to Exam Mode &rarr;
                </button>
              </div>
            ) : (
              <div className="demo-question-view">
                {/* Scenario / Question Text */}
                <div className="demo-question-text-wrap">
                  <span className="demo-q-prefix">Scenario #{currentQ.id}:</span>
                  <h3 className="demo-question-text">{currentQ.question}</h3>
                </div>

                {/* Options List */}
                <div className="demo-options-list">
                  {currentQ.options.map((option, optIdx) => {
                    const optionLetter = String.fromCharCode(65 + optIdx);
                    const isSelected = selectedOption === option || currentAnswerState?.selected === option;
                    const isCorrectAnswer = option === currentQ.correctAnswer;
                    
                    let optionClass = 'demo-option-item';
                    if (isAnswered) {
                      if (isCorrectAnswer) {
                        optionClass += ' correct';
                      } else if (isSelected && !isCorrectAnswer) {
                        optionClass += ' wrong';
                      } else {
                        optionClass += ' dimmed';
                      }
                    } else if (isSelected) {
                      optionClass += ' selected';
                    }

                    return (
                      <button
                        key={optIdx}
                        type="button"
                        onClick={() => handleSelect(option)}
                        disabled={isAnswered}
                        className={optionClass}
                      >
                        <span className="option-letter">{optionLetter}</span>
                        <span className="option-text">{option}</span>
                        {isAnswered && isCorrectAnswer && (
                          <span className="option-status-icon correct">✓ Correct</span>
                        )}
                        {isAnswered && isSelected && !isCorrectAnswer && (
                          <span className="option-status-icon wrong">✗ Incorrect</span>
                        )}
                      </button>
                    );
                  })}
                </div>

                {/* Explanation Reveal */}
                {showExplanation && (
                  <div className={`demo-explanation-card ${isAnswered && (selectedOption === currentQ.correctAnswer || currentAnswerState?.isCorrect) ? 'correct-bg' : 'wrong-bg'}`}>
                    <div className="demo-exp-header">
                      <div className="demo-exp-badge">
                        {selectedOption === currentQ.correctAnswer || currentAnswerState?.isCorrect ? (
                          <span style={{ color: '#10b981', display: 'flex', alignItems: 'center', gap: '6px' }}>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                              <polyline points="20 6 9 17 4 12" />
                            </svg>
                            Correct! Stage Promoted to Apprentice II
                          </span>
                        ) : (
                          <span style={{ color: '#ef4444', display: 'flex', alignItems: 'center', gap: '6px' }}>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                              <line x1="18" y1="6" x2="6" y2="18" />
                              <line x1="6" y1="6" x2="18" y2="18" />
                            </svg>
                            Review Required • SRS Interval Reset
                          </span>
                        )}
                      </div>
                      <span className="demo-citation-pill">{currentQ.citation}</span>
                    </div>

                    <p className="demo-exp-body">{currentQ.explanation}</p>

                    <div className="demo-srs-feedback">
                      <div className="srs-chip">
                        <span className="srs-chip-label">Next Review:</span>
                        <span className="srs-chip-val">
                          {selectedOption === currentQ.correctAnswer || currentAnswerState?.isCorrect ? 'In 8 Hours' : 'In 4 Hours (Apprentice I)'}
                        </span>
                      </div>
                      <div className="srs-chip">
                        <span className="srs-chip-label">Gating Impact:</span>
                        <span className="srs-chip-val">
                          {selectedOption === currentQ.correctAnswer || currentAnswerState?.isCorrect ? '+1 Towards 85% Guru Target' : '0 Progress Gated'}
                        </span>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Footer Controls */}
          <div className="demo-card-footer">
            <div className="demo-footer-left">
              <button
                type="button"
                onClick={handlePrev}
                className="btn-demo-nav"
                disabled={currentIndex === 0}
              >
                &larr; Previous
              </button>
              <button
                type="button"
                onClick={handleNext}
                className="btn-demo-nav primary"
              >
                {currentIndex === SAMPLE_QUESTIONS.length - 1 ? 'Start Over ↺' : 'Next Question →'}
              </button>
              {isAnswered && (
                <button
                  type="button"
                  onClick={handleReset}
                  className="btn-demo-retry"
                >
                  Retry Question ↺
                </button>
              )}
            </div>

            <div className="demo-footer-right">
              {score.total > 0 && (
                <span className="demo-score-tag">
                  Score: <strong>{score.correct}</strong> / {score.total} ({Math.round((score.correct / score.total) * 100)}%)
                </span>
              )}
              <a href="#downloads" className="demo-cta-download">
                Unlock All 282+ Questions in Native App &rarr;
              </a>
            </div>
          </div>
        </div>

        {/* Feature Teasers below Demo */}
        <div className="demo-highlights-grid">
          <div className="demo-highlight-box">
            <div className="highlight-icon">⏱️</div>
            <h4>Instant SRS Feedback</h4>
            <p>Answers are graded with real-time interval scheduling simulations, exactly mirroring our native app engine.</p>
          </div>
          <div className="demo-highlight-box">
            <div className="highlight-icon">⚖️</div>
            <h4>Official NPC Alignments</h4>
            <p>Every scenario draws directly from the 2012 DPA, 2016 IRR, and official NPC advisory circulars.</p>
          </div>
          <div className="demo-highlight-box">
            <div className="highlight-icon">🔒</div>
            <h4>Zero Ads &bull; 100% Offline</h4>
            <p>Download the Android or Windows app to study without internet connectivity, cloud tracking, or logins.</p>
          </div>
        </div>
      </div>
    </section>
  );
}
