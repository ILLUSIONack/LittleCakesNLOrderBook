'use client';

import React from 'react';
import Navbar from '@/components/Navbar';
import OrderForm from '@/components/OrderForm';
import OrderList from '@/components/OrderList';

export default function OrderPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      
      <div className="pt-20 pb-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Page Header */}
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold text-gray-900 mb-4">
              Cake Orders
            </h1>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Place your custom cake order and view all orders in real-time
            </p>
          </div>

          {/* Order Form and List */}
          <div className="grid lg:grid-cols-2 gap-12">
            {/* Order Form */}
            <div>
              <OrderForm />
            </div>
            
            {/* Order List */}
            <div>
              <OrderList />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
} 