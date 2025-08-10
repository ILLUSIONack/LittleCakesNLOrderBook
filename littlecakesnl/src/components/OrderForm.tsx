'use client';

import React, { useState, useRef } from 'react';
import { useFirestore } from '@/hooks/useFirestore';
import { useImageUpload } from '@/hooks/useImageUpload';
import { OrderData } from '@/types';

export default function OrderForm() {
  const { addDocument, loading, error } = useFirestore();
  const { uploadImage, uploading, uploadError, clearError } = useImageUpload();
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [formData, setFormData] = useState<OrderData>({
    customerName: '',
    cakeType: '',
    quantity: 1,
    deliveryDate: '',
    specialInstructions: '',
    imageUrl: '',
    imageFileName: ''
  });

  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  // Temporary debug info - remove this later
  const debugInfo = {
    apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY ? '✅ Loaded' : '❌ Missing',
    projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID ? '✅ Loaded' : '❌ Missing',
    authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN ? '✅ Loaded' : '❌ Missing'
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      
      // Create preview
      const reader = new FileReader();
      reader.onload = (e) => {
        setImagePreview(e.target?.result as string);
      };
      reader.readAsDataURL(file);
      
      clearError();
    }
  };

  const removeImage = () => {
    setSelectedFile(null);
    setImagePreview(null);
    setFormData(prev => ({ ...prev, imageUrl: '', imageFileName: '' }));
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      let finalFormData = { ...formData };
      
      // Upload image if selected
      if (selectedFile) {
        const uploadResult = await uploadImage(selectedFile);
        if (uploadResult) {
          finalFormData.imageUrl = uploadResult.url;
          finalFormData.imageFileName = uploadResult.fileName;
        } else {
          return; // Upload failed, error already set
        }
      }
      
      await addDocument('orders', finalFormData);
      alert('Order submitted successfully!');
      
      // Reset form
      setFormData({
        customerName: '',
        cakeType: '',
        quantity: 1,
        deliveryDate: '',
        specialInstructions: '',
        imageUrl: '',
        imageFileName: ''
      });
      setSelectedFile(null);
      setImagePreview(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (err) {
      console.error('Error submitting order:', err);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'quantity' ? parseInt(value) || 1 : value
    }));
  };

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-6 text-center text-gray-800">Place Your Cake Order</h2>
      
      {error && (
        <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
          {error}
        </div>
      )}

      {uploadError && (
        <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
          {uploadError}
        </div>
      )}
      
      {/* Debug Info - Remove this later */}
      <div className="mb-4 p-3 bg-gray-100 rounded text-sm">
        <p className="font-medium text-gray-700 mb-2">Firebase Config Status:</p>
        <div className="space-y-1">
          <p>API Key: {debugInfo.apiKey}</p>
          <p>Project ID: {debugInfo.projectId}</p>
          <p>Auth Domain: {debugInfo.authDomain}</p>
        </div>
      </div>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="customerName" className="block text-sm font-medium text-gray-700 mb-1">
            Customer Name *
          </label>
          <input
            type="text"
            id="customerName"
            name="customerName"
            value={formData.customerName}
            onChange={handleChange}
            required
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div>
          <label htmlFor="cakeType" className="block text-sm font-medium text-gray-700 mb-1">
            Cake Type *
          </label>
          <select
            id="cakeType"
            name="cakeType"
            value={formData.cakeType}
            onChange={handleChange}
            required
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Select a cake type</option>
            <option value="chocolate">Chocolate Cake</option>
            <option value="vanilla">Vanilla Cake</option>
            <option value="red-velvet">Red Velvet Cake</option>
            <option value="carrot">Carrot Cake</option>
            <option value="cheesecake">Cheesecake</option>
          </select>
        </div>

        <div>
          <label htmlFor="quantity" className="block text-sm font-medium text-gray-700 mb-1">
            Quantity *
          </label>
          <input
            type="number"
            id="quantity"
            name="quantity"
            min="1"
            max="10"
            value={formData.quantity}
            onChange={handleChange}
            required
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div>
          <label htmlFor="deliveryDate" className="block text-sm font-medium text-gray-700 mb-1">
            Delivery Date *
          </label>
          <input
            type="date"
            id="deliveryDate"
            name="deliveryDate"
            value={formData.deliveryDate}
            onChange={handleChange}
            required
            min={new Date().toISOString().split('T')[0]}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div>
          <label htmlFor="imageUpload" className="block text-sm font-medium text-gray-700 mb-1">
            Cake Reference Image (Optional)
          </label>
          <input
            ref={fileInputRef}
            type="file"
            id="imageUpload"
            accept="image/*"
            onChange={handleFileSelect}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <p className="text-xs text-gray-500 mt-1">Max size: 5MB. Supported formats: JPG, PNG, GIF</p>
        </div>

        {imagePreview && (
          <div className="relative">
            <img 
              src={imagePreview} 
              alt="Preview" 
              className="w-full h-32 object-cover rounded-md border border-gray-300"
            />
            <button
              type="button"
              onClick={removeImage}
              className="absolute top-2 right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm hover:bg-red-600"
            >
              ×
            </button>
          </div>
        )}

        <div>
          <label htmlFor="specialInstructions" className="block text-sm font-medium text-gray-700 mb-1">
            Special Instructions
          </label>
          <textarea
            id="specialInstructions"
            name="specialInstructions"
            value={formData.specialInstructions}
            onChange={handleChange}
            rows={3}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Any special requests or dietary requirements..."
          />
        </div>

        <button
          type="submit"
          disabled={loading || uploading}
          className={`w-full py-2 px-4 rounded-md font-medium transition-colors duration-200 ${
            loading || uploading
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-blue-600 hover:bg-blue-700 text-white'
          }`}
        >
          {loading || uploading ? 'Submitting...' : 'Submit Order'}
        </button>
      </form>
    </div>
  );
} 