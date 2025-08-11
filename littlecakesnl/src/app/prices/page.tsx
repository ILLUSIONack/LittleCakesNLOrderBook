'use client';

import { useState, useEffect } from 'react';
import Head from 'next/head';
import Navbar from '@/components/Navbar';

const metadata = {
  title: 'Custom Cake Prices | LittleCakesNL - Rotterdam & Vlaardingen',
  description: 'View our transparent pricing for custom cakes, wedding cakes, birthday cakes, and cupcakes. Starting prices with pickup in Rotterdam and Vlaardingen.',
  keywords: 'cake prices Netherlands, custom cake cost Rotterdam, wedding cake prices Vlaardingen, birthday cake pricing, cupcake prices Holland',
  canonical: 'https://littlecakesnl.nl/prices',
  openGraph: {
    title: 'Custom Cake Prices | LittleCakesNL',
    description: 'Transparent pricing for custom cakes in Rotterdam and Vlaardingen. Starting prices for wedding cakes, birthday cakes, and more.',
    url: 'https://littlecakesnl.nl/prices',
    siteName: 'LittleCakesNL',
    type: 'website',
    images: [
      {
        url: '/cakesrc.png',
        width: 1200,
        height: 630,
        alt: 'LittleCakesNL Custom Cake Prices',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Custom Cake Prices | LittleCakesNL',
    description: 'Transparent pricing for custom cakes in Rotterdam and Vlaardingen.',
    images: ['/cakesrc.png'],
  },
  robots: {
    index: true,
    follow: true,
  },
};

const PricesPage = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    setIsVisible(true);
    
    const handleMouseMove = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };
    
    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return (
    <>
      <Head>
        <title>{metadata.title}</title>
        <meta name="description" content={metadata.description} />
        <meta name="keywords" content={metadata.keywords} />
        <link rel="canonical" href={metadata.canonical} />
        <meta property="og:title" content={metadata.openGraph.title} />
        <meta property="og:description" content={metadata.openGraph.description} />
        <meta property="og:url" content={metadata.openGraph.url} />
        <meta property="og:site_name" content={metadata.openGraph.siteName} />
        <meta property="og:type" content={metadata.openGraph.type} />
        <meta property="og:image" content={metadata.openGraph.images[0].url} />
        <meta name="twitter:card" content={metadata.twitter.card} />
        <meta name="twitter:title" content={metadata.twitter.title} />
        <meta name="twitter:description" content={metadata.twitter.description} />
        <meta name="twitter:image" content={metadata.twitter.images[0]} />
        <meta name="robots" content="index, follow" />
      </Head>
      
      <div className="min-h-screen bg-gradient-to-br from-pink-50 via-white to-purple-50">
        {/* Structured Data for Pricing */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "PriceSpecification",
              "description": "Custom cake pricing for LittleCakesNL",
              "priceCurrency": "EUR",
              "eligibleRegion": {
                "@type": "Place",
                "name": "Netherlands",
                "containsPlace": [
                  {
                    "@type": "City",
                    "name": "Rotterdam"
                  },
                  {
                    "@type": "City", 
                    "name": "Vlaardingen"
                  }
                ]
              },
              "offers": [
                {
                  "@type": "Offer",
                  "itemOffered": {
                    "@type": "Product",
                    "name": "Custom Wedding Cake",
                    "category": "Wedding Cakes"
                  },
                  "price": "40",
                  "priceCurrency": "EUR",
                  "description": "Starting price for custom wedding cakes"
                },
                {
                  "@type": "Offer", 
                  "itemOffered": {
                    "@type": "Product",
                    "name": "Birthday Cake",
                    "category": "Birthday Cakes"
                  },
                  "price": "35",
                  "priceCurrency": "EUR",
                  "description": "Starting price for custom birthday cakes"
                }
              ]
            })
          }}
        />

        <Navbar />
        
        {/* Hero Section */}
        <section className="pt-32 pb-20 relative overflow-hidden">
          {/* Subtle floating elements */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div 
              className="absolute w-16 h-16 rounded-full bg-gradient-to-r from-pink-200 to-purple-200 opacity-30 animate-float"
              style={{ 
                top: '15%', 
                left: '10%',
                transform: `translate(${mousePosition.x * 0.005}px, ${mousePosition.y * 0.005}px)`
              }}
            />
            <div 
              className="absolute w-12 h-12 rounded-full bg-gradient-to-r from-blue-200 to-indigo-200 opacity-25 animate-float"
              style={{ 
                top: '75%', 
                right: '15%',
                transform: `translate(${mousePosition.x * -0.003}px, ${mousePosition.y * -0.003}px)`,
                animationDelay: '2s'
              }}
            />
          </div>

          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <div className={`transform transition-all duration-1000 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
            }`}>
              <div className="inline-flex items-center justify-center w-20 h-20 rounded-2xl bg-gradient-to-br from-pink-500 to-purple-600 text-white text-3xl mb-8 shadow-xl">
                💰
              </div>
              <h1 className="text-4xl lg:text-5xl font-bold text-gray-900 mb-6">
                <span className="bg-gradient-to-r from-pink-600 via-purple-600 to-blue-600 bg-clip-text text-transparent">
                  Transparent Pricing
                </span>
              </h1>
              <div className="w-24 h-1 bg-gradient-to-r from-pink-400 to-purple-500 mx-auto mb-8 rounded-full"></div>
              <p className="text-lg lg:text-xl text-gray-600 max-w-2xl mx-auto leading-relaxed mb-8">
                Starting prices for our custom cakes - add-ons and special decorations will be quoted separately
              </p>
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 shadow-lg border border-white/20 max-w-md mx-auto">
                <div className="flex items-center justify-center gap-4 text-sm text-gray-600">
                  <div className="flex items-center gap-2">
                    <span className="w-2 h-2 bg-pink-400 rounded-full"></span>
                    <span>Rotterdam & Vlaardingen</span>
                  </div>
                  <div className="w-px h-4 bg-gray-300"></div>
                  <div className="flex items-center gap-2">
                    <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                    <span>Pickup Only</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Price List Section */}
        <section className="pb-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            
            {/* Price Grid */}
            <div className="grid lg:grid-cols-2 gap-8 mb-16">
              
              {/* Left Column - Cake Types */}
              <div className="space-y-6">
                
                {/* Bento Cakes */}
                <div className={`bg-white rounded-3xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="flex items-center mb-6">
                    <div className="w-14 h-14 bg-gradient-to-br from-pink-400 to-rose-500 rounded-2xl flex items-center justify-center text-white text-xl mr-4 group-hover:scale-110 transition-transform duration-300">
                      🍱
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-1">Bento Cakes</h3>
                      <p className="text-sm text-gray-500">Starting prices</p>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">1-4 person</span>
                      <span className="font-bold text-pink-600 text-lg">€35</span>
                    </div>
                  </div>
                </div>

                {/* Round Cakes */}
                <div className={`bg-white rounded-3xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="flex items-center mb-6">
                    <div className="w-14 h-14 bg-gradient-to-br from-purple-400 to-indigo-500 rounded-2xl flex items-center justify-center text-white text-xl mr-4 group-hover:scale-110 transition-transform duration-300">
                      ⭕
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-1">Round Cakes</h3>
                      <p className="text-sm text-gray-500">Starting prices</p>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">4-8 person</span>
                      <span className="font-bold text-purple-600 text-lg">€40</span>
                    </div>
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">8-15 person</span>
                      <span className="font-bold text-purple-600 text-lg">€60</span>
                    </div>
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">15-20 person</span>
                      <span className="font-bold text-purple-600 text-lg">€80</span>
                    </div>
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">20-30 person</span>
                      <span className="font-bold text-purple-600 text-lg">€100</span>
                    </div>
                  </div>
                  
                  {/* Two Tiered Section */}
                  <div className="mt-6 pt-6 border-t border-gray-200">
                    <h4 className="font-bold text-gray-800 mb-4 text-center text-lg">Two Tiered</h4>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center py-3 px-4 bg-purple-50 rounded-xl border border-purple-100">
                        <span className="text-gray-700 font-medium">35-40 person</span>
                        <span className="font-bold text-purple-600 text-lg">€130</span>
                      </div>
                      <div className="flex justify-between items-center py-3 px-4 bg-purple-50 rounded-xl border border-purple-100">
                        <span className="text-gray-700 font-medium">45-50 person</span>
                        <span className="font-bold text-purple-600 text-lg">€150</span>
                      </div>
                    </div>
                    <p className="text-sm text-gray-500 mt-4 text-center italic">
                      DM us for 50+ person cake
                    </p>
                  </div>
                </div>

                {/* Heart Cakes */}
                <div className={`bg-white rounded-3xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="flex items-center mb-6">
                    <div className="w-14 h-14 bg-gradient-to-br from-red-400 to-pink-500 rounded-2xl flex items-center justify-center text-white text-xl mr-4 group-hover:scale-110 transition-transform duration-300">
                      💝
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-1">Heart Cakes</h3>
                      <p className="text-sm text-gray-500">Starting prices</p>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">4-8 person</span>
                      <span className="font-bold text-red-600 text-lg">€50</span>
                    </div>
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">8-15 person</span>
                      <span className="font-bold text-red-600 text-lg">€70</span>
                    </div>
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">15-20 person</span>
                      <span className="font-bold text-red-600 text-lg">€90</span>
                    </div>
                  </div>
                  
                  {/* Two Tiered Section */}
                  <div className="mt-6 pt-6 border-t border-gray-200">
                    <h4 className="font-bold text-gray-800 mb-4 text-center text-lg">Two Tiered</h4>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center py-3 px-4 bg-red-50 rounded-xl border border-red-100">
                        <span className="text-gray-700 font-medium">20-30 person</span>
                        <span className="font-bold text-red-600 text-lg">€120</span>
                      </div>
                      <div className="flex justify-between items-center py-3 px-4 bg-red-50 rounded-xl border border-red-100">
                        <span className="text-gray-700 font-medium">30-40 person</span>
                        <span className="font-bold text-red-600 text-lg">€140</span>
                      </div>
                      <div className="flex justify-between items-center py-3 px-4 bg-red-50 rounded-xl border border-red-100">
                        <span className="text-gray-700 font-medium">40-50 person</span>
                        <span className="font-bold text-red-600 text-lg">€160</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Cupcakes */}
                <div className={`bg-white rounded-3xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="flex items-center mb-6">
                    <div className="w-14 h-14 bg-gradient-to-br from-yellow-400 to-orange-500 rounded-2xl flex items-center justify-center text-white text-xl mr-4 group-hover:scale-110 transition-transform duration-300">
                      🧁
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-1">Cupcakes</h3>
                      <p className="text-sm text-gray-500">Starting prices</p>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">1 cupcake</span>
                      <span className="font-bold text-yellow-600 text-lg">€3.50</span>
                    </div>
                    <div className="flex justify-between items-center py-3 px-4 bg-gray-50 rounded-xl">
                      <span className="text-gray-700 font-medium">12 cupcakes</span>
                      <span className="font-bold text-yellow-600 text-lg">€30</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Right Column - Options & Flavors */}
              <div className="space-y-6">
                
                {/* Cake Fillings */}
                <div className={`bg-white rounded-3xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="flex items-center mb-6">
                    <div className="w-14 h-14 bg-gradient-to-br from-green-400 to-teal-500 rounded-2xl flex items-center justify-center text-white text-xl mr-4 group-hover:scale-110 transition-transform duration-300">
                      🍰
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-1">Cake Fillings</h3>
                      <p className="text-sm text-gray-500">Available options</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div className="flex items-center p-3 bg-green-50 rounded-xl border border-green-100">
                      <span className="w-2 h-2 bg-green-400 rounded-full mr-3"></span>
                      <span className="text-gray-700 text-sm">Vanilla cream</span>
                    </div>
                    <div className="flex items-center p-3 bg-green-50 rounded-xl border border-green-100">
                      <span className="w-2 h-2 bg-green-400 rounded-full mr-3"></span>
                      <span className="text-gray-700 text-sm">Strawberry cream</span>
                    </div>
                    <div className="flex items-center p-3 bg-green-50 rounded-xl border border-green-100">
                      <span className="w-2 h-2 bg-green-400 rounded-full mr-3"></span>
                      <span className="text-gray-700 text-sm">Raspberry cream</span>
                    </div>
                    <div className="flex items-center p-3 bg-green-50 rounded-xl border border-green-100">
                      <span className="w-2 h-2 bg-green-400 rounded-full mr-3"></span>
                      <span className="text-gray-700 text-sm">White chocolate ganache</span>
                    </div>
                    <div className="flex items-center p-3 bg-green-50 rounded-xl border border-green-100 sm:col-span-2">
                      <span className="w-2 h-2 bg-green-400 rounded-full mr-3"></span>
                      <span className="text-gray-700 text-sm">Chocolate ganache</span>
                    </div>
                  </div>
                </div>

                {/* Cake Flavours */}
                <div className={`bg-white rounded-3xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="flex items-center mb-6">
                    <div className="w-14 h-14 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-2xl flex items-center justify-center text-white text-xl mr-4 group-hover:scale-110 transition-transform duration-300">
                      🎂
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-1">Cake Flavours</h3>
                      <p className="text-sm text-gray-500">Base flavors</p>
                    </div>
                  </div>
                  <div className="space-y-4">
                    <div className="flex items-center p-4 bg-blue-50 rounded-xl border border-blue-100">
                      <div className="w-12 h-12 bg-gradient-to-br from-yellow-300 to-yellow-500 rounded-full flex items-center justify-center text-white font-bold mr-4">
                        V
                      </div>
                      <div>
                        <h4 className="font-bold text-gray-800">Vanilla</h4>
                        <p className="text-sm text-gray-600">Classic vanilla sponge</p>
                      </div>
                    </div>
                    <div className="flex items-center p-4 bg-blue-50 rounded-xl border border-blue-100">
                      <div className="w-12 h-12 bg-gradient-to-br from-amber-600 to-brown-700 rounded-full flex items-center justify-center text-white font-bold mr-4">
                        C
                      </div>
                      <div>
                        <h4 className="font-bold text-gray-800">Chocolate</h4>
                        <p className="text-sm text-gray-600">Rich chocolate sponge</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Call to Action Card */}
                <div className={`bg-gradient-to-br from-pink-50 via-purple-50 to-blue-50 rounded-3xl p-8 shadow-lg border-2 border-pink-200 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 group ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                }`}>
                  <div className="text-center">
                    <div className="w-16 h-16 bg-gradient-to-br from-pink-500 to-purple-600 rounded-2xl flex items-center justify-center text-white text-2xl mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                      📞
                    </div>
                    <h3 className="text-xl font-bold text-gray-800 mb-4">Ready to Order?</h3>
                    <p className="text-gray-600 mb-6 leading-relaxed text-sm">
                      Get your custom quote today! All prices are starting rates - add-ons and special decorations will be quoted separately.
                    </p>
                    <a
                      href="https://littlecakesnl.fillout.com/t/mEu3kPtDbius"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-3 bg-gradient-to-r from-pink-500 to-purple-600 text-white px-6 py-3 rounded-full font-bold hover:from-pink-600 hover:to-purple-700 transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl"
                    >
                      <span>🎂</span>
                      Get Your Quote
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                      </svg>
                    </a>
                  </div>
                </div>
              </div>
            </div>

            {/* Bottom Notice */}
            <div className={`text-center transform transition-all duration-1000 delay-800 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
            }`}>
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 shadow-lg border border-gray-100 max-w-2xl mx-auto">
                <div className="flex items-center justify-center gap-3 mb-4">
                  <span className="text-2xl">💡</span>
                  <h3 className="text-lg font-bold text-gray-800">Please Note</h3>
                </div>
                <p className="text-gray-600 leading-relaxed text-sm">
                  <strong>These are starting prices, add-ons will cost extra.</strong><br/>
                  Final pricing depends on design complexity, decorations, and special requirements.
                </p>
              </div>
            </div>

            {/* Contact Section */}
            <div className={`text-center mt-16 transform transition-all duration-1000 delay-900 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
            }`}>
              <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-8 shadow-lg border border-gray-100 max-w-4xl mx-auto">
                <h3 className="text-2xl font-bold text-gray-800 mb-4">Have Questions About Pricing?</h3>
                <p className="text-gray-600 mb-8 leading-relaxed">
                  Every cake is unique! Contact us on Instagram for a personalized quote based on your specific requirements.
                </p>
                <div className="flex flex-wrap justify-center gap-4">
                  <a
                    href="https://www.instagram.com/littlecakesnl/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-3 bg-gradient-to-r from-pink-500 to-purple-600 text-white px-6 py-3 rounded-full font-bold hover:from-pink-600 hover:to-purple-700 transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl"
                  >
                    <span>📱</span>
                    Contact on Instagram
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                  <a
                    href="/"
                    className="inline-flex items-center gap-3 bg-gray-100 text-gray-700 px-6 py-3 rounded-full font-bold hover:bg-gray-200 transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl"
                  >
                    <span>🏠</span>
                    Back to Homepage
                  </a>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </>
  );
};

export default PricesPage;