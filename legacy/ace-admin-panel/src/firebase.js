/* @format */

// 🔥 Import Firebase modules
import { initializeApp } from 'firebase/app';
import {
	getMessaging,
	getToken,
	onMessage,
	isSupported,
} from 'firebase/messaging';

// 🔥 Firebase Config
const firebaseConfig = {
	apiKey: import.meta.env.VITE_APP_API_KEY,
	authDomain: import.meta.env.VITE_APP_AUTH_DOMAIN,
	projectId: import.meta.env.VITE_APP_PROJECT_ID,
	storageBucket: import.meta.env.VITE_APP_STORAGE_BUCKET,
	messagingSenderId: import.meta.env.VITE_APP_MESSAGING_SENDER_ID,
	appId: import.meta.env.VITE_APP_APP_ID,
	measurementId: import.meta.env.VITE_APP_MEASUREMENT_ID,
};

// 🔥 Initialize Firebase App
const firebaseApp = initializeApp(firebaseConfig);

// 🔥 Initialize Firebase Messaging (Only if supported)
let messaging = null;

isSupported()
	.then((supported) => {
		if (supported) {
			messaging = getMessaging(firebaseApp);
			console.log('✅ Firebase Messaging is supported and initialized.');
		} else {
			console.warn('⚠️ Firebase Messaging is not supported in this browser.');
		}
	})
	.catch((err) => console.error('🚨 Error checking messaging support:', err));

// 🔥 Function to get FCM Token
export const getFirebaseToken = async () => {
	if (!messaging) {
		console.warn('⚠️ Firebase Messaging is not initialized.');
		return null;
	}

	try {
		const token = await getToken(messaging, {
			vapidKey: import.meta.env.VITE_APP_VAPID_KEY,
		});
		if (token) {
			console.log('🔥 FCM Token:', token);
			return token;
		} else {
			console.warn('⚠️ No FCM token available. Requesting permission...');
			return null;
		}
	} catch (err) {
		console.error('🚨 Error fetching Firebase token:', err);
		return null;
	}
};

// 🔥 Listen for Foreground Messages
export const onForegroundMessage = (callback) => {
	if (!messaging) {
		console.warn('⚠️ Firebase Messaging is not initialized.');
		return;
	}

	onMessage(messaging, (payload) => {
		console.log('📩 Foreground Message Received:', payload);
		callback(payload);
	});
};
