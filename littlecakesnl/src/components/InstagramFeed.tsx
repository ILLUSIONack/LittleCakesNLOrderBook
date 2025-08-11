'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Heart, MessageCircle, Instagram, ExternalLink } from 'lucide-react';
import Image from 'next/image';

interface CakePost {
  id: string;
  imageUrl: string;
  likes: number;
  comments: number;
}

interface CakeFeedProps {
  maxPosts?: number;
}

const CakeFeed: React.FC<CakeFeedProps> = ({ maxPosts = 6 }) => {
  const [posts, setPosts] = useState<CakePost[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate loading Instagram posts
    const mockPosts: CakePost[] = [
      {
        id: '1',
        imageUrl: '/images/orders/pic1.png',
        likes: 127,
        comments: 23
      },
      {
        id: '2',
        imageUrl: '/images/orders/pic2.png',
        likes: 89,
        comments: 15
      },
      {
        id: '3',
        imageUrl: '/images/orders/pic3.png',
        likes: 156,
        comments: 31
      },
      {
        id: '4',
        imageUrl: '/images/orders/pic4.png',
        likes: 203,
        comments: 42
      },
      {
        id: '5',
        imageUrl: '/images/orders/pic5.png',
        likes: 78,
        comments: 12
      },
      {
        id: '6',
        imageUrl: '/images/orders/pic6.png',
        likes: 134,
        comments: 28
      }
    ];

    // Simulate API delay
    setTimeout(() => {
      setPosts(mockPosts.slice(0, maxPosts));
      setIsLoading(false);
    }, 1000);
  }, [maxPosts]);

  if (isLoading) {
    return (
      <section className="py-16 bg-gradient-to-br from-pink-50 via-white to-purple-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
                Follow Our Journey
              </h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                See our latest creations and get inspired for your next celebration
              </p>
            </motion.div>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
            {Array.from({ length: maxPosts }).map((_, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: i * 0.1 }}
                className="bg-white rounded-2xl shadow-lg overflow-hidden"
              >
                <div className="animate-pulse">
                  <div className="h-64 bg-gray-200"></div>
                  <div className="p-4">
                    <div className="h-4 bg-gray-200 rounded mb-2"></div>
                    <div className="h-3 bg-gray-200 rounded w-3/4"></div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="py-16 bg-gradient-to-br from-pink-50 via-white to-purple-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Follow Our Journey
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              See our latest creations and get inspired for your next celebration
            </p>
          </motion.div>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
          {posts.map((post, index) => (
            <motion.article
              key={post.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              whileHover={{ y: -8, scale: 1.02 }}
              className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-2xl transition-all duration-300 group"
            >
              {/* Image Container */}
              <div className="relative overflow-hidden">
                <Image 
                  src={post.imageUrl} 
                  alt={`Custom cake creation ${post.id} by LittleCakesNL - Handcrafted with love in Rotterdam and Vlaardingen, Netherlands`}
                  width={400}
                  height={256}
                  className="w-full h-64 object-cover group-hover:scale-110 transition-transform duration-300"
                />
                
                {/* Instagram Badge */}
                <div className="absolute top-3 right-3 bg-gradient-to-r from-pink-500 to-purple-600 text-white p-2 rounded-full shadow-lg">
                  <Instagram className="w-4 h-4" />
                </div>
                
                {/* Overlay on hover */}
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-all duration-300 flex items-center justify-center">
                  <motion.div
                    initial={{ opacity: 0, scale: 0.8 }}
                    whileHover={{ opacity: 1, scale: 1 }}
                    className="bg-white/90 backdrop-blur-sm rounded-full p-3 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                  >
                    <ExternalLink className="w-5 h-5 text-gray-700" />
                  </motion.div>
                </div>
              </div>

              {/* Content */}
              <div className="p-4">
                {/* Engagement Stats */}
                <div className="flex items-center justify-center gap-6 text-sm text-gray-500">
                  <div className="flex items-center gap-1">
                    <Heart className="w-4 h-4 text-red-500" />
                    <span>{post.likes}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <MessageCircle className="w-4 h-4 text-blue-500" />
                    <span>{post.comments}</span>
                  </div>
                </div>
              </div>
            </motion.article>
          ))}
        </div>

        {/* Follow CTA - REMOVED to avoid duplication */}
      </div>
    </section>
  );
};

export default CakeFeed; 