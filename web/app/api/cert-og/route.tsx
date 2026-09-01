import { ImageResponse } from 'next/og';
import { NextRequest } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const name = searchParams.get('name') || 'Distinguished DPO Candidate';
    const course = searchParams.get('course') || 'DPO ACE Competency Examination';
    const id = searchParams.get('id') || 'DPA-DPOACE-VERIFIED';
    const date = searchParams.get('date') || new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

    return new ImageResponse(
      (
        <div
          style={{
            height: '100%',
            width: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'space-between',
            backgroundColor: '#FFFFFF',
            padding: '48px 54px',
            fontFamily: 'sans-serif',
            color: '#0F172A',
            border: '12px solid #0284C7',
          }}
        >
          {/* Header */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              width: '100%',
              borderBottom: '2px solid #E2E8F0',
              paddingBottom: 16,
            }}
          >
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              <div
                style={{
                  fontSize: 14,
                  fontWeight: 800,
                  color: '#0284C7',
                  letterSpacing: '0.12em',
                  textTransform: 'uppercase',
                  display: 'flex',
                  alignItems: 'center',
                }}
              >
                ★ OFFICIAL VERIFIED PRIVACY CREDENTIAL
              </div>
              <div style={{ fontSize: 26, fontWeight: 900, color: '#0F172A', marginTop: 4 }}>
                PHILIPPINE DATA PRIVACY COMMISSION (DPA) MASTERY
              </div>
            </div>
            
            <div
              style={{
                background: '#F0F9FF',
                border: '2px solid #0284C7',
                borderRadius: 12,
                padding: '8px 16px',
                fontSize: 14,
                fontWeight: 800,
                color: '#0369A1',
              }}
            >
              Registry ID: {id}
            </div>
          </div>

          {/* Certificate Body */}
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              textAlign: 'center',
              margin: '16px 0',
            }}
          >
            <div style={{ fontSize: 18, color: '#64748B', marginBottom: 10, fontStyle: 'italic' }}>
              This officially certifies that
            </div>
            <div
              style={{
                fontSize: 48,
                fontWeight: 900,
                color: '#0F172A',
                borderBottom: '4px solid #0284C7',
                paddingBottom: 6,
                marginBottom: 14,
                letterSpacing: '-0.02em',
              }}
            >
              {name}
            </div>
            <div style={{ fontSize: 17, color: '#334155', maxWidth: 840 }}>
              has successfully demonstrated verified competency and mastery in Philippine Data Privacy Law (RA 10173):
            </div>
            <div
              style={{
                fontSize: 32,
                fontWeight: 900,
                color: '#0369A1',
                marginTop: 8,
              }}
            >
              {course}
            </div>
          </div>

          {/* Footer Metadata */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              width: '100%',
              borderTop: '2px solid #E2E8F0',
              paddingTop: 16,
            }}
          >
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              <div style={{ fontSize: 13, color: '#64748B' }}>Conferred on: {date}</div>
              <div style={{ fontSize: 13, color: '#059669', fontWeight: 800, marginTop: 2 }}>
                Status: Cryptographically Authenticated &bull; DPA Registry v1.6.0
              </div>
            </div>

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                background: 'linear-gradient(135deg, #0284C7 0%, #0369A1 100%)',
                color: '#FFFFFF',
                padding: '10px 24px',
                borderRadius: 30,
                fontSize: 15,
                fontWeight: 800,
              }}
            >
              ✓ Verified DPO Practitioner
            </div>
          </div>
        </div>
      ),
      {
        width: 1200,
        height: 630,
      }
    );
  } catch {
    return new Response(`Failed to generate the certificate image`, {
      status: 500,
    });
  }
}
