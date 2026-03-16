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
import {
	acceptWebBookings,
	getDurationWebBookings,
} from '../../../../service/operations/webBookingsApi';
import { useDispatch, useSelector } from 'react-redux';
import { refreshWebBookings } from '../../../../slices/webBookingSlice';
import toast from 'react-hot-toast';
import { useState } from 'react';

function AcceptWebBooking({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { user } = useSelector((state) => state.auth);
	const { webBooking } = useSelector((state) => state.webBooking);
	const [journeyTime, setJourneyTime] = useState(null);

	const addLocalSchema = Yup.object().shape({
		byName: Yup.string().required('Name is required'), // Changed from email to username
	});

	const initialValues = {
		byName:
			user?.fullName ||
			JSON.parse(localStorage?.getItem('userData'))?.fullName ||
			'',
		requiredTime:
			journeyTime || `${webBooking?.pickupDateTime?.split('T')[1].slice(0, 5)}`,
		price: '',
	};

	const handleJourneyClick = async () => {
		try {
			const response = await getDurationWebBookings(webBooking?.id);

			if (response.status === 'success') {
				const durationMinutes = response.data; // Minutes to subtract
				const pickupTime = webBooking?.pickupDateTime
					?.split('T')[1]
					.slice(0, 5); // "HH:mm"

				if (pickupTime) {
					// Convert "HH:mm" string to Date object
					const [hours, minutes] = pickupTime.split(':').map(Number);
					const date = new Date();
					date.setHours(hours);
					date.setMinutes(minutes - durationMinutes); // Subtract minutes

					// Format back to HH:mm
					const updatedTime = date.toTimeString().slice(0, 5);

					// Update state
					setJourneyTime(updatedTime);
					formik.setFieldValue('requiredTime', updatedTime);
				}
			}
		} catch (error) {
			console.log(error);
		}
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			console.log('Submitted Values:', values);
			const payload = {
				id: webBooking?.id,
				byName: values.byName,
				requiredTime: values.requiredTime, // Changed from pickupDateTime to requiredTime
				price: values.price || 0,
			};
			const response = await acceptWebBookings(payload);
			if (response.status === 'success') {
				toast.success('Booking accepted Successfully');
				await dispatch(refreshWebBookings());
				onOpenChange(); // Reset Formik's submitting state
				setSubmitting(false);
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
						Accept Web Booking {`${webBooking?.id}`}
					</h3>

					<form onSubmit={formik.handleSubmit}>
						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>By Name</label>
								<label className='input'>
									<input
										placeholder='Enter name'
										autoComplete='off'
										readOnly
										{...formik.getFieldProps('byName')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.byName && formik.errors.byName,
										})}
									/>
								</label>
								{formik.touched.byName && formik.errors.byName && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.name}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 mt-4 w-full'>
								<label className='form-label text-gray-900'></label>
								<button
									type='button'
									className='btn btn-primary'
									onClick={handleJourneyClick}
								>
									Calculate Journey Time
								</button>
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Pickup Date Time
								</label>
								<label className='input'>
									<input
										placeholder='Enter Time'
										autoComplete='off'
										{...formik.getFieldProps('requiredTime')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.requiredTime &&
												formik.errors.requiredTime,
										})}
									/>
								</label>
								{formik.touched.requiredTime && formik.errors.requiredTime && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.requiredTime}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>Price</label>
								<label className='input'>
									<input
										type='number'
										placeholder='Enter price'
										autoComplete='off'
										{...formik.getFieldProps('price')}
										className={clsx('form-control', {
											'is-invalid': formik.touched.price && formik.errors.price,
										})}
									/>
								</label>
								{formik.touched.price && formik.errors.price && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.price}
									</span>
								)}
							</div>
						</div>
						{webBooking?.arriveBy && (
							<div className='flex gap-1 pb-2'>
								<label className='switch'>
									<span className='switch-label'>
										Arrive BY :{' '}
										{webBooking?.pickupDateTime
											.split('T')[1]
											.split('.')[0]
											?.slice(0, 5)}
									</span>
								</label>
							</div>
						)}

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

export { AcceptWebBooking };
