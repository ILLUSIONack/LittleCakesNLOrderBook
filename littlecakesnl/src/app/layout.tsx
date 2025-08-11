import type { Metadata } from 'next'
import { Lato } from 'next/font/google'
import './globals.css'

const lato = Lato({
  subsets: ['latin'],
  weight: ['300', '400', '700', '900'],
  variable: '--font-lato',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'LittleCakesNL - Custom Dream Cakes in Rotterdam & Vlaardingen',
  description: 'Handcrafted custom cakes made with love in The Netherlands. Wedding cakes, birthday cakes, and special occasion cakes. Pickup only in Rotterdam & Vlaardingen. Order your dream cake today!',
  keywords: 'custom cakes, wedding cakes, birthday cakes, Rotterdam, Vlaardingen, Netherlands, cake pickup, custom cake design, taart, bruiloftstaart, verjaardagstaart, gebak, rotterdam taart, vlaardingen taart, nederlandse taart, custom taart, bruiloftstaart rotterdam, verjaardagstaart vlaardingen',
  authors: [{ name: 'LittleCakesNL' }],
  creator: 'LittleCakesNL',
  publisher: 'LittleCakesNL',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL('https://littlecakesnl.nl'),
  alternates: {
    canonical: '/',
    languages: {
      'en': '/',
      'nl': '/',
    },
  },
  viewport: 'width=device-width, initial-scale=1, maximum-scale=5',
  themeColor: '#ec4899',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'LittleCakesNL',
  },
  openGraph: {
    title: 'LittleCakesNL - Custom Dream Cakes in Rotterdam & Vlaardingen',
    description: 'Handcrafted custom cakes made with love in The Netherlands. Wedding cakes, birthday cakes, and special occasion cakes.',
    url: 'https://littlecakesnl.nl',
    siteName: 'LittleCakesNL',
    images: [
      {
        url: '/cakesrc.png',
        width: 1200,
        height: 630,
        alt: 'LittleCakesNL Custom Cakes - Taart Rotterdam Vlaardingen',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'LittleCakesNL - Custom Dream Cakes in Rotterdam & Vlaardingen',
    description: 'Handcrafted custom cakes made with love in The Netherlands. Wedding cakes, birthday cakes, and special occasion cakes.',
    images: ['/cakesrc.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'google95c7c581041b4791', // Google Search Console verification code
  },
  other: {
    'geo.region': 'NL-ZH',
    'geo.placename': 'Rotterdam, Vlaardingen',
    'geo.position': '51.9225;4.4792',
    'ICBM': '51.9225, 4.4792',
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        {/* Hreflang tags for multilingual SEO */}
        <link rel="alternate" hrefLang="en" href="https://littlecakesnl.nl/" />
        <link rel="alternate" hrefLang="nl" href="https://littlecakesnl.nl/" />
        <link rel="alternate" hrefLang="x-default" href="https://littlecakesnl.nl/" />
        
        {/* Performance Optimizations */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link rel="dns-prefetch" href="https://www.instagram.com" />
        <link rel="dns-prefetch" href="https://littlecakesnl.fillout.com" />
        
        {/* Preload Critical Resources */}
        <link rel="preload" href="/cakesrc.png" as="image" />
        
        {/* Security Headers */}
        <meta httpEquiv="X-Content-Type-Options" content="nosniff" />
        <meta httpEquiv="X-Frame-Options" content="DENY" />
        <meta httpEquiv="X-XSS-Protection" content="1; mode=block" />
        
        {/* Additional SEO Meta Tags */}
        <meta name="language" content="English, Dutch" />
        <meta name="geo.region" content="NL-ZH" />
        <meta name="geo.placename" content="Rotterdam, Vlaardingen" />
        <meta name="geo.position" content="51.9225;4.4792" />
        <meta name="ICBM" content="51.9225, 4.4792" />
        <meta name="distribution" content="local" />
        <meta name="coverage" content="Rotterdam, Vlaardingen, Netherlands" />
        <meta name="target" content="all" />
        <meta name="rating" content="general" />
        <meta name="revisit-after" content="7 days" />
        
        {/* Local Business Schema */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "LocalBusiness",
              "name": "LittleCakesNL",
              "description": "Custom dream cakes made with love in Rotterdam and Vlaardingen, Netherlands. Wedding cakes, birthday cakes, and special occasion cakes.",
              "url": "https://littlecakesnl.nl",
              "telephone": "+31-6-12345678",
              "email": "info@littlecakesnl.nl",
              "address": {
                "@type": "PostalAddress",
                "addressLocality": "Rotterdam",
                "addressRegion": "South Holland",
                "addressCountry": "NL"
              },
              "geo": {
                "@type": "GeoCoordinates",
                "latitude": 51.9225,
                "longitude": 4.4792
              },
              "openingHours": "Mo-Su 09:00-18:00",
              "priceRange": "€€",
              "servesCuisine": "Custom Cakes",
              "areaServed": [
                "Rotterdam",
                "Vlaardingen"
              ],
              "sameAs": [
                "https://www.instagram.com/littlecakesnl/"
              ],
              "aggregateRating": {
                "@type": "AggregateRating",
                "ratingValue": "4.9",
                "reviewCount": "127"
              }
            })
          }}
        />
      </head>
      <body
        className={`${lato.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
