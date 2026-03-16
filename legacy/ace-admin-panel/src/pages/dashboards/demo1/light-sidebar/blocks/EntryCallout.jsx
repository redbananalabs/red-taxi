/** @format */

import { DataGrid, KeenIcon } from '@/components';
import { toast } from 'sonner';
import { useState, useMemo, useEffect } from 'react';

import { useSelector } from 'react-redux';

const EntryCallout = () => {
	const { driverWeeksEarnings } = useSelector((state) => state.dashboard);
	const [searchQuery, setSearchQuery] = useState('');
	const [tableData, setTableData] = useState([]);
	const userRole = JSON.parse(localStorage.getItem('userData'))?.roleId || 0;

	useEffect(() => {
		if (driverWeeksEarnings) {
			setTableData(driverWeeksEarnings);
		}
	}, [driverWeeksEarnings]);

	const columns = useMemo(() => {
		const allColumns = [
			{
				accessorKey: 'identifier',
				header: <span className='font-bold'>Driver</span>,
				enableSorting: true,
				cell: (info) => {
					return (
						<div className='p-1 rounded font-semibold'>{info.getValue()}</div>
					);
				},
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'jobsCount',
				header: <span className='font-bold'>Jobs</span>,
				enableSorting: true,
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'cashEarned',
				header: <span className='font-bold'>Cash</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'accEarned',
				header: <span className='font-bold'>Acc</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'rankEarned',
				header: <span className='font-bold'>Rank</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'commissionCash',
				header: <span className='font-bold'>Cash Comms</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'commissionRank',
				header: <span className='font-bold'>Rank Comms</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'takeHome',
				header: <span className='font-bold'>Total</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'commission',
				header: <span className='font-bold'>Total Comms</span>,
				enableSorting: true,
				cell: ({ getValue }) => {
					return (
						<div className='flex items-center gap-1'>
							<span>£{getValue()?.toFixed(2)}</span>
						</div>
					);
				},
				meta: { headerClassName: 'w-12' },
			},
		];
		const roleBasedColumns = {
			1: allColumns, // Admin sees all columns
			2: allColumns.filter(
				(col) =>
					col.accessorKey === 'identifier' ||
					col.accessorKey === 'jobsCount' ||
					col.accessorKey === 'accEarned'
			), // User sees only 'Driver', 'Jobs', 'Acc'
			3: allColumns.filter(
				(col) =>
					col.accessorKey === 'identifier' || col.accessorKey === 'jobsCount'
			), // Driver sees only 'Driver' & 'Jobs'
		};

		return roleBasedColumns[userRole] || [];
	}, [userRole]);

	const totalSum =
		tableData?.reduce((acc, curr) => acc + (curr.takeHome || 0), 0) || 0;
	const totalCommsSum =
		tableData?.reduce((acc, curr) => acc + (curr.commission || 0), 0) || 0;

	// ✅ Filter Data Based on Search Query
	const filteredData = tableData.filter((driver) =>
		driver.fullname.toLowerCase().includes(searchQuery.toLowerCase())
	);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			toast(`Total ${selectedRowIds.length} are selected.`, {
				description: `Selected row IDs: ${selectedRowIds}`,
				action: {
					label: 'Undo',
					onClick: () => console.log('Undo'),
				},
			});
		}
	};

	const Toolbar = ({ setSearchQuery }) => {
		const [inputValue, setInputValue] = useState(searchQuery);
		const handleKeyDown = (e) => {
			if (e.key === 'Enter') {
				setSearchQuery(inputValue);
			}
		};
		const handleChange = (event) => {
			setInputValue(event.target.value);
		};
		return (
			<div className='card-header border-b-0 px-5'>
				<h3 className='card-title'>Weeks Totals</h3>
				<div className='input input-sm max-w-48'>
					<KeenIcon icon='magnifier' />
					<input
						type='text'
						placeholder='Search Driver'
						value={inputValue}
						onChange={handleChange}
						onKeyDown={handleKeyDown}
					/>
				</div>
			</div>
		);
	};

	return (
		<>
			<DataGrid
				columns={columns}
				data={filteredData}
				rowSelection={true}
				onRowSelectionChange={handleRowSelection}
				pagination={{
					size: 5,
				}}
				toolbar={<Toolbar setSearchQuery={setSearchQuery} />}
				layout={{
					card: true,
				}}
				applyRowColor={true}
			/>
			{userRole === 1 && (
				<div className='flex justify-end items-center mt-4 p-4 bg-gray-100 rounded-lg'>
					<div className='font-bold text-lg text-gray-800 flex gap-4'>
						<span>Total Earnings:</span>
						<div className='flex items-center gap-1'>
							<span>£{totalSum.toFixed(2)}</span>
						</div>
						<span>Total Commissions:</span>
						<div className='flex items-center gap-1'>
							<span>£{totalCommsSum.toFixed(2)}</span>
						</div>
					</div>
				</div>
			)}
		</>
	);
};
export { EntryCallout };
