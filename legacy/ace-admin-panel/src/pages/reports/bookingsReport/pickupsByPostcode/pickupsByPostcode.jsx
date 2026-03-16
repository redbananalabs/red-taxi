/**
 * eslint-disable react/prop-types
 *
 * @format
 */

/** @format */
/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import { KeenIcon } from '@/components';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
// import { Container } from '@/components/container';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { addDays, format } from 'date-fns';
import { cn } from '@/lib/utils';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
	// Circle,
	GoogleMap,
	// Marker,
	HeatmapLayer,
} from '@react-google-maps/api';
import {
	refreshPickupPostcodes,
	setPickupPostcodes,
} from '../../../../slices/reportSlice';
import useGoogleMapsLoader from '../../../../utils/googleMapLoader';
// const apiKey = import.meta.env.VITE_GOOGLE_API_KEY;
function PickupsByPostcode() {
	const { isLoaded } = useGoogleMapsLoader();
	const dispatch = useDispatch();
	const { pickupPostcodes } = useSelector((state) => state.reports);
	// const [heatmapData, setHeatmapData] = useState([]);
	// const [bubbleData, setBubbleData] = useState([]);
	const [heatmapData, setHeatmapData] = useState([]);
	// const [loading, setLoading] = useState(true);
	const mapCenter = { lat: 51.0397, lng: -2.2863 };
	const mapZoom = 10;
	const [isFullScreen, setIsFullScreen] = useState(false); // ✅ Full-screen state
	const [lastUpdated, setLastUpdated] = useState(0);
	// const [searchInput, setSearchInput] = useState('');
	const [openDate, setOpenDate] = useState(false);
	const [date, setDate] = useState({
		from: new Date(),
		to: addDays(new Date(), 20),
	});
	const [tempRange, setTempRange] = useState(date);
	const [scope, setScope] = useState(3);
	const [pickupHash, setPickupHash] = useState('');
	const hashPostcodes = (arr) =>
		JSON.stringify(arr.map((p) => `${p.pickupPostCode}-${p.count}`));

	useEffect(() => {
		const newHash = hashPostcodes(pickupPostcodes);
		if (newHash !== pickupHash) {
			setPickupHash(newHash);
			setLastUpdated(Date.now()); // Force re-fetch bubbles
		}
	}, [pickupPostcodes]);

	console.log(pickupPostcodes);
	useEffect(() => {
		if (openDate) {
			setTempRange({ from: null, to: null });
		}
	}, [openDate]);

	const getLatLngFromPostcode = async (postcode) => {
		try {
			const response = await fetch(
				`https://api.postcodes.io/postcodes/${encodeURIComponent(postcode)}`
			);
			const data = await response.json();

			if (data.status === 200 && data.result) {
				return {
					lat: data.result.latitude,
					lng: data.result.longitude,
				};
			} else {
				console.warn('Postcodes.io error:', data.status, data.error);
				return null;
			}
		} catch (error) {
			console.error('Postcodes.io fetch error:', error);
			return null;
		}
	};

	useEffect(() => {
		if (!isLoaded || !pickupPostcodes.length) return;

		const fetchLatLngData = async () => {
			//   const bubbleDataArray = [];

			//   for (const item of pickupPostcodes) {
			//     const location = await getLatLngFromPostcode(
			//       item.pickupPostCode,
			//       apiKey
			//     );

			//     if (location) {
			//       bubbleDataArray.push({
			//         type: "circle",
			//         center: { lat: location.lat, lng: location.lng },
			//         radius: 100,
			//         options: {
			//           fillColor: "rgba(0, 128, 0, 0.4)",
			//           fillOpacity: 0.7,
			//           strokeColor: "rgba(0, 128, 0, 0.4)",
			//           strokeOpacity: 0.8,
			//           strokeWeight: 1,
			//         },
			//       });

			//   if (item.count > 10) {
			//     bubbleDataArray.push({
			//       type: "circle",
			//       center: { lat: location.lat, lng: location.lng },
			//       radius: 30,
			//       options: {
			//         fillColor: "rgba(128, 0 , 128, 0.7)",
			//         fillOpacity: 0.8,
			//         strokeColor: "rgba(128, 0 , 128, 0.7)",
			//         strokeOpacity: 0.9,
			//         strokeWeight: 1,
			//       },
			//     });
			//   }

			//   bubbleDataArray.push({
			//     type: "label",
			//     position: { lat: location.lat, lng: location.lng },
			//     label: {
			//       text: item.count.toString(),
			//       color: "#000",
			//       fontSize: "14px",
			//       fontWeight: "bold",
			//     },
			//   });
			// }
			//   }
			const heatmapPoints = [];

			for (const item of pickupPostcodes) {
				const location = await getLatLngFromPostcode(item.pickupPostCode);
				if (location) {
					heatmapPoints.push({
						location: new window.google.maps.LatLng(location.lat, location.lng),
						weight: item.count || 1, // use item.count as the weight
					});
				}
			}
			setHeatmapData(heatmapPoints);
			//   setBubbleData(bubbleDataArray);
		};

		fetchLatLngData();
	}, [lastUpdated, isLoaded]);

	const handleDateSelect = (range) => {
		setTempRange(range);
		if (range?.from && range?.to) {
			setDate(range);
			setOpenDate(false);
		}
	};
	// const handleClick = () => {
	// 	dispatch(
	// 		refreshBookingsByStatus(
	// 			format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
	// 			scope,
	// 			status || ''
	// 		)
	// 	);
	// };

	useEffect(() => {
		// Agar status, scope ya date change hota hai to API call karega
		dispatch(
			refreshPickupPostcodes(
				format(new Date(date.from), "yyyy-MM-dd'T'00:00:00'Z'"),
				format(new Date(date.to), "yyyy-MM-dd'T'00:00:00'Z'"),
				scope
			)
		);
	}, [date, scope, dispatch]);

	useEffect(() => {
		if (pickupPostcodes.length) {
			setLastUpdated(Date.now()); // Trigger a map update whenever postcodes change
		}
	}, [pickupPostcodes]);

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

	const columns = useMemo(() => {
		let baseColumns = [
			{
				accessorKey: 'pickupPostCode',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Pickup Postcodes</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.pickupPostCode}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'count',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Count</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>{row.original.count}</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
		];

		return baseColumns;
	}, []);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	useEffect(() => {
		return () => {
			dispatch(setPickupPostcodes([])); // Clear table data
		};
	}, [dispatch]);

	useEffect(() => {
		const handleKeyDown = (event) => {
			if (event.key === 'F12') {
				event.preventDefault();
				setIsFullScreen((prevState) => !prevState); // Toggle full-screen
			}
			if (event.key === 'Escape' && isFullScreen) {
				setIsFullScreen(false); // Exit full-screen on Escape key
			}
		};

		window.addEventListener('keydown', handleKeyDown);
		return () => window.removeEventListener('keydown', handleKeyDown);
	}, [isFullScreen]);

	const containerStyle = {
		width: isFullScreen ? '100vw' : '100%',
		height: isFullScreen ? '100vh' : '100%',
		position: isFullScreen ? 'fixed' : 'relative',
		top: isFullScreen ? 0 : 'auto',
		left: isFullScreen ? 0 : 'auto',
		zIndex: isFullScreen ? 9999 : 'auto',
	};

	// console.log('heatmapData:', heatmapData, isLoaded);
	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {pickupPostcodes?.length} Report(s){' '}
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
											className='input input-sm'
											style={{ height: '40px', marginTop: '1rem' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Jobs'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div> */}
									<div className='flex flex-wrap items-center gap-2.5'>
										<div className='flex flex-col'>
											<label className='form-label'>Date Range</label>
											<Popover
												open={openDate}
												onOpenChange={setOpenDate}
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

										<div className='flex flex-col'>
											<label className='form-label'>Scope</label>
											<Select
												value={scope}
												onValueChange={(value) => setScope(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={3}>All</SelectItem>
													<SelectItem value={0}>Cash</SelectItem>
													<SelectItem value={4}>Card</SelectItem>
													<SelectItem value={1}>Account</SelectItem>
													<SelectItem value={2}>Rank</SelectItem>
												</SelectContent>
											</Select>
										</div>

										{/* <button
							className='btn btn-sm btn-outline btn-primary'
							style={{ height: '40px' }}
							onClick={handleClick}
							disabled={loading}
						>
							<KeenIcon icon='magnifier' />{' '}
							{loading ? 'Searching...' : 'Search'}
						</button> */}
									</div>
								</div>
							</div>
							<div className='card-body'>
								{pickupPostcodes.length ? (
									<>
										{isLoaded && (
											<div className='my-6 h-[500px]'>
												<GoogleMap
													mapContainerStyle={containerStyle}
													center={mapCenter}
													zoom={mapZoom}
												>
													{/* {bubbleData.map((item, index) => {
														if (item.type === 'circle') {
															return (
																<Circle
																	key={index}
																	center={item.center}
																	radius={item.radius}
																	options={item.options}
																/>
															);
														}

														if (item.type === 'label') {
															return (
																<Marker
																	key={index}
																	position={item.position}
																	label={item.label}
																	icon={{
																		path: window.google.maps.SymbolPath.CIRCLE,
																		scale: 0, // Hides the marker icon itself
																	}}
																/>
															);
														}

														return null;
													})} */}
													{heatmapData.length > 0 && (
														<HeatmapLayer
															data={heatmapData}
															options={{
																radius: 40,
																opacity: 0.9,
																gradient: [
																	'rgba(0, 255, 0, 0)', // Transparent Green (start)
																	'rgba(0, 255, 0, 1)', // Green
																	'rgba(255, 255, 0, 1)', // Yellow
																	'rgba(255, 165, 0, 1)', // Orange
																	'rgba(255, 0, 0, 1)',
																],
															}}
														/>
													)}
												</GoogleMap>
											</div>
										)}

										<DataGrid
											columns={columns}
											data={pickupPostcodes}
											rowSelection={true}
											onRowSelectionChange={handleRowSelection}
											pagination={{ size: 10 }}
											sorting={[{ id: 'pickupPostCode', desc: false }]}
											layout={{ card: true }}
										/>
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

export { PickupsByPostcode };
