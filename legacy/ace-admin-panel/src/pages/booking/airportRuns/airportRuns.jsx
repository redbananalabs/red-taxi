/** @format */

import { useEffect, useMemo, useState } from 'react';
// import {
// 	Popover,
// 	PopoverContent,
// 	PopoverTrigger,
// } from '@/components/ui/popover';
// import { Calendar } from '@/components/ui/calendar';
// import { format } from 'date-fns';
// import { cn } from '@/lib/utils';
// import { KeenIcon } from '@/components';
import { Tablejourney } from './tablejourney';
import { useDispatch, useSelector } from 'react-redux';
import { refreshAirportRuns } from '../../../slices/bookingSlice';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';

const AirportRuns = () => {
	const dispatch = useDispatch();
	const { airportRuns } = useSelector((state) => state.booking);
	const [selectedOption, setSelectedOption] = useState('Last 1 Month');
	// const [date, setDate] = useState(new Date());

	const filteredData = useMemo(() => {
		return airportRuns || [];
	}, [airportRuns]);

	const month =
		selectedOption === 'Last 1 Month'
			? 1
			: selectedOption === 'Last 3 Months'
				? 3
				: selectedOption === 'Last 6 Months'
					? 6
					: selectedOption === 'Last 12 Months'
						? 12
						: 0;

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

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
				accessorKey: 'identifier',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md whitespace-nowrap`}>
						{row?.original?.identifier}
					</span>
				),
				meta: { headerClassName: 'w-32' },
			},
			{
				accessorKey: 'date',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Date</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{new Date(row.original.date).toLocaleDateString('en-GB')}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},

			{
				accessorKey: 'pickup',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Pickup</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row?.original?.pickup}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'destin',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Destination</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row?.original?.destin}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'price',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Price</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						£{row?.original?.price?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'w-18' },
			},
		],
		[]
	);

	useEffect(() => {
		dispatch(refreshAirportRuns(month));
	}, [dispatch, month]);

	return (
		<div className='max-w-[1850px] w-full mx-auto px-6 py-4'>
			{/* Header Section */}
			<div className='mb-4'>
				<h2 className='text-xl leading-none font-medium text-gray-900 '>
					Last Airport Journeys
				</h2>
				<h6 className='text-gray-600 dark:text-gray-600'>Select Period</h6>
			</div>

			{/* Date Picker */}
			{/* <div className='flex justify-between items-center mb-4'>
				<Popover>
					<PopoverTrigger asChild>
						<button className='input border-gray-300 bg-transparent w-48 py-2 px-3 rounded-md'>
							<KeenIcon
								icon='calendar'
								className='mr-2'
							/>
							{date ? format(date, 'LLL dd, y') : <span>Pick a date</span>}
						</button>
					</PopoverTrigger>
					<PopoverContent
						className='w-auto p-0 shadow-md'
						align='start'
					>
						<Calendar
							initialFocus
							mode='single'
							defaultMonth={date}
							selected={date}
							onSelect={setDate}
							numberOfMonths={1}
						/>
					</PopoverContent>
				</Popover>
			</div> */}

			{/* Tab Navigation */}
			<div className='flex border border-gray-300 dark:border-gray-300 rounded-md overflow-hidden'>
				{[
					'Last 1 Month',
					'Last 3 Months',
					'Last 6 Months',
					'Last 12 Months',
				].map((option) => (
					<button
						key={option}
						onClick={() => setSelectedOption(option)}
						className={`flex-1 py-2 text-center text-sm font-medium transition-all duration-300 ${
							selectedOption === option
								? 'text-blue-500 dark:text-blue-400 border-b-2 border-blue-500 dark:border-blue-400'
								: 'text-gray-700 dark:text-gray-700 hover:text-gray-900 dark:hover:text-gray-100'
						}`}
					>
						{option}
					</button>
				))}
			</div>

			{/* Table Section */}
			<div className='overflow-x-auto mt-6 border border-gray-200 dark:border-gray-200 rounded-md'>
				{filteredData?.length > 0 ? (
					<DataGrid
						columns={columns}
						data={filteredData}
						rowSelection={true}
						onRowSelectionChange={handleRowSelection}
						pagination={{ size: 10 }}
						sorting={[{ id: 'identifier', desc: false }]}
						layout={{ card: true }}
					/>
				) : (
					<div className='p-3 text-center text-gray-500 dark:text-gray-400'>
						No data available
					</div>
				)}
			</div>

			<Tablejourney month={month} />
		</div>
	);
};

export { AirportRuns };
