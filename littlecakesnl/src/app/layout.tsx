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
  description: 'Handcrafted custom cakes made with love in The Netherlands. Wedding cakes, birthday cakes, and special occasion cakes. Pickup in Rotterdam & Vlaardingen. Order your dream cake today!',
  keywords: 'custom cakes, wedding cakes, birthday cakes, Rotterdam, Vlaardingen, Netherlands, cake delivery, cake pickup, custom cake design',
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
        alt: 'LittleCakesNL Custom Cakes',
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
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${lato.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
