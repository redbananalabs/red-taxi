/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarActions,
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
import { addDays } from 'date-fns';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import { AddAccounts } from '../addAccounts';
import { EditAccounts } from '../editAccounts';
import { DeleteAccounts } from '../deleteAccounts';
import { setAccount } from '../../../../slices/accountSlice';
import { Link } from 'react-router-dom';
import { refreshAllDrivers } from '../../../../slices/driverSlice';
function SearchBooking() {
	const dispatch = useDispatch();
	const { drivers } = useSelector((state) => state.driver);
	const [selectedDriver, setSelectedDriver] = useState(0);
	const [searchInput, setSearchInput] = useState('');
	const [createAccountModal, setAccountModal] = useState(false);
	const [editAccountModal, setEditAccountModal] = useState(false);
	const [deleteAccountModal, setDeleteAccountModal] = useState(false);
	const [date, setDate] = useState({
		from: new Date(),
		to: addDays(new Date(), 20),
	});
	const driversData = useMemo(
		() => [
			{
				driver: 10,
				name: 'Alan',
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
				name: 'Rob',
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
				name: 'Charles',
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
				accessorKey: '#',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='#'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.accountId}</span>
				),
				meta: { headerClassName: 'w-1' },
			},
			{
				accessorKey: 'Date',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Date'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.date}</span>
				),
				meta: { headerClassName: 'w-2' },
			},
			{
				accessorKey: 'Destination',
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
						{row.original.address}
					</span>
				),
				meta: { headerClassName: 'min-w-[50px]' },
			},
			{
				accessorKey: '*',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='*'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.postcode}
					</span>
				),
				meta: { headerClassName: 'w-5' },
			},
			{
				accessorKey: 'Passenger',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Passenger'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.email}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px] w-5' },
			},
			{
				accessorKey: 'Pax',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Pax'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.email}
					</span>
				),
				meta: { headerClassName: 'w-5' },
			},
			{
				accessorKey: 'Phone',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Phone'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.email}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'driver',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Driver £'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.email}
					</span>
				),
				meta: { headerClassName: 'w-5' },
			},
			{
				accessorKey: 'Acc',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Acc £'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.email}
					</span>
				),
				meta: { headerClassName: 'w-5' },
			},
			{
				accessorKey: 'M',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='M £'
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.email}
					</span>
				),
				meta: { headerClassName: 'w-5' },
			},
			{
				accessorKey: 'action',
				header: ({ column }) => (
					<DataGridColumnHeader
						title='Actions'
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div className='w-full flex justify-start items-center gap-2'>
						<button
							className='rounded-full px-2 py-2  w-8 h-8 flex justify-center items-center hover:bg-red-100 group'
							onClick={() => {
								dispatch(setAccount(row));
								setEditAccountModal(true);
							}}
						>
							<KeenIcon
								icon='pencil'
								className='group-hover:text-red-600'
							/>
						</button>
						<button
							className='rounded-full px-2 py-2  w-8 h-8 flex justify-center items-center hover:bg-red-100 group'
							onClick={() => {
								dispatch(setAccount(row));
								setDeleteAccountModal(true);
							}}
						>
							<KeenIcon
								icon='trash'
								className='group-hover:text-red-600'
							/>
						</button>
					</div>
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

	const handleClose = () => {
		if (createAccountModal) {
			setAccountModal(false);
			return;
		}
		if (editAccountModal) {
			setEditAccountModal(false);
			return;
		}

		if (deleteAccountModal) {
			setDeleteAccountModal(false);
			return;
		}
	};

	useEffect(() => {
		dispatch(refreshAllDrivers());
	}, [dispatch]);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>Showing {'23'} Accounts </ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<Link to='/bookings/booking-dispatch'>
							<button
								className='btn btn-sm btn-primary px-4 py-4'
								// onClick={() => setAccountModal(true)}
							>
								+ Create New
							</button>
						</Link>
					</ToolbarActions>
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
												placeholder='Search Booking'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div>
									<div className='flex items-center gap-2.5'>
										<Popover>
											<PopoverTrigger asChild>
												<button
													id='date'
													className={cn(
														'btn btn-sm btn-light data-[state=open]:bg-light-active',
														!date && 'text-gray-400'
													)}
													style={{ height: '40px' }}
												>
													<KeenIcon
														icon='calendar'
														className='me-0.5'
													/>
													{date?.from ? (
														date.to ? (
															<>
																{format(date.from, 'LLL dd, y')} -{' '}
																{format(date.to, 'LLL dd, y')}
															</>
														) : (
															format(date.from, 'LLL dd, y')
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
													initialFocus
													mode='range'
													defaultMonth={date?.from}
													selected={date}
													onSelect={setDate}
													numberOfMonths={2}
												/>
											</PopoverContent>
										</Popover>
									</div>
									<Select
										value={selectedDriver}
										onValueChange={(value) => setSelectedDriver(value)}
									>
										<SelectTrigger
											className='w-28 hover:shadow-lg'
											size='sm'
											style={{ height: '40px' }}
										>
											<SelectValue placeholder='Select' />
										</SelectTrigger>
										<SelectContent className='w-32'>
											<SelectItem value={0}>All</SelectItem>
											{drivers?.length > 0 &&
												drivers?.map((driver) => (
													<>
														<SelectItem value={driver?.id}>
															{driver?.fullName}
														</SelectItem>
													</>
												))}
										</SelectContent>
									</Select>

									<Select defaultValue='all'>
										<SelectTrigger
											className='w-28'
											size='sm'
											style={{ height: '40px' }}
										>
											<SelectValue placeholder='Select Priced' />
										</SelectTrigger>
										<SelectContent className='w-32'>
											<SelectItem value='all'>All</SelectItem>
											<SelectItem value='cash'>Without Price </SelectItem>
											<SelectItem value='card'>Price</SelectItem>
										</SelectContent>
									</Select>

									<Select defaultValue='all'>
										<SelectTrigger
											className='w-28'
											size='sm'
											style={{ height: '40px' }}
										>
											<SelectValue placeholder='Select Scope' />
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
			{createAccountModal && (
				<AddAccounts
					open={createAccountModal}
					onOpenChange={handleClose}
				/>
			)}
			{editAccountModal && (
				<EditAccounts
					open={editAccountModal}
					onOpenChange={handleClose}
				/>
			)}
			{deleteAccountModal && (
				<DeleteAccounts
					open={deleteAccountModal}
					onOpenChange={handleClose}
				/>
			)}
		</Fragment>
	);
}

export { SearchBooking };
