# Firebase Setup Guide for LittleCakesNL

This guide will help you set up Firebase Firestore and Storage for your Next.js application.

## Prerequisites
- A Firebase project (you can use your existing iOS project)
- Firebase project configuration

## Step 1: Enable Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. In the left sidebar, click "Firestore Database"
4. Click "Create database"
5. Choose "Start in test mode" (we'll set up security rules later)
6. Select a location for your database (choose the closest to your users)
7. Click "Done"

## Step 2: Enable Firebase Storage

1. In the left sidebar, click "Storage"
2. Click "Get started"
3. Choose "Start in test mode" (we'll set up security rules later)
4. Select a location for your storage (same as your Firestore location)
5. Click "Done"

## Step 3: Get Your Firebase Configuration

1. Click the gear icon (⚙️) next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. If you don't have a web app, click the web icon (</>) to register one
5. Copy the configuration object

## Step 4: Set Environment Variables

1. Create a `.env.local` file in your project root (same level as `package.json`)
2. Add your Firebase configuration:

```bash
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key_here
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id_here
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id_here
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id_here
```

Replace the values with your actual Firebase configuration.

## Step 5: Install Firebase Dependencies

The project already has Firebase installed, but if you need to reinstall:

```bash
npm install firebase
```

## Step 6: Test Your Setup

1. Restart your development server: `npm run dev`
2. Navigate to `/order` page
3. Check the debug section shows ✅ for all Firebase config values
4. Try submitting an order with an image
5. Check if the order appears in the real-time list
6. Verify the image is displayed in the order list

## Features Implemented

✅ **Firebase Firestore Integration**
- Real-time data synchronization
- CRUD operations (Create, Read, Update, Delete)
- Automatic timestamps

✅ **Firebase Storage Integration**
- Image upload with validation
- File size limits (5MB max)
- Image type validation (JPG, PNG, GIF)
- Unique filename generation
- Image preview before upload

✅ **Order Management System**
- Customer information form
- Cake type selection
- Quantity and delivery date
- Special instructions
- Reference image upload
- Real-time order display
- Order deletion

## Project Structure

```
src/
├── lib/
│   └── firebase.ts          # Firebase initialization
├── context/
│   └── FirebaseContext.tsx  # Firebase context provider
├── hooks/
│   ├── useFirestore.ts      # Firestore CRUD operations
│   └── useImageUpload.ts    # Image upload functionality
├── components/
│   ├── OrderForm.tsx        # Order submission form
│   └── OrderList.tsx        # Real-time order display
├── types/
│   └── index.ts             # TypeScript interfaces
└── app/
    └── order/
        └── page.tsx         # Order page
```

## Troubleshooting

### Common Issues:

1. **"Port already in use"**
   - The app will automatically try the next available port
   - Check the terminal output for the correct URL

2. **"Firebase config missing"**
   - Ensure `.env.local` file exists in project root
   - Restart dev server after creating/updating `.env.local`
   - Check for typos in environment variable names

3. **"Image upload failed"**
   - Verify Firebase Storage is enabled
   - Check file size (max 5MB)
   - Ensure file is an image type

4. **"Orders not loading"**
   - Check Firestore Database is enabled
   - Verify security rules allow read/write
   - Check browser console for errors

### Security Rules (Advanced)

For production, update your Firestore and Storage security rules:

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /orders/{orderId} {
      allow read, write: if true; // For testing only
      // Add proper authentication rules for production
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /cake-orders/{allPaths=**} {
      allow read, write: if true; // For testing only
      // Add proper authentication rules for production
    }
  }
}
```

## Next Steps

1. **Test the complete flow**: Submit orders with and without images
2. **Customize the form**: Add more cake types, fields, or validation
3. **Implement authentication**: Add user login/signup
4. **Add admin features**: Order management, status updates
5. **Deploy to production**: Set up proper security rules and deploy

## Support

If you encounter issues:
1. Check the browser console for error messages
2. Verify all environment variables are set correctly
3. Ensure Firebase services are enabled in your project
4. Check the debug section on the `/order` page for config status

Your Firebase integration is now complete with both Firestore database and Storage for images! 🎂 