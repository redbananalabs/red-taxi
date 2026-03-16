/** @format */

import { useState, useEffect } from 'react';
import { GoogleMap, Marker } from '@react-google-maps/api';
import { Typography, Box } from '@mui/material';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
import { DataGrid, DataGridColumnHeader } from '@/components';
import { gstAllGPS } from '../../../service/operations/gpsApi';
import useGoogleMapsLoader from '../../../utils/googleMapLoader';
import { convertHexToRgba } from '../../../utils/colorConvertor';
const DriverTracking = () => {
	const { isLoaded } = useGoogleMapsLoader();

	const search = '';
	const [selectedDriver, setSelectedDriver] = useState('all');
	const [drivers, setDrivers] = useState([]);
	const [mapCenter, setMapCenter] = useState({ lat: 51.0397, lng: -2.2863 }); // Default map center
	const [mapZoom, setMapZoom] = useState(14); // Default zoom level
	const [isBouncing, setIsBouncing] = useState(false); // Track bounce state
	const [isFullScreen, setIsFullScreen] = useState(false); // ✅ Full-screen state
	const [returnView, setReturnView] = useState(false);
	// Function to fetch GPS data
	const fetchGPSData = async () => {
		try {
			const response = await gstAllGPS(); // Fetch data

			if (response?.status === 'success') {
				// Map the API response to match the drivers structure
				const mappedDrivers = Object.values(response).filter(
					(item) => typeof item === 'object'
				);
				setDrivers(mappedDrivers);
			} else {
				console.error('Failed to fetch GPS data:', response);
			}
		} catch (error) {
			console.error('Error fetching GPS data:', error);
		}
	};

	const startTracking = () => {
		setSelectedDriver('all');
		setMapCenter({ lat: 51.0397, lng: -2.2863 });
		setMapZoom(14);
	};

	// Fetch GPS data on component mount and every 10 seconds
	useEffect(() => {
		fetchGPSData(); // Initial fetch
		const interval = setInterval(fetchGPSData, 10000); // Fetch every 10 seconds

		return () => clearInterval(interval); // Cleanup interval on unmount
	}, []);

	// Toggle Full-Screen Mode on F12
	useEffect(() => {
		const handleKeyDown = (event) => {
			if (event.key === 'F12') {
				event.preventDefault();
				setIsFullScreen((prevState) => !prevState);
			}
			if (event.key === 'Escape' && isFullScreen) {
				setIsFullScreen(false); // Exit full-screen on Escape key
			}
		};

		window.addEventListener('keydown', handleKeyDown);
		return () => window.removeEventListener('keydown', handleKeyDown);
	}, [isFullScreen]);

	useEffect(() => {
		if (returnView) {
			const timeout = setTimeout(() => {
				startTracking(); // Your tracking logic
				setReturnView(false); // Optional: reset the toggle
			}, 30000); // 30,000 ms = 30 seconds

			// Cleanup the timeout if component unmounts or returnView changes before 30s
			return () => clearTimeout(timeout);
		}
	}, [returnView]);

	const handleDriverSelection = (driverReg) => {
		setSelectedDriver(driverReg);

		if (driverReg === 'all') {
			// Bounce all markers
			setIsBouncing('all');

			// Stop bounce after 30 seconds
			setTimeout(() => {
				setIsBouncing(null); // Reset bounce state
			}, 30000);

			// Reset to default map center and zoom
			setMapCenter({ lat: 51.0397, lng: -2.2863 });
			setMapZoom(2);
		} else {
			// Find the selected driver's data
			const selectedDriverData = drivers.find(
				(driver) => driver.regNo === driverReg
			);

			if (selectedDriverData) {
				// Recenter map to the selected driver's location
				setMapCenter({
					lat: selectedDriverData.latitude,
					lng: selectedDriverData.longitude,
				});
				setMapZoom(16); // Zoom in

				// Bounce the selected driver's marker
				setIsBouncing(driverReg);

				// Stop bounce after 30 seconds
				setTimeout(() => {
					setIsBouncing(null); // Reset bounce state
				}, 30000);
			}
		}
	};

	// Filter drivers based on selected driver and search input removed for now

	const filteredDrivers =
		// selectedDriver === 'all'
		// ?
		drivers.filter((driver) =>
			driver.regNo?.toLowerCase().includes(search.toLowerCase())
		);
	// : drivers.filter(
	// 		(driver) =>
	// 			driver.regNo === selectedDriver &&
	// 			driver.regNo?.toLowerCase().includes(search.toLowerCase())
	// 	);

	const containerStyle = {
		width: isFullScreen ? '100vw' : '100%',
		height: isFullScreen ? '100vh' : '100%',
		position: isFullScreen ? 'fixed' : 'relative',
		top: isFullScreen ? 0 : 'auto',
		left: isFullScreen ? 0 : 'auto',
		zIndex: isFullScreen ? 9999 : 'auto',
	};

	const getColoredCarIcon = (color) =>
		`data:image/svg+xml;charset=UTF-8,${encodeURIComponent(`
		  <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" viewBox="0 0 24 24" fill="${convertHexToRgba(color)}">
			<path fill="${convertHexToRgba(color)}" d="M5 16c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm13 0c-.55 0-1 
			  .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm-13.65-2.5l1.45-4.5h11.4l1.45 
			  4.5H4.35zM20 8h-1.26l-1.6-4.79A1.99 1.99 0 0015.21 2H8.79c-.84 0-1.59.52-1.89 
			  1.31L5.26 8H4c-1.1 0-2 .9-2 2v8c0 1.1.9 2 2 2h1c0 1.1.9 2 2 2s2-.9 
			  2-2h6c0 1.1.9 2 2 2s2-.9 2-2h1c1.1 0 2-.9 2-2v-8c0-1.1-.9-2-2-2z"/>
		  </svg>
		`)}`;

	return (
		<Box className='p-4 space-y-6'>
			{/* Header Section */}
			<Box className='flex flex-col md:flex-row items-center justify-between'>
				{/* Title */}
				<Typography
					variant='h4'
					className='font-bold text-gray-800 text-center md:text-left'
				>
					Driver Tracking
				</Typography>

				{/* Date and Time Section */}
				<Box className='flex items-center space-x-2 mt-4 md:mt-0'>
					{/* Clock Icon */}
					<svg
						xmlns='http://www.w3.org/2000/svg'
						className='h-6 w-6 text-gray-500'
						fill='none'
						viewBox='0 0 24 24'
						stroke='currentColor'
					>
						<path
							strokeLinecap='round'
							strokeLinejoin='round'
							strokeWidth='2'
							d='M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z'
						/>
					</svg>

					{/* Date */}
					<Typography className='text-gray-700 font-medium text-sm sm:text-base'>
						{new Date().toLocaleDateString('en-GB', {
							weekday: 'long',
							year: 'numeric',
							month: 'long',
							day: 'numeric',
						})}
					</Typography>

					{/* Time */}
					<Typography className='text-gray-900 font-semibold text-sm sm:text-lg'>
						{new Date().toLocaleTimeString('en-GB', {
							hour: '2-digit',
							minute: '2-digit',
							second: '2-digit',
						})}
					</Typography>
				</Box>
			</Box>

			{/* Search and Driver Selection Section */}
			<Box className='flex flex-col lg:flex-row items-center space-y-4 lg:space-y-0 lg:space-x-4'>
				{/* Select Driver Dropdown */}
				<Box className='w-full lg:w-[15%]'>
					<Typography className='mb-1 text-gray-800 dark:text-gray-700 font-medium'>
						Select Driver
					</Typography>

					<Select
						value={selectedDriver}
						onValueChange={(value) => handleDriverSelection(value)} // Custom select uses onValueChange instead of onChange
					>
						<SelectTrigger>
							<SelectValue placeholder='Select Driver' />
						</SelectTrigger>

						<SelectContent>
							<SelectItem value='all'>All</SelectItem>

							{drivers.map((driver) => (
								<SelectItem
									key={driver.userId}
									value={driver.regNo}
								>
									{driver.username} / {driver.regNo}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</Box>

				<Box>
					<div className='flex items-center gap-2'>
						<label className='switch switch-md flex-1 sm:flex-none mt-4'>
							<span className='switch-label'>Return View</span>
							<input
								type='checkbox'
								name='check'
								checked={returnView} // Controlled value
								onChange={(e) => setReturnView(e.target.checked)} // Update state on change
							/>
						</label>
					</div>
				</Box>
			</Box>

			{/* Map and Table Section */}
			<Box className='flex flex-col gap-4 h-[900px]'>
				{/* Map Section */}
				<Box
					className='flex-grow rounded-lg shadow-md overflow-hidden border border-gray-200'
					style={{ flex: '65%' }}
				>
					{isLoaded ? (
						<GoogleMap
							mapContainerStyle={containerStyle}
							center={mapCenter} // Dynamic map center
							zoom={mapZoom} // Dynamic zoom level
						>
							{filteredDrivers.map((driver) => (
								<Marker
									key={driver.userId}
									position={{
										lat: driver.latitude || 0,
										lng: driver.longitude || 0,
									}}
									title={`Driver: ${driver.username || 'Unknown'} | Speed: ${
										driver.speed.toFixed(2) || 'N/A'
									} km/h`}
									icon={{
										// url: '/media/images/car/gps-navigation.png',
										url: getColoredCarIcon(driver.htmlColor || '#fff'),
										scaledSize: new window.google.maps.Size(25, 25), // Adjust size of the icon
									}}
									animation={
										isBouncing === 'all' || isBouncing === driver.regNo
											? window.google.maps.Animation.BOUNCE
											: null
									} // Bounce only if this driver's regNo matches the bouncing state
								/>
							))}
						</GoogleMap>
					) : (
						<Box className='flex items-center justify-center h-full'>
							<Typography
								variant='body1'
								className='text-gray-500'
							>
								Loading Map...
							</Typography>
						</Box>
					)}
					{/* Small text visible at bottom */}
					<Box
						className='absolute left-1/4 transform -translate-x-1/4 px-1 py-1 rounded-md shadow-md mb-4'
						style={{ zIndex: 10 }}
					>
						<Typography
							variant='caption'
							className='text-gray-800 font-semibold whitespace-nowrap'
						>
							🔍 Press <strong>F12</strong> to view the map in fullscreen mode.
						</Typography>
					</Box>
				</Box>
				{/* Updated Table section design */}
				<Box
					className='rounded-lg mt-6'
					style={{ flex: '43%' }}
				>
					<div className='card card-grid min-w-full'>
						<div className='card-header flex-wrap gap-2'>
							<Typography
								variant='h6'
								className='font-bold text-gray-800'
							>
								Driver List
							</Typography>
						</div>

						<div className='card-body'>
							<DataGrid
								columns={[
									{
										accessorKey: 'userId',
										header: ({ column }) => (
											<DataGridColumnHeader
												title=<span className='font-bold'>#</span>
												column={column}
											/>
										),
										enableSorting: true,
										cell: ({ row }) => <span>{row.original.userId}</span>,
										meta: { headerClassName: 'w-20' },
									},
									{
										accessorKey: 'username',
										header: ({ column }) => (
											<DataGridColumnHeader
												title=<span className='font-bold'>Name</span>
												column={column}
											/>
										),
										enableSorting: true,
										cell: ({ row }) => (
											<span className='font-medium'>
												{row.original.username || 'N/A'}
											</span>
										),
										meta: { headerClassName: 'min-w-[120px]' },
									},
									{
										accessorKey: 'regNo',
										header: ({ column }) => (
											<DataGridColumnHeader
												title=<span className='font-bold'>Reg No</span>
												column={column}
											/>
										),
										enableSorting: true,
										cell: ({ row }) => (
											<span className='font-medium'>
												{row.original.regNo || 'N/A'}
											</span>
										),
										meta: { headerClassName: 'min-w-[120px]' },
									},
									{
										accessorKey: 'gpsLastUpdated',
										header: ({ column }) => (
											<DataGridColumnHeader
												title=<span className='font-bold'>Last Updated</span>
												column={column}
											/>
										),
										enableSorting: true,
										cell: ({ row }) => (
											<span>
												{row.original.gpsLastUpdated
													? new Date(
															row.original.gpsLastUpdated
														).toLocaleDateString('en-Gb') +
														' ' +
														row.original.gpsLastUpdated
															?.split('T')[1]
															.slice(0, 8)
													: 'N/A'}
											</span>
										),
										meta: { headerClassName: 'min-w-[150px]' },
									},
									{
										accessorKey: 'speed',
										header: ({ column }) => (
											<DataGridColumnHeader
												title=<span className='font-bold'>Speed (mph)</span>
												column={column}
											/>
										),
										enableSorting: true,
										cell: ({ row }) => (
											<span className='font-medium'>
												{row.original.speed
													? `${parseFloat(row.original.speed).toFixed(2)} mph`
													: '0.00 mph'}
											</span>
										),
										meta: { headerClassName: 'min-w-[100px]' },
									},
								]}
								data={filteredDrivers}
								rowSelection={true}
								pagination={{ size: 5 }}
								sorting={[{ id: 'userId', desc: false }]}
								layout={{ card: true }}
							/>
						</div>
					</div>
				</Box>
			</Box>
		</Box>
	);
};

export { DriverTracking };
