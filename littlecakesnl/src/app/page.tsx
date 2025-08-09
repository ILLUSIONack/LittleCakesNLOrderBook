'use client';

import { useState, useEffect } from 'react';
import Navbar from '@/components/Navbar';

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

  return (
    <div className="min-h-screen mobile-viewport flex flex-col overflow-hidden">
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
                  Share a screenshot of your request via Instagram <span className="font-semibold text-pink-600">@littlecakesnl</span>. We&apos;ll respond within 48 hours with details.
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

            {/* CTA Section */}
            <div className={`space-y-6 transform transition-all duration-1000 delay-450 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              
              {/* Primary CTA with Urgency & Social Proof */}
              <div className="space-y-4">
                {/* Urgency Badge - Desktop Only (above button) */}
                <div className="hidden lg:inline-flex items-center gap-2 px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm font-semibold mb-3">
                  <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
                  Limited spots per week
                </div>
                
                <a 
                  href="https://littlecakesnl.fillout.com/t/mEu3kPtDbius"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-block"
                >
                  <button className="btn-modern px-12 py-5 text-xl font-bold hover-glow group relative overflow-hidden animate-pulse">
                    <span className="relative z-10 flex items-center gap-3">
                      🎂 Place Your Order
                      <svg className="w-6 h-6 transition-transform group-hover:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                      </svg>
                    </span>
                  </button>
                </a>
                
                {/* Urgency Badge - Mobile Only (below button) */}
                <div className="lg:hidden flex justify-center">
                  <div className="inline-flex items-center gap-2 px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm font-semibold">
                    <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
                    Limited spots per week
                  </div>
                </div>
                
                {/* Value Props Under CTA */}
                <div className="flex flex-wrap justify-center gap-4 text-sm text-gray-600">
                  <div className="flex items-center gap-1">
                    <span className="text-green-500">✓</span>
                    <span>No commitment</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <span className="text-green-500">✓</span>
                    <span>Custom pricing</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <span className="text-green-500">✓</span>
                    <span>48h response</span>
                  </div>
                </div>
                
                <p className="text-xs text-gray-400">
                  By requesting a quote you agree to our terms and conditions
                </p>
              </div>

              {/* Instagram Note - Enhanced Design */}
              <div className="glass-effect p-6 rounded-2xl mb-6 text-center relative overflow-hidden group hover-glow">
                {/* Animated Background Gradient */}
                <div className="absolute inset-0 bg-gradient-to-br from-pink-50 via-purple-25 to-pink-50 opacity-50 group-hover:opacity-70 transition-opacity duration-300"></div>
                
                {/* Content */}
                <div className="relative z-10">
                  {/* Header with Instagram Icon */}
                  <div className="flex items-center justify-center gap-3 mb-3">
                    <div className="p-2 bg-gradient-to-br from-pink-500 to-purple-600 rounded-xl shadow-lg animate-pulse">
                      <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                      </svg>
                    </div>
                    <h3 className="font-bold text-gray-800 text-lg">Follow us on Instagram</h3>
                    <div className="p-2 bg-gradient-to-br from-pink-500 to-purple-600 rounded-xl shadow-lg animate-pulse">
                      <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
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
                          <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
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

              {/* Trust Indicators */}
              <div className="pt-6 border-t border-gray-200">
                <div className="flex flex-wrap justify-center lg:justify-start gap-4 sm:gap-6">
                  <div className="flex items-center gap-2">
                    <span className="text-green-500">✓</span>
                    <span className="text-xs sm:text-sm text-gray-600">Quality Guaranteed</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-blue-500">🛡️</span>
                    <span className="text-xs sm:text-sm text-gray-600">Secure Ordering</span>
                  </div>
                </div>
              </div>
            </div>


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
    </div>
  );
};

export default Home;