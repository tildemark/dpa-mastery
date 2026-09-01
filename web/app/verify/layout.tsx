import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Credential Verification & Integrity Check | DPA Mastery',
  description: 'Public cryptographic validation portal for Philippine Data Privacy Law (RA 10173) competency credentials.',
  openGraph: {
    title: 'Verify DPO Credential | DPA Mastery',
    description: 'Official cryptographically validated competency credential in Philippine Data Privacy Law (RA 10173).',
    siteName: 'DPA Mastery Assessment Registry',
  },
};

export default function VerifyLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}

