/** @format */

import { useState, useMemo, Fragment, useEffect } from 'react';
import { DataGrid, DataGridColumnHeader } from '@/components';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
// import { Input } from '@/components/ui/input';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import {
	Select,
	SelectTrigger,
	SelectContent,
	SelectItem,
	SelectValue,
} from '@/components/ui/select';
import { Calendar } from '@/components/ui/calendar';
import { format, subDays } from 'date-fns';
import { cn } from '@/lib/utils';
import { KeenIcon } from '@/components/keenicons';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshAvailabilityReport,
	setAvailableHoursByDay,
	setMonth,
	setUnavailable,
	setWeek,
	setWeekDay,
	setWeekEnd,
} from '../../../slices/availabilitySlice';
import toast from 'react-hot-toast';
import { refreshAllDrivers } from '../../../slices/driverSlice';

const monthNames = [
	'',
	'January',
	'February',
	'March',
	'April',
	'May',
	'June',
	'July',
	'August',
	'September',
	'October',
	'November',
	'December',
];

const weekDayNames = [
	'Sunday',
	'Monday',
	'Tuesday',
	'Wednesday',
	'Thursday',
	'Friday',
	'Saturday',
];

const AvailabilityReport = () => {
	const dispatch = useDispatch();
	const {
		availableHoursByDay,
		weekDay,
		weekEnd,
		week,
		month,
		unavailable,
		loading,
	} = useSelector((state) => state.availability);
	const [open, setOpen] = useState(false); // State to control Popover open/close
	const [selectedTab, setSelectedTab] = useState('dayHours');
	const [driverNumber, setDriverNumber] = useState(0);
	const { drivers } = useSelector((state) => state.driver);
	const [dateRange, setDateRange] = useState({
		from: subDays(new Date(), 30), // December 28, 2024
		to: new Date(), // January 28, 2025
	});
	const [tempRange, setTempRange] = useState(dateRange);

	useEffect(() => {
		if (open) {
			setTempRange({ from: null, to: null });
		}
	}, [open]);

	const handleDateSelect = (range) => {
		setTempRange(range);
		if (range?.from && range?.to) {
			setDateRange(range);
			setOpen(false);
		}
	};

	useEffect(() => {
		return () => {
			dispatch(setAvailableHoursByDay([])); // Clear table data
			dispatch(setWeekDay([])); // Clear table data
			dispatch(setWeekEnd([])); // Clear table data
			dispatch(setWeek([])); // Clear table data
			dispatch(setMonth([])); // Clear table data
			dispatch(setUnavailable([]));
		};
	}, [dispatch]);

	const handleSearch = async () => {
		if (!String(driverNumber)?.trim()) {
			toast.error('Please enter a Driver ID');
			return;
		}
		const payload = {
			userId: Number(driverNumber),
			startDate: format(new Date(dateRange?.from), 'yyyy-MM-dd'),
			endDate: format(new Date(dateRange?.to), 'yyyy-MM-dd'),
		};
		dispatch(refreshAvailabilityReport(payload));
	};

	const handleTabClick = (tab) => {
		setSelectedTab(tab);
	};

	// ✅ Data grouped by selected tab
	const dataByTab = useMemo(() => {
		const dataset = {
			dayHours: availableHoursByDay,
			monthHours: month,
			weekHours: week,
			weekdayHours: weekDay,
			weekendHours: weekEnd,
			unavailableHours: unavailable,
		};

		return dataset[selectedTab] || [];
	}, [
		month,
		selectedTab,
		week,
		weekDay,
		weekEnd,
		availableHoursByDay,
		unavailable,
	]);

	// ✅ Dynamic column headers based on selected tab
	const columns = useMemo(() => {
		if (selectedTab === 'dayHours') {
			return [
				{
					accessorKey: 'userId',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Driver #</span>
							column={column}
						/>
					),
					cell: ({ row }) => {
						const userId = row.original.userId;
						const driver = drivers.find((d) => d?.id === userId);
						return (
							<span className={`font-medium ${row.original.color}`}>
								{driver
									? `${driver.id.toString().padStart(2, '0')} - ${driver.fullName}`
									: '-'}
							</span>
						);
					},
				},
				{
					accessorKey: 'date',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Date</span>
							column={column}
						/>
					),
				},
				{
					accessorKey: 'hoursAvailable',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Hours Available</span>
							column={column}
						/>
					),
				},
			];
		} else if (selectedTab === 'monthHours') {
			return [
				{
					accessorKey: 'userId',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Driver #</span>
							column={column}
						/>
					),
					cell: ({ row }) => {
						const userId = row.original.userId;
						const driver = drivers.find((d) => d?.id === userId);
						return (
							<span className={`font-medium ${row.original.color}`}>
								{driver
									? `${driver.id.toString().padStart(2, '0')} - ${driver.fullName}`
									: '-'}
							</span>
						);
					},
				},
				{
					accessorKey: 'month',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Month</span>
							column={column}
						/>
					),
				},
				{
					accessorKey: 'totalHours',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Total Hours</span>
							column={column}
						/>
					),
				},
			];
		} else if (selectedTab === 'weekHours') {
			return [
				{
					accessorKey: 'userId',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Driver #</span>
							column={column}
						/>
					),
					cell: ({ row }) => {
						const userId = row.original.userId;
						const driver = drivers.find((d) => d?.id === userId);
						return (
							<span className={`font-medium ${row.original.color}`}>
								{driver
									? `${driver.id.toString().padStart(2, '0')} - ${driver.fullName}`
									: '-'}
							</span>
						);
					},
				},
				{
					accessorKey: 'week',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Week #</span>
							column={column}
						/>
					),
				},
				{
					accessorKey: 'totalHours',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Total Hours</span>
							column={column}
						/>
					),
				},
			];
		} else if (selectedTab === 'weekdayHours') {
			return [
				{
					accessorKey: 'userId',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Driver #</span>
							column={column}
						/>
					),
					cell: ({ row }) => {
						const userId = row.original.userId;
						const driver = drivers.find((d) => d?.id === userId);
						return (
							<span className={`font-medium ${row.original.color}`}>
								{driver
									? `${driver.id.toString().padStart(2, '0')} - ${driver.fullName}`
									: '-'}
							</span>
						);
					},
				},
				{
					accessorKey: 'day',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Week Days</span>
							column={column}
						/>
					),
				},
				{
					accessorKey: 'totalHours',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Total Hours</span>
							column={column}
						/>
					),
				},
			];
		} else if (selectedTab === 'weekendHours') {
			return [
				{
					accessorKey: 'userId',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Driver #</span>
							column={column}
						/>
					),
					cell: ({ row }) => {
						const userId = row.original.userId;
						const driver = drivers.find((d) => d?.id === userId);
						return (
							<span className={`font-medium ${row.original.color}`}>
								{driver
									? `${driver.id.toString().padStart(2, '0')} - ${driver.fullName}`
									: '-'}
							</span>
						);
					},
				},
				{
					accessorKey: 'weekendDay',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Weekend Day</span>
							column={column}
						/>
					),
				},
				{
					accessorKey: 'totalHours',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Total Hours</span>
							column={column}
						/>
					),
				},
			];
		} else if (selectedTab === 'unavailableHours') {
			return [
				{
					accessorKey: 'userId',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Driver #</span>
							column={column}
						/>
					),
					cell: ({ row }) => {
						const userId = row.original.userId;
						const driver = drivers.find((d) => d?.id === userId);
						return (
							<span className={`font-medium ${row.original.color}`}>
								{driver
									? `${driver.id.toString().padStart(2, '0')} - ${driver.fullName}`
									: '-'}
							</span>
						);
					},
					meta: { headerClassName: 'min-w-[10px]' },
				},
				{
					accessorKey: 'unAvailableDates',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Unavailable Dates</span>
							column={column}
						/>
					),
					meta: { headerClassName: 'min-w-[120px]' },
				},
				{
					accessorKey: 'totalUnAvailableDays',
					header: ({ column }) => (
						<DataGridColumnHeader
							title=<span className='font-bold'>Total Unavailable Days</span>
							column={column}
						/>
					),
					meta: { headerClassName: 'min-w-[120px]' },
				},
			];
		}
		return [];
	}, [selectedTab, drivers]);

	const formattedDataByTab = useMemo(() => {
		if (selectedTab === 'dayHours') {
			return dataByTab.map((item) => ({
				userId: item.userId,
				date: new Date(item.date).toLocaleDateString('en-GB'), // Convert date
				hoursAvailable: item.hoursAvailable,
			}));
		} else if (selectedTab === 'monthHours') {
			return dataByTab.map((item) => ({
				userId: item.userId,
				month: monthNames[item.month],
				totalHours: item.totalHours,
			}));
		} else if (selectedTab === 'weekHours') {
			return dataByTab.map((item) => ({
				userId: item.userId,
				week: item.week,
				totalHours: item.totalHours,
			}));
		} else if (selectedTab === 'weekdayHours') {
			return dataByTab.map((item) => ({
				userId: item.userId,
				day: weekDayNames[item.day],
				totalHours: item.totalHours,
			}));
		} else if (selectedTab === 'weekendHours') {
			return dataByTab.map((item) => ({
				userId: item.userId,
				weekendDay: weekDayNames[item.weekendDay],
				totalHours: item.totalHours,
			}));
		} else if (selectedTab === 'unavailableHours') {
			return dataByTab.map((item) => ({
				userId: item.userId,
				unAvailableDates: Array.isArray(item.unAvailableDates)
					? item.unAvailableDates
							.map((date) =>
								typeof date === 'number'
									? weekDayNames[date]
									: new Date(date).toLocaleDateString('en-GB')
							)
							.join(', ')
					: 'None',
				totalUnAvailableDays: item.totalUnAvailableDays,
			}));
		}
		return [];
	}, [dataByTab, selectedTab]);

	const formatedTotalsByTab = useMemo(() => {
		if (!Array.isArray(dataByTab)) return 0;

		if (selectedTab === 'weekdayHours' || selectedTab === 'weekendHours') {
			return dataByTab.reduce((total, curr) => {
				return total + (curr.totalHours || 0);
			}, 0);
		}
		return 0;
	}, [dataByTab, selectedTab]);

	useEffect(() => {
		dispatch(refreshAllDrivers());
	}, [dispatch]);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				{/* Header Section */}
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>Showing Availability Report</ToolbarDescription>
					</ToolbarHeading>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							<div className='card-header flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'>
									<div className='flex flex-wrap gap-2 w-full justify-start items-center'>
										{/* <label
											className='input input-sm w-36'
											style={{ height: '36px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='number'
												placeholder='Search Driver Id'
												value={driverNumber}
												onChange={(e) => setDriverNumber(e.target.value)}
											/>
										</label> */}

										<div className='flex flex-col'>
											<label className='form-label'>Driver</label>
											<Select
												value={driverNumber}
												onValueChange={(value) => setDriverNumber(value)}
											>
												<SelectTrigger
													className='w-40 hover:shadow-lg'
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
											<label className='form-label'>Date Range</label>
											<Popover
												open={open}
												onOpenChange={setOpen}
											>
												<PopoverTrigger
													asChild
													className='h-9'
												>
													<button
														className={cn(
															'btn btn-sm btn-light data-[state=open]:bg-light-active',
															!dateRange && 'text-gray-400'
														)}
													>
														<KeenIcon
															icon='calendar'
															className='me-0.5'
														/>
														{dateRange?.from ? (
															dateRange.to ? (
																<>
																	{format(dateRange.from, 'dd/MM/yyyy')} →{' '}
																	{format(dateRange.to, 'dd/MM/yyyy')}
																</>
															) : (
																format(dateRange.from, 'dd/MM/yyyy')
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
														mode='range'
														defaultMonth={dateRange?.from}
														selected={tempRange}
														onSelect={handleDateSelect}
														numberOfMonths={2}
														initialFocus
													/>
												</PopoverContent>
											</Popover>
										</div>

										<button
											className='btn btn-sm btn-outline btn-primary mt-4'
											style={{ height: '36px' }}
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
								{/* Tabs - Centered */}
								<div className='mt-6 flex flex-wrap justify-center gap-6'>
									{[
										{
											id: 'dayHours',
											label: '📌 DAY HOURS',
											color: 'bg-cyan-400',
										},
										{
											id: 'monthHours',
											label: '📌 MONTH HOURS',
											color: 'bg-green-400',
										},
										{
											id: 'weekHours',
											label: '🔧 WEEK# HOURS',
											color: 'bg-yellow-400',
										},
										{
											id: 'weekdayHours',
											label: '⚙️ WEEKDAY HOURS',
											color: 'bg-blue-400',
										},
										{
											id: 'weekendHours',
											label: '⌚ WEEKEND HOURS',
											color: 'bg-red-500',
										},
										{
											id: 'unavailableHours',
											label: '⌛ UNAVAILABLE DATES',
											color: 'bg-red-500',
										},
									].map((tab) => (
										<button
											key={tab.id}
											onClick={() => handleTabClick(tab.id)}
											className={`relative px-5 pb-2 flex items-center gap-2 text-sm font-medium transition-all duration-300 ${selectedTab === tab.id ? 'text-blue-500' : 'text-gray-600'}`}
										>
											{tab.label}
											<span
												className={`w-2 h-2 rounded-full ${tab.color}`}
											></span>
											{selectedTab === tab.id && (
												<div className='absolute bottom-0 left-0 w-full h-[2px] bg-blue-500 rounded transition-all duration-300'></div>
											)}
										</button>
									))}
								</div>

								{/* Data Grid */}
								<div className='mt-6 flex justify-center'>
									<div className='w-[700px]'>
										<DataGrid
											columns={columns}
											data={formattedDataByTab}
											pagination={{ size: 10 }}
											sorting={[{ id: 'userId', desc: false }]}
											layout={{ card: true }}
										/>
									</div>
								</div>

								{(selectedTab === 'weekdayHours' ||
									selectedTab === 'weekendHours') && (
									<div className='flex justify-end items-center mt-4 p-4 bg-gray-100 rounded-lg'>
										<div className='font-bold text-lg text-gray-800 flex gap-4'>
											<span>
												{selectedTab === 'weekdayHours'
													? 'Total Weekday Hours'
													: selectedTab === 'weekendHours'
														? 'Total Weekend Hours:'
														: ''}
											</span>
											<div className='flex items-center gap-1'>
												<span>{formatedTotalsByTab.toFixed(2)}</span>
											</div>
										</div>
									</div>
								)}
							</div>
						</div>
					</div>
				</div>
			</div>
		</Fragment>
	);
};

export { AvailabilityReport };
