/**
 * eslint-disable prettier/prettier
 *
 * @format
 */

import { useEffect, useMemo, useRef, useState } from 'react';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
} from '@/components';
import { Input } from '@/components/ui/input';
import {
	getTariffConfig,
	setTariffConfig,
} from '../../../service/operations/settingsApi';
import toast from 'react-hot-toast';

const Tariff = () => {
	const [tariffData, setTariffData] = useState([]);
	const inputRefs = useRef({});
	const changedTariffs = useRef(new Set());

	const handleInputChange = (id, field, value) => {
		const inputKey = `${id}-${field}`;

		// Store the currently focused input
		inputRefs.current[inputKey] = document.activeElement;
		const updatedTariffs = tariffData.map((tariff) =>
			tariff.id === id ? { ...tariff, [field]: parseFloat(value) || 0 } : tariff
		);
		setTariffData(updatedTariffs);
		// const updatedTariff = updatedTariffs.find((tariff) => tariff.id === id);
		changedTariffs.current.add(id);
		setTimeout(() => {
			if (inputRefs.current[inputKey]) {
				inputRefs.current[inputKey].focus();
			}
		}, 0);
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
				accessorKey: 'name',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Tariff Name</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => <div className='p-2'>{row.original.name}</div>,
				meta: { headerClassName: 'min-w-[40px] text-center' },
			},
			{
				accessorKey: 'description',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Description</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div className='p-2'>{row.original.description}</div>
				),
				meta: { headerClassName: 'min-w-[140px] text-left' },
			},
			{
				accessorKey: 'initialCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Initial Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				cell: ({ row }) => (
					<input
						type='number'
						className='w-16 text-center border rounded p-1 dark:bg-inherit dark:ring-inherit'
						value={row.original.initialCharge}
						onChange={(e) =>
							handleInputChange(
								row.original.id,
								'initialCharge',
								e.target.value
							)
						}
						ref={(input) => {
							if (input) {
								const key = `${row.original.id}-initialCharge`;
								inputRefs.current[key] = input;
							}
						}}
					/>
				),
				meta: { headerClassName: 'min-w-[20px] text-center' },
			},
			{
				accessorKey: 'firstMileCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>First Mile Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				cell: ({ row }) => (
					<input
						type='number'
						className='w-16 text-center border rounded p-1 dark:bg-inherit dark:ring-inherit'
						value={row.original.firstMileCharge}
						onChange={(e) =>
							handleInputChange(
								row.original.id,
								'firstMileCharge',
								e.target.value
							)
						}
						ref={(input) => {
							if (input) {
								const key = `${row.original.id}-firstMileCharge`;
								inputRefs.current[key] = input;
							}
						}}
					/>
				),
				meta: { headerClassName: 'min-w-[20px] text-center' },
			},
			{
				accessorKey: 'additionalMileCharge',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Additional Mile Charge</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				cell: ({ row }) => (
					<input
						type='number'
						className='w-16 text-center border rounded p-1 dark:bg-inherit dark:ring-inherit'
						value={row.original.additionalMileCharge}
						onChange={(e) =>
							handleInputChange(
								row.original.id,
								'additionalMileCharge',
								e.target.value
							)
						}
						ref={(input) => {
							if (input) {
								const key = `${row.original.id}-additionalMileCharge`;
								inputRefs.current[key] = input;
							}
						}}
					/>
				),
				meta: { headerClassName: 'min-w-[20px] text-center' },
			},
		],
		[tariffData]
	);

	const handleUpdateTariffs = async () => {
		const updatedTariffs = tariffData.filter((tariff) =>
			changedTariffs.current.has(tariff.id)
		);
		if (updatedTariffs.length === 0) {
			toast.error('No changes detected.');
			return;
		}
		try {
			console.log('updated tariff data', updatedTariffs);
			const updatePromises = updatedTariffs.map((tariff) =>
				setTariffConfig(tariff)
			);
			const responses = await Promise.all(updatePromises);
			const allSuccess = responses.every(
				(response) => response.status === 'success'
			);
			if (allSuccess) {
				toast.success('Tariff Updated Successfully');
				changedTariffs.current.clear();
			} else {
				toast.error('Unable to update Tariff');
				console.error('Failed to update Tariff Data:', responses);
			}
		} catch (error) {
			console.log(error);
			toast.error('Unable to update Tariff');
			console.error('Failed to update Tariff Data:', error.message);
		}
	};

	useEffect(() => {
		async function getTariff() {
			try {
				const response = await getTariffConfig();
				if (response.status === 'success') {
					const tariffArray = Object.keys(response)
						.filter((key) => key !== 'status')
						.map((key) => response[key]);
					setTariffData(tariffArray);
				} else {
					toast.error('Unable to fetch Tariff Data');
					console.error('Failed to fetch Tariff Data:', response.message);
				}
			} catch (error) {
				console.log(error);
			}
		}

		getTariff();
	}, []);

	return (
		<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
			<h2 className='text-xl leading-none font-medium text-gray-900 mb-8'>
				Tariff Configuration
			</h2>

			{/* Table */}
			<DataGrid
				columns={columns}
				data={tariffData}
				rowSelection={false}
				pagination={{ size: 5 }}
				sorting={[{ id: 'name', desc: false }]}
				layout={{ card: true }}
			/>

			{/* Update Button */}
			<div className='mt-4'>
				<button
					className='btn btn-sm btn-primary px-4 py-4'
					onClick={handleUpdateTariffs}
				>
					UPDATE TARIFF
				</button>
			</div>
		</div>
	);
};

export { Tariff };
