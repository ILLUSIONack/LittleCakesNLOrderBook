export interface OrderData {
  customerName: string;
  cakeType: string;
  quantity: number;
  deliveryDate: string;
  specialInstructions: string;
  imageUrl?: string; // Optional image URL
  imageFileName?: string; // Optional original filename
}

export interface OrderDocument extends OrderData {
  id: string;
  createdAt: {
    toDate: () => Date;
  } | null; // Firestore Timestamp
  updatedAt: {
    toDate: () => Date;
  } | null; // Firestore Timestamp
}

export interface FirestoreQueryOptions {
  orderByField?: string;
  orderDirection?: 'asc' | 'desc';
  limitCount?: number;
}

export interface ImageUploadResult {
  url: string;
  fileName: string;
} 