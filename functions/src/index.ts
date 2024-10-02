/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// import {onRequest} from "firebase-functions/v2/https";
// import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

admin.initializeApp();
const db = admin.firestore();

// Define the interface for the fillout data
// Define the interface for the fillout data
interface Fillout {
    id: string;
    submissionId: string;
    submissionTime: string;
    lastUpdatedAt: string;
    questions: SubmissionQuestion[];
  }

interface SubmissionQuestion {
    id: string;
    name: string;
    type: string;
    value: ValueType;
}

interface ValueType {
    stringValue?: string;
    arrayValue?: string[];
}

interface ApiResponse {
    responses: Fillout[];
}

// Cloud Function to poll for new submissions every 5 minutes
export const pollNewSubmissions = functions.pubsub.schedule("every 1 minutes")
  .onRun(async () => {
    try {
      const apiKey1 = "sk_prod_AK3PAinuOn7QNxELDnxAw11M5RVDFlQa4";
      const apiKey2 = "ZIbZG01wPNvOLSAwuCAO3kBkuNKK7kZAFe2";
      const apiKey3 = "J6zaO0NZBWEJm00owW4AbYInY8RQ14j_9811";

      const apiKey = apiKey1 + apiKey2 + apiKey3;
      const response = await axios.get<ApiResponse>("https://api.fillout.com/v1/api/forms/iEcWEeeX6rus/submissions", {
        headers: {
          Authorization: `Bearer ${apiKey}`,
        },
      });
      console.log("API Response:", response.data);

      // Access the responses array
      const fillouts = Array.isArray(response.data.responses) ?
        response.data.responses : [];

      if (!Array.isArray(fillouts) || fillouts.length === 0) {
        console.warn("No fillouts found.");
        return; // Exit if fillouts is not an array or is empty
      }

      // Fetch all submissions from Firestore
      const firebaseSubmissionsSnapshot = await
      db.collection("submissionsDev").get();
      const firebaseSubmissions = firebaseSubmissionsSnapshot.docs
        .map((doc) => doc.data());

      // Create a Set for efficient lookup of submissionIds
      const existingSubmissionIds = new
      Set(firebaseSubmissions.map((sub: any) => sub.submissionId));

      // For each fillout, check if it exists in Firestore
      const batch = db.batch(); // Use batch writes for efficiency
      for (const fillout of fillouts) {
        if (!existingSubmissionIds.has(fillout.submissionId)) {
          // If the submission doesn't exist in Firestore, add new questions
          const updatedQuestions = [...fillout.questions];

          updatedQuestions.push({
            id: String(updatedQuestions.length),
            name: "Total amount €",
            type: "ShortAnswer",
            value: {stringValue: " "}, // Initial empty value
          });

          updatedQuestions.push({
            id: String(updatedQuestions.length + 1),
            name: "Remaining amount €",
            type: "ShortAnswer",
            value: {stringValue: " "}, // Initial empty value
          });

          const mappedSubmission = {
            collectionId: fillout.submissionId,
            submissionId: fillout.submissionId,
            submissionTime: fillout.submissionTime,
            lastUpdatedAt: fillout.lastUpdatedAt,
            questions: updatedQuestions,
            isViewed: false,
            isConfirmed: false,
            isDeleted: false,
            isCompleted: false,
          };

          // Add the new submission to Firestore
          const docRef = db.collection("submissionsDev")
            .doc(fillout.submissionId);
          batch.set(docRef, mappedSubmission, {merge: true});
          console.log(`Added new submission with ID: ${fillout.submissionId}`);
        } else {
          console.log(`Submission ID: ${fillout.submissionId} already exists.`);
        }
      }

      await batch.commit(); // Commit all writes in a single batch
      console.log("Firestore updated with new submissions.");
    } catch (error) {
      console.error("Error polling new submissions:", error);
    }
    return null;
  });

// Firestore trigger for submission updates (optional)
export const onSubmissionUpdate = functions.firestore
  .document("submissions/{submissionId}")
  .onUpdate((change) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // Logic for when a submission is updated
    if (newValue?.isChecked !== previousValue?.isChecked) {
      console.log(`Submission ${change.after.id} was checked.`);
    }
    return null;
  });
