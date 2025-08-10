'use client';

import React from 'react';
import { useFirestore, useCollectionListener } from '@/hooks/useFirestore';
import { OrderDocument } from '@/types';

export default function OrderList() {
  const { deleteDocument } = useFirestore();
  const { documents: orders, loading, error } = useCollectionListener<OrderDocument>('orders', {
    orderByField: 'createdAt',
    orderDirection: 'desc'
  });

  const handleDelete = async (orderId: string) => {
    if (window.confirm('Are you sure you want to delete this order?')) {
      try {
        await deleteDocument('orders', orderId);
      } catch (error) {
        console.error('Error deleting order:', error);
      }
    }
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto p-6">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">Recent Orders</h2>
        <div className="text-center py-8">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading orders...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-4xl mx-auto p-6">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">Recent Orders</h2>
        <div className="text-center py-8">
          <p className="text-red-600">Error loading orders: {error}</p>
        </div>
      </div>
    );
  }

  if (orders.length === 0) {
    return (
      <div className="max-w-4xl mx-auto p-6">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">Recent Orders</h2>
        <div className="text-center py-8">
          <p className="text-gray-600">No orders yet. Be the first to place an order!</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Recent Orders</h2>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {orders.map((order: OrderDocument) => (
          <div key={order.id} className="bg-white rounded-lg shadow-md p-4 border border-gray-200">
            <div className="flex justify-between items-start mb-3">
              <h3 className="font-semibold text-lg text-gray-800">{order.customerName}</h3>
              <button
                onClick={() => handleDelete(order.id)}
                className="text-red-500 hover:text-red-700 text-sm font-medium"
              >
                Delete
              </button>
            </div>
            
            {/* Image Display */}
            {order.imageUrl && (
              <div className="mb-3">
                <img 
                  src={order.imageUrl} 
                  alt={`Cake reference for ${order.customerName}`}
                  className="w-full h-32 object-cover rounded-md border border-gray-200"
                />
                <p className="text-xs text-gray-500 mt-1 truncate">{order.imageFileName}</p>
              </div>
            )}
            
            <div className="space-y-2 text-sm text-gray-600">
              <p><span className="font-medium">Cake Type:</span> {order.cakeType}</p>
              <p><span className="font-medium">Quantity:</span> {order.quantity}</p>
              <p><span className="font-medium">Delivery Date:</span> {order.deliveryDate}</p>
              {order.specialInstructions && (
                <p><span className="font-medium">Special Instructions:</span> {order.specialInstructions}</p>
              )}
              {order.createdAt && (
                <p><span className="font-medium">Ordered:</span> {order.createdAt.toDate().toLocaleDateString()}</p>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
} 