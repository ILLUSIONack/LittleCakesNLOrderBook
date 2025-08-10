'use client';

import { useState, useEffect } from 'react';
import { 
  collection, 
  addDoc, 
  getDocs, 
  doc, 
  updateDoc, 
  deleteDoc,
  query,
  orderBy,
  limit,
  onSnapshot,
  DocumentData,
  Query,
  CollectionReference
} from 'firebase/firestore';
import { useFirebase } from '@/context/FirebaseContext';
import { OrderData, FirestoreQueryOptions } from '@/types';

export function useFirestore() {
  const { db } = useFirebase();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Add a document to a collection
  const addDocument = async (collectionName: string, data: OrderData) => {
    setLoading(true);
    setError(null);
    try {
      const docRef = await addDoc(collection(db, collectionName), {
        ...data,
        createdAt: new Date(),
        updatedAt: new Date()
      });
      return docRef;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  };

  // Get documents from a collection
  const getDocuments = async (collectionName: string) => {
    setLoading(true);
    setError(null);
    try {
      const querySnapshot = await getDocs(collection(db, collectionName));
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  };

  // Update a document
  const updateDocument = async (collectionName: string, docId: string, data: Partial<OrderData>) => {
    setLoading(true);
    setError(null);
    try {
      const docRef = doc(db, collectionName, docId);
      await updateDoc(docRef, {
        ...data,
        updatedAt: new Date()
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  };

  // Delete a document
  const deleteDocument = async (collectionName: string, docId: string) => {
    setLoading(true);
    setError(null);
    try {
      const docRef = doc(db, collectionName, docId);
      await deleteDoc(docRef);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  };

  return {
    addDocument,
    getDocuments,
    updateDocument,
    deleteDocument,
    loading,
    error
  };
}

// Separate hook for real-time collection listening
export function useCollectionListener<T = DocumentData>(collectionName: string, options?: FirestoreQueryOptions) {
  const { db } = useFirebase();
  const [documents, setDocuments] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let q: CollectionReference | Query = collection(db, collectionName);
    
    if (options?.orderByField) {
      q = query(q, orderBy(options.orderByField, options.orderDirection || 'desc'));
    }
    
    if (options?.limitCount) {
      q = query(q, limit(options.limitCount));
    }

    const unsubscribe = onSnapshot(q, (querySnapshot) => {
      const docs = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data()
      })) as T[];
      setDocuments(docs);
      setLoading(false);
    }, (err) => {
      setError(err.message);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [db, collectionName, options?.orderByField, options?.orderDirection, options?.limitCount]);

  return { documents, loading, error };
} 