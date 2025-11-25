'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const StickyCTA = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [isDismissed, setIsDismissed] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const scrollY = window.scrollY;
      if (!isDismissed) {
        setIsVisible(scrollY > 300);
      }
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [isDismissed]);

  if (!isVisible || isDismissed) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ y: 100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        exit={{ y: 100, opacity: 0 }}
        transition={{ duration: 0.3, ease: "easeOut" }}
        className="fixed bottom-4 left-4 right-4 z-50"
      >
        {/* Main CTA Container */}
        <div className="bg-white rounded-2xl shadow-2xl border border-pink-100 overflow-hidden max-w-4xl mx-auto">
          {/* Gradient Background */}
          <div className="relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-r from-pink-500 via-purple-600 to-pink-600 opacity-90"></div>
            
            {/* Animated Background Elements */}
            <div className="absolute inset-0">
              <div className="absolute top-0 left-0 w-32 h-32 bg-white/10 rounded-full -translate-x-16 -translate-y-16 animate-pulse"></div>
              <div className="absolute bottom-0 right-0 w-24 h-24 bg-white/10 rounded-full translate-x-12 translate-y-12 animate-pulse" style={{animationDelay: '1s'}}></div>
            </div>

            {/* Content */}
            <div className="relative z-10 p-4 sm:p-6">
              <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
                
                {/* Left Side - Text */}
                <div className="flex-1 text-center sm:text-left">
                  <div className="flex items-center justify-center sm:justify-start gap-3 mb-2">
                    <div className="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center">
                      <span className="text-lg">🎂</span>
                    </div>
                    <h3 className="text-lg sm:text-xl font-bold text-white">
                      Ready for Your Dream Cake?
                    </h3>
                  </div>
                  <p className="text-white/90 text-sm sm:text-base">
                    Get a custom quote in minutes - no commitment required
                  </p>
                </div>

                {/* Right Side - CTA Button */}
                <div className="flex-shrink-0">
                  <a 
                    href="https://littlecakesnl.fillout.com/t/vzLF1V9hvNus"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-block"
                  >
                    <motion.button 
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      className="bg-white text-pink-600 px-6 py-3 rounded-xl font-bold text-lg shadow-lg hover:shadow-xl transition-all duration-300 group relative overflow-hidden"
                    >
                      {/* Button Background Animation */}
                      <div className="absolute inset-0 bg-gradient-to-r from-pink-100 to-purple-100 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      
                      {/* Button Content */}
                      <div className="relative z-10 flex items-center gap-2">
                        <span>Place Order Now</span>
                        <svg className="w-5 h-5 transition-transform group-hover:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                        </svg>
                      </div>
                    </motion.button>
                  </a>
                </div>
              </div>

              {/* Trust Indicators */}
              <div className="mt-4 pt-4 border-t border-white/20">
                <div className="flex flex-wrap justify-center sm:justify-start gap-4 text-xs text-white/80">
                  <div className="flex items-center gap-1">
                    <span className="text-green-300">✓</span>
                    <span>1-3 days response</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <span className="text-green-300">✓</span>
                    <span>Custom pricing</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <span className="text-green-300">✓</span>
                    <span>Local pickup</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Close Button */}
        <motion.button
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
          onClick={() => setIsDismissed(true)}
          className="absolute top-2 right-2 w-8 h-8 bg-white/20 rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-colors duration-200"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </motion.button>
      </motion.div>
    </AnimatePresence>
  );
};

export default StickyCTA;

