/** @format */
import ApexChart from 'react-apexcharts';
import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
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
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format, subDays } from 'date-fns';
import { cn } from '@/lib/utils';
import { DataGrid, DataGridColumnHeader } from '@/components';
import { Input } from '@/components/ui/input';
import { getTurndownBookings } from '../../../service/operations/bookingApi';
// import toast from 'react-hot-toast';
function TurndownBookings() {
	const [loading, setLoading] = useState(false); // ✅ Track loading state
	const [chartData, setChartData] = useState({
		data: [],
		labels: [],
	});

	const colors = ['var(--tw-primary)', 'var(--tw-success)', 'var(--tw-info)'];
	const [turndownData, setTurndownData] = useState([]);
	const [totalData, setTotalData] = useState(0);
	const [date, setDate] = useState({
		from: subDays(new Date(), 30),
		to: new Date(),
	});
	const [open, setOpen] = useState(false);

	const [tempRange, setTempRange] = useState(date);

	useEffect(() => {
		if (open) {
			setTempRange({ from: null, to: null });
		}
	}, [open]);

	const handleDateSelect = (range) => {
		setTempRange(range);
		if (range?.from && range?.to) {
			setDate(range);
			setOpen(false);
		}
	};

	const handleSearch = async () => {
		setLoading(true);
		try {
			const response = await getTurndownBookings(
				format(new Date(date?.from), 'yyyy-MM-dd'),
				format(new Date(date?.to), 'yyyy-MM-dd')
			);
			if (response.status === 'success') {
				console.log('-----', response);
				setTurndownData(response?.data);
				setTotalData(response.total);
				// setChartData({
				// 	data: response?.jobCountDateRangeValues || [],
				// 	labels: response?.jobCountDateRangeLabels || [],
				// });
			}
		} catch (error) {
			console.log(error);
		} finally {
			setLoading(false); // ✅ Reset loading after API call
		}
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
				accessorKey: 'id',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'># id</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.id}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'dateTime',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Date/Time</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{new Date(row.original.dateTime?.split('T')[0])?.toLocaleDateString(
							'en-GB'
						)}{' '}
						{row.original.dateTime?.split('T')[1].split('.')[0]?.slice(0, 5)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'amount',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Amount</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.amount?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
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

	const options = {
		series: chartData.data,
		labels: chartData.labels,
		colors: colors,
		fill: {
			colors: colors,
		},
		chart: {
			type: 'donut',
			height: 400,
		},
		stroke: {
			show: true,
			width: 2,
		},
		dataLabels: {
			enabled: false,
		},
		plotOptions: {
			pie: {
				expandOnClick: false,
			},
		},
		legend: {
			offsetY: -10,
			offsetX: -10,
			fontSize: '13px',
			fontWeight: '500',
			itemMargin: {
				vertical: 1,
			},
			labels: {
				colors: 'var(--tw-gray-700)',
				useSeriesColors: false,
			},
		},
		responsive: [
			{
				breakpoint: 480,
				options: {
					chart: {
						width: 200,
					},
					legend: {
						position: 'bottom',
					},
				},
			},
		],
	};

	// const columnTotals = useMemo(() => {
	// 	return turndownData.reduce(
	// 		(totals, item) => {
	// 			totals.cashTotal += item.cashTotal || 0;
	// 			totals.accTotal += item.accTotal || 0;
	// 			totals.rankTotal += item.rankTotal || 0;
	// 			totals.commsTotal += item.commsTotal || 0;
	// 			totals.grossTotal += item.grossTotal || 0;
	// 			totals.netTotal += item.netTotal || 0;
	// 			return totals;
	// 		},
	// 		{
	// 			cashTotal: 0,
	// 			accTotal: 0,
	// 			rankTotal: 0,
	// 			commsTotal: 0,
	// 			grossTotal: 0,
	// 			netTotal: 0,
	// 		}
	// 	);
	// }, [turndownData]);

	useEffect(() => {
		return () => {
			setTurndownData([]); // Clear table data
			setChartData({
				data: [],
				labels: [],
			});
		};
	}, []);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {turndownData?.length} records with a total amount of £
							{totalData?.toFixed(2)}
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
									{/* <div className='flex'>
										<label
											className='input input-sm hover:shadow-lg'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='number'
												placeholder='Search Driver Id'
												value={driverNumber}
												onChange={(e) => setDriverNumber(e.target.value)}
											/>
										</label>
									</div> */}
									<div className='flex flex-wrap items-center gap-2.5'>
										<div className='flex flex-col'>
											<label className='form-label'>Date Range</label>
											<Popover
												open={open}
												onOpenChange={setOpen}
											>
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
														selected={tempRange}
														onSelect={handleDateSelect}
														numberOfMonths={2}
													/>
												</PopoverContent>
											</Popover>
										</div>

										<button
											className='btn btn-sm btn-outline btn-primary mt-4'
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
							{chartData && (
								<div className='mt-4 flex justify-center items-center px-3 py-1 mb-2'>
									<ApexChart
										options={options}
										series={options.series}
										type='donut'
										width='100%'
										height='100%'
									/>
								</div>
							)}
							<div className='card-body'>
								{turndownData?.length > 0 ? (
									<>
										<DataGrid
											columns={columns}
											data={turndownData}
											rowSelection={true}
											onRowSelectionChange={handleRowSelection}
											pagination={{ size: 10 }}
											sorting={[{ id: 'id', desc: false }]}
											layout={{ card: true }}
										/>
										{/* <div className='flex justify-end gap-6 bg-[#14151A] font-semibold p-3 mt-2'>
											<span className=''>
												Total Cash: {columnTotals.cashTotal}
											</span>
											<span className=''>
												Total Account: {columnTotals.accTotal}
											</span>
											<span className=''>
												Total Rank: {columnTotals.rankTotal}
											</span>
											<span className=''>
												Total Comms: {columnTotals.commsTotal}
											</span>
											<span className=''>
												Gross Total: {columnTotals.grossTotal}
											</span>
											<span className=''>
												Net Total: {columnTotals.netTotal}
											</span>
										</div> */}
									</>
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

export { TurndownBookings };
