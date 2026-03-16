/** @format */

import { useEffect, useState } from 'react';
import { AvailabilityTable } from './availability-table';

import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { KeenIcon } from '@/components';
import {
	Select,
	SelectTrigger,
	SelectContent,
	SelectItem,
	SelectValue,
} from '@/components/ui/select';
import { CustomModal } from './customModal';
import { SelectedAvailabilityTable } from './selectedAvaliability';
import toast from 'react-hot-toast';
import { updateAvailability } from '../../../service/operations/availabilityApi';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshAllAvailability,
	refreshAvailability,
} from '../../../slices/availabilitySlice';
import { refreshAllDrivers } from '../../../slices/driverSlice';

const Availability = () => {
	const dispatch = useDispatch();
	const { drivers } = useSelector((state) => state.driver);
	const { availability } = useSelector((state) => state.availability);
	const [selectedDriver, setSelectedDriver] = useState(0);
	const [isCustomModal, setIsCustomModal] = useState(false);
	const [date, setDate] = useState(new Date());
	const [open, setOpen] = useState(false);
	const handleClose = () => {
		setIsCustomModal(false);
	};

	const checkExistingAvailability = (from, to) => {
		if (!availability || !selectedDriver) return false;

		const selectedDateKey = format(new Date(date), 'yyyy-MM-dd'); // Format date to match stored keys
		const timeToMinutes = (timeStr) => {
			if (!timeStr || typeof timeStr !== 'string') return null; // Ensure time is valid
			const [hours, minutes] = timeStr.split(':').map(Number);
			return hours * 60 + minutes;
		};

		const selectedStart = timeToMinutes(from);
		const selectedEnd = timeToMinutes(to);

		const isOverlapping = availability[0]?.some((entry) => {
			if (!entry?.date) {
				console.warn('⚠️ Skipping entry with missing date:', entry);
				return false; // Skip this entry
			}
			let parsedDate;
			try {
				parsedDate = new Date(entry.date);
				if (isNaN(parsedDate.getTime())) {
					throw new Error('Invalid date format');
				}
			} catch (error) {
				console.error('❌ Invalid date in entry:', entry.date, error);
				return false; // Skip this entry
			}
			const entryDate = format(parsedDate, 'yyyy-MM-dd'); // Convert to proper format
			const existingStart = timeToMinutes(entry.from);
			const existingEnd = timeToMinutes(entry.to);

			return (
				entryDate === selectedDateKey && // Ensure same date
				((selectedStart >= existingStart && selectedStart < existingEnd) || // Starts inside existing slot
					(selectedEnd > existingStart && selectedEnd <= existingEnd) || // Ends inside existing slot
					(selectedStart <= existingStart && selectedEnd >= existingEnd)) // Fully covers existing slot
			);
		});
		if (isOverlapping) {
			console.warn(
				`❌ Availability conflict detected for ${from} - ${to}. Blocking API call.`
			);
			return true; // Prevents API call
		}

		return false; // No conflicts, proceed with API call
	};

	const handleClick = async (type) => {
		if (!selectedDriver) {
			toast.error('Please select a driver');
			return;
		}
		const payload = {
			userId: selectedDriver,
			date: format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
			from: '',
			to: '',
			giveOrTake: false,
			type: 1,
			note: '',
		};

		if (type === 'srAmOnly') {
			payload.from = '07:30:00';
			payload.to = '09:15:00';
		} else if (type === 'srPmOnly') {
			payload.from = '14:30:00';
			payload.to = '16:15:00';
		} else if (type === 'srOnly') {
			const amExists = checkExistingAvailability('07:30:00', '09:15:00');
			const pmExists = checkExistingAvailability('14:30:00', '16:15:00');

			if (amExists && pmExists) {
				toast.error('SR AM & PM Availability already exists!');
				return;
			}

			const requests = [];
			if (!amExists) {
				requests.push(
					updateAvailability({ ...payload, from: '07:30:00', to: '09:15:00' })
				);
			}
			if (!pmExists) {
				requests.push(
					updateAvailability({ ...payload, from: '14:30:00', to: '16:15:00' })
				);
			}

			if (requests.length === 0) return; // If both exist, stop execution

			try {
				const responses = await Promise.all(requests);
				if (responses.every((res) => res?.status === 'success')) {
					dispatch(
						refreshAvailability(
							selectedDriver,
							format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'")
						)
					);
					dispatch(
						refreshAllAvailability(
							format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'")
						)
					);
					toast.success('SR Availability updated successfully!');
				} else {
					throw new Error('One or more requests failed');
				}
			} catch (error) {
				toast.error('Failed to update SR availability');
				console.error(error);
			}
			return;
		} else if (type === 'unavailableAllDay') {
			payload.from = '00:00:00';
			payload.to = '23:59:59';
			payload.type = 2; // Unavailable All Day
			payload.note = 'Unavailable All Day';
		}

		if (checkExistingAvailability(payload.from, payload.to)) {
			toast.error(
				`Availability for this time (${payload.from} - ${payload.to}) already exists!`
			);
			return;
		}

		try {
			const response = await updateAvailability(payload);
			if (response.status === 'success') {
				toast.success(`Availability updated for Driver #${selectedDriver}`);
				dispatch(
					refreshAvailability(
						selectedDriver,
						format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'")
					)
				);
				dispatch(
					refreshAllAvailability(
						format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'")
					)
				);
			} else {
				toast.error('Failed to update availability');
			}
		} catch (error) {
			console.error('Error setting availability:', error);
			toast.error('Something went wrong');
		}
	};

	const handleDateSelect = (date) => {
		setDate(date); // Update the date range
		// Close the popover if both from and to dates are selected
		setOpen(false);
	};

	useEffect(() => {
		dispatch(refreshAllDrivers());
	}, [dispatch]);

	useEffect(() => {
		dispatch(
			refreshAllAvailability(format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"))
		);
	}, [date, dispatch]);

	useEffect(() => {
		dispatch(
			refreshAvailability(
				selectedDriver,
				format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'")
			)
		);
	}, [date, dispatch, selectedDriver]);

	return (
		<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
			{/* Header Section */}
			<div className='flex justify-between items-center'>
				<h2 className='text-xl leading-none font-medium text-gray-900 '>
					Availability
				</h2>
			</div>

			{/* Date & Unavailable Button */}
			<div className='flex flex-wrap justify-start items-center mt-4 gap-3'>
				<Popover
					open={open}
					onOpenChange={setOpen}
				>
					<PopoverTrigger asChild>
						<button
							id='date'
							className={cn(
								'input data-[state=open]:border-primary',
								!date && 'text-muted-foreground'
							)}
							style={{ width: '13rem', marginTop: '16px' }}
						>
							<KeenIcon
								icon='calendar'
								className='-ms-0.5'
							/>
							{date ? format(date, 'LLL dd, y') : <span>Pick a date</span>}
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
							onSelect={handleDateSelect}
							numberOfMonths={1}
						/>
					</PopoverContent>
				</Popover>
				<div className='flex flex-col'>
					<label className='form-label'>Driver</label>
					<Select
						value={selectedDriver}
						onValueChange={(value) => setSelectedDriver(value)}
					>
						<SelectTrigger
							className=' w-32 hover:shadow-lg'
							size='sm'
							style={{ height: '40px' }}
						>
							<SelectValue placeholder='Select' />
						</SelectTrigger>
						<SelectContent className='w-36'>
							<SelectItem value={0}>All</SelectItem>
							{drivers?.length > 0 &&
								drivers?.map((driver) => (
									<>
										<SelectItem value={driver?.id}>
											{driver?.id} - {driver?.fullName}
										</SelectItem>
									</>
								))}
						</SelectContent>
					</Select>
				</div>

				<button
					className='btn btn-primary mt-4'
					onClick={() => setIsCustomModal(true)}
					disabled={selectedDriver === 0}
				>
					Custom
				</button>
				<button
					className='btn btn-primary mt-4'
					onClick={() => handleClick('srAmOnly')}
					disabled={selectedDriver === 0}
				>
					SR AM Only
				</button>
				<button
					className='btn btn-primary mt-4'
					onClick={() => handleClick('srPmOnly')}
					disabled={selectedDriver === 0}
				>
					SR PM Only
				</button>
				<button
					className='btn btn-primary mt-4'
					onClick={() => handleClick('srOnly')}
					disabled={selectedDriver === 0}
				>
					SR Only
				</button>
				<button
					className='btn btn-danger mt-4'
					onClick={() => handleClick('unavailableAllDay')}
					disabled={selectedDriver === 0}
				>
					UNAVAILABLE (ALL DAY)
				</button>
			</div>

			{/* Conditionally Show Form or Table */}

			{selectedDriver !== 0 && (
				<div className='overflow-x-auto mt-4'>
					<div className='mt-4 mb-5 p-4 rounded-md text-start'>
						Selected Drivers Availability
					</div>
					<SelectedAvailabilityTable
						selectedDate={date}
						selectedDriver={selectedDriver}
					/>
				</div>
			)}

			{/* No Availability Message */}
			<div className='mt-4 mb-5 py-4 px-1 rounded-md text-start'>
				All Drivers Availability
			</div>

			{/* Table */}
			<AvailabilityTable />

			{isCustomModal && (
				<CustomModal
					open={isCustomModal}
					onOpenChange={handleClose}
					selectedDate={date}
					selectedDriver={selectedDriver}
					checkExistingAvailability={checkExistingAvailability}
				/>
			)}
		</div>
	);
};

export { Availability };
