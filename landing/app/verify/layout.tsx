import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Credential Verification & Integrity Check | DPA Mastery',
  description: 'Public cryptographic validation portal for Philippine Data Privacy Law (RA 10173) competency credentials.',
  openGraph: {
    title: 'Verify DPO Credential | DPA Mastery',
    description: 'Official cryptographically validated competency credential in Philippine Data Privacy Law (RA 10173).',
    siteName: 'DPA Mastery Assessment Registry',
    url: 'https://dpa-mastery.sanchez.ph/verify',
    images: [
      {
        url: 'https://dpa-mastery.sanchez.ph/api/cert-og',
        width: 1200,
        height: 630,
        alt: 'Credential Verification Portal',
        type: 'image/png',
      },
    ],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Verify DPO Credential | DPA Mastery',
    description: 'Public cryptographic validation portal for Philippine Data Privacy Law (RA 10173) competency credentials.',
    images: ['https://dpa-mastery.sanchez.ph/api/cert-og'],
  },
};

export default function VerifyLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}

