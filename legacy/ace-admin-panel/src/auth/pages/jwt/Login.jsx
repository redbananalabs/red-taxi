/** @format */

import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import clsx from 'clsx';
import * as Yup from 'yup';
import { useFormik } from 'formik';
import { KeenIcon } from '@/components';
import { useDispatch, useSelector } from 'react-redux'; // Import Redux hooks
import { login } from '../../../service/operations/authApi'; // Redux login action
import { Alert } from '@/components';
import { getFirebaseToken } from '../../../firebase';
import toast from 'react-hot-toast';
import { updateFCM } from '../../../service/operations/gpsApi';
import { setIsNotifications } from '../../../slices/authSlice';

// Validation schema
const loginSchema = Yup.object().shape({
	username: Yup.string()
		.min(3, 'Minimum 3 symbols')
		.max(50, 'Maximum 50 symbols')
		.required('Username is required'),
	password: Yup.string()
		.min(3, 'Minimum 3 symbols')
		.max(50, 'Maximum 50 symbols')
		.required('Password is required'),
	remember: Yup.boolean(),
});

// Initial values
const initialValues = {
	username: 'peter', // Placeholder username
	password: 'Mooman',
	remember: false,
};

const Login = () => {
	const [loading, setLoading] = useState(false); // Local loading state
	const [showPassword, setShowPassword] = useState(false); // Show/hide password state
	const dispatch = useDispatch(); // Hook to dispatch Redux actions
	const navigate = useNavigate(); // Hook for navigation
	const { error } = useSelector((state) => state.auth); // Extract auth state from Redux
	const [fcmToken, setFcmToken] = useState(null);

	const handleFCMUpdate = async () => {
		try {
			const permission = await Notification.requestPermission();
			if (permission !== 'granted') {
				toast.error('Notification permission denied.');
				return;
			}

			const token = await getFirebaseToken();
			if (token && token !== fcmToken) {
				setFcmToken(token);
				const response = await updateFCM(token);
				if (response?.status === 'success') {
					toast.success('FCM token updated successfully!');
					localStorage.setItem('isNotification', true);
					dispatch(setIsNotifications(true));
				}
			}
		} catch (error) {
			console.error('Error updating FCM token:', error);
			toast.error('Error updating FCM token.');
		}
	};
	// Formik for form handling
	const formik = useFormik({
		initialValues,
		validationSchema: loginSchema,
		onSubmit: async (values, { setSubmitting }) => {
			setLoading(true);

			// Dispatch Redux login action
			await dispatch(
				login(
					{
						username: values.username, // Pass username
						password: values.password, // Pass password
					},
					navigate, // Pass navigate to handle navigation after login
				),
			);
			await handleFCMUpdate();

			// Handle remember me logic
			if (values.remember) {
				localStorage.setItem('username', values.username);
			} else {
				localStorage.removeItem('username');
			}

			setLoading(false); // Stop the loading state
			setSubmitting(false); // Reset Formik's submitting state
		},
	});

	// Toggle password visibility
	const togglePassword = (event) => {
		event.preventDefault();
		setShowPassword(!showPassword);
	};

	return (
		<div className='card max-w-[390px] w-full'>
			<form
				className='card-body flex flex-col gap-5 p-10'
				onSubmit={formik.handleSubmit}
				noValidate
			>
				<div className='text-center mb-2.5'>
					<h3 className='text-lg font-semibold text-gray-900 leading-none mb-2.5'>
						Sign in
					</h3>
					<div className='flex items-center justify-center font-medium'>
						<span className='text-2sm text-gray-600 me-1.5'>
							Need an account?
						</span>
						<Link
							to='/auth/signup'
							className='text-2sm link'
						>
							Sign up
						</Link>
					</div>
				</div>

				{/* Alert for errors */}
				{error && <Alert variant='danger'>{error}</Alert>}

				{/* Username Input */}
				<div className='flex flex-col gap-1'>
					<label className='form-label text-gray-900'>Username</label>
					<label className='input'>
						<input
							placeholder='Enter username'
							autoComplete='off'
							{...formik.getFieldProps('username')}
							className={clsx('form-control', {
								'is-invalid': formik.touched.username && formik.errors.username,
							})}
						/>
					</label>
					{formik.touched.username && formik.errors.username && (
						<span
							role='alert'
							className='text-danger text-xs mt-1'
						>
							{formik.errors.username}
						</span>
					)}
				</div>

				{/* Password Input */}
				<div className='flex flex-col gap-1'>
					<div className='flex items-center justify-between gap-1'>
						<label className='form-label text-gray-900'>Password</label>
						<Link
							to='/auth/reset-password'
							className='text-2sm link shrink-0'
						>
							Forgot Password?
						</Link>
					</div>
					<label className='input'>
						<input
							type={showPassword ? 'text' : 'password'}
							placeholder='Enter Password'
							autoComplete='off'
							{...formik.getFieldProps('password')}
							className={clsx('form-control', {
								'is-invalid': formik.touched.password && formik.errors.password,
							})}
						/>
						<button
							className='btn btn-icon'
							onClick={togglePassword}
						>
							<KeenIcon
								icon='eye'
								className={clsx('text-gray-500', {
									hidden: showPassword,
								})}
							/>
							<KeenIcon
								icon='eye-slash'
								className={clsx('text-gray-500', {
									hidden: !showPassword,
								})}
							/>
						</button>
					</label>
					{formik.touched.password && formik.errors.password && (
						<span
							role='alert'
							className='text-danger text-xs mt-1'
						>
							{formik.errors.password}
						</span>
					)}
				</div>

				{/* Remember Me */}
				<label className='checkbox-group'>
					<input
						className='checkbox checkbox-sm'
						type='checkbox'
						{...formik.getFieldProps('remember')}
					/>
					<span className='checkbox-label'>Remember me</span>
				</label>

				{/* Submit Button */}
				<button
					type='submit'
					className='btn btn-primary flex justify-center grow'
					disabled={loading || formik.isSubmitting}
				>
					{loading ? 'Please wait...' : 'Sign In'}
				</button>
			</form>
		</div>
	);
};

export { Login };
