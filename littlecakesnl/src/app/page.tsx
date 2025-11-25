'use client';

import { useState, useEffect } from 'react';
import Navbar from '@/components/Navbar';
import CakeFeed from '@/components/InstagramFeed';
import StickyCTA from '@/components/StickyCTA';
import { motion } from 'framer-motion';

const Home = () => {
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

  // Local Business Structured Data for SEO
  const localBusinessData = {
    "@context": "https://schema.org",
    "@type": "Bakery",
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
    "hasOfferCatalog": {
      "@type": "OfferCatalog",
      "name": "Custom Cake Services",
      "itemListElement": [
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "Service",
            "name": "Wedding Cakes",
            "description": "Custom wedding cakes with personalized designs"
          }
        },
        {
          "@type": "Offer", 
          "itemOffered": {
            "@type": "Service",
            "name": "Birthday Cakes",
            "description": "Personalized birthday and celebration cakes"
          }
        },
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "Service", 
            "name": "Cupcakes",
            "description": "Custom decorated cupcakes for events"
          }
        }
      ]
    },
    "sameAs": [
      "https://www.instagram.com/littlecakesnl/"
    ],
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "4.9",
      "reviewCount": "127"
    },
    "review": [
      {
        "@type": "Review",
        "reviewRating": {
          "@type": "Rating",
          "ratingValue": "5",
          "bestRating": "5"
        },
        "author": {
          "@type": "Person",
          "name": "Sarah M."
        },
        "reviewBody": "Amazing wedding cake! The design was exactly what I wanted and tasted incredible."
      },
      {
        "@type": "Review",
        "reviewRating": {
          "@type": "Rating",
          "ratingValue": "5",
          "bestRating": "5"
        },
        "author": {
          "@type": "Person",
          "name": "Michael K."
        },
        "reviewBody": "Best birthday cake I've ever had. The attention to detail is incredible!"
      }
    ],
    "menu": "https://littlecakesnl.fillout.com/t/vzLF1V9hvNus",
    "acceptsReservations": false,
    "currenciesAccepted": "EUR",
    "paymentAccepted": "Cash, Credit Card, Bank Transfer"
  };

  return (
    <div className="min-h-screen mobile-viewport flex flex-col overflow-hidden">
      {/* Structured Data for SEO */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(localBusinessData)
        }}
      />
      
      {/* Social Media Profile Schema */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "Organization",
            "name": "LittleCakesNL",
            "url": "https://littlecakesnl.nl",
            "logo": "https://littlecakesnl.nl/cakesrc.png",
            "sameAs": [
              "https://www.instagram.com/littlecakesnl/"
            ],
            "contactPoint": {
              "@type": "ContactPoint",
              "contactType": "customer service",
              "availableLanguage": ["English", "Dutch"]
            }
          })
        }}
      />
      
      {/* Breadcrumb Schema */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "BreadcrumbList",
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": "Home",
                "item": "https://littlecakesnl.nl"
              }
            ]
          })
        }}
      />
      
      {/* WebPage Schema */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "WebPage",
            "name": "LittleCakesNL - Custom Dream Cakes in Rotterdam & Vlaardingen",
            "description": "Handcrafted custom cakes made with love in The Netherlands. Wedding cakes, birthday cakes, and special occasion cakes. Pickup only in Rotterdam & Vlaardingen.",
            "url": "https://littlecakesnl.nl",
            "mainEntity": {
              "@type": "Bakery",
              "name": "LittleCakesNL"
            },
            "breadcrumb": {
              "@type": "BreadcrumbList",
              "itemListElement": [
                {
                  "@type": "ListItem",
                  "position": 1,
                  "name": "Home",
                  "item": "https://littlecakesnl.nl"
                }
              ]
            }
          })
        }}
      />
      
      {/* FAQ Schema for Homepage FAQ Section */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "FAQPage",
            "mainEntity": [
              {
                "@type": "Question",
                "name": "How do I order a custom cake?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "Fill out our order form with your requirements, then send us a screenshot via Instagram @littlecakesnl. We'll respond within 1-3 working days with a quote."
                }
              },
              {
                "@type": "Question",
                "name": "Do you offer delivery?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "No, we only offer pickup service in Rotterdam and Vlaardingen. This helps us maintain quality and reduce costs."
                }
              },
              {
                "@type": "Question",
                "name": "How far in advance should I order?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "We recommend ordering at least 2 weeks in advance for custom cakes due to our limited weekly spots."
                }
              }
            ]
          })
        }}
      />
      
      {/* Article Schema for Blog Content */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "ItemList",
            "name": "Cake Tips & Inspiration",
            "description": "Helpful articles about custom cakes, local pickup, and cake inspiration",
            "itemListElement": [
              {
                "@type": "Article",
                "position": 1,
                "name": "Wedding Cake Trends in Rotterdam",
                "description": "Discover the latest wedding cake trends popular in Rotterdam and how to choose the perfect design for your special day.",
                "url": "https://littlecakesnl.nl#wedding-cakes",
                "author": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                },
                "publisher": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                }
              },
              {
                "@type": "Article",
                "position": 2,
                "name": "Birthday Cake Ideas for All Ages",
                "description": "Creative birthday cake ideas that will make any celebration special, from kids to adults.",
                "url": "https://littlecakesnl.nl#birthday-cakes",
                "author": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                },
                "publisher": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                }
              },
              {
                "@type": "Article",
                "position": 3,
                "name": "Local Cake Pickup in Rotterdam Metropolitan Area",
                "description": "Serving Rotterdam and Vlaardingen with convenient pickup locations and local expertise.",
                "url": "https://littlecakesnl.nl#local-pickup",
                "author": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                },
                "publisher": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                }
              },
              {
                "@type": "Article",
                "position": 4,
                "name": "Custom Cake Design Process",
                "description": "Learn how we work with you to create the perfect custom cake design from concept to creation.",
                "url": "https://littlecakesnl.nl#custom-design",
                "author": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                },
                "publisher": {
                  "@type": "Organization",
                  "name": "LittleCakesNL"
                }
              }
            ]
          })
        }}
      />
      
      {/* Service Schema for Cake Services */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "ItemList",
            "name": "Custom Cake Services",
            "description": "Professional custom cake services offered by LittleCakesNL",
            "itemListElement": [
              {
                "@type": "Service",
                "position": 1,
                "name": "Wedding Cakes",
                "description": "Custom wedding cakes with personalized designs, perfect for your special day. Available in Rotterdam and Vlaardingen.",
                "provider": {
                  "@type": "Bakery",
                  "name": "LittleCakesNL"
                },
                "areaServed": ["Rotterdam", "Vlaardingen"],
                "serviceType": "Wedding Cake Design",
                "priceRange": "€€"
              },
              {
                "@type": "Service",
                "position": 2,
                "name": "Birthday Cakes",
                "description": "Personalized birthday and celebration cakes for all ages. Custom designs and flavors available.",
                "provider": {
                  "@type": "Bakery",
                  "name": "LittleCakesNL"
                },
                "areaServed": ["Rotterdam", "Vlaardingen"],
                "serviceType": "Birthday Cake Design",
                "priceRange": "€€"
              },
              {
                "@type": "Service",
                "position": 3,
                "name": "Cupcakes",
                "description": "Custom decorated cupcakes for events and celebrations. Perfect for parties and gatherings.",
                "provider": {
                  "@type": "Bakery",
                  "name": "LittleCakesNL"
                },
                "areaServed": ["Rotterdam", "Vlaardingen"],
                "serviceType": "Cupcake Design",
                "priceRange": "€"
              }
            ]
          })
        }}
      />
      
      <Navbar />
      
      {/* Main Content - Single Page Layout */}
      <div className="flex-1 flex flex-col lg:flex-row hero-bg">
        
        {/* Left Content Area - Full width on mobile, 60% on desktop */}
        <div className="w-full lg:w-3/5 flex items-center justify-center p-6 lg:p-12 pt-20 lg:pt-16 relative min-h-[calc(100vh-4rem)]">
          
          {/* Floating Decorative Elements */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            {/* Mobile Background Image - Subtle */}
            <div className="lg:hidden absolute inset-0 opacity-5">
              <div 
                className="absolute inset-0 bg-cover bg-center bg-no-repeat"
                style={{ backgroundImage: 'url(/cakesrc.png)' }}
              />
            </div>
            
            {/* Floating Elements */}
            <div 
              className="absolute w-20 h-20 rounded-full morph-gradient opacity-20 animate-float float-delay-1"
              style={{ 
                top: '10%', 
                left: '10%',
                transform: `translate(${mousePosition.x * 0.01}px, ${mousePosition.y * 0.01}px)`
              }}
            />
            <div 
              className="absolute w-16 h-16 rounded-full bg-gradient-to-r from-black to-gray-600 opacity-30 animate-float float-delay-2"
              style={{ 
                top: '70%', 
                right: '15%',
                transform: `translate(${mousePosition.x * -0.005}px, ${mousePosition.y * -0.005}px)`
              }}
            />
            <div 
              className="absolute w-12 h-12 rounded-full bg-gradient-to-r from-pink-300 to-pink-500 opacity-25 animate-float float-delay-3"
              style={{ 
                top: '40%', 
                left: '5%',
                transform: `translate(${mousePosition.x * 0.008}px, ${mousePosition.y * 0.008}px)`
              }}
            />
          </div>

          <div className={`max-w-2xl mx-auto text-center lg:text-left transform transition-all duration-1000 ${
            isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
          }`}>
            
            {/* Main Headline */}
            <h1 className={`text-4xl lg:text-6xl xl:text-7xl font-bold mb-6 leading-tight transform transition-all duration-1000 delay-200 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              <span className="gradient-text">Custom Dream Cakes</span>
              <br />
              <span className="text-gray-700 text-3xl lg:text-4xl xl:text-5xl">Made Just for You</span>
            </h1>

            {/* Subheadline */}
            <p className={`text-xl lg:text-2xl text-gray-600 mb-8 leading-relaxed transform transition-all duration-1000 delay-300 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              <span className="font-semibold text-pink-600">Delicious custom cakes</span> in The Netherlands
            </p>

            {/* Process Title */}
            <div className={`text-center mb-6 transform transition-all duration-1000 delay-350 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              <h2 className="text-2xl lg:text-3xl font-bold text-gray-800">
                How It Works
              </h2>
            </div>

            {/* Ordering Process Steps */}
            <div className={`grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6 mb-8 sm:mb-10 transform transition-all duration-1000 delay-400 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              <div className="modern-card p-6 hover-scale text-center relative">
                <div className="absolute -top-3 -left-3 w-8 h-8 bg-gradient-to-r from-pink-500 to-pink-600 text-white rounded-full flex items-center justify-center text-sm font-bold">
                  1
                </div>
                <div className="text-4xl mb-3">📝</div>
                <h3 className="font-bold text-gray-800 mb-2">Place Your Quote</h3>
                <p className="text-sm text-gray-600 leading-relaxed">
                  Click the &quot;Place Order&quot; button to fill out our form with your cake specifications and requirements.
                </p>
              </div>
              <div className="modern-card p-6 hover-scale text-center relative">
                <div className="absolute -top-3 -left-3 w-8 h-8 bg-gradient-to-r from-pink-500 to-pink-600 text-white rounded-full flex items-center justify-center text-sm font-bold">
                  2
                </div>
                <div className="text-4xl mb-3">📱</div>
                <h3 className="font-bold text-gray-800 mb-2">Send Screenshot</h3>
                <p className="text-sm text-gray-600 leading-relaxed">
                  Share a screenshot of your request via Instagram <span className="font-semibold text-pink-600">@littlecakesnl</span>. We&apos;ll respond within 1-3 working days with details.
                </p>
              </div>
              <div className="modern-card p-6 hover-scale text-center relative">
                <div className="absolute -top-3 -left-3 w-8 h-8 bg-gradient-to-r from-pink-500 to-pink-600 text-white rounded-full flex items-center justify-center text-sm font-bold">
                  3
                </div>
                <div className="text-4xl mb-3">💰</div>
                <h3 className="font-bold text-gray-800 mb-2">Confirm & Pay</h3>
                <p className="text-sm text-gray-600 leading-relaxed">
                  Receive your custom price and payment request via Instagram <span className="font-semibold text-pink-600">@littlecakesnl</span>. Confirm to start baking!
                </p>
              </div>
            </div>

            {/* CTA Section - Enhanced */}
            <div className={`space-y-6 transform transition-all duration-1000 delay-450 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              
              {/* Primary CTA Section - Enhanced */}
              <div className="space-y-6">
                {/* Enhanced CTA Button */}
                <div className="flex justify-center">
                  <a 
                    href="https://littlecakesnl.fillout.com/t/vzLF1V9hvNus"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-block group"
                  >
                    <motion.button 
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      className="btn-modern px-16 py-6 text-2xl font-bold hover-glow group relative overflow-hidden animate-pulse shadow-2xl"
                    >
                      {/* Enhanced Button Background */}
                      <div className="absolute inset-0 bg-gradient-to-r from-pink-500 via-purple-600 to-pink-600 opacity-90 group-hover:opacity-100 transition-opacity duration-300"></div>
                      
                      {/* Button Content */}
                      <span className="relative z-10 flex items-center gap-4 text-white">
                        <span className="text-3xl">🎂</span>
                        <span>Place Your Order Now</span>
                        <svg className="w-7 h-7 transition-transform group-hover:translate-x-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                        </svg>
                      </span>
                    </motion.button>
                  </a>
                </div>
                
                {/* Enhanced Value Props */}
                <div className="flex flex-wrap justify-center gap-6 text-base text-gray-600">
                  <div className="flex items-center gap-2 bg-white/80 px-4 py-2 rounded-full shadow-lg">
                    <span className="text-green-500 text-xl">✓</span>
                    <span className="font-semibold">No commitment</span>
                  </div>
                  <div className="flex items-center gap-2 bg-white/80 px-4 py-2 rounded-full shadow-lg">
                    <span className="text-green-500 text-xl">✓</span>
                    <span className="font-semibold">Custom pricing</span>
                  </div>
                  <div className="flex items-center gap-2 bg-white/80 px-4 py-2 rounded-full shadow-lg">
                    <span className="text-green-500 text-xl">✓</span>
                    <span className="font-semibold">1-3 days response</span>
                  </div>
                </div>
                
                {/* Enhanced Trust Message */}
                <div className="text-center">
                  <p className="text-sm text-gray-500 mb-2">
                    Join 100+ happy customers who got their dream cakes
                  </p>
                  <p className="text-xs text-gray-400">
                    By requesting a quote you agree to our terms and conditions
                  </p>
                </div>
              </div>
            </div>

            {/* Instagram Note - Enhanced Design */}


          </div>
        </div>

        {/* Right Image Area - Desktop Only */}
        <div className="hidden lg:block lg:w-2/5 relative overflow-hidden">
          
          {/* Background Image */}
          <div 
            className="absolute inset-0 bg-cover bg-center transition-transform duration-700 hover:scale-105"
            style={{ 
              backgroundImage: 'url(/cakesrc.png)',
              transform: `scale(${1 + mousePosition.x * 0.00005})`
            }}
          />
          
          {/* Dark Overlay - Desktop Only */}
          <div className="absolute inset-0 bg-black/50" />
          
          {/* Gradient Overlay */}
          <div className="absolute inset-0 bg-gradient-to-l from-black/60 via-black/30 to-transparent" />
          
          {/* Premium Badge */}
          <div className="absolute top-8 left-8 right-8">
            <div className="glass-effect px-4 py-2 rounded-full text-sm font-bold text-white text-center animate-fade-in">
              🎂 Premium Custom Cakes
            </div>
          </div>
          
          {/* Decorative Elements */}
          <div className="absolute inset-0">
            <div className="absolute top-20 right-20 w-24 h-24 rounded-full glass-effect animate-float float-delay-1" />
            <div className="absolute bottom-32 right-12 w-16 h-16 rounded-full glass-effect animate-float float-delay-2" />
          </div>
          
          {/* Content Overlay */}
          <div className="absolute bottom-12 left-8 right-8 text-white">
            <div className="glass-card p-6">
              <h3 className="text-xl font-bold mb-2">Premium Craftsmanship</h3>
              <p className="text-sm text-white/90">
                Each cake is a masterpiece, carefully crafted with attention to detail and love.
              </p>
            </div>
          </div>
        </div>
      </div>



      {/* SEO Content Section - Business Information */}
      <section className="py-16 bg-gradient-to-b from-white to-gray-50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto">
            
            {/* About LittleCakesNL */}
            <div className="mb-16">
              <div className="text-center mb-8">
                <div className="w-16 h-16 bg-gradient-to-br from-pink-100 to-purple-100 rounded-full flex items-center justify-center mx-auto mb-6">
                  <span className="text-2xl">🎂</span>
                </div>
                <h2 className="text-3xl lg:text-4xl font-bold text-gray-800 mb-4">
                  About LittleCakesNL
                </h2>
                <div className="w-20 h-1 bg-gradient-to-r from-pink-400 to-purple-500 mx-auto rounded-full"></div>
              </div>
              <div className="prose prose-lg mx-auto text-gray-600">
                <p className="mb-4">
                  LittleCakesNL is your premier destination for custom cakes in Rotterdam and Vlaardingen, Netherlands. 
                  We specialize in creating unique, handcrafted cakes that turn your vision into reality. Whether you&apos;re 
                  celebrating a wedding, birthday, anniversary, or any special occasion, our expert bakers bring creativity 
                  and passion to every creation.
                </p>
                <p className="mb-4">
                  Located in the heart of South Holland, we serve customers in Rotterdam and Vlaardingen. 
                  Our commitment to quality ingredients, artistic design, and personalized service has made us 
                  the trusted choice for custom cakes in these communities.
                </p>
              </div>
            </div>

            {/* Services Grid */}
            <div className="mb-16">
              <div className="text-center mb-10">
                <div className="w-16 h-16 bg-gradient-to-br from-purple-100 to-pink-100 rounded-full flex items-center justify-center mx-auto mb-6">
                  <span className="text-2xl">✨</span>
                </div>
                <h2 className="text-3xl lg:text-4xl font-bold text-gray-800 mb-4">
                  Our Cake Services
                </h2>
                <div className="w-20 h-1 bg-gradient-to-r from-purple-400 to-pink-500 mx-auto rounded-full"></div>
                <p className="text-lg text-gray-600 mt-4 max-w-2xl mx-auto">
                  From elegant weddings to joyful celebrations, we create cakes that make every moment special
                </p>
              </div>
                            <div className="grid md:grid-cols-3 gap-8">
                <div className="bg-white p-8 rounded-3xl shadow-xl border border-gray-100 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                  <div className="w-16 h-16 bg-gradient-to-br from-pink-100 to-red-100 rounded-2xl flex items-center justify-center mb-6">
                    <span className="text-2xl">💒</span>
                  </div>
                  <h3 className="text-xl font-bold text-gray-800 mb-4">Wedding Cakes</h3>
                  <p className="text-gray-600 mb-4">
                    Create the perfect centerpiece for your special day with our elegant wedding cakes. 
                    From classic tiered designs to modern minimalist styles, we work closely with you 
                    to design a cake that reflects your personality and wedding theme.
                  </p>
                  <ul className="text-sm text-gray-600 space-y-1">
                    <li>• Multi-tier designs</li>
                    <li>• Custom flavors and fillings</li>
                    <li>• Sugar flower decorations</li>
                    <li>• Pickup in Rotterdam & Vlaardingen</li>
                  </ul>
                </div>

                <div className="bg-white p-8 rounded-3xl shadow-xl border border-gray-100 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                  <div className="w-16 h-16 bg-gradient-to-br from-purple-100 to-pink-100 rounded-2xl flex items-center justify-center mb-6">
                    <span className="text-2xl">🎉</span>
                  </div>
                  <h3 className="text-xl font-bold text-gray-800 mb-4">Birthday & Celebration Cakes</h3>
                  <p className="text-gray-600 mb-4">
                    Make every birthday unforgettable with our custom celebration cakes. Whether it&apos;s 
                    a child&apos;s themed party or an adult&apos;s milestone celebration, we create cakes that 
                    bring joy and excitement to any gathering.
                  </p>
                  <ul className="text-sm text-gray-600 space-y-1">
                    <li>• Character and theme cakes</li>
                    <li>• Personalized messages</li>
                    <li>• Fondant and buttercream options</li>
                    <li>• Various sizes available</li>
                  </ul>
                </div>

                <div className="bg-white p-8 rounded-3xl shadow-xl border border-gray-100 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                  <div className="w-16 h-16 bg-gradient-to-br from-blue-100 to-pink-100 rounded-2xl flex items-center justify-center mb-6">
                    <span className="text-2xl">🎊</span>
                  </div>
                  <h3 className="text-xl font-bold text-gray-800 mb-4">Gender Reveal Cakes</h3>
                  <p className="text-gray-600 mb-4">
                    Make your gender reveal party unforgettable with our stunning surprise cakes! 
                    Our specially designed cakes feature hidden colored fillings that reveal the gender 
                    when cut, creating a magical moment for family and friends.
                  </p>
                  <ul className="text-sm text-gray-600 space-y-1">
                    <li>• Hidden colored fillings (pink/blue)</li>
                    <li>• Custom decorations and themes</li>
                    <li>• Perfect for intimate gatherings</li>
                    <li>• Available in various sizes</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Why Choose Us */}
            <div className="bg-gradient-to-r from-pink-50 to-purple-50 p-10 rounded-3xl mb-16 shadow-xl border border-pink-100">
              <div className="text-center mb-10">
                <div className="w-16 h-16 bg-gradient-to-br from-pink-200 to-purple-200 rounded-full flex items-center justify-center mx-auto mb-6">
                  <span className="text-2xl">⭐</span>
                </div>
                <h3 className="text-3xl lg:text-4xl font-bold text-gray-800 mb-4">
                  Why Choose LittleCakesNL?
                </h3>
                <div className="w-20 h-1 bg-gradient-to-r from-pink-400 to-purple-500 mx-auto rounded-full"></div>
                <p className="text-lg text-gray-600 mt-4 max-w-2xl mx-auto">
                  We combine creativity, quality, and local expertise to deliver exceptional cakes
                </p>
              </div>
              <div className="grid md:grid-cols-3 gap-8">
                <div className="text-center">
                  <div className="w-16 h-16 bg-pink-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-2xl">🎨</span>
                  </div>
                  <h4 className="font-bold text-gray-800 mb-2">Custom Design</h4>
                  <p className="text-sm text-gray-600">
                    Every cake is uniquely designed according to your specifications and preferences
                  </p>
                </div>
                <div className="text-center">
                  <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-2xl">🌱</span>
                  </div>
                  <h4 className="font-bold text-gray-800 mb-2">Quality Ingredients</h4>
                  <p className="text-sm text-gray-600">
                    We use only the finest, fresh ingredients to ensure exceptional taste and quality
                  </p>
                </div>
                <div className="text-center">
                  <div className="w-16 h-16 bg-pink-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-2xl">📍</span>
                  </div>
                  <h4 className="font-bold text-gray-800 mb-2">Local Service</h4>
                  <p className="text-sm text-gray-600">
                    Convenient pickup locations in Rotterdam and Vlaardingen, serving the local community
                  </p>
                </div>
              </div>
            </div>

            {/* Location Information */}
            <div className="bg-white p-8 rounded-3xl shadow-xl border border-gray-100 mb-16">
              <div className="text-center mb-8">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-100 to-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
                  <span className="text-2xl">📍</span>
                </div>
                <h3 className="text-2xl lg:text-3xl font-bold text-gray-800 mb-4">Service Areas</h3>
                <div className="w-20 h-1 bg-gradient-to-r from-blue-400 to-green-500 mx-auto rounded-full"></div>
              </div>
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold text-gray-800 mb-2">Primary Locations</h4>
                  <ul className="text-gray-600 space-y-1">
                    <li>• Rotterdam - City center and surrounding areas</li>
                    <li>• Vlaardingen - All neighborhoods</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-800 mb-2">Pickup Locations</h4>
                  <ul className="text-gray-600 space-y-1">
                    <li>• Free pickup in Rotterdam</li>
                    <li>• Free pickup in Vlaardingen</li>
                    <li>• Pickup only - no delivery service</li>
                    <li>• Flexible pickup times</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Blog/Content Section for SEO */}
            <div className="mt-16 mb-16">
              <div className="text-center mb-10">
                <div className="w-16 h-16 bg-gradient-to-br from-yellow-100 to-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
                  <span className="text-2xl">📚</span>
                </div>
                <h3 className="text-3xl lg:text-4xl font-bold text-gray-800 mb-4">
                  Cake Tips & Inspiration
                </h3>
                <div className="w-20 h-1 bg-gradient-to-r from-yellow-400 to-orange-500 mx-auto rounded-full"></div>
                <p className="text-lg text-gray-600 mt-4 max-w-2xl mx-auto">
                  Discover helpful tips and creative ideas for your next cake celebration
                </p>
              </div>
              <div className="grid md:grid-cols-2 gap-6">
                <article className="bg-white p-6 rounded-2xl shadow-lg border border-gray-100">
                  <h4 className="text-lg font-bold text-gray-800 mb-3">
                    How to Choose the Perfect Wedding Cake
                  </h4>
                  <p className="text-gray-600 text-sm mb-4">
                    Selecting your wedding cake is one of the most exciting decisions you&apos;ll make for your big day. 
                    Consider your wedding theme, guest count, and personal taste preferences. Our expert bakers 
                    can help you design a cake that perfectly complements your celebration.
                  </p>
                  <div className="text-xs text-gray-500">
                    <span>Wedding Cakes</span> • <span>Design Tips</span> • <span>Rotterdam</span>
                  </div>
                </article>

                <article className="bg-white p-6 rounded-2xl shadow-lg border border-gray-100">
                  <h4 className="text-lg font-bold text-gray-800 mb-3">
                    Birthday Cake Trends in The Netherlands
                  </h4>
                  <p className="text-gray-600 text-sm mb-4">
                    From classic chocolate to trendy unicorn designs, birthday cakes in the Netherlands 
                    are becoming more creative and personalized. Discover the latest trends and how to 
                    make your celebration cake truly special with custom designs and flavors.
                  </p>
                  <div className="text-xs text-gray-500">
                    <span>Birthday Cakes</span> • <span>Trends</span> • <span>Vlaardingen</span>
                  </div>
                </article>

                <article className="bg-white p-6 rounded-2xl shadow-lg border border-gray-100">
                  <h4 className="text-lg font-bold text-gray-800 mb-3">
                    Cupcake vs. Cake: Which is Right for Your Event?
                  </h4>
                  <p className="text-gray-600 text-sm mb-4">
                    Planning an event in Rotterdam or Vlaardingen? Learn the pros and cons of cupcakes 
                    versus traditional cakes. Cupcakes offer individual portions and variety, while cakes 
                    create a stunning centerpiece. We can help you decide based on your event needs.
                  </p>
                  <div className="text-xs text-gray-500">
                    <span>Cupcakes</span> • <span>Event Planning</span> • <span>South Holland</span>
                  </div>
                </article>

                <article className="bg-white p-6 rounded-2xl shadow-lg border border-gray-100">
                  <h4 className="text-lg font-bold text-gray-800 mb-3">
                    Local Cake Pickup in Rotterdam Metropolitan Area
                  </h4>
                  <p className="text-gray-600 text-sm mb-4">
                    Serving Rotterdam and Vlaardingen with convenient pickup locations. 
                    Our local presence means better communication and understanding 
                    of local preferences and dietary requirements common in the Netherlands.
                  </p>
                  <div className="text-xs text-gray-500">
                    <span>Local Pickup</span> • <span>Rotterdam</span> • <span>Service Area</span>
                  </div>
                </article>
              </div>
            </div>
            
          </div>
      {/* Cake Feed Section - Social Proof */}
      <CakeFeed maxPosts={6} />
      
      {/* Instagram Note - Enhanced Design */}
      <div className="glass-effect p-6 rounded-2xl mb-6 text-center relative overflow-hidden group hover-glow max-w-4xl mx-auto">
        {/* Animated Background Gradient */}
        <div className="absolute inset-0 bg-gradient-to-br from-pink-50 via-purple-25 to-pink-50 opacity-50 group-hover:opacity-70 transition-opacity duration-300"></div>
        
        {/* Content */}
        <div className="relative z-10">
          {/* Header with Instagram Icon */}
          <div className="flex items-center justify-center gap-3 mb-3">
            <div className="p-2 bg-gradient-to-br from-pink-500 to-purple-600 rounded-xl shadow-lg animate-pulse">
              <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0-5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
              </svg>
            </div>
            <h3 className="font-bold text-gray-800 text-lg">Follow us on Instagram</h3>
            <div className="p-2 bg-gradient-to-br from-pink-500 to-purple-600 rounded-xl shadow-lg animate-pulse">
              <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0-5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
              </svg>
            </div>
          </div>
          
          {/* Enhanced Description */}
          <div className="mb-4 p-3 bg-white/60 rounded-xl border border-pink-100">
            <p className="text-sm text-gray-700 font-medium leading-relaxed">
              🎂 <strong>All communication happens via Instagram!</strong><br/>
              <span className="text-gray-600">Order confirmations, updates, and support - quick & personal service</span>
            </p>
          </div>
          
          {/* Enhanced CTA Button */}
          <a 
            href="https://www.instagram.com/littlecakesnl/"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-3 px-6 py-3 bg-gradient-to-r from-pink-500 via-purple-500 to-pink-600 text-white rounded-full font-bold hover:scale-110 hover:shadow-lg transition-all duration-300 group/btn relative overflow-hidden"
          >
            {/* Button Background Animation */}
            <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-pink-500 to-purple-600 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-300"></div>
            
            {/* Button Content */}
            <div className="relative z-10 flex items-center gap-3">
              <div className="p-1 bg-white/20 rounded-full">
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0-5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                </svg>
              </div>
              <span className="font-bold">@littlecakesnl</span>
              <svg className="w-4 h-4 transition-transform group-hover/btn:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
            </div>
          </a>
          
          {/* Additional Visual Elements */}
          <div className="mt-4 flex justify-center gap-2">
            <span className="w-2 h-2 bg-pink-400 rounded-full animate-pulse"></span>
            <span className="w-2 h-2 bg-purple-400 rounded-full animate-pulse" style={{animationDelay: '0.2s'}}></span>
            <span className="w-2 h-2 bg-pink-400 rounded-full animate-pulse" style={{animationDelay: '0.4s'}}></span>
          </div>
        </div>
      </div>
        </div>
      </section>
      <StickyCTA />
    </div>
  );
};

export default Home;