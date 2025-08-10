import type { Metadata } from 'next';
import Navbar from '@/components/Navbar';
import FAQContent from '@/components/FAQContent';

export const metadata: Metadata = {
  title: 'FAQ - LittleCakesNL Custom Cakes Rotterdam & Vlaardingen',
  description: 'Frequently asked questions about ordering custom cakes from LittleCakesNL. Learn about pickup locations, pricing, and more in Rotterdam and Vlaardingen.',
  keywords: 'custom cake FAQ, cake ordering questions, Rotterdam cake pickup, Vlaardingen cake pickup, wedding cake questions, cake pricing',
  openGraph: {
    title: 'FAQ - LittleCakesNL Custom Cakes Rotterdam & Vlaardingen',
    description: 'Frequently asked questions about ordering custom cakes from LittleCakesNL. Learn about pickup locations, pricing, and more in Rotterdam and Vlaardingen.',
    url: 'https://littlecakesnl.nl/faq',
    type: 'website',
  },
  alternates: {
    canonical: 'https://littlecakesnl.nl/faq',
  },
};

export default function FAQPage() {
  return (
    <>
      {/* FAQ Structured Data for SEO */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "FAQPage",
            "mainEntity": [
              {
                "@type": "Question",
                "name": "How do I place a custom cake order?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "Simply click the 'Place Order' button and fill out our detailed form with your requirements. We'll get back to you within 1-3 working days with a quote and timeline."
                }
              },
              {
                "@type": "Question",
                "name": "Do you offer delivery?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "We currently only offer pickup service. Delivery is not available at this time."
                }
              },
              {
                "@type": "Question",
                "name": "Where can I pick up my cake?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "We offer convenient pickup locations in Rotterdam and Vlaardingen. The exact pickup address will be provided when you confirm your order."
                }
              },
              {
                "@type": "Question",
                "name": "How much advance notice do you need?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "We recommend ordering 2 weeks in advance for custom cakes due to our limited weekly spots."
                }
              },
              {
                "@type": "Question",
                "name": "What sizes are available?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "Various cake sizes are available. When filling out the order form, you can select your preferred size from the available options."
                }
              },
              {
                "@type": "Question",
                "name": "How are prices calculated?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "Pricing depends on size, complexity of design, and ingredients used. Basic cakes start from €25, with custom decorations priced individually."
                }
              },
              {
                "@type": "Question",
                "name": "Do you offer wedding cakes?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "Yes! We specialize in creating beautiful wedding cakes for your special day."
                }
              },
              {
                "@type": "Question",
                "name": "What payment methods do you accept?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "After you confirm your order, we'll send you a secure payment link via Instagram for easy and convenient payment."
                }
              },
              {
                "@type": "Question",
                "name": "Can I see my cake before pickup?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "You can request to see a photo of your completed cake before pickup. We'll do our best to accommodate this request."
                }
              },
              {
                "@type": "Question",
                "name": "What's your cancellation policy?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "Orders can be cancelled up to 5 days before the scheduled pickup date for a partial refund. Please note that advance payments are non-refundable."
                }
              },
              {
                "@type": "Question",
                "name": "What if I don't receive a response within 1-3 working days?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": "If you haven't heard back from us within 1-3 working days after submitting your order, please send us another message via Instagram. We want to ensure every inquiry is handled promptly"
                }
              }
            ]
          })
        }}
      />
      
      {/* Local Business Schema for FAQ Page */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "Bakery",
            "name": "LittleCakesNL",
            "description": "Custom dream cakes made with love in Rotterdam and Vlaardingen, Netherlands. FAQ page with common questions about our services.",
            "url": "https://littlecakesnl.nl/faq",
            "telephone": "+31-6-12345678",
            "email": "info@littlecakesnl.nl",
            "address": {
              "@type": "PostalAddress",
              "addressLocality": "Rotterdam",
              "addressRegion": "South Holland",
              "addressCountry": "NL"
            },
            "areaServed": ["Rotterdam", "Vlaardingen"],
            "sameAs": ["https://www.instagram.com/littlecakesnl/"]
          })
        }}
      />
      
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <FAQContent />
      </div>
    </>
  );
}