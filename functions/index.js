const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Fillout webhook handler
 * Receives form submissions from Fillout and saves them to Firestore
 */
exports.filloutWebhook = onRequest({
  invoker: 'public',  // Allow unauthenticated requests from Fillout webhooks
  cors: true,
}, async (req, res) => {
    // Only accept POST requests
    if (req.method !== "POST") {
        return res.status(405).send("Method Not Allowed");
    }

    try {
        // Parse request body (handle string or already parsed JSON)
        let bodyData = req.body;
        if (typeof bodyData === 'string') {
            bodyData = JSON.parse(bodyData);
        }

        // Extract submission data from various possible payload structures
        let submissionData = null;
        
        if (bodyData.submission) {
            submissionData = bodyData.submission;
        } else if (bodyData.data?.submission) {
            submissionData = bodyData.data.submission;
        } else if (bodyData.event === "form_response" && bodyData.data) {
            submissionData = bodyData.data;
        } else if (bodyData.formResponse) {
            submissionData = bodyData.formResponse;
        } else if (bodyData.submissionId || bodyData.questions) {
            submissionData = bodyData;
        } else if (bodyData && typeof bodyData === 'object' && Object.keys(bodyData).length > 0) {
            // Fallback: treat entire body as submission
            submissionData = bodyData;
        }

        if (!submissionData || !bodyData) {
            logger.error("Invalid payload: Missing submission data");
            return res.status(400).json({
                error: "Bad Request: Missing submission data",
                message: "Expected payload structure: { submission: {...} } or { data: { submission: {...} } }"
            });
        }

        // Extract submission fields with fallbacks
        const submissionId = submissionData.submissionId || submissionData.id || submissionData.responseId || `submission-${Date.now()}`;
        const submissionTime = submissionData.submissionTime || submissionData.submittedAt || submissionData.createdAt || new Date().toISOString();
        const lastUpdatedAt = submissionData.lastUpdatedAt || submissionData.updatedAt || submissionTime;
        const questions = submissionData.questions || submissionData.responses || submissionData.answers || [];

        // Transform questions to standardized format
        const transformedQuestions = questions.map((q, index) => {
            const question = {
                id: q.id || q.questionId || `q${index}`,
                name: q.name || q.question || q.label || `Question ${index + 1}`,
                type: q.type || q.questionType || 'ShortAnswer',
            };
            
            // Handle different value field names
            const value = q.value ?? q.answer ?? q.response;
            if (value != null && value !== '') {
                question.value = value;
            }
            
            return question;
        });

        // Add additional fields for order management
        const additionalQuestions = [
            { id: `q${transformedQuestions.length}`, name: "Total amount €", type: "ShortAnswer", value: " " },
            { id: `q${transformedQuestions.length + 1}`, name: "Remaining amount €", type: "ShortAnswer", value: " " },
            { id: `q${transformedQuestions.length + 2}`, name: "Notitie", type: "ShortAnswer", value: " " },
        ];
        const allQuestions = [...transformedQuestions, ...additionalQuestions];

        // Save to Firestore
        const db = admin.firestore();
        const docRef = db.collection("submissionsVersion2").doc();
        const collectionId = docRef.id;

        const submission = {
            submissionId,
            submissionTime,
            lastUpdatedAt,
            questions: allQuestions,
            type: "new",
            state: "unviewed",
            collectionId,
        };

        await docRef.set(submission);

        logger.info(`Submission saved: ${submissionId} (collectionId: ${collectionId})`);

        return res.status(200).json({
            message: "Submission successfully processed and stored.",
            collectionId,
        });
    } catch (error) {
        logger.error("Error processing webhook:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
});

/**
 * Test function (can be removed if not needed)
 */
exports.helloWorld = functions.https.onCall((data, context) => {
    logger.info("HelloWorld called");
    return { message: "Hello, World!" };
});
