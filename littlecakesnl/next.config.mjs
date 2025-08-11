/** @type {import('next').NextConfig} */
const nextConfig = {
  // Image optimization for better Core Web Vitals
  images: {
    domains: ['littlecakesnl.nl'],
    formats: ['image/webp', 'image/avif'],
  },
  
  // Performance optimizations
  experimental: {
    optimizeCss: true,
    optimizePackageImports: ['@/components'],
  },
  
  // Headers for SEO and security
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on'
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin'
          }
        ],
      },
    ]
  },
  
  // Redirects for better URL structure and Dutch keywords
  async redirects() {
    return [
      {
        source: '/taart',
        destination: '/',
        permanent: true,
      },
      {
        source: '/gebak',
        destination: '/',
        permanent: true,
      },
      {
        source: '/bruiloftstaart',
        destination: '/services/wedding-cakes',
        permanent: true,
      },
      {
        source: '/verjaardagstaart',
        destination: '/',
        permanent: true,
      },
      {
        source: '/nl',
        destination: '/',
        permanent: true,
      },
    ]
  },
};

export default nextConfig;
