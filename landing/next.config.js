/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  basePath: process.env.NEXT_PUBLIC_BASE_PATH || '',
  async rewrites() {
    return [
      {
        source: '/app',
        destination: '/app/index.html',
      },
      {
        source: '/app/',
        destination: '/app/index.html',
      },
    ];
  },
};

module.exports = nextConfig;
