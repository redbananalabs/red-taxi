/** @format */
import { DataGrid, KeenIcon } from '@/components';
import { toast } from 'sonner';
import { useState, useMemo, useEffect } from 'react';

import { useSelector } from 'react-redux';
import isLightColor from '../../../../../utils/isLight';
function DriverAllocationMsgStatus() {
	const { allocationStatus } = useSelector((state) => state.dashboard);
	const [searchQuery, setSearchQuery] = useState('');
	const [tableData, setTableData] = useState([]);

	useEffect(() => {
		if (allocationStatus) {
			setTableData(allocationStatus);
		}
	}, [allocationStatus]);

	const columns = useMemo(
		() => [
			{
				accessorKey: 'sentAt',
				header: 'Sent At',
				enableSorting: true,
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'identifier',
				header: 'Driver',
				enableSorting: true,
				cell: (info) => {
					const rowData = info.row.original;
					const bgColor = rowData.colourCode || '#ffffff'; // Default to white if color is missing

					return (
						<div
							className='p-1 rounded text-gray-900 font-semibold'
							style={{
								backgroundColor: bgColor, // ✅ Apply background color dynamically
								color: isLightColor(bgColor) ? 'black' : 'white', // ✅ Ensure readable text
							}}
						>
							{info.getValue()}
						</div>
					);
				},
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'jobId',
				header: 'Job #',
				enableSorting: true,
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'pickUp',
				header: 'Pickup',
				enableSorting: true,
				cell: (info) => (
					<div className='flex items-center gap-1'>
						<span>{info.getValue()}</span>
					</div>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'passengerName',
				header: 'Passenger Name',
				enableSorting: true,
				cell: (info) => (
					<div className='flex items-center gap-1'>
						<span>{info.getValue()}</span>
					</div>
				),
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'pending',
				header: 'Pending',
				enableSorting: true,
				cell: (info) => (
					<div className='flex items-center gap-1'>
						<span>{info.getValue()}</span>
					</div>
				),
				meta: { headerClassName: 'w-12' },
			},
			{
				accessorKey: 'x',
				header: 'X',
				enableSorting: true,
				cell: (info) => (
					<div className='flex items-center gap-1'>
						<span>{info.getValue()}</span>
					</div>
				),
				meta: { headerClassName: 'w-12' },
			},
		],
		[]
	);

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
				<h3 className='card-title'>Driver Allocation Responses</h3>
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
			/>
			<div className='flex justify-end items-center mt-4 p-4 bg-gray-100 rounded-lg mb-4'>
				<div className='font-bold text-lg text-gray-800 flex gap-4'>
					<span>Last Updated:</span>
					<div className='flex items-center gap-1'>
						<span>01/02/25 - 07:22:48</span>
					</div>
				</div>
			</div>
		</>
	);
}

export { DriverAllocationMsgStatus };
