/** @format */
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
import clsx from 'clsx';
import { useDispatch, useSelector } from 'react-redux';
import toast from 'react-hot-toast';
import { useEffect, useState } from 'react';
import isLightColor from '../../utils/isLight';
import { KeenIcon } from '@/components';
import {
	sendDirectMsgToDriver,
	sendGlobalMsgToDriver,
} from '../../service/operations/dashboardApi';
import { refreshAllDrivers } from '../../slices/driverSlice';

function SendDriverMsgModal({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { isDirectMsgModal, isGlobalMsgModal } = useSelector(
		(state) => state.dashboard
	);
	const { drivers } = useSelector((state) => state.driver);
	const [searchInput, setSearchInput] = useState('');
	const [selectedDrivers, setSelectedDrivers] = useState([]);
	console.log('drivers', drivers);

	const addLocalSchema = Yup.object().shape({
		// Changed from email to username
		message: Yup.string().required('message is required'),
	});

	const filteredDrivers = drivers.filter((driver) => {
		return driver?.fullName.toLowerCase().includes(searchInput.toLowerCase());
	});

	const toggleDriverSelection = (driverId) => {
		setSelectedDrivers((prevSelected) =>
			prevSelected.includes(driverId)
				? prevSelected.filter((id) => id !== driverId)
				: [...prevSelected, driverId]
		);
	};

	const initialValues = {
		message: '',
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			console.log('Submitted Values:', values);
			try {
				if (isDirectMsgModal) {
					if (selectedDrivers.length === 0) {
						toast.error('Please select at least one driver.');
						setSubmitting(false);
						return;
					}

					const promises = selectedDrivers.map((driverId) =>
						sendDirectMsgToDriver(driverId, values.message)
					);
					await Promise.all(promises);
					toast.success('Messages sent successfully!');
				}
				if (isGlobalMsgModal) {
					await sendGlobalMsgToDriver(values.message);
					toast.success('Global message sent successfully!');
				}
				onOpenChange();
			} catch (error) {
				toast.error('Failed to send messages.');
				console.error(error);
			} finally {
				setSubmitting(false);
			}
		},
	});

	useEffect(() => {
		if (isDirectMsgModal) {
			dispatch(refreshAllDrivers());
		}
	}, [dispatch, isDirectMsgModal]);

	return (
		<Dialog
			open={open}
			onOpenChange={onOpenChange}
		>
			<DialogContent
				className={`${isDirectMsgModal ? 'max-w-[600px]' : 'max-w-[500px]'} `}
			>
				<DialogHeader className='border-0'>
					<DialogTitle></DialogTitle>
					<DialogDescription></DialogDescription>
				</DialogHeader>
				<DialogBody className='flex flex-col items-center pt-0 pb-4'>
					<h3 className='text-lg font-medium text-gray-900 text-center mb-3'>
						{isDirectMsgModal
							? 'Send Message to Selected Drivers'
							: 'Send Message to All Drivers'}
					</h3>

					<div className='flex justify-center items-start gap-4 w-full'>
						{isDirectMsgModal && (
							<div className='flex-col w-[50%]'>
								<h4 className='text-sm font-medium text-gray-900 text-start mb-3'>
									Select Driver(s)
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
									{filteredDrivers.length > 0 &&
										filteredDrivers.map((driver) => (
											<>
												<div
													key={driver.id}
													className='p-1'
												>
													<div
														style={{ backgroundColor: driver.colorRGB }}
														className='rounded-md'
													>
														<label className='checkbox-group flex justify-between p-1'>
															<span
																className={`${isLightColor(driver.colorRGB) ? 'text-black' : 'text-white'} checkbox-label ml-2`}
															>
																{String(driver?.id).padStart(2, '0')} -{' '}
																{driver?.fullName}
															</span>
															<input
																className='checkbox checkbox-sm mr-2'
																type='checkbox'
																checked={selectedDrivers.includes(driver.id)}
																onChange={() =>
																	toggleDriverSelection(driver.id)
																}
															/>
														</label>
													</div>
												</div>
											</>
										))}
								</div>
							</div>
						)}
						<form
							onSubmit={formik.handleSubmit}
							className={`${isDirectMsgModal ? 'w-[50%]' : 'w-full'}`}
						>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>Message</label>
								<label className=''>
									<textarea
										placeholder='Enter message'
										rows={6}
										autoComplete='off'
										{...formik.getFieldProps('message')}
										className={clsx(
											'form-control textarea text-2sm text-gray-600 font-normal',
											{
												'is-invalid':
													formik.touched.message && formik.errors.message,
											}
										)}
									/>
								</label>
								{formik.touched.message && formik.errors.message && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.message}
									</span>
								)}
							</div>

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
								>
									Send Message
								</button>
							</div>
						</form>
					</div>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { SendDriverMsgModal };
