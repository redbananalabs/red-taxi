/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { KeenIcon } from '@/components';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import clsx from 'clsx';
import { amendAcceptBooking } from '../../../../service/operations/webBookingsApi';
import { useDispatch, useSelector } from 'react-redux';
import { refreshRejectedWebBookings } from '../../../../slices/webBookingSlice';
import toast from 'react-hot-toast';
import { useState } from 'react';

function AmendRejectedBooking({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { user } = useSelector((state) => state.auth);
	const { rejectBooking } = useSelector((state) => state.webBooking);
	const [dateOpen, setDateOpen] = useState(false);
	const addLocalSchema = Yup.object().shape({
		byName: Yup.string().required('Name is required'), // Changed from email to username
	});

	const pickupDateTime = rejectBooking?.pickupDateTime
		? new Date(rejectBooking.pickupDateTime)
		: null;

	const initialValues = {
		byName:
			user?.fullName ||
			JSON.parse(localStorage?.getItem('userData'))?.fullName ||
			'',
		pickupDate: pickupDateTime, // for Calendar (Date object)
		pickupTime: rejectBooking?.pickupDateTime
			? rejectBooking?.pickupDateTime?.split('T')[1]?.slice(0, 5) // HH:mm
			: '',
		passengers: rejectBooking.passengers || 0,
		vehicles: 1,
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			const { pickupDate, pickupTime } = values;
			const pickupDateTime =
				pickupDate && pickupTime
					? `${format(pickupDate, 'yyyy-MM-dd')}T${pickupTime}:00`
					: null;
			const payload = {
				id: rejectBooking?.id,
				byName: values.byName,
				pickupDateTime, // Changed from pickupDateTime to requiredTime
				passengers: values.passengers || 0,
				vehicles: values.vehicles || 1,
			};
			const response = await amendAcceptBooking(payload);
			if (response.status === 'success') {
				toast.success('Amend request sent Successfully');
				await dispatch(refreshRejectedWebBookings());
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
						Amend Accept {`${rejectBooking?.id}`}
					</h3>

					<form
						onSubmit={formik.handleSubmit}
						className='w-full'
					>
						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Pickup Date</label>
								<Popover
									open={dateOpen}
									onOpenChange={setDateOpen}
								>
									<PopoverTrigger asChild>
										<button
											id='date'
											className={cn(
												'input data-[state=open]:border-primary',
												!formik.values.pickupDate && 'text-muted-foreground'
											)}
										>
											<KeenIcon
												icon='calendar'
												className='-ms-0.5'
											/>
											{formik.values.pickupDate ? (
												format(formik.values.pickupDate, 'LLL dd, y')
											) : (
												<span>Pick a date</span>
											)}
										</button>
									</PopoverTrigger>
									<PopoverContent
										className='w-auto p-0'
										align='start'
									>
										<Calendar
											initialFocus
											mode='single' // Single date selection
											defaultMonth={formik.values.pickupDate}
											selected={formik.values.pickupDate}
											onSelect={(val) => {
												formik.setFieldValue('pickupDate', val);
												setDateOpen(false);
											}}
											numberOfMonths={1}
										/>
									</PopoverContent>
								</Popover>
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Pickup Time</label>
								<label className='input'>
									<input
										type='time'
										placeholder='Enter Time'
										autoComplete='off'
										{...formik.getFieldProps('pickupTime')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.pickupTime && formik.errors.pickupTime,
										})}
									/>
								</label>
								{formik.touched.pickupTime && formik.errors.pickupTime && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.pickupTime}
									</span>
								)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Passengers</label>
								<label className='input'>
									<input
										type='number'
										placeholder='Enter passengers'
										autoComplete='off'
										{...formik.getFieldProps('passengers')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.passengers && formik.errors.passengers,
										})}
									/>
								</label>
								{formik.touched.passengers && formik.errors.passengers && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.passengers}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Vehicles</label>
								<Select
									defaultValue='0'
									value={formik.values.vehicles.toString()}
									onValueChange={(value) =>
										formik.setFieldValue('vehicles', Number(value))
									}
								>
									<SelectTrigger className='w-full'>
										<SelectValue placeholder='Select' />
									</SelectTrigger>
									<SelectContent>
										<SelectItem value='1'>1</SelectItem>
										<SelectItem value='2'>2</SelectItem>
										<SelectItem value='3'>3</SelectItem>
										<SelectItem value='4'>4</SelectItem>
										<SelectItem value='5'>5</SelectItem>
										<SelectItem value='6'>6</SelectItem>
										<SelectItem value='7'>7</SelectItem>
										<SelectItem value='8'>8</SelectItem>
										<SelectItem value='9'>9</SelectItem>
									</SelectContent>
								</Select>
								{formik.touched.vehicleType && formik.errors.vehicleType && (
									<span
										color='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.vehicleType}
									</span>
								)}
							</div>
						</div>
						{rejectBooking?.arriveBy && (
							<div className='flex gap-1 pb-2'>
								<label className='switch'>
									<span className='switch-label'>
										Arrive BY :{' '}
										{rejectBooking?.pickupDateTime
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

export { AmendRejectedBooking };
