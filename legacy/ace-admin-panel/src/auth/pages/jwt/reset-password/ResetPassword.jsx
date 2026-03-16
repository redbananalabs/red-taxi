/** @format */

import clsx from 'clsx';
import { useFormik } from 'formik';
import { useState } from 'react';
import { Link } from 'react-router-dom';
import * as Yup from 'yup';
import { Alert, KeenIcon } from '@/components';
import { AxiosError } from 'axios';
import { resetUserPassword } from '../../../../service/operations/authApi';
const initialValues = {
	userId: 0,
};
const forgotPasswordSchema = Yup.object().shape({
	userId: Yup.string().required('User Id is required'),
});
const ResetPassword = () => {
	const [loading, setLoading] = useState(false);
	const [newPassword, setNewPassword] = useState('');
	const [hasErrors, setHasErrors] = useState(undefined);
	const formik = useFormik({
		initialValues,
		validationSchema: forgotPasswordSchema,
		onSubmit: async (values, { setStatus, setSubmitting }) => {
			setLoading(true);
			setHasErrors(undefined);
			try {
				const response = await resetUserPassword(values.userId);
				if (response.status === 'success') {
					setNewPassword(response.password);
					setHasErrors(false);
					setLoading(false);
				}
			} catch (error) {
				if (error instanceof AxiosError && error.response) {
					setStatus(error.response.data.message);
				} else {
					setStatus('Password reset failed. Please try again.');
				}
				setNewPassword('');
				setHasErrors(true);
				setLoading(false);
				setSubmitting(false);
			}
		},
	});
	return (
		<div className='card max-w-[370px] w-full'>
			<form
				className='card-body flex flex-col gap-5 p-10'
				noValidate
				onSubmit={formik.handleSubmit}
			>
				<div className='text-center'>
					<h3 className='text-lg font-semibold text-gray-900'>Your User Id</h3>
					<span className='text-2sm text-gray-600 font-medium'>
						Enter your user id to reset password
					</span>
				</div>

				{hasErrors && <Alert variant='danger'>{formik.status}</Alert>}

				{hasErrors === false && (
					<Alert variant='success'>
						Password reset request sent. Please try to login now with new
						password.
					</Alert>
				)}

				<div className='flex flex-col gap-1'>
					<label className='form-label text-gray-900'>User Id</label>
					<label className='input'>
						<input
							type='number'
							placeholder='Enter User Id'
							autoComplete='off'
							{...formik.getFieldProps('userId')}
							className={clsx(
								'form-control bg-transparent',
								{
									'is-invalid': formik.touched.userId && formik.errors.userId,
								},
								{
									'is-valid': formik.touched.userId && !formik.errors.userId,
								}
							)}
						/>
					</label>
					{formik.touched.userId && formik.errors.userId && (
						<span
							role='alert'
							className='text-danger text-xs mt-1'
						>
							{formik.errors.userId}
						</span>
					)}
				</div>

				<div className='text-blue-400'>
					<span className='text-center text-sm'>{newPassword}</span>
				</div>

				<div className='flex flex-col gap-5 items-stretch'>
					<button
						type='submit'
						className='btn btn-primary flex justify-center grow'
						disabled={loading || formik.isSubmitting}
					>
						{loading ? 'Please wait...' : 'Continue'}
					</button>

					<Link
						to='/auth/login'
						className='flex items-center justify-center text-sm gap-2 text-gray-700 hover:text-primary'
					>
						<KeenIcon icon='black-left' />
						Back to Login
					</Link>
				</div>
			</form>
		</div>
	);
};
export { ResetPassword };
