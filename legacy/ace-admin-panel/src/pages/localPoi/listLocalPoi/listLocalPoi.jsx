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
// import {
// 	Select,
// 	SelectContent,
// 	SelectItem,
// 	SelectTrigger,
// 	SelectValue,
// } from '@/components/ui/select';
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
import { AddLocalPoi } from '../addLocalPoi';
import { EditLocalPoi } from '../editLocalPoi';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshAllLocalPOIS,
	setLocalPOI,
} from '../../../slices/localPOISlice';
import { DeleteLocalPoi } from '../deleteLocalPoi';
function ListLocalPoi() {
	const dispatch = useDispatch();
	const { localPOIs } = useSelector((state) => state.localPoi);
	const [searchInput, setSearchInput] = useState('');
	const [createLocalPoiModal, setCreateLocalPoiModal] = useState(false);
	const [editLocalPoiModal, setEditLocalPoiModal] = useState(false);
	const [deleteLocalPoiModal, setDeleteLocalPoiModal] = useState(false);
	// const [date, setDate] = useState(new Date());

	useEffect(() => {
		dispatch(refreshAllLocalPOIS());
	}, [dispatch]);

	const filterLocalPois = localPOIs?.filter(
		(poi) =>
			poi?.name?.toLowerCase().includes(searchInput.toLowerCase()) ||
			poi?.address.toLowerCase().includes(searchInput.toLowerCase()) ||
			poi?.postcode.toLowerCase().includes(searchInput.toLowerCase())
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

	const getLocalPoiType = (type) => {
		switch (type) {
			case 0:
				return 'Not set';
			case 1:
				return 'Train Station';
			case 2:
				return 'Supermarket';
			case 3:
				return 'House';
			case 4:
				return 'Pub';
			case 5:
				return 'Restaurant';
			case 6:
				return 'Doctors';
			case 7:
				return 'Airport';
			case 8:
				return 'Ferry Port';
			case 9:
				return 'Hotel';
			case 10:
				return 'School';
			case 11:
				return 'Hospital';
			case 12:
				return 'Wedding Venue';
			case 13:
				return 'Miscellaneous';
			case 14:
				return 'Shopping Center';
			default:
				return '';
		}
	};

	const columns = useMemo(
		() => [
			{
				accessorKey: 'name',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Name</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>
						{row.original.name ? row.original.name : '-'}
					</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'postcode',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Postcode</span>
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
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'address',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Address</span>
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
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'type',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Type</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{getLocalPoiType(row.original.type)}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
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
								dispatch(setLocalPOI(row.original));
								setEditLocalPoiModal(true);
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
								dispatch(setLocalPOI(row.original));
								setDeleteLocalPoiModal(true);
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
		if (createLocalPoiModal) {
			setCreateLocalPoiModal(false);
			return;
		}
		if (editLocalPoiModal) {
			setEditLocalPoiModal(false);
			return;
		}

		if (deleteLocalPoiModal) {
			setDeleteLocalPoiModal(false);
			return;
		}
	};

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {localPOIs.length} Local POIs{' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<button
							className='btn btn-sm btn-primary px-4 py-4'
							onClick={() => setCreateLocalPoiModal(true)}
						>
							Add New POI
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
									<div className='flex'>
										<label
											className='input input-sm'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Local POIs'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div>
									{/* <div className='flex items-center gap-2.5'>
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
									</div> */}
								</div>
							</div>
							<div className='card-body'>
								<DataGrid
									columns={columns}
									data={filterLocalPois}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'name', desc: false }]}
									layout={{ card: true }}
								/>
							</div>
						</div>
					</div>
				</div>
			</div>
			{createLocalPoiModal && (
				<AddLocalPoi
					open={createLocalPoiModal}
					onOpenChange={handleClose}
				/>
			)}
			{editLocalPoiModal && (
				<EditLocalPoi
					open={editLocalPoiModal}
					onOpenChange={handleClose}
				/>
			)}
			{deleteLocalPoiModal && (
				<DeleteLocalPoi
					open={deleteLocalPoiModal}
					onOpenChange={handleClose}
				/>
			)}
		</Fragment>
	);
}

export { ListLocalPoi };
