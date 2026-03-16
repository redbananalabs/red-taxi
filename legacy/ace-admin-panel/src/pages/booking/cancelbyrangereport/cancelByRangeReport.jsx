/** @format */
import { useEffect, useMemo, useState } from 'react';
import { Input } from '@/components/ui/input';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format, isBefore, startOfDay } from 'date-fns';
import { cn } from '@/lib/utils';
import { KeenIcon } from '@/components';
import { DataGrid, DataGridColumnHeader } from '@/components';
import { cancelReportByDateRange } from '../../../service/operations/bookingApi';
import toast from 'react-hot-toast';
import { formatMyDate } from '../../../utils/Date';

const CancelByRangeReport = () => {
	const [driverNumber, setDriverNumber] = useState(0);
	const [open, setOpen] = useState(false);
	const [data, setData] = useState([]);
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
				from: formatMyDate(dateRange?.from),
				to: formatMyDate(dateRange?.to),
				accountNo: driverNumber || 0,
			};

			const response = await cancelReportByDateRange(payload);
			console.log('cancel report ---', response);
			if (response.status === 'success') {
				toast.success('Reports Cancelled Successfully');
				const result = Object.keys(response)
					.filter((key) => key !== 'status')
					.map((key) => response[key]);
				setData(result);
			}
		} catch (error) {
			console.error('Error canceling reports by date range:', error);
			toast.error('Error cancelling bookings by date range');
		}
	};

	const today = startOfDay(new Date());

	const ColumnInputFilter = ({ column }) => {
		return (
			<Input
				placeholder='Filter...'
				value={column.getFilterValue() ?? ''}
				onChange={(event) => column.setFilterValue(event.target.value)}
				className='h-9 w-full max-w-40'
			/>
		);
	};

	const columns = useMemo(
		() => [
			{
				accessorKey: 'id',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Booking #</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
						className={`justify-center`}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div
						className={`p-2 rounded-md text-center`}
						// style={{
						// 	color: isLightColor(row.original?.colorCode) ? 'black' : 'white',
						// }}
					>
						{row.original.id}
					</div>
				),
				meta: { headerClassName: 'w-20 text-center' },
			},
			{
				accessorKey: 'pickupDateTime',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Pickup Date/Time</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
						className={` justify-center`}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div
						className={`p-2 rounded-md text-center text-gray-700`}
						// style={{
						// 	color: isLightColor(row.original?.colorCode) ? 'black' : 'white',
						// }}
					>
						{row.original.pickupDateTime
							? new Date(row.original.pickupDateTime).toLocaleDateString(
									'en-GB'
								) +
								' ' +
								row.original.pickupDateTime
									.split('T')[1]
									?.split('.')[0]
									?.slice(0, 5)
							: '-'}
					</div>
				),
				meta: { headerClassName: 'min-w-[200px] text-center' },
			},
			{
				accessorKey: 'passengerName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Passenger Name</span>
						column={column}
						className={` justify-center`}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div
						className={`p-2 rounded-md text-center text-gray-700`}
						// style={{
						// 	color: isLightColor(row.original?.colorCode) ? 'black' : 'white',
						// }}
					>
						{row.original.passengerName}
					</div>
				),
				meta: { headerClassName: 'min-w-[180px] text-center' },
			},
		],
		[]
	);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	const Toolbar = () => {
		// const [searchInput, setSearchInput] = useState('');
		return (
			<div className='card-header flex-wrap gap-2 border-b-0 px-5'>
				<div className='flex flex-wrap gap-2 lg:gap-5'>
					{/* <div className='flex'>
						<label className='input input-sm'>
							<input
								type='text'
								placeholder='Search drivers'
								value={searchInput}
								onChange={(e) => setSearchInput(e.target.value)}
							/>
						</label>
					</div> */}
					{/* <div className='flex flex-wrap gap-2.5'>
						<Select defaultValue='all'>
							<SelectTrigger
								className='w-28'
								size='sm'
							>
								<SelectValue placeholder='Filter' />
							</SelectTrigger>
							<SelectContent className='w-32'>
								<SelectItem value='all'>All</SelectItem>
								<SelectItem value='morning'>Morning Shift</SelectItem>
								<SelectItem value='evening'>Evening Shift</SelectItem>
							</SelectContent>
						</Select>
					</div> */}
				</div>
			</div>
		);
	};

	return (
		<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
			{/* Header Section */}
			<h2 className='text-xl leading-none font-medium text-gray-900 '>
				Cancel Report By Date Range
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
								CANCEL REPORTS
							</button>
						</div>
					</div>
				</div>
			</div>

			<div className='mt-4 mb-5 py-4 px-1 rounded-md text-start'>Bookings</div>

			<DataGrid
				columns={columns}
				data={data}
				rowSelection={true}
				onRowSelectionChange={handleRowSelection}
				pagination={{ size: 10 }}
				sorting={[{ id: 'userId', desc: false }]}
				toolbar={<Toolbar />}
				layout={{ card: true }}
				applyRowColor={true}
			/>
		</div>
	);
};

export { CancelByRangeReport };
