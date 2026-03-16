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
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import clsx from 'clsx';
import { useState } from 'react';
import { KeenIcon } from '@/components';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { Calendar } from '@/components/ui/calendar';
import { updateAvailability } from '../../../service/operations/availabilityApi';
import toast from 'react-hot-toast';
import {
	refreshAllAvailability,
	refreshAvailability,
} from '../../../slices/availabilitySlice';
import { useDispatch } from 'react-redux';

function CustomModal({
	open,
	onOpenChange,
	selectedDate,
	selectedDriver,
	checkExistingAvailability,
}) {
	const dispatch = useDispatch();
	const [date, setDate] = useState(new Date(selectedDate));

	const validationSchema = Yup.object().shape({
		from: Yup.string().required('From time is required'),
		to: Yup.string().required('To time is required'),
		note: Yup.string(),
		giveOrTake: Yup.boolean(),
	});

	const formik = useFormik({
		initialValues: {
			from: '',
			to: '',
			note: '',
			giveOrTake: false,
		},
		validationSchema,
		onSubmit: async (values, { setSubmitting, resetForm }) => {
			try {
				const hasExist = checkExistingAvailability(values.from, values.to);

				if (hasExist) {
					toast.error('This time slot is already exist. Choose another slot');
					return;
				}
				const payload = {
					userId: selectedDriver, // Driver ID
					date: format(new Date(date), "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), // Formatted Date
					from: values.from,
					to: values.to,
					giveOrTake: values.giveOrTake, // Checkbox value
					type: values.type, // Default Type 1 (Available)
					note: values.note || '', // Optional note
				};

				await updateAvailability(payload);
				toast.success('Available Hours Added Successfully');
				dispatch(
					refreshAvailability(
						selectedDriver,
						format(new Date(selectedDate), "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
					)
				);
				dispatch(
					refreshAllAvailability(
						format(new Date(selectedDate), "yyyy-MM-dd'T'00:00:00'Z'")
					)
				);
				resetForm(); // Reset the form after submission
				onOpenChange(); // Close Modal
			} catch (error) {
				toast.error('Failed to add hours');
				console.error(error);
			}
			setSubmitting(false);
		},
	});

	const handleAvailabilitySubmit = async (type) => {
		await formik.setFieldValue('type', type);
		formik.handleSubmit();
	};

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
						Custom Availability {selectedDriver}
					</h3>

					<form onSubmit={formik.handleSubmit}>
						<div className='flex flex-col gap-1 pb-2 w-full'>
							<label className='form-label text-gray-900'>Date</label>
							<Popover>
								<PopoverTrigger asChild>
									<button
										id='date'
										className={cn(
											'input data-[state=open]:border-primary',
											!date && 'text-muted-foreground'
										)}
									>
										<KeenIcon
											icon='calendar'
											className='-ms-0.5'
										/>
										{date ? (
											format(date, 'LLL dd, y')
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
										defaultMonth={date}
										selected={date}
										onSelect={setDate}
										numberOfMonths={1}
									/>
								</PopoverContent>
							</Popover>
						</div>
						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-[50%]'>
								<label className='form-label text-gray-900'>From</label>
								<label className='input'>
									<input
										type='time'
										placeholder='Enter Time'
										autoComplete='off'
										{...formik.getFieldProps('from')}
										className={clsx('form-control', {
											'is-invalid': formik.touched.from && formik.errors.from,
										})}
									/>
								</label>
								{formik.touched.from && formik.errors.from && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.from}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-[50%]'>
								<label className='form-label text-gray-900'>To</label>
								<label className='input'>
									<input
										type='time'
										placeholder='Enter Time'
										autoComplete='off'
										{...formik.getFieldProps('to')}
										className={clsx('form-control', {
											'is-invalid': formik.touched.to && formik.errors.to,
										})}
									/>
								</label>
								{formik.touched.to && formik.errors.to && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.to}
									</span>
								)}
							</div>
						</div>

						<div className='flex flex-col gap-1 pb-2'>
							<label className='form-label text-gray-900'>Note</label>
							<label className=''>
								<textarea
									placeholder='e.g., Locals Only..'
									autoComplete='off'
									{...formik.getFieldProps('note')}
									className={clsx(
										'form-control textarea text-2sm text-gray-600 font-normal',
										{
											'is-invalid': formik.touched.note && formik.errors.note,
										}
									)}
								/>
							</label>
							{formik.touched.note && formik.errors.note && (
								<span
									role='alert'
									className='text-danger text-xs mt-1'
								>
									{formik.errors.note}
								</span>
							)}
						</div>

						<div className='flex items-center gap-2'>
							<label className='switch'>
								<span className='switch-label'>Give Or Take (+/-)</span>
								<input
									type='checkbox'
									name='giveOrTake'
									checked={formik.values.giveOrTake}
									onChange={(e) =>
										formik.setFieldValue('giveOrTake', e.target.checked)
									}
								/>
							</label>
							{formik.touched.giveOrTake && formik.errors.giveOrTake && (
								<span
									role='alert'
									className='text-danger text-xs mt-1'
								>
									{formik.errors.giveOrTake}
								</span>
							)}
						</div>

						<div className='flex justify-end mb-2 mt-3'>
							<button
								type='button'
								className='btn btn-primary bg-green-600 hover:bg-green-500'
								onClick={() => handleAvailabilitySubmit(1)}
							>
								Add Available Hours
							</button>
							<button
								type='button'
								className='btn btn-danger ml-2'
								onClick={() => handleAvailabilitySubmit(2)}
							>
								Add Unavailable Hours
							</button>
						</div>
					</form>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { CustomModal };
