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
import { DataGrid, DataGridColumnHeader } from '@/components';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import { AddAccounts } from '../addAccounts';
import { EditAccounts } from '../editAccounts';
import { DeleteAccounts } from '../deleteAccounts';
import { refreshAllAccounts, setAccount } from '../../../slices/accountSlice';
import { refreshAllAccountTariffs } from '../../../slices/tariffsSlice';
function ListAccounts() {
	const dispatch = useDispatch();
	const [searchInput, setSearchInput] = useState('');
	const [createAccountModal, setAccountModal] = useState(false);
	const [editAccountModal, setEditAccountModal] = useState(false);
	const [deleteAccountModal, setDeleteAccountModal] = useState(false);
	const { accounts } = useSelector((state) => state.account);
	// const [date, setDate] = useState(new Date());

	const filterAccounts = accounts?.filter(
		(acc) =>
			acc?.businessName?.toLowerCase()?.includes(searchInput.toLowerCase()) ||
			acc?.address1?.toLowerCase()?.includes(searchInput.toLowerCase()) ||
			acc?.postcode?.toLowerCase()?.includes(searchInput.toLowerCase()) ||
			acc?.email?.toLowerCase()?.includes(searchInput.toLowerCase())
	);

	useEffect(() => {
		dispatch(refreshAllAccounts());
		dispatch(refreshAllAccountTariffs());
	}, [dispatch]);

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
				accessorKey: 'accNo',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Acc #</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.accNo}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'businessName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Name</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.businessName}</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},

			{
				accessorKey: 'address1',
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
						{row.original.address1 ? row.original?.address1 : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
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
						{row.original.postcode ? row.original.postcode : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'email',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Email</span>
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
								dispatch(setAccount(row.original));
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
								dispatch(setAccount(row.original));
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

	return (
		<Fragment>
			<div className=' pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {accounts.length} Accounts{' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<button
							className='btn btn-sm btn-primary px-4 py-4'
							onClick={() => setAccountModal(true)}
						>
							Add New Account
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
												placeholder='Search Accounts'
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
									data={filterAccounts}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'accNo', desc: false }]}
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

export { ListAccounts };
