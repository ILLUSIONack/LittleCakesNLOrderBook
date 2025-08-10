'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

interface FAQItem {
  id: number;
  question: string;
  answer: string;
}

const faqData: FAQItem[] = [
  {
    id: 1,
    question: "How do I place a custom cake order?",
    answer: "Simply click the 'Place Order' button and fill out our detailed form with your requirements. We'll get back to you within 1-3 working days with a quote and timeline."
  },
  {
    id: 2,
    question: "Do you offer delivery?",
    answer: "We currently only offer pickup service. Delivery is not available at this time."
  },
  {
    id: 3,
    question: "Where can I pick up my cake?",
    answer: "We offer convenient pickup locations in Rotterdam and Vlaardingen. The exact pickup address will be provided when you confirm your order."
  },
  {
    id: 4,
    question: "How much advance notice do you need?",
    answer: "We recommend ordering 2 weeks in advance for custom cakes due to our limited weekly spots."
  },
  {
    id: 5,
    question: "What sizes are available?",
    answer: "Various cake sizes are available. When filling out the order form, you can select your preferred size from the available options."
  },
  {
    id: 6,
    question: "How are prices calculated?",
    answer: "Pricing depends on size, complexity of design, and ingredients used. Basic cakes start from €25, with custom decorations priced individually."
  },
  {
    id: 7,
    question: "Do you offer wedding cakes?",
    answer: "Yes! We specialize in creating beautiful wedding cakes for your special day."
  },
  {
    id: 8,
    question: "What payment methods do you accept?",
    answer: "After you confirm your order, we'll send you a secure payment link via Instagram for easy and convenient payment."
  },
  {
    id: 9,
    question: "Can I see my cake before pickup?",
    answer: "You can request to see a photo of your completed cake before pickup. We'll do our best to accommodate this request."
  },
  {
    id: 10,
    question: "What's your cancellation policy?",
    answer: "Orders can be cancelled up to 5 days before the scheduled pickup date for a partial refund. Please note that advance payments are non-refundable."
  },
  {
    id: 11,
    question: "What if I don't receive a response within 1-3 working days?",
    answer: "If you haven't heard back from us within 1-3 working days after submitting your order, please send us another message via Instagram. We want to ensure every inquiry is handled promptly"
  }
];

export default function FAQContent() {
  const [openItems, setOpenItems] = useState<number[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const toggleItem = (id: number) => {
    setOpenItems(prev => 
      prev.includes(id) 
        ? prev.filter(item => item !== id)
        : [...prev, id]
    );
  };

  const filteredFAQs = faqData.filter(faq =>
    faq.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
    faq.answer.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <>
      {/* Hero Section */}
      <section className="pt-20 pb-16 hero-bg">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className={`text-center max-w-4xl mx-auto transform transition-all duration-1000 ${
            isVisible ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
          }`}>
            
            {/* Breadcrumb */}
            <div className={`mb-8 transform transition-all duration-1000 delay-200 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              <nav className="text-sm">
                <Link href="/" className="text-gray-500 hover:text-pink-500 transition-colors">
                  Home
                </Link>
                <span className="mx-2 text-gray-400">/</span>
                <span className="text-gray-800 font-semibold">FAQ</span>
              </nav>
            </div>

            {/* Title */}
            <h1 className={`text-4xl lg:text-6xl font-bold mb-6 transform transition-all duration-1000 delay-300 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              Frequently Asked <span className="gradient-text">Questions</span>
            </h1>
            
            <p className={`text-xl text-gray-600 mb-8 leading-relaxed transform transition-all duration-1000 delay-400 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              Everything you need to know about ordering your perfect custom cake
            </p>

            {/* Search Bar */}
            <div className={`max-w-md mx-auto transform transition-all duration-1000 delay-500 ${
              isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
            }`}>
              <div className="relative">
                <input
                  type="text"
                  placeholder="Search questions..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl bg-white focus:border-pink-500 focus:ring-2 focus:ring-pink-200 outline-none transition-all duration-300"
                />
                <svg className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>
            </div>

            {/* FAQ Accordion Section - Moved inside hero */}
            <div className="mt-12 max-w-4xl mx-auto">
              
              {/* Results Count */}
              {searchTerm && (
                <div className={`mb-8 text-center transform transition-all duration-1000 delay-600 ${
                  isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
                }`}>
                  <p className="text-gray-600">
                    Found {filteredFAQs.length} result{filteredFAQs.length !== 1 ? 's' : ''} for &quot;{searchTerm}&quot;
                  </p>
                </div>
              )}

              {/* FAQ Items */}
              <div className={`space-y-4 transform transition-all duration-1000 delay-700 ${
                isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
              }`}>
                {filteredFAQs.map((faq, index) => (
                <div 
                  key={faq.id}
                  className={`modern-card overflow-hidden transform transition-all duration-500 ${
                    isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
                  }`}
                  style={{ transitionDelay: `${600 + index * 100}ms` }}
                >
                  <button
                    onClick={() => toggleItem(faq.id)}
                    className="w-full p-6 text-left flex items-center justify-between hover:bg-gray-50 transition-colors duration-200"
                  >
                    <h3 className="text-lg font-semibold text-gray-800 pr-4">
                      {faq.question}
                    </h3>
                    <div className={`transform transition-transform duration-300 ${
                      openItems.includes(faq.id) ? 'rotate-180' : 'rotate-0'
                    }`}>
                      <svg className="w-5 h-5 text-pink-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </div>
                  </button>
                  
                  <div className={`overflow-hidden transition-all duration-300 ${
                    openItems.includes(faq.id) ? 'max-h-48 opacity-100' : 'max-h-0 opacity-0'
                  }`}>
                    <div className="px-6 pb-6">
                      <div className="border-t border-gray-100 pt-4">
                        <p className="text-gray-600 leading-relaxed">
                          {faq.answer}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                ))}

                {/* No Results */}
                {searchTerm && filteredFAQs.length === 0 && (
                  <div className="text-center py-12">
                    <div className="text-6xl mb-4">🔍</div>
                    <h3 className="text-xl font-semibold text-gray-800 mb-2">No results found</h3>
                    <p className="text-gray-600 mb-6">
                      Try searching with different keywords or browse all questions above.
                    </p>
                    <button
                      onClick={() => setSearchTerm('')}
                      className="text-pink-500 hover:text-pink-600 font-semibold"
                    >
                      Clear search
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-r from-pink-50 to-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-3xl mx-auto text-center">
            <div className="glass-card p-8 lg:p-12">
              <h2 className="text-3xl lg:text-4xl font-bold mb-4">
                Still have questions?
              </h2>
              <p className="text-xl text-gray-600 mb-8">
                We&apos;re here to help! Get in touch or place your order directly.
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a 
                  href="https://littlecakesnl.fillout.com/t/mEu3kPtDbius"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-block"
                >
                  <button className="btn-modern px-10 py-4 text-lg font-bold hover-glow group relative overflow-hidden">
                    <span className="relative z-10 flex items-center gap-2">
                      🎂 Get FREE Quote (1-3 Days Response)
                      <svg className="w-5 h-5 transition-transform group-hover:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                      </svg>
                    </span>
                  </button>
                </a>
                
                <Link href="/">
                  <button className="px-8 py-3 border-2 border-pink-500 text-pink-500 rounded-full font-semibold hover:bg-pink-50 transition-all duration-300">
                    Back to Home
                  </button>
                </Link>
              </div>
              
              {/* Trust Signal */}
              <div className="mt-6 text-center">
                <div className="inline-flex items-center gap-2 px-4 py-2 bg-green-100 text-green-700 rounded-full text-sm font-semibold">
                  <span className="text-green-500">✓</span>
                  No obligation • Custom pricing • 500+ happy customers
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
} 