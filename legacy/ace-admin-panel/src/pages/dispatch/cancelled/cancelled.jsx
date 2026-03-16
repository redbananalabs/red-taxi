/** @format */

import { Fragment, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import { KeenIcon } from '@/components';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
// import { Container } from '@/components/container';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';
function Cancelled() {
	const [searchInput, setSearchInput] = useState('');
	const [date, setDate] = useState(new Date());
	const driversData = useMemo(
		() => [
			{
				driver: 10,
				name: 'Alan Waistell',
				details: '00:00 - 23:59',
				color: 'bg-yellow-500',
			},
			{
				driver: 13,
				name: 'Lee Harrison',
				details: '00:00 - 23:59',
				color: 'bg-blue-300',
			},
			{
				driver: 30,
				name: 'Richard Elgar',
				details: '07:30 - 17:30',
				color: 'bg-red-400',
			},
			{
				driver: 16,
				name: 'James Owen',
				details: '07:00 - 17:00 (+/-)',
				color: 'bg-gray-700 text-white font-bold',
			},
			{
				driver: 14,
				name: 'Andrew James',
				details: '07:30 - 17:30',
				color: 'bg-green-500',
			},
			{
				driver: 4,
				name: 'Paul Barber',
				details: '07:00 - 18:00',
				color: 'bg-green-400',
			},
			{
				driver: 12,
				name: 'Chris Gray',
				details: '07:00 - 16:00',
				color: 'bg-blue-700 text-white font-bold',
			},
			{
				driver: 5,
				name: 'Mark Phillips',
				details: '07:00 - 16:30',
				color: 'bg-pink-500',
			},
			{
				driver: 11,
				name: 'Nigel Reynolds',
				details: '07:00 - 17:00',
				color: 'bg-gray-400',
			},
			{
				driver: 2,
				name: 'Kate Hall',
				details: '07:00 - 22:30',
				color: 'bg-purple-400',
			},
			{
				driver: 8,
				name: 'Peter Farrell',
				details: '08:20 - 10:00',
				color: 'bg-purple-200',
			},
			{
				driver: 7,
				name: 'Caroline Stimson',
				details: '11:00 - 17:00',
				color: 'bg-red-200',
			},
			{
				driver: 6,
				name: 'Rob Holton',
				details: '07:00 - 22:00',
				color: 'bg-blue-400',
			},
			{
				driver: 31,
				name: 'Bill Wood',
				details: '16:00 - 17:00',
				color: 'bg-red-300',
			},
			{
				driver: 26,
				name: 'Charles Farnham',
				details: '07:00 - 17:00 (all routes)',
				color: 'bg-blue-800 text-white font-bold',
			},
			{
				driver: 18,
				name: 'Jean Williams',
				details: '07:30 - 09:15 (AM SR)',
				color: 'bg-yellow-400',
			},
		],
		[]
	);

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
				accessorKey: 'bookingId',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='# id'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.bookingId}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'date',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Date'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.date}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'pickUp',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Pick Up'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.pickUp}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'destination',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Destination'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.destination}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'passenger',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Passenger'
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>{row.original.passenger}</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'pax',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Pax'
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>{row.original.pax}</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'cancelledBy',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Cancelled By'
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.cancelledBy}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},

			{
				accessorKey: 'lastUpdated',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Last Updated'
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>{row.original.lastUpdated}</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'restore',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Restore'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.restore}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
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
	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {'23'} Cancelled Jobs{' '}
						</ToolbarDescription>
					</ToolbarHeading>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							<div className='card-header flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'>
									<div className='flex'>
										<label
											className='input input-sm'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Jobs'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div>
									<div className='flex flex-wrap items-center gap-2.5'>
										<Popover>
											<PopoverTrigger asChild>
												<button
													id='date'
													className={cn(
														'input data-[state=open]:border-primary',
														!date && 'text-muted-foreground'
													)}
													style={{ width: '13rem' }}
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

										<Select defaultValue='all'>
											<SelectTrigger
												className='w-28'
												size='sm'
												style={{ height: '40px' }}
											>
												<SelectValue placeholder='Select' />
											</SelectTrigger>
											<SelectContent className='w-32'>
												<SelectItem value='all'>All</SelectItem>
												<SelectItem value='cash'>Cash</SelectItem>
												<SelectItem value='card'>Card</SelectItem>
												<SelectItem value='account'>Account</SelectItem>
												<SelectItem value='rank'>Rank</SelectItem>
											</SelectContent>
										</Select>

										<button
											className='btn btn-sm btn-outline btn-primary'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' /> Search
										</button>
									</div>
								</div>
							</div>
							<div className='card-body'>
								<DataGrid
									columns={columns}
									data={driversData}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'driver', desc: false }]}
									layout={{ card: true }}
								/>
							</div>
						</div>
					</div>
				</div>
			</div>
		</Fragment>
	);
}

export { Cancelled };
