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
import { useDispatch, useSelector } from 'react-redux';
// import { DeleteLocalPoi } from '../deleteLocalPoi';
import {
	refreshAllAccountTariffs,
	setAccountTariff,
} from '../../../slices/tariffsSlice';
import { AddAccountTariff } from '../addAccountTariffs';
import { EditAccountTariff } from '../editAccountTariffs';
function ListAccountTariffs() {
	const dispatch = useDispatch();
	const { accountTariffs } = useSelector((state) => state.tariff);
	const [searchInput, setSearchInput] = useState('');
	const [createAccountTariffModal, setCreateAccountTariffModal] =
		useState(false);
	const [editAccountTariffModal, setEditAccountTariffModal] = useState(false);
	// const [deleteLocalPoiModal, setDeleteLocalPoiModal] = useState(false);
	// const [date, setDate] = useState(new Date());

	console.log('account tariffs---', accountTariffs);

	useEffect(() => {
		dispatch(refreshAllAccountTariffs());
	}, [dispatch]);

	const filterLocalPois = accountTariffs?.filter((tariffs) =>
		tariffs?.name?.toLowerCase().includes(searchInput.toLowerCase())
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
				meta: { headerClassName: 'w-30' },
			},
			{
				accessorKey: 'accountInitialCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Account Initial Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original?.accountInitialCharge?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'driverInitialCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver Initial Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original?.driverInitialCharge?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'accountFirstMileCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Account First Mile Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original?.accountFirstMileCharge?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'driverFirstMileCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver First Mile Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original?.driverFirstMileCharge?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'accountAdditionalMileCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>
							Account Additional Mile Charge
						</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original?.accountAdditionalMileCharge?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'driverAdditionalMileCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>
							Driver Additional Mile Charge
						</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original?.driverAdditionalMileCharge?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
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
								dispatch(setAccountTariff(row.original));
								setEditAccountTariffModal(true);
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
								dispatch(setAccountTariff(row.original));
								setDeleteLocalPoiModal(true);
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
		if (createAccountTariffModal) {
			setCreateAccountTariffModal(false);
			return;
		}
		if (editAccountTariffModal) {
			setEditAccountTariffModal(false);
			return;
		}

		// if (deleteLocalPoiModal) {
		// 	setDeleteLocalPoiModal(false);
		// 	return;
		// }
	};

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {accountTariffs.length} Account Tariffs{' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<button
							className='btn btn-sm btn-primary px-4 py-4'
							onClick={() => setCreateAccountTariffModal(true)}
						>
							Add New Tariffs
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
												placeholder='Search'
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
			{createAccountTariffModal && (
				<AddAccountTariff
					open={createAccountTariffModal}
					onOpenChange={handleClose}
				/>
			)}
			{editAccountTariffModal && (
				<EditAccountTariff
					open={editAccountTariffModal}
					onOpenChange={handleClose}
				/>
			)}
			{/* {deleteLocalPoiModal && (
				<DeleteLocalPoi
					open={deleteLocalPoiModal}
					onOpenChange={handleClose}
				/>
			)} */}
		</Fragment>
	);
}

export { ListAccountTariffs };
