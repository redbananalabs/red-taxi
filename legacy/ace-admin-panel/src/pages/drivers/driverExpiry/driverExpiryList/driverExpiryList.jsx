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
// import {
// 	Popover,
// 	PopoverContent,
// 	PopoverTrigger,
// } from '@/components/ui/popover';
// import { Calendar } from '@/components/ui/calendar';
// import { format } from 'date-fns';
// import { cn } from '@/lib/utils';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshAllDrivers,
	refreshAllDriversExpiry,
	setDriversExpiry,
} from '../../../../slices/driverSlice';
import { UpdateDriverExpiry } from '../updateExpiry';
import isLightColor from '../../../../utils/isLight';
import { AddDriverExpiry } from '../addExpiry';
function DriverExpiryList() {
	const dispatch = useDispatch();
	const { driversExpiryList, drivers } = useSelector((state) => state.driver);
	const [selectedDriver, setSelectedDriver] = useState(0);
	const [addDriverModal, setAddDriverModal] = useState(false);
	const [editDriverModal, setEditDriverModal] = useState(false);
	const [selectedType, setSelectedType] = useState('9');
	const [selectedExpiryType, setSelectedExpiryType] = useState('all');
	// const [deleteDriverModal, setDeleteDriverModal] = useState(false);
	// const [date, setDate] = useState(new Date());

	const sortedDriversExpiryList = [...driversExpiryList].sort((a, b) => {
		// Get today's date for comparison
		const today = new Date();
		today.setHours(0, 0, 0, 0);

		// Parse expiry dates, default to far future if invalid/null
		const expiryA = a.expiryDate
			? new Date(a.expiryDate)
			: new Date('9999-12-31');
		const expiryB = b.expiryDate
			? new Date(b.expiryDate)
			: new Date('9999-12-31');
		expiryA.setHours(0, 0, 0, 0);
		expiryB.setHours(0, 0, 0, 0);

		// Sort: Expired (past) first, then expiring (future)
		return expiryA - expiryB;
	});

	const filteredDriver = sortedDriversExpiryList?.filter((driver) => {
		// Ensure driver exists before filtering
		if (!driver) return false;

		// Get today's date and reset time for accurate comparison
		const today = new Date();
		today.setHours(0, 0, 0, 0);

		// Ensure expiryDate is valid and parsed correctly
		const expiryDate = driver?.expiryDate ? new Date(driver.expiryDate) : null;
		if (expiryDate) expiryDate.setHours(0, 0, 0, 0); // Normalize time

		// Check if driver filter should be applied (if NOT 'all', apply filtering)
		const isMatch =
			selectedDriver === 0 ||
			selectedDriver === 'all' ||
			driver?.userId === selectedDriver;

		// Check if document type filter should be applied (if NOT 'all', apply filtering)
		const isTypeMatch =
			selectedType === '' ||
			selectedType === '9' ||
			selectedType === 'all' ||
			String(driver?.documentType) === selectedType;

		// Check expiry filter
		let isExpiryMatch = true; // Default to true in case no expiry filter is selected
		if (expiryDate) {
			if (selectedExpiryType === 'expiring') {
				isExpiryMatch = expiryDate > today; // Expiring (expiryDate is in the future)
			} else if (selectedExpiryType === 'expired') {
				isExpiryMatch = expiryDate < today; // Expired (expiryDate is in the past)
			}
		}

		// Apply filters independently using OR (||) instead of AND (&&)
		return (
			(selectedDriver === 'all' || isMatch) &&
			(selectedType === 'all' || isTypeMatch) &&
			(selectedExpiryType === 'all' || isExpiryMatch)
		);
	});

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

	const docTypeName = {
		0: 'Insurance',
		1: 'MOT',
		2: 'DBS',
		3: 'VehicleBadge',
		4: 'DriverLicense',
		5: 'SafeGuarding',
		6: 'FirstAidCert',
		7: 'DriverPhoto',
		8: '-',
	};

	const doctypeColor = {
		0: 'bg-blue-500', // Insurance (Primary)
		1: 'bg-gray-500', // MOT (Secondary)
		2: 'bg-green-600', // DBS (Success)
		3: 'bg-red-500', // Vehicle Badge (Danger)
		4: 'bg-yellow-600', // Driver License (Warning)
		5: 'bg-cyan-400', // Safe Guarding (Info)
		6: 'bg-purple-500', // First Aid Cert
		7: 'bg-pink-500', // Driver Photo
		8: 'bg-inherit', // Default
	};

	const columns = useMemo(
		() => [
			{
				accessorKey: 'userId',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver #</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span
						className={`p-2 rounded-md whitespace-nowrap`}
						style={{
							backgroundColor: row.original.colorCode,
							color: isLightColor(row?.original?.colorCode) ? 'black' : 'white',
						}}
					>
						{row.original.userId} - {row.original.fullname}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'documentType',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Type</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span
						className={`font-semibold px-3 py-1 rounded-full ${doctypeColor[row.original.documentType]} ${isLightColor(doctypeColor[row.original.documentType]) ? 'text-black' : 'text-white'}`}
					>
						{docTypeName[row.original.documentType]}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'expiryDate',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Expiry Date</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => {
					const expiryDate = new Date(row.original.expiryDate);
					const today = new Date();
					today.setHours(0, 0, 0, 0); // Reset time for accurate comparison

					const daysDiff = Math.floor(
						(expiryDate - today) / (1000 * 60 * 60 * 24)
					);

					let bgColor = ''; // Default color
					if (daysDiff < -7) {
						bgColor = 'text-orange-500'; // Expired more than 7 days ago
					} else if (daysDiff < -1) {
						bgColor = 'text-red-600'; // Expired within the last 1-7 days
					} else {
						bgColor = 'text-black';
					}
					return (
						<span
							className={`p-2 rounded-md whitespace-nowrap bg-white ${bgColor}  font-semibold`}
						>
							{new Date(
								row.original.expiryDate?.split('T')[0]
							)?.toLocaleDateString('en-GB')}{' '}
							{row.original.expiryDate
								?.split('T')[1]
								.split('.')[0]
								?.slice(0, 5)}
						</span>
					);
				},
				meta: { headerClassName: 'w-25' },
			},
			// {
			// 	accessorKey: 'lastUpdatedOn',
			// 	header: ({ column }) => (
			// 		<DataGridColumnHeader
			// 			title=<span className='font-bold'>Last Updated On</span>
			// 			filter={<ColumnInputFilter column={column} />}
			// 			column={column}
			// 		/>
			// 	),
			// 	enableSorting: true,
			// 	cell: ({ row }) => (
			// 		<span className={`p-2 rounded-md whitespace-nowrap`}>
			// 			{new Date(
			// 				row.original.lastUpdatedOn?.split('T')[0]
			// 			)?.toLocaleDateString('en-GB')}{' '}
			// 			{row.original.lastUpdatedOn
			// 				?.split('T')[1]
			// 				.split('.')[0]
			// 				?.slice(0, 5)}
			// 		</span>
			// 	),
			// 	meta: { headerClassName: 'w-25' },
			// },
			// {
			// 	accessorKey: 'colorRGB',
			// 	header: ({ column }) => (
			// 		<DataGridColumnHeader
			// 			title=<span className='font-bold'>Color</span>
			// 			filter={<ColumnInputFilter column={column} />}
			// 			column={column}
			// 		/>
			// 	),
			// 	enableSorting: true,
			// 	cell: ({ row }) => (
			// 		<span
			// 			className={`font-medium p-2 rounded-md ${isLightColor(row.original.colorRGB) ? 'text-black' : 'text-white'}`}
			// 			style={{ backgroundColor: row.original.colorRGB }}
			// 		>
			// 			{row.original.colorRGB}
			// 		</span>
			// 	),
			// 	meta: { headerClassName: 'w-20' },
			// },
			// {
			// 	accessorKey: 'fullName',
			// 	header: ({ column }) => (
			// 		<DataGridColumnHeader
			// 			title=<span className='font-bold'>Full Name</span>
			// 			filter={<ColumnInputFilter column={column} />}
			// 			column={column}
			// 		/>
			// 	),
			// 	enableSorting: true,
			// 	cell: ({ row }) => (
			// 		<span className={`p-2 rounded-md whitespace-nowrap`}>
			// 			{row.original.fullName}
			// 		</span>
			// 	),
			// 	meta: { headerClassName: 'w-25' },
			// },
			// {
			// 	accessorKey: 'phoneNumber',
			// 	header: ({ column }) => (
			// 		<DataGridColumnHeader
			// 			title=<span className='font-bold'>Phone Number</span>
			// 			filter={<ColumnInputFilter column={column} />}
			// 			column={column}
			// 		/>
			// 	),
			// 	enableSorting: true,
			// 	cell: ({ row }) => (
			// 		<span className={`font-medium ${row.original.color}`}>
			// 			{row.original.phoneNumber}
			// 		</span>
			// 	),
			// 	meta: { headerClassName: 'w-20' },
			// },
			// {
			// 	accessorKey: 'role',
			// 	header: ({ column }) => (
			// 		<DataGridColumnHeader
			// 			title=<span className='font-bold'>Role</span>
			// 			filter={<ColumnInputFilter column={column} />}
			// 			column={column}
			// 		/>
			// 	),
			// 	enableSorting: true,
			// 	cell: ({ row }) => (
			// 		<span className={`font-medium ${row.original.color}`}>
			// 			{row.original.role === 1
			// 				? 'Admin'
			// 				: row.original.role === 2
			// 					? 'User'
			// 					: 'Driver'}
			// 		</span>
			// 	),
			// 	meta: { headerClassName: 'w-20' },
			// },
			{
				accessorKey: 'action',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Actions</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div className='w-full flex justify-start items-center gap-2'>
						<button
							className='rounded-full px-2 py-2  w-8 h-8 flex justify-center items-center hover:bg-red-100 group'
							onClick={() => {
								dispatch(setDriversExpiry(row.original));
								setEditDriverModal(true);
							}}
						>
							<KeenIcon
								icon='pencil'
								className='group-hover:text-red-600'
							/>
						</button>
						{/* <button
							className='rounded-full px-2 py-2  w-8 h-8 flex justify-center items-center hover:bg-red-100 group'
							onClick={() => {
								dispatch(setDriver(row.original));
								setDeleteDriverModal(true);
							}}
						>
							<KeenIcon
								icon='trash'
								className='group-hover:text-red-600'
							/>
						</button> */}
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
		if (editDriverModal) {
			setEditDriverModal(false);
			return;
		}

		if (addDriverModal) {
			setAddDriverModal(false);
			return;
		}
	};

	useEffect(() => {
		dispatch(refreshAllDrivers());
		dispatch(refreshAllDriversExpiry());
	}, [dispatch]);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {driversExpiryList?.length} Expiry&apos;s{' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<button
							className='btn btn-sm btn-primary px-4 py-4'
							onClick={() => setAddDriverModal(true)}
						>
							Add New Expiry
						</button>
					</ToolbarActions>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							<div className='card-header flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'>
									{/* <div className='flex'>
										<label
											className='input input-sm'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Drivers'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div> */}
									<div className='flex items-center gap-2.5'>
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

										<div className='flex flex-col'>
											<label className='form-label'>Doc Type</label>
											<Select
												value={selectedType}
												onValueChange={(value) => setSelectedType(value)}
											>
												<SelectTrigger
													className='w-32'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-36'>
													<SelectItem value='9'>All</SelectItem>
													<SelectItem value='0'>Insurance</SelectItem>
													<SelectItem value='1'>MOT</SelectItem>
													<SelectItem value='2'>DBS</SelectItem>
													<SelectItem value='3'>VehicleBadge</SelectItem>
													<SelectItem value='4'>DriverLicense</SelectItem>
													<SelectItem value='5'>SafeGuarding</SelectItem>
													<SelectItem value='6'>FirstAidCert</SelectItem>
													<SelectItem value='7'>DriverPhoto</SelectItem>
												</SelectContent>
											</Select>
										</div>

										<div className='flex flex-col'>
											<label className='form-label'>Type</label>
											<Select
												value={selectedExpiryType}
												onValueChange={(value) => setSelectedExpiryType(value)}
											>
												<SelectTrigger
													className='w-32'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-36'>
													<SelectItem value='all'>All</SelectItem>
													<SelectItem value='expiring'>Expiring</SelectItem>
													<SelectItem value='expired'>Expired</SelectItem>
												</SelectContent>
											</Select>
										</div>

										{/* <Popover>
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
										</Popover> */}

										{/* <button
											className='btn btn-sm btn-outline btn-primary'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' /> Search
										</button> */}
									</div>
								</div>
							</div>
							<div className='card-body'>
								<DataGrid
									columns={columns}
									data={filteredDriver}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'userId', desc: false }]}
									layout={{ card: true }}
									applyRowColor={true}
								/>
							</div>
						</div>
					</div>
				</div>
			</div>

			{editDriverModal && (
				<UpdateDriverExpiry
					open={editDriverModal}
					onOpenChange={handleClose}
				/>
			)}
			{addDriverModal && (
				<AddDriverExpiry
					open={addDriverModal}
					onOpenChange={handleClose}
				/>
			)}
			{/* {deleteDriverModal && (
				<DeleteDriver
					open={deleteDriverModal}
					onOpenChange={handleClose}
				/>
			)} */}
		</Fragment>
	);
}

export { DriverExpiryList };
