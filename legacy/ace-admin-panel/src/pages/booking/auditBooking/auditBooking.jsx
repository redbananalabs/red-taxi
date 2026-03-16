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
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';
import toast from 'react-hot-toast';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshAuditBookings,
	setAuditBookings,
} from '../../../slices/bookingSlice';
function AuditBooking() {
	const dispatch = useDispatch();
	const { auditBookings, loading } = useSelector((state) => state.booking);
	const [searchInput, setSearchInput] = useState('');

	const handleSearch = async () => {
		if (!searchInput.trim()) {
			toast.error('Please enter a booking ID');
			dispatch(setAuditBookings([])); // Reset table if input is empty
			return;
		}
		dispatch(refreshAuditBookings(searchInput));
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
				accessorKey: 'timeStamp',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Date/Time of Change</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{new Date(
							row.original.timeStamp?.split('T')[0]
						)?.toLocaleDateString('en-GB')}{' '}
						{row.original.timeStamp?.split('T')[1].split('.')[0]?.slice(0, 5)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'userFullName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Changed By User</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.userFullName ? row.original.userFullName : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'propertyName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Property Name</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.propertyName ? row.original.propertyName : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'oldValue',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Previous Value</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.oldValue ? row?.original?.oldValue : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'newValue',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>New Value</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row.original.newValue ? row.original.newValue : '-'}
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
							{auditBookings.length > 0
								? `Showing ${auditBookings.length} Audit Results for Booking #: ${searchInput}`
								: 'Search for booking details'}
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
									<div className='flex gap-2'>
										<label
											className='input input-sm'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Booking Id'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
										<button
											className='btn btn-sm btn-outline btn-primary'
											style={{ height: '40px' }}
											onClick={handleSearch}
											disabled={loading}
										>
											<KeenIcon icon='magnifier' />{' '}
											{loading ? 'Searching...' : 'Search'}
										</button>
									</div>
								</div>
							</div>
							<div className='card-body'>
								{auditBookings.length > 0 ? (
									<DataGrid
										columns={columns}
										data={auditBookings}
										rowSelection={true}
										onRowSelectionChange={handleRowSelection}
										pagination={{ size: 10 }}
										sorting={[{ id: 'timeStamp', desc: false }]}
										layout={{ card: true }}
									/>
								) : (
									<div className='text-center py-10 text-gray-500'>
										No data found
									</div>
								)}
							</div>
						</div>
					</div>
				</div>
			</div>
		</Fragment>
	);
}

export { AuditBooking };
