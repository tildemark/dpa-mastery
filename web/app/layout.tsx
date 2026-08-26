import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'DPA Mastery — Philippine NPC Data Privacy Exam Prep',
  description: 'Static OTA Seed API and Hub for DPA Mastery offline-first SRS review app.',
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: 'any' },
      { url: '/favicon.png', type: 'image/png', sizes: '32x32' },
      { url: '/logo-192.png', type: 'image/png', sizes: '192x192' },
      { url: '/logo-512.png', type: 'image/png', sizes: '512x512' },
    ],
    apple: [
      { url: '/apple-touch-icon.png', sizes: '180x180' },
    ],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
