/** @format */
import { useEffect, useState } from 'react';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format, isBefore, startOfDay } from 'date-fns';
import { cn } from '@/lib/utils';
import { KeenIcon } from '@/components';
import { cancelBookingByDateRange } from '../../../service/operations/bookingApi';
import toast from 'react-hot-toast';

const CancelByRange = () => {
	const [driverNumber, setDriverNumber] = useState(0);
	const [open, setOpen] = useState(false);
	const [dateRange, setDateRange] = useState({
		from: new Date(), // January 31, 2025
		to: new Date(), // Same default date
	});

	const [tempRange, setTempRange] = useState(dateRange);

	useEffect(() => {
		if (open) {
			setTempRange({ from: null, to: null });
		}
	}, [open]);

	const handleDateSelect = (range) => {
		setTempRange(range);
		if (range?.from && range?.to) {
			setDateRange(range);
			setOpen(false);
		}
	};

	const handleCancelButton = async () => {
		try {
			const payload = {
				from: dateRange?.from,
				to: dateRange?.to,
				accountNo: driverNumber || 0,
			};

			const response = await cancelBookingByDateRange(payload);
			if (response.status === 'success') {
				toast.success('Bookings Cancelled Successfully');
			}
		} catch (error) {
			console.error('Error canceling bookings by date range:', error);
			toast.error('Error cancelling bookings by date range');
		}
	};

	const today = startOfDay(new Date());

	return (
		<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
			{/* Header Section */}
			<h2 className='text-xl leading-none font-medium text-gray-900 '>
				Cancel Bookings By Date Range
			</h2>

			{/* Filter Inputs */}
			<div className='flex flex-wrap items-center gap-4 mt-4'>
				{/* Driver Number Selection */}

				<div className='flex flex-col gap-1'>
					<label className='form-label text-gray-900'>Account Number</label>
					<label className='input'>
						<input
							type='number'
							autoComplete='off'
							name='driverNumber'
							placeholder='Enter Number'
							value={driverNumber}
							onChange={(e) => setDriverNumber(e.target.value)}
						/>
					</label>
				</div>

				{/* Date Picker */}
				<div className='flex flex-col gap-1'>
					{/* Added Label for Date Picker */}
					<label
						htmlFor='date'
						className='form-label text-gray-900'
					>
						Date Range
					</label>

					<div className='flex items-center gap-2 relative'>
						<Popover
							open={open}
							onOpenChange={setOpen}
						>
							<PopoverTrigger asChild>
								<button
									className={cn(
										'btn btn-sm btn-light data-[state=open]:bg-light-active',
										!dateRange && 'text-gray-400'
									)}
									style={{ height: '40px' }}
								>
									<KeenIcon
										icon='calendar'
										className='me-0.5'
									/>
									{dateRange?.from ? (
										dateRange.to ? (
											<>
												{format(dateRange.from, 'LLL dd, y')} -{' '}
												{format(dateRange.to, 'LLL dd, y')}
											</>
										) : (
											format(dateRange.from, 'LLL dd, y')
										)
									) : (
										<span>Pick a date range</span>
									)}
								</button>
							</PopoverTrigger>

							<PopoverContent
								className='w-auto p-0'
								align='end'
							>
								<Calendar
									mode='range'
									defaultMonth={dateRange?.from}
									selected={tempRange}
									onSelect={handleDateSelect}
									numberOfMonths={2}
									initialFocus
									disabled={(date) => isBefore(date, today)}
								/>
							</PopoverContent>
						</Popover>

						{/* Cancel Jobs Button */}
						<div className='flex justify-end'>
							<button
								type='submit'
								className='btn btn-sm btn-primary px-4 py-4'
								onClick={handleCancelButton}
							>
								CANCEL JOBS
							</button>
						</div>
					</div>
				</div>
			</div>
		</div>
	);
};

export { CancelByRange };
