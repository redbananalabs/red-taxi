/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { useDispatch, useSelector } from 'react-redux';
import toast from 'react-hot-toast';
import { useEffect, useState } from 'react';
import { refreshAllDrivers } from '../../../../slices/driverSlice';
import isLightColor from '../../../../utils/isLight';
import { KeenIcon } from '@/components';
import { allocateBooking } from '../../../../service/operations/bookingApi';
import { refreshBookingsByStatus } from '../../../../slices/bookingSlice';
import { format } from 'date-fns';

function AllocateBookingModal({ open, onOpenChange, date, scope, status }) {
	const dispatch = useDispatch();
	const { drivers } = useSelector((state) => state.driver);
	const { booking } = useSelector((state) => state.booking);
	const [searchInput, setSearchInput] = useState('');
	const [selectedDriver, setSelectedDriver] = useState(null); // ✅ Single driver selection
	const userData = JSON.parse(localStorage.getItem('userData'));

	useEffect(() => {
		dispatch(refreshAllDrivers());
	}, [dispatch]);

	const filteredDrivers = drivers.filter((driver) =>
		driver?.fullName.toLowerCase().includes(searchInput.toLowerCase())
	);

	const handleDriverSelection = (driverId) => {
		setSelectedDriver(driverId); // ✅ Selecting a driver replaces the previous one
	};

	const formik = useFormik({
		initialValues: {},
		validationSchema: Yup.object().shape({}),
		onSubmit: async (values, { setSubmitting }) => {
			if (!selectedDriver) {
				toast.error('Please select a driver before submitting.');
				setSubmitting(false);
				return;
			}
			try {
				console.log(booking, userData);
				const payload = {
					bookingId: booking?.id || 0,
					userId: selectedDriver || 0,
					actionByUserId: userData?.userId || 0,
				};

				const response = await allocateBooking(payload);

				if (response.status === 'success') {
					dispatch(
						refreshBookingsByStatus(
							format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
							scope,
							status
						)
					);
					// You can handle the API call here if needed.
					toast.success(`Booking allocated to Driver #${selectedDriver}`);
					onOpenChange(); // Close the modal
				} else {
					toast.error(response?.message);
				}
			} catch (error) {
				toast.error('Failed to allocate booking.');
				console.error(error);
			} finally {
				setSubmitting(false);
			}
		},
	});

	return (
		<Dialog
			open={open}
			onOpenChange={onOpenChange}
		>
			<DialogContent className='max-w-[500px]'>
				<DialogHeader className='border-0'>
					<DialogTitle></DialogTitle>
					<DialogDescription></DialogDescription>
				</DialogHeader>
				<DialogBody className='flex flex-col items-center pt-0 pb-4'>
					<h3 className='text-lg font-medium text-gray-900 text-center mb-3'>
						Allocate Booking To:{' '}
						{selectedDriver ? `Driver #${selectedDriver}` : 'None'}
					</h3>

					<div className='flex justify-center items-start gap-4 w-full'>
						<div className='flex-col w-full'>
							<h4 className='text-sm font-medium text-gray-900 text-start mb-3'>
								Select a Driver
							</h4>
							<div className='flex mb-2'>
								<label
									className='input input-sm'
									style={{ height: '40px' }}
								>
									<KeenIcon icon='magnifier' />
									<input
										type='text'
										placeholder='Search Drivers'
										value={searchInput}
										onChange={(e) => setSearchInput(e.target.value)}
									/>
								</label>
							</div>

							<div className='max-h-[400px] h-[400px] overflow-y-auto scrollable-y'>
								{filteredDrivers.length > 0 ? (
									filteredDrivers.map((driver) => (
										<div
											key={driver.id}
											className='p-1'
										>
											<div
												style={{ backgroundColor: driver.colorRGB }}
												className='rounded-md'
											>
												<label className='checkbox-group flex justify-between p-1 cursor-pointer'>
													<span
														className={`${
															isLightColor(driver.colorRGB)
																? 'text-black'
																: 'text-white'
														} checkbox-label ml-2`}
													>
														{String(driver?.id).padStart(2, '0')} -{' '}
														{driver?.fullName}
													</span>
													<input
														className='radio radio-sm mr-2' // ✅ Changed to radio button for single selection
														type='radio'
														name='selectedDriver'
														checked={selectedDriver === driver.id}
														onChange={() => handleDriverSelection(driver.id)}
													/>
												</label>
											</div>
										</div>
									))
								) : (
									<p className='text-gray-500 text-sm text-center'>
										No drivers found.
									</p>
								)}
							</div>
							<form
								onSubmit={formik.handleSubmit}
								className='w-full'
							>
								<div className='flex justify-end mb-2 mt-2'>
									<button
										className='btn btn-light'
										onClick={() => onOpenChange()}
									>
										Cancel
									</button>
									<button
										className='btn btn-primary ml-2'
										type='submit'
										disabled={!selectedDriver}
									>
										Submit
									</button>
								</div>
							</form>
						</div>
					</div>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { AllocateBookingModal };
