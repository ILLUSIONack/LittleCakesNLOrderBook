'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';

const Navbar = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
      isScrolled ? 'backdrop-blur-md bg-white/90 shadow-lg' : 'backdrop-blur-sm bg-white/10'
    }`}>
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          
          {/* Logo */}
          <Link href="/" className="flex items-center group">
            <span className={`text-2xl font-bold hover:scale-105 transition-all duration-300 ${
              isScrolled ? 'gradient-text' : 'text-pink-500 drop-shadow-lg'
            }`}>
              🎂 LittleCakesNL
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            <Link 
              href="/"
              className={`nav-link font-medium transition-all duration-300 relative group ${
                isScrolled ? 'text-gray-700 hover:text-pink-500' : 'text-white hover:text-pink-200'
              }`}
            >
              Home
              <span className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-pink-500 to-pink-600 transition-all duration-300 group-hover:w-full"></span>
            </Link>
            
            <Link 
              href="/faq"
              className={`nav-link font-medium transition-all duration-300 relative group ${
                isScrolled ? 'text-gray-700 hover:text-pink-500' : 'text-white hover:text-pink-200'
              }`}
            >
              FAQ
              <span className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-pink-500 to-pink-600 transition-all duration-300 group-hover:w-full"></span>
            </Link>

            {/* CTA Button */}
            <a 
              href="https://littlecakesnl.fillout.com/t/mEu3kPtDbius"
              target="_blank"
              rel="noopener noreferrer"
              className="btn-modern px-6 py-2.5 text-sm font-bold hover-scale group relative overflow-hidden"
              style={{ background: 'var(--gradient-primary)' }}
            >
              <span className="relative z-10 flex items-center gap-2">
                Place Order
                <svg className="w-4 h-4 transition-transform group-hover:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </span>
            </a>
          </div>

          {/* Mobile menu button */}
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className={`md:hidden p-2 rounded-md transition-colors duration-200 ${
              isScrolled 
                ? 'text-gray-700 hover:text-pink-500 hover:bg-gray-100' 
                : 'text-pink-500 hover:text-pink-300 hover:bg-white/10'
            }`}
          >
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              {isMobileMenuOpen ? (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              )}
            </svg>
          </button>
        </div>

        {/* Mobile Navigation */}
        <div className={`md:hidden transition-all duration-300 overflow-hidden ${
          isMobileMenuOpen ? 'max-h-64 opacity-100' : 'max-h-0 opacity-0'
        }`}>
          <div className="py-4 space-y-4 bg-white/95 backdrop-blur-md rounded-lg mt-2 shadow-lg border border-white/20">
            <Link 
              href="/"
              onClick={() => setIsMobileMenuOpen(false)}
              className="block px-4 py-2 text-gray-700 hover:text-pink-500 font-medium transition-colors duration-200"
            >
              Home
            </Link>
            <Link 
              href="/faq"
              onClick={() => setIsMobileMenuOpen(false)}
              className="block px-4 py-2 text-gray-700 hover:text-pink-500 font-medium transition-colors duration-200"
            >
              FAQ
            </Link>
            <div className="px-4">
              <a 
                href="https://littlecakesnl.fillout.com/t/mEu3kPtDbius"
                target="_blank"
                rel="noopener noreferrer"
                className="block w-full text-center btn-modern px-6 py-3 text-sm font-bold"
                style={{ background: 'var(--gradient-primary)' }}
              >
                Place Order 🎂
              </a>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;