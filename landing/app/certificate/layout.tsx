import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Data Privacy Certificate of Mastery | DPA Mastery',
  description: 'Official Verified Credential & Assessment Registry under Philippine Data Privacy Act (RA 10173).',
  openGraph: {
    title: 'Data Privacy Certificate of Mastery | DPA Mastery',
    description: 'Official Verified Credential & Assessment Registry under Philippine Data Privacy Act (RA 10173).',
    siteName: 'DPA Mastery Assessment Registry',
    url: 'https://dpa-mastery.sanchez.ph/certificate',
    images: [
      {
        url: 'https://dpa-mastery.sanchez.ph/api/cert-og',
        width: 1200,
        height: 630,
        alt: 'Data Privacy Certificate of Mastery',
        type: 'image/png',
      },
    ],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Data Privacy Certificate of Mastery | DPA Mastery',
    description:
      'Official verifiable digital certificate of achievement for Philippine Data Privacy Act of 2012 (RA 10173) competency examination.',
    images: ['https://dpa-mastery.sanchez.ph/api/cert-og'],
  },
};

export default function CertificateLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}


