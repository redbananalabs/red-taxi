/** @format */

// Import necessary modules and components
import { useEffect, useState } from "react"; // Hook for side effects like updating the DOM
import { BrowserRouter } from "react-router-dom"; // Provides routing functionality for the app
import { useSettings } from "@/providers/SettingsProvider"; // Custom hook to access app settings
import { AppRouting } from "@/routing"; // Component that defines app routes
import { PathnameProvider } from "@/providers"; // Custom provider for managing the current pathname
import { onForegroundMessage } from "./firebase";
import toast from "react-hot-toast";

// Import environment variable for the app's base URL
const { BASE_URL } = import.meta.env;

// Main App Component
const App = () => {
  const { settings } = useSettings();
  const [notifications, setNotifications] = useState([]);
  // const [fcmToken, setFcmToken] = useState(null);

  // Side effect to update the `themeMode` class on the root HTML element
  useEffect(() => {
    // Remove existing theme classes (light/dark) from the document
    document.documentElement.classList.remove("dark");
    document.documentElement.classList.remove("light");

    // Add the current theme mode (light or dark) to the document
    document.documentElement.classList.add(settings.themeMode);
  }, [settings]); // Re-run the effect whenever `settings` changes

  // Handle foreground notifications
  useEffect(() => {
    const unsubscribe = onForegroundMessage((payload) => {
      if (payload?.notification) {
        const { title, body } = payload.notification;
        setNotifications((prev) => [...prev, { title, body }]); // Store notifications
        toast.success(`🔔 ${title}: ${body}`);
      }
    });

    return () => unsubscribe && unsubscribe();
  }, []);

  // Request notification permission (memoized)
  // const requestPermission = useCallback(async () => {
  // 	try {
  // 		const permission = await Notification.requestPermission();
  // 		('Notification permission result:', permission);
  // 		if (permission === 'granted') {
  // 			const token = await getFirebaseToken();
  // 			if (token && token !== fcmToken) {
  // 				// Only send if token is new
  // 				setFcmToken(token); // Store the token to prevent duplicate calls
  // 				try {
  // 					const response = await updateFCM(token);
  // 					console.log('FCM token sent to API successfully:', response);
  // 					toast.success('FCM token updated successfully!');
  // 				} catch (error) {
  // 					console.error('Error sending FCM token to API:', error);
  // 					toast.error('Failed to update FCM token.');
  // 				}
  // 			} else if (!token) {
  // 				console.warn('No FCM token retrieved.');
  // 			}
  // 		} else {
  // 			console.warn('Notification permission not granted:', permission);
  // 			toast.error('Notification permission denied.');
  // 		}
  // 	} catch (error) {
  // 		console.error('Error requesting notification permission:', error);
  // 		toast.error('Error requesting notification permission.');
  // 	}
  // }, [fcmToken]);

  // useEffect(() => {
  // 	requestPermission();
  // }, [requestPermission]);

  // Return the app's main structure
  return (
    <BrowserRouter
      basename={BASE_URL} // Sets the base URL for routing (useful for deploying to subdirectories)
    >
      {/* Custom provider for managing pathname state */}
      <PathnameProvider>
        {/* Handles app routing by rendering pages based on the URL */}
        <AppRouting />
      </PathnameProvider>

      {/* Toast notifications for showing alerts/messages */}
      {/* <Toaster /> */}
    </BrowserRouter>
  );
};

export { App }; // Export the App component for use in index.js or elsewhere
