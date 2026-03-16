/** @format */

import { useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import { DataGrid, DataGridColumnHeader, KeenIcon } from '@/components';
import { useSelector } from 'react-redux';
const Teams = () => {
	const { jobsBookedToday } = useSelector((state) => state.dashboard);
	const [searchQuery, setSearchQuery] = useState('');
	const [tableData, setTableData] = useState([]);

	useEffect(() => {
		if (jobsBookedToday) {
			setTableData(jobsBookedToday);
		}
	}, [jobsBookedToday]);

	const columns = useMemo(
		() => [
			{
				accessorKey: 'bookedBy',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Booked By</span>
						column={column}
					/>
				),
				enableSorting: true,
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'cashJobs',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Cash Jobs Booked</span>
						column={column}
					/>
				),
				enableSorting: true,
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'accountJobs',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Account Jobs Booked</span>
						column={column}
					/>
				),
				enableSorting: true,
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'rankJobs',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Rank Jobs Booked</span>
						column={column}
					/>
				),
				enableSorting: true,
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'total',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Total Booked</span>
						column={column}
					/>
				),
				enableSorting: true,
				meta: { headerClassName: 'w-20' },
			},
		],
		[]
	);

	const filteredData = tableData.filter((data) =>
		data?.bookedBy.toLowerCase().includes(searchQuery.toLowerCase())
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
				<h3 className='card-title'>Booking Stats</h3>
				<div className='input input-sm max-w-48'>
					<KeenIcon icon='magnifier' />
					<input
						type='text'
						placeholder='Search name'
						value={inputValue}
						onChange={handleChange}
						onKeyDown={handleKeyDown}
					/>
				</div>
			</div>
		);
	};
	return (
		<DataGrid
			columns={columns}
			data={filteredData}
			rowSelection={true}
			onRowSelectionChange={handleRowSelection}
			pagination={{
				size: 5,
			}}
			sorting={[{ id: 'bookedBy', desc: false }]}
			toolbar={<Toolbar setSearchQuery={setSearchQuery} />}
			layout={{
				card: true,
			}}
		/>
	);
};
export { Teams };
