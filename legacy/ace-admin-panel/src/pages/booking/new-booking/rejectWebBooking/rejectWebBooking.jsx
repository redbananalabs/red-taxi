/** @format */
/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';

import { useFormik } from 'formik';
import * as Yup from 'yup';
import clsx from 'clsx';
import { rejectWebBookings } from '../../../../service/operations/webBookingsApi';
import { useDispatch, useSelector } from 'react-redux';
import { refreshWebBookings } from '../../../../slices/webBookingSlice';
import toast from 'react-hot-toast';

function RejectWebBooking({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { user } = useSelector((state) => state.auth);
	const { webBooking } = useSelector((state) => state.webBooking);
	const addLocalSchema = Yup.object().shape({
		byName: Yup.string().required('Name is required'), // Changed from email to username
		reason: Yup.string().required('Reason is required'),
	});

	const initialValues = {
		id: webBooking?.id,
		byName:
			user?.fullName ||
			JSON.parse(localStorage?.getItem('userData'))?.fullName ||
			'',
		reason: '',
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			console.log('Submitted Values:', values);
			const payload = {
				id: webBooking?.id,
				byName: values.byName,
				reason: values.reason,
			};
			const response = await rejectWebBookings(payload);
			if (response.status === 'success') {
				toast.success('Booking rejected Successfully');
				await dispatch(refreshWebBookings());
				setSubmitting(false);
				onOpenChange(); // Reset Formik's submitting state
			}
		},
	});
	return (
		<Dialog
			open={open}
			onOpenChange={onOpenChange}
		>
			<DialogContent className='max-w-[500px]'>
				<DialogHeader className='border-0'>
					<DialogTitle></DialogTitle>
					<DialogDescription></DialogDescription>
				</DialogHeader>
				<DialogBody className='flex flex-col items-center pt-0 pb-4'>
					<h3 className='text-lg font-medium text-gray-900 text-center mb-3'>
						Reject Web Booking {`${webBooking?.id}`}
					</h3>

					<form
						onSubmit={formik.handleSubmit}
						className='w-full'
					>
						<div className='flex flex-col gap-1 pb-2'>
							<label className='form-label text-gray-900'>Name</label>
							<label className='input'>
								<input
									placeholder='Enter name'
									autoComplete='off'
									{...formik.getFieldProps('byName')}
									className={clsx('form-control', {
										'is-invalid': formik.touched.byName && formik.errors.byName,
									})}
								/>
							</label>
							{formik.touched.byName && formik.errors.byName && (
								<span
									role='alert'
									className='text-danger text-xs mt-1'
								>
									{formik.errors.byName}
								</span>
							)}
						</div>
						<div className='flex flex-col gap-1 pb-2'>
							<label className='form-label text-gray-900'>Reason</label>
							<label className=''>
								<textarea
									placeholder='Enter reason'
									autoComplete='off'
									{...formik.getFieldProps('reason')}
									className={clsx(
										'form-control textarea text-2sm text-gray-600 font-normal',
										{
											'is-invalid':
												formik.touched.reason && formik.errors.reason,
										}
									)}
								/>
							</label>
							{formik.touched.reason && formik.errors.reason && (
								<span
									role='alert'
									className='text-danger text-xs mt-1'
								>
									{formik.errors.reason}
								</span>
							)}
						</div>

						<div className='flex justify-end mb-2 mt-2'>
							<button
								className='btn btn-light'
								onClick={() => onOpenChange()}
							>
								Cancel
							</button>
							<button
								className='btn btn-primary ml-2'
								type='submit'
							>
								Submit
							</button>
						</div>
					</form>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { RejectWebBooking };
