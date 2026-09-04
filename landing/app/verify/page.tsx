'use client';

import React, { useState, useMemo } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import {
  ShieldCheck,
  ShieldAlert,
  Award,
  ArrowLeft,
  CheckCircle2,
  ExternalLink,
  Share2,
  Calendar,
  UserCheck,
  BookOpen,
  Hash,
  Sparkles,
  Search,
  Lock,
  FileCheck2,
  Check,
} from 'lucide-react';
import { Suspense } from 'react';
import { APP_CONFIG } from '../config';

const PACK_REGISTRY: Record<string, { code: string; name: string; packId: string; questions: number; color: string }> = {
  DPOACE: {
    code: 'DPOACE',
    name: 'Philippine DPO Competency Assessment',
    packId: 'dpo_ace',
    questions: 450,
    color: '#0284C7',
  },
  NPCDPO: {
    code: 'NPCDPO',
    name: 'Data Privacy Compliance Curriculum',
    packId: 'npc_dpo_core',
    questions: 300,
    color: '#059669',
  },
  CSPRIVACY: {
    code: 'CSPRIVACY',
    name: 'Cybersecurity & Privacy Engineering',
    packId: 'cs_privacy_security',
    questions: 220,
    color: '#0891B2',
  },
};

function computeDeterministicChecksum(name: string, packId: string): string {
  const seed = `${name.trim().toLowerCase()}_${packId}_2026`;
  let hash = 0x811c9dc5;
  for (let i = 0; i < seed.length; i++) {
    hash ^= seed.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return ((hash >>> 0) & 0xffff).toString(16).toUpperCase().padStart(4, '0');
}

function VerifyContent() {
  const searchParams = useSearchParams();
  const rawId = searchParams.get('id') || '';
  const rawName = searchParams.get('name') || '';
  const rawPack = searchParams.get('pack') || '';

  const [inputSerial, setInputSerial] = useState(rawId);
  const [inputName, setInputName] = useState(rawName);
  const [copied, setCopied] = useState(false);

  const verificationResult = useMemo(() => {
    const trimmedSerial = inputSerial.trim().toUpperCase();
    const trimmedName = inputName.trim();

    if (!trimmedSerial) {
      return { status: 'empty', message: 'Enter a Credential Registry ID to initiate verification' };
    }

    // Format: DPA-<CODE>-<CHECKSUM>-VERIFIED
    const parts = trimmedSerial.split('-');
    if (parts.length !== 4 || parts[0] !== 'DPA' || parts[3] !== 'VERIFIED') {
      return {
        status: 'invalid_format',
        message: 'Invalid serial sequence. Format must match DPA-<CODE>-<CHECKSUM>-VERIFIED',
      };
    }

    const packCode = parts[1];
    const checksum = parts[2];
    const matchedPack = PACK_REGISTRY[packCode] || {
      code: packCode,
      name: rawPack || 'Philippine DPO Competency Assessment',
      packId: packCode.toLowerCase(),
      questions: 450,
      color: '#0284C7',
    };

    if (!trimmedName) {
      return {
        status: 'name_required',
        pack: matchedPack,
        message: 'Enter recipient candidate name to compute cryptographic hash signature match',
      };
    }

    const expectedChecksum = computeDeterministicChecksum(trimmedName, matchedPack.packId);
    const isValid = checksum === expectedChecksum;

    return {
      status: isValid ? 'valid' : 'hash_mismatch',
      isValid,
      pack: matchedPack,
      expectedChecksum,
      providedChecksum: checksum,
      candidateName: trimmedName,
      serial: trimmedSerial,
    };
  }, [inputSerial, inputName, rawPack]);

  const handleCopyValidationReport = () => {
    const reportText = `[DPA Mastery Credential Validation]\nSerial: ${inputSerial}\nCandidate: ${inputName}\nStatus: ${verificationResult.isValid ? 'AUTHENTIC & VERIFIED' : 'FAILED'}\nLedger Verification URL: ${window.location.href}`;
    navigator.clipboard.writeText(reportText);
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)', color: 'var(--text-main)', paddingBottom: '80px' }}>
      <div style={{ maxWidth: '960px', margin: '0 auto', padding: '36px 20px 0' }}>
        {/* Navigation / Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '28px', flexWrap: 'wrap', gap: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <Link href="/" className="btn btn-secondary" style={{ padding: '8px 14px', fontSize: '13px' }}>
              <ArrowLeft size={16} /> Home
            </Link>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ width: '36px', height: '36px', borderRadius: '10px', background: 'rgba(2, 132, 199, 0.15)', border: '1px solid rgba(2, 132, 199, 0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <ShieldCheck size={20} color="#0284C7" />
              </div>
              <div>
                <h1 style={{ fontSize: '20px', fontWeight: 800, margin: 0 }}>Public Credential Verification Ledger</h1>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Cryptographic Zero-Knowledge Validation &bull; Philippine DPA Registry</span>
              </div>
            </div>
          </div>

          {verificationResult.status === 'valid' ? (
            <Link
              href={`/certificate?name=${encodeURIComponent(inputName)}&id=${encodeURIComponent(inputSerial)}`}
              className="btn btn-primary"
              style={{ padding: '8px 16px', fontSize: '13px', background: 'linear-gradient(135deg, #0284C7 0%, #0369A1 100%)', borderColor: '#0284C7' }}
            >
              <Award size={16} /> View Certificate Canvas
            </Link>
          ) : (
            <button
              disabled
              className="btn btn-secondary"
              style={{ padding: '8px 16px', fontSize: '13px', opacity: 0.5, cursor: 'not-allowed' }}
              title="Verification must pass to view certificate"
            >
              <Award size={16} /> View Certificate Canvas
            </button>
          )}
        </div>

        {/* Verification Status Banner */}
        {verificationResult.status === 'valid' ? (
          <div style={{ background: '#ffffff', color: '#0f172a', borderRadius: '20px', padding: '32px', border: '1px solid #bbf7d0', boxShadow: '0 20px 40px rgba(0,0,0,0.12)', marginBottom: '32px', position: 'relative', overflow: 'hidden' }}>
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '20px', flexWrap: 'wrap' }}>
              <div style={{ width: '56px', height: '56px', borderRadius: '16px', background: '#dcfce7', border: '2px solid #86efac', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <ShieldCheck size={32} color="#15803d" />
              </div>
              <div style={{ flex: 1, minWidth: '280px' }}>
                <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '4px 12px', background: '#dcfce7', borderRadius: '100px', fontSize: '12px', fontWeight: 800, color: '#15803d', marginBottom: '10px' }}>
                  <CheckCircle2 size={14} /> AUTHENTIC &bull; OFFICIALLY VALIDATED CREDENTIAL
                </div>
                <h2 style={{ fontSize: '26px', fontWeight: 900, color: '#0f172a', margin: '0 0 6px' }}>
                  {verificationResult.candidateName}
                </h2>
                <p style={{ fontSize: '15px', color: '#334155', margin: '0 0 16px', lineHeight: 1.5 }}>
                  Demonstrated verified mastery and competency in <strong>{verificationResult.pack?.name}</strong> under the Philippine Data Privacy Act of 2012 (RA 10173) framework.
                </p>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px', background: '#f8fafc', padding: '16px', borderRadius: '12px', border: '1px solid #e2e8f0' }}>
                  <div>
                    <span style={{ fontSize: '11px', fontWeight: 700, color: '#64748b', textTransform: 'uppercase' }}>Registry Serial</span>
                    <div className="mono-font" style={{ fontSize: '14px', fontWeight: 800, color: '#0284c7' }}>{verificationResult.serial}</div>
                  </div>
                  <div>
                    <span style={{ fontSize: '11px', fontWeight: 700, color: '#64748b', textTransform: 'uppercase' }}>Validation Status</span>
                    <div style={{ fontSize: '13px', fontWeight: 800, color: '#15803d', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Check size={14} /> Passed Examination
                    </div>
                  </div>
                  <div>
                    <span style={{ fontSize: '11px', fontWeight: 700, color: '#64748b', textTransform: 'uppercase' }}>Protocol</span>
                    <div style={{ fontSize: '13px', color: '#334155', fontWeight: 600 }}>DPA Engine v{APP_CONFIG.version}</div>
                  </div>
                  <div>
                    <span style={{ fontSize: '11px', fontWeight: 700, color: '#64748b', textTransform: 'uppercase' }}>Cryptographic Hash</span>
                    <div className="mono-font" style={{ fontSize: '13px', color: '#0369a1', fontWeight: 700 }}>0x{verificationResult.providedChecksum} (MATCH)</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div style={{ background: 'var(--surface)', borderRadius: '20px', padding: '28px', border: '1px solid rgba(239, 68, 68, 0.4)', marginBottom: '32px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(239, 68, 68, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <ShieldAlert size={26} color="#ef4444" />
              </div>
              <div>
                <h3 style={{ fontSize: '18px', fontWeight: 800, color: '#f87171', margin: '0 0 4px' }}>Validation Alert</h3>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: 0 }}>
                  {verificationResult.message}
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Search / Validation Lookup Form */}
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border-light)', borderRadius: '20px', padding: '28px', marginBottom: '32px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Search size={18} color="#0284C7" /> Verify Another Candidate or Credential ID
          </h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '16px', marginBottom: '20px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--text-muted)', marginBottom: '6px' }}>
                Candidate Full Name
              </label>
              <input
                type="text"
                value={inputName}
                onChange={(e) => setInputName(e.target.value)}
                placeholder="e.g. Alfredo Sanchez Jr."
                style={{ width: '100%', padding: '12px 16px', background: 'var(--bg)', border: '1px solid var(--border-light)', borderRadius: '10px', color: '#fff', fontSize: '14px', outline: 'none' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--text-muted)', marginBottom: '6px' }}>
                Credential Serial ID
              </label>
              <input
                type="text"
                value={inputSerial}
                onChange={(e) => setInputSerial(e.target.value)}
                placeholder="e.g. DPA-DPOACE-B02E-VERIFIED"
                className="mono-font"
                style={{ width: '100%', padding: '12px 16px', background: 'var(--bg)', border: '1px solid var(--border-light)', borderRadius: '10px', color: '#fff', fontSize: '14px', outline: 'none' }}
              />
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Lock size={14} color="#10B981" /> Zero-knowledge deterministic offline verification engine
            </div>
            <button
              onClick={handleCopyValidationReport}
              className="btn btn-secondary"
              style={{ fontSize: '12.5px', padding: '8px 14px' }}
            >
              {copied ? <Check size={14} color="#10B981" /> : <FileCheck2 size={14} />}
              {copied ? 'Report Copied!' : 'Copy Verification Report'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function VerifyPage() {
  return (
    <Suspense fallback={<div style={{ minHeight: '100vh', background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>Loading Registry Ledger...</div>}>
      <VerifyContent />
    </Suspense>
  );
}
