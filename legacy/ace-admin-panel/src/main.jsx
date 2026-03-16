/** @format */

import '@/components/keenicons/assets/styles.css';
import './styles/globals.css';
import axios from 'axios';
import ReactDOM from 'react-dom/client';
import { App } from './App';
import { setupAxios } from './auth';
import { ProvidersWrapper } from './providers';
import React from 'react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import rootReducer from './reducer';
import { Toaster } from 'react-hot-toast';

/**
 * Inject interceptors for axios.
 *
 * @see https://github.com/axios/axios#interceptors
 */
setupAxios(axios);
const store = configureStore({
	reducer: rootReducer,
});

if ('serviceWorker' in navigator) {
	navigator.serviceWorker
		.register('/firebase-messaging-sw.js')
		.then((registration) => {
			console.log('Service Worker Registered:', registration);
		})
		.catch((err) => {
			console.error('Service Worker Registration Failed:', err);
		});
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
	<React.StrictMode>
		<ProvidersWrapper>
			<Provider store={store}>
				<App />
				<Toaster
					position='top-right'
					toastOptions={{
						success: {
							style: {
								background: '#22c55e', // green-500
								color: '#fff',
							},
							iconTheme: {
								primary: '#ffffff',
								secondary: '#16a34a', // green-600
							},
						},
						error: {
							style: {
								background: '#ef4444', // red-500
								color: '#fff',
							},
							iconTheme: {
								primary: '#ffffff',
								secondary: '#dc2626', // red-600
							},
						},
						style: {
							padding: '12px 16px',
							borderRadius: '8px',
							fontSize: '14px',
						},
					}}
				/>
			</Provider>
		</ProvidersWrapper>
	</React.StrictMode>
);
