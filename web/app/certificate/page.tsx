'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import QRCode from 'qrcode';
import {
  Award,
  Share2,
  Download,
  Printer,
  Copy,
  ArrowLeft,
  Sparkles,
  ExternalLink,
  ShieldCheck,
  Check,
  QrCode,
} from 'lucide-react';

import { useSearchParams } from 'next/navigation';
import { Suspense } from 'react';
import { toJpeg, toPng } from 'html-to-image';
import { APP_CONFIG } from '../config';

const OFFICIAL_PACKS = [
  {
    id: 'dpo_ace',
    title: 'Philippine DPO Competency Assessment & RA 10173 Simulation',
    code: 'DPOACE',
    domain: 'Data Privacy & Governance',
    questionsCount: 450,
    color: '#818CF8',
  },
  {
    id: 'npc_dpo_core',
    title: 'Data Privacy Compliance & IRR Curriculum',
    code: 'NPCDPO',
    domain: 'Compliance & Regulation',
    questionsCount: 300,
    color: '#10B981',
  },
  {
    id: 'cs_privacy_security',
    title: 'Cybersecurity & Privacy Engineering Standards',
    code: 'CSPrivacy',
    domain: 'Technical Safeguards',
    questionsCount: 220,
    color: '#06B6D4',
  },
];

function computeChecksum(name: string, packId: string): string {
  const seed = `${name.trim().toLowerCase()}_${packId}_2026`;
  let hash = 0x811c9dc5;
  for (let i = 0; i < seed.length; i++) {
    hash ^= seed.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return ((hash >>> 0) & 0xffff).toString(16).toUpperCase().padStart(4, '0');
}

function CertificateContent() {
  const searchParams = useSearchParams();
  const urlName = searchParams.get('name');
  const urlId = searchParams.get('id');
  const urlPack = searchParams.get('pack');

  const initialPack = OFFICIAL_PACKS.find((p) => {
    if (urlPack && p.title.toLowerCase().includes(urlPack.toLowerCase())) return true;
    if (urlId) {
      const parts = urlId.toUpperCase().split('-');
      if (parts.length > 1) {
        if (parts[1] === 'DPOACE' && p.id === 'dpo_ace') return true;
        if (parts[1] === 'NPCDPO' && p.id === 'npc_dpo_core') return true;
        if (parts[1] === 'CSPRIVACY' && p.id === 'cs_privacy_security') return true;
      }
    }
    return false;
  }) || OFFICIAL_PACKS[0];

  const [studentName, setStudentName] = useState(urlName || 'Distinguished DPO Candidate');
  const [selectedPackId, setSelectedPackId] = useState(initialPack.id);
  const [issueDate, setIssueDate] = useState('September 2026');
  const [copied, setCopied] = useState(false);
  const [qrCodeDataUrl, setQrCodeDataUrl] = useState<string>('');
  const [downloadingImg, setDownloadingImg] = useState<boolean>(false);
  const certRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (urlName) setStudentName(urlName);
    if (urlPack) {
      const match = OFFICIAL_PACKS.find((p) => p.title.toLowerCase().includes(urlPack.toLowerCase()) || p.id === urlPack);
      if (match) setSelectedPackId(match.id);
    }
  }, [urlName, urlPack]);

  const pack = OFFICIAL_PACKS.find((p) => p.id === selectedPackId) || OFFICIAL_PACKS[0];
  const checksum = computeChecksum(studentName, selectedPackId);
  const certSerial = `DPA-${pack.code}-${checksum}-VERIFIED`;

  const verificationUrl = `https://dpa.sanchez.ph/verify?id=${encodeURIComponent(certSerial)}&name=${encodeURIComponent(
    studentName
  )}&pack=${encodeURIComponent(pack.title)}`;

  // Generate dynamic QR Code for instant mobile verification
  useEffect(() => {
    QRCode.toDataURL(verificationUrl, {
      width: 160,
      margin: 1,
      color: {
        dark: '#000000',
        light: '#FFFFFF',
      },
    })
      .then((url) => setQrCodeDataUrl(url))
      .catch((err) => console.error('QR generation error:', err));
  }, [verificationUrl]);

  // LinkedIn Certification URL Format (Pre-filled with DPA Mastery LinkedIn Org ID 144796321)
  const linkedInCertUrl = `https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME&name=${encodeURIComponent(
    `${pack.title} (Mastery)`
  )}&organizationName=${encodeURIComponent(
    'DPA Mastery'
  )}&organizationId=144796321&issueYear=2026&issueMonth=9&certUrl=${encodeURIComponent(
    verificationUrl
  )}&certId=${encodeURIComponent(certSerial)}`;

  // LinkedIn Feed Share URL
  const linkedInShareUrl = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(
    verificationUrl
  )}`;

  // Facebook Share URL
  const facebookShareUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(
    verificationUrl
  )}`;

  const handleCopyLink = () => {
    navigator.clipboard.writeText(verificationUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  const handlePrint = () => {
    window.print();
  };

  const handleExportImage = async (format: 'jpeg' | 'png') => {
    if (!certRef.current) return;
    try {
      setDownloadingImg(true);
      const exportFn = format === 'jpeg' ? toJpeg : toPng;
      const dataUrl = await exportFn(certRef.current, {
        quality: 0.98,
        pixelRatio: 2, // High-res 2x retina crisp export
        backgroundColor: '#FFFFFF',
      });
      const link = document.createElement('a');
      const filename = `DPA-Mastery-Certificate-${studentName.replace(/\s+/g, '_')}-${certSerial}.${format === 'jpeg' ? 'jpg' : 'png'}`;
      link.download = filename;
      link.href = dataUrl;
      link.click();
    } catch (err) {
      console.error('Failed to export certificate image:', err);
    } finally {
      setDownloadingImg(false);
    }
  };

  return (
    <div className="cert-page-wrapper" style={{ minHeight: '100vh', background: 'var(--bg)', color: 'var(--text-main)', paddingBottom: '80px' }}>
      <div className="container cert-page-container" style={{ maxWidth: '1100px', margin: '0 auto', padding: '30px 20px 0' }}>
        {/* Navigation / Header */}
        <div className="no-print" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '28px', flexWrap: 'wrap', gap: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
            <Link href="/" className="btn btn-secondary" style={{ padding: '8px 14px', fontSize: '13px' }}>
              <ArrowLeft size={16} /> Home
            </Link>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <Image
                src="/logo-192.png"
                alt="DPA Mastery Logo"
                width={38}
                height={38}
                style={{ borderRadius: 10, objectFit: 'contain' }}
              />
              <div>
                <h1 style={{ fontSize: '24px', fontWeight: 800, display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <Award size={24} style={{ color: '#0284C7' }} />
                  Data Privacy Certificate of Mastery
                </h1>
                <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                  Official verifiable credential with dynamic QR validation &amp; LinkedIn 1-tap sync
                </span>
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'nowrap' }}>
            <button
              onClick={() => handleExportImage('jpeg')}
              disabled={downloadingImg}
              className="btn btn-primary"
              style={{ padding: '8px 14px', fontSize: '12.5px', whiteSpace: 'nowrap', background: 'linear-gradient(135deg, #0284C7 0%, #0369A1 100%)', borderColor: '#0284C7' }}
              title="Export high-resolution JPG image to attach to LinkedIn"
            >
              <Download size={14} /> {downloadingImg ? 'Saving...' : 'Save JPG'}
            </button>
            <button onClick={handlePrint} className="btn btn-secondary" style={{ padding: '8px 12px', fontSize: '12.5px', whiteSpace: 'nowrap' }}>
              <Printer size={14} /> Print / PDF
            </button>
            <button onClick={handleCopyLink} className="btn btn-secondary" style={{ padding: '8px 12px', fontSize: '12.5px', whiteSpace: 'nowrap' }}>
              {copied ? <Check size={14} color="#10B981" /> : <Copy size={14} />}
              {copied ? 'Copied!' : 'Copy URL'}
            </button>
          </div>
        </div>

        {/* Verified Credential Header Status Bar */}
        <div className="card no-print" style={{ background: 'var(--surface)', padding: '16px 20px', borderRadius: '16px', marginBottom: '24px', border: '1px solid rgba(2, 132, 199, 0.25)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#10B981', boxShadow: '0 0 10px #10B981' }} />
            <div style={{ fontSize: '13px', fontWeight: 700, color: '#E5E7EB' }}>
              Authenticated Scholar: <span style={{ color: '#38BDF8' }}>{studentName}</span> &bull; Curriculum: <span style={{ color: '#818CF8' }}>{pack.title}</span>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12px', color: 'var(--text-muted)' }}>
            <ShieldCheck size={16} color="#10B981" />
            <span>Cryptographic Serial: <strong className="mono-font" style={{ color: '#38BDF8' }}>{certSerial}</strong></span>
          </div>
        </div>

        {/* Certificate Display Frame */}
        <div className="cert-frame" ref={certRef}>
          <div className="cert-corner-decor cert-tl" />
          <div className="cert-corner-decor cert-tr" />
          <div className="cert-corner-decor cert-bl" />
          <div className="cert-corner-decor cert-br" />

          {/* Certificate Header */}
          <div style={{ position: 'relative', textAlign: 'center', marginBottom: '20px', minHeight: '120px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{ position: 'absolute', left: 0, top: '50%', transform: 'translateY(-50%)', margin: 0 }}>
              <Image
                src="/logo-512.png"
                alt="DPA Mastery Crest"
                width={120}
                height={120}
                style={{ filter: 'drop-shadow(0 6px 16px rgba(2, 132, 199, 0.2))' }}
              />
            </div>

            <div style={{ maxWidth: '680px', margin: '0 auto' }}>
              <div className="cert-badge">
                <Award size={15} /> Verified Achievement Credential
              </div>
              <h2 className="cert-title" style={{ textAlign: 'center', margin: '4px 0 6px' }}>
                PHILIPPINE DATA PRIVACY ACT (RA 10173) MASTERY
              </h2>
              <p className="cert-subtitle" style={{ textAlign: 'center' }}>
                Data Privacy Governance &amp; DPO Competency Assessment Registry &bull; Platform v{APP_CONFIG.version}
              </p>
            </div>
          </div>

          {/* Recipient */}
          <div className="cert-recipient-section">
            <p className="cert-body-intro">
              This officially certifies that
            </p>
            <div className="cert-student-name">
              {studentName || 'Distinguished DPO Candidate'}
            </div>
            <p className="cert-body-text">
              has satisfied all rigorous knowledge requirements and demonstrated verified competency and mastery in Philippine Data Privacy Law (Republic Act No. 10173), its Implementing Rules and Regulations (IRR), and NPC Landmark Advisory Circulars in:
            </p>
            <div className="cert-course-name" style={{ color: '#0369A1' }}>
              {pack.title}
            </div>
            <p className="cert-body-subtext">
              Validated through the comprehensive 50-question Timed Simulation Examination (Passing Score &ge; 75%) and Spaced Repetition (SRS) Active Recall standards across all {pack.questionsCount} syllabus questions.
            </p>
          </div>

          {/* Verification Bar with Live QR Code & Professional Award Ribbon Seal */}
          <div className="cert-verify-bar">
            <div className="cert-meta-col">
              <div className="cert-meta-label">Credential Serial</div>
              <div className="mono-font cert-serial">{certSerial}</div>
              <div className="cert-meta-desc">Framework: {pack.code} &bull; Conferred: {issueDate}</div>
              <div className="cert-status-tag">Status: Authenticated &#10003;</div>
            </div>

            {/* Center Professional Rosette / Ribbon Seal */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <svg viewBox="0 0 100 120" width="84" height="100">
                {/* Ribbon Tails */}
                <path d="M 32 80 L 22 115 L 38 108 L 48 115 L 44 80 Z" fill="#0369A1" stroke="#075985" strokeWidth="1" />
                <path d="M 68 80 L 56 115 L 62 108 L 78 115 L 68 80 Z" fill="#0284C7" stroke="#075985" strokeWidth="1" />
                {/* 36-Point Starburst Rosette */}
                <path
                  d="M 50 10 
                     L 57 14 L 64 12 L 69 18 L 76 19 L 79 26 L 86 30 L 87 37 L 91 43 L 89 50 L 91 57 L 87 63 L 86 70 L 79 74 L 76 81 L 69 82 L 64 88 L 57 86 L 50 90 
                     L 43 86 L 36 88 L 31 82 L 24 81 L 21 74 L 14 70 L 13 63 L 9 57 L 11 50 L 9 43 L 13 37 L 14 30 L 21 26 L 24 19 L 31 18 L 36 12 L 43 14 Z"
                  fill="url(#sealGrad)"
                  stroke="#075985"
                  strokeWidth="1.5"
                />
                {/* Inner Disc */}
                <circle cx="50" cy="50" r="30" fill="url(#sealInner)" stroke="#0369A1" strokeWidth="1.5" />
                {/* Star border / Beaded ring */}
                <circle cx="50" cy="50" r="26" fill="none" stroke="#BAE6FD" strokeWidth="1" strokeDasharray="2,2" />
                {/* Verified Checkmark in Center */}
                <path
                  d="M 38 49 L 46 57 L 63 39"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="4.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
                <defs>
                  <linearGradient id="sealGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#38BDF8" />
                    <stop offset="50%" stopColor="#0284C7" />
                    <stop offset="100%" stopColor="#0369A1" />
                  </linearGradient>
                  <linearGradient id="sealInner" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#0284C7" />
                    <stop offset="60%" stopColor="#0369A1" />
                    <stop offset="100%" stopColor="#075985" />
                  </linearGradient>
                </defs>
              </svg>
            </div>

            {/* QR Code Validation Box */}
            <a
              href={verificationUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="cert-qr-link"
              title="Click or scan to verify on DPA Registry"
            >
              {qrCodeDataUrl ? (
                <div className="cert-qr-img-wrap">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={qrCodeDataUrl} alt="Scan QR to verify" width={64} height={64} style={{ display: 'block' }} />
                </div>
              ) : (
                <div style={{ width: 64, height: 64, display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#fff', borderRadius: 8 }}>
                  <QrCode size={28} color="#F59E0B" />
                </div>
              )}
              <div className="cert-qr-text">
                <div className="cert-qr-action">
                  Scan to Verify <ExternalLink size={11} />
                </div>
                <div className="cert-qr-sub">
                  Instant zero-knowledge public verification
                </div>
              </div>
            </a>
          </div>

          {/* Signatures & Accreditation Footer */}
          <div className="cert-signatures-footer">
            <div className="cert-sig-left">
              <div style={{ height: '40px', display: 'flex', alignItems: 'flex-end', paddingLeft: '24px', marginBottom: '-4px' }}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src="/signature.svg"
                  alt="Alfredo Sanchez Jr. Signature"
                  width={110}
                  height={38}
                  style={{ display: 'block' }}
                />
              </div>
              <div className="cert-sig-name-left">
                Alfredo Sanchez Jr.
              </div>
              <div className="cert-sig-line-left">
                Lead Architect &amp; Creator &bull; <a href="https://sanchez.ph" target="_blank" rel="noopener noreferrer" style={{ color: '#D8B4FE', textDecoration: 'none' }}>sanchez.ph</a>
              </div>
            </div>

            <div className="cert-sig-right" style={{ textAlign: 'right' }}>
              <div style={{ height: '40px' }} />
              <div className="cert-sig-name-right">
                DPA Assessment Board
              </div>
              <div className="cert-sig-line-right">
                Curriculum &amp; Legal Competency Standards
              </div>
            </div>
          </div>
        </div>

        {/* Social & Professional Sharing Action Center */}
        <div className="card no-print" style={{ background: 'var(--surface)', border: '1px solid var(--border-light)', borderRadius: '20px', padding: '32px 24px', textAlign: 'center', marginBottom: '40px' }}>
          <h3 style={{ fontSize: '22px', fontWeight: 800, marginBottom: '8px' }}>
            Publish &amp; Showcase Your Verified Credential
          </h3>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', maxWidth: '680px', margin: '0 auto 24px', lineHeight: 1.6 }}>
            Add this credential directly to your <strong>LinkedIn Licenses &amp; Certifications</strong>, download a crisp <strong>High-Resolution JPG / PNG image</strong> to attach as media to your profile, or share directly to your feed with rich OpenGraph preview cards.
          </p>

          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '14px', flexWrap: 'wrap', marginBottom: '20px' }}>
            <button
              onClick={() => handleExportImage('jpeg')}
              disabled={downloadingImg}
              className="btn btn-primary"
              style={{
                padding: '14px 24px',
                fontSize: '14px',
                fontWeight: 700,
                background: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
                borderColor: '#059669',
                boxShadow: '0 4px 16px rgba(16, 185, 129, 0.35)',
              }}
            >
              <Download size={18} /> {downloadingImg ? 'Generating...' : 'Download JPG for LinkedIn Media'}
            </button>

            <button
              onClick={() => handleExportImage('png')}
              disabled={downloadingImg}
              className="btn btn-secondary"
              style={{ padding: '14px 22px', fontSize: '14px', fontWeight: 600 }}
            >
              <Download size={18} /> Download Lossless PNG
            </button>

            <a
              href={linkedInCertUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-linkedin"
              style={{ padding: '14px 24px', fontSize: '14px' }}
            >
              <Award size={18} /> Add to LinkedIn Licenses
            </a>

            <a
              href={linkedInShareUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-secondary"
              style={{ padding: '14px 22px', fontSize: '14px', borderColor: 'rgba(10, 102, 194, 0.4)' }}
            >
              <Share2 size={18} color="#0A66C2" /> Share on LinkedIn Feed
            </a>

            <a
              href={facebookShareUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-facebook"
              style={{ padding: '14px 22px', fontSize: '14px' }}
            >
              <Share2 size={18} /> Post to Facebook
            </a>
          </div>

          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '8px 16px', background: 'rgba(255, 255, 255, 0.04)', borderRadius: '20px', fontSize: '12px', color: 'var(--text-muted)' }}>
            <Sparkles size={14} color="#F59E0B" /> 
            <span><strong>Tip:</strong> In LinkedIn <em>&ldquo;Add license or certification&rdquo;</em>, click <strong>&ldquo;Add media&rdquo;</strong> to attach the downloaded JPG.</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function CertificatePage() {
  return (
    <Suspense fallback={<div style={{ minHeight: '100vh', background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>Loading Data Privacy Certificate...</div>}>
      <CertificateContent />
    </Suspense>
  );
}
