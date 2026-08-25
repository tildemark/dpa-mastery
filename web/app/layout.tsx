import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'DPA Mastery — Philippine NPC Data Privacy Exam Prep',
  description: 'Static OTA Seed API and Hub for DPA Mastery offline-first SRS review app.',
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
