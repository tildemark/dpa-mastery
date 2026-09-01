import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Data Privacy Certificate of Mastery | DPA Mastery',
  description: 'Official Verified Credential & Assessment Registry under Philippine Data Privacy Act (RA 10173).',
  openGraph: {
    title: 'Data Privacy Certificate of Mastery | DPA Mastery',
    description: 'Official Verified Credential & Assessment Registry under Philippine Data Privacy Act (RA 10173).',
    siteName: 'DPA Mastery Assessment Registry',
    images: [
      {
        url: 'https://dpa.sanchez.ph/api/cert-og',
        width: 1200,
        height: 630,
        type: 'image/png',
        alt: 'DPA Mastery Certificate of Mastery',
      },
    ],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Data Privacy Certificate of Mastery | DPA Mastery',
    description: 'Official Verified Credential & Assessment Registry under Philippine Data Privacy Act (RA 10173).',
    images: ['https://dpa.sanchez.ph/api/cert-og'],
  },
};

export default function CertificateLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}

