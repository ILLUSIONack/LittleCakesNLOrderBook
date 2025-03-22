/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');

// exports.helloWorld = functions.https.onRequest((req, res) => {
    // logger.info("Hello logs!", {structuredData: true});
//     res.status(200).json({ message: "Hello, World!" });
// });

// const functions = require("firebase-functions");

exports.helloWorld = functions.https.onCall((data, context) => {
    // Return data in the correct format
    logger.info("Hello logs!", {structuredData: true});
    return { "message" : "Hello, World!"};
});

// const functions = require('firebase-functions');
// const axios = require('axios');

// const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.filloutWebhook = functions.https.onRequest(async (req, res) => {
    // Ensure the request is a POST request
    if (req.method !== "POST") {
        logger.info("Received non-POST request");
        return res.status(405).send("Method Not Allowed");
    }

    try {
        // Log the incoming webhook data
        logger.info("Received Webhook Data:", JSON.stringify(req.body, null, 2));

        // Extract submission data from the payload
        const submissionData = req.body.submission;

        if (!submissionData) {
            logger.error("Invalid payload: Missing 'submission' field.");
            console.error("Invalid payload: Missing 'submission' field.");
            return res.status(400).send("Bad Request: Missing 'submission' field.");
        }

        // Extract relevant fields
        const { submissionId, submissionTime, lastUpdatedAt, questions } = submissionData;

        // Transform the questions, excluding the value field if it's empty
        let transformedQuestions = questions.map((q, index) => {
            const question = {
                id: q.id || `q${index}`,
                name: q.name,
                type: q.type,
            };
            if (q.value) {
                question.value = q.value; // Include value only if it's non-empty
            }
            return question;
        });

        // Append additional questions
        const additionalQuestions = [
            {
                id: `q${transformedQuestions.length}`,
                name: "Total amount €",
                type: "ShortAnswer",
                value: " ",
            },
            {
                id: `q${transformedQuestions.length + 1}`,
                name: "Remaining amount €",
                type: "ShortAnswer",
                value: " ",
            },
            {
                id: `q${transformedQuestions.length + 2}`,
                name: "Notitie",
                type: "ShortAnswer",
                value: " ",
            },
        ];
        transformedQuestions = [...transformedQuestions, ...additionalQuestions];

        // Initialize Firestore
        const db = admin.firestore();

        // Add the submission to Firestore
        const docRef = db.collection("submissionsVersion2").doc(); // Auto-generate document ID
        const collectionId = docRef.id; // Get the generated document ID

        // Prepare the submission document
        const submission = {
            submissionId: submissionId, // Use the provided submissionId
            submissionTime: submissionTime || new Date().toISOString(),
            lastUpdatedAt: lastUpdatedAt || new Date().toISOString(),
            questions: transformedQuestions,
            type: "new", // Add the new type property
            state: "unviewed", // Add the unviewed state property
            collectionId: collectionId, // Use the Firestore document ID as collectionId
        };

        // Save the submission to Firestore
        await docRef.set(submission);

        logger.info(`Submission successfully saved with collectionId: ${collectionId}.`);

        // Respond back with a success message
        return res.status(200).json({
            message: "Submission successfully processed and stored.",
            collectionId: collectionId,
        });
    } catch (error) {
        logger.error("Error during webhook processing:", error);
        console.error("Error during webhook processing:", error);
        return res.status(500).send("Internal Server Error");
    }
});