'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface FAQItem {
  question: string;
  answer: string;
  category: string;
}

const faqData: FAQItem[] = [
  {
    category: "Ordering",
    question: "How do I place a custom cake order?",
    answer: "Simply click the 'Place Order' button and fill out our detailed form with your requirements. We'll get back to you within 1-3 working days with a quote and timeline."
  },
  {
    category: "Ordering",
    question: "How much advance notice do you need?",
    answer: "We recommend ordering 2 weeks in advance for custom cakes due to our limited weekly spots."
  },
  {
    category: "Ordering",
    question: "What if I don't receive a response within 1-3 working days?",
    answer: "If you haven't heard back from us within 1-3 working days after submitting your order, please send us another message via Instagram. We want to ensure every inquiry is handled promptly."
  },
  {
    category: "Pickup & Delivery",
    question: "Do you offer delivery?",
    answer: "We currently only offer pickup service. Delivery is not available at this time."
  },
  {
    category: "Pickup & Delivery",
    question: "Where can I pick up my cake?",
    answer: "We offer convenient pickup locations in Rotterdam and Vlaardingen. The exact pickup address will be provided when you confirm your order."
  },
  {
    category: "Pricing & Payment",
    question: "How are prices calculated?",
    answer: "Pricing depends on size, complexity of design, and ingredients used. Basic cakes start from €25, with custom decorations priced individually."
  },
  {
    category: "Pricing & Payment",
    question: "What payment methods do you accept?",
    answer: "After you confirm your order, we'll send you a secure payment link via Instagram for easy and convenient payment."
  },
  {
    category: "Products",
    question: "What sizes are available?",
    answer: "Various cake sizes are available. When filling out the order form, you can select your preferred size from the available options."
  },
  {
    category: "Products",
    question: "Do you offer wedding cakes?",
    answer: "Yes! We specialize in creating beautiful wedding cakes for your special day."
  },
  {
    category: "Policies",
    question: "Can I see my cake before pickup?",
    answer: "You can request to see a photo of your completed cake before pickup. We'll do our best to accommodate this request."
  },
  {
    category: "Policies",
    question: "What's your cancellation policy?",
    answer: "Orders can be cancelled up to 5 days before the scheduled pickup date for a partial refund. Please note that advance payments are non-refundable."
  }
];

const FAQContent = () => {
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>("All");

  const categories = ["All", ...Array.from(new Set(faqData.map(item => item.category)))];
  
  const filteredFAQs = selectedCategory === "All" 
    ? faqData 
    : faqData.filter(item => item.category === selectedCategory);

  const toggleFAQ = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <main className="flex-1 pt-20 pb-16 bg-gradient-to-b from-white to-pink-50">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-4xl">
        {/* Header */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <div className="w-16 h-16 bg-gradient-to-br from-pink-100 to-purple-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <span className="text-3xl">❓</span>
          </div>
          <h1 className="text-4xl lg:text-5xl font-bold text-gray-800 mb-4">
            Frequently Asked Questions
          </h1>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            Find answers to common questions about ordering custom cakes from LittleCakesNL
          </p>
        </motion.div>

        {/* Category Filter */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="flex flex-wrap justify-center gap-3 mb-10"
        >
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-4 py-2 rounded-full font-medium transition-all duration-300 ${
                selectedCategory === category
                  ? 'bg-gradient-to-r from-pink-500 to-purple-600 text-white shadow-lg'
                  : 'bg-white text-gray-600 hover:bg-pink-50 border border-gray-200'
              }`}
            >
              {category}
            </button>
          ))}
        </motion.div>

        {/* FAQ List */}
        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="space-y-4"
        >
          {filteredFAQs.map((faq, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: index * 0.05 }}
              className="bg-white rounded-2xl shadow-lg border border-gray-100 overflow-hidden"
            >
              <button
                onClick={() => toggleFAQ(index)}
                className="w-full px-6 py-5 text-left flex items-center justify-between hover:bg-pink-50 transition-colors duration-200"
              >
                <div className="flex items-center gap-4">
                  <span className="text-pink-500 text-xl">
                    {openIndex === index ? '−' : '+'}
                  </span>
                  <span className="font-semibold text-gray-800">{faq.question}</span>
                </div>
                <span className="text-xs px-3 py-1 bg-pink-100 text-pink-600 rounded-full">
                  {faq.category}
                </span>
              </button>
              
              <AnimatePresence>
                {openIndex === index && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.3 }}
                    className="overflow-hidden"
                  >
                    <div className="px-6 pb-5 pt-2 text-gray-600 border-t border-gray-100">
                      <p className="pl-9">{faq.answer}</p>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </motion.div>

        {/* Contact CTA */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="mt-12 text-center bg-gradient-to-r from-pink-50 to-purple-50 rounded-3xl p-8"
        >
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            Still have questions?
          </h2>
          <p className="text-gray-600 mb-6">
            Feel free to reach out to us on Instagram for any additional questions!
          </p>
          <a
            href="https://www.instagram.com/littlecakesnl/"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-purple-600 text-white px-8 py-3 rounded-full font-bold shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0-5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
            </svg>
            Contact Us on Instagram
          </a>
        </motion.div>
      </div>
    </main>
  );
};

export default FAQContent;

