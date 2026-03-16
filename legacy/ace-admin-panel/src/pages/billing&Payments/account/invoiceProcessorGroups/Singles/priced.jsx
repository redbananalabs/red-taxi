/** @format */
import KeyboardArrowRightIcon from '@mui/icons-material/KeyboardArrowRight';
import KeyboardArrowLeftIcon from '@mui/icons-material/KeyboardArrowLeft';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import { EmailOutlined } from '@mui/icons-material';

import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import { accountDriverPostOrUnpostJobs } from '../../../../../service/operations/billing&Payment';
import toast from 'react-hot-toast';

export default function Priced({ handleShow }) {
	const { accountChargeableGroupSplitJobs } = useSelector(
		(state) => state.billing
	);
	const { singles } = accountChargeableGroupSplitJobs;
	const { priced } = singles;
	const [expandedPassengers, setExpandedPassengers] = useState({});
	// const [expandedPickupGroups, setExpandedPickupGroups] = useState({});
	const [expandedDestinationGroups, setExpandedDestinationGroups] = useState(
		{}
	);
	const [currentPage, setCurrentPage] = useState(0);
	const [itemsPerPage, setItemsPerPage] = useState(10);

	const [currentPagePassenger, setCurrentPagePassenger] = useState(0);
	const [itemsPerPagePassenger, setItemsPerPagePassenger] = useState(10);

	const togglePassenger = (passengerId) => {
		setExpandedPassengers((prev) => ({
			...prev,
			[passengerId]: !prev[passengerId],
		}));
	};

	// const togglePickupGroup = (passengerId, pickup) => {
	// 	setExpandedPickupGroups((prev) => ({
	// 		...prev,
	// 		[`${passengerId}-${pickup}`]: !prev[`${passengerId}-${pickup}`],
	// 	}));
	// };

	const toggleDestinationGroup = (passengerId, destination) => {
		setExpandedDestinationGroups((prev) => ({
			...prev,
			[`${passengerId}-${destination}`]: !prev[`${passengerId}-${destination}`],
		}));
	};

	const handleRevert = async (job) => {
		try {
			const response = await accountDriverPostOrUnpostJobs(false, [
				job?.bookingId,
			]);
			if (response?.status === 'success') {
				toast.success('Job reverted successfully');
				handleShow();
			} else {
				toast.error('Failed to revert job');
			}
		} catch (error) {
			console.error('Failed to revert job:', error);
			toast.error('Failed to revert job');
		}
	};

	return (
		<div className='mb-10'>
			<table className='w-full border-collapse border border-gray-300'>
				<thead>
					<tr>
						<th className='border border-gray-300 px-4 text-start py-2 text-gray-700'>
							Id #
						</th>
						<th className='border border-gray-300 px-4 text-start py-2 text-gray-700'>
							Date
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Acc #
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Driver #
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Pax
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Vias
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Waiting
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Wait. Charge
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Actual Miles
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Driver
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Journey Charge
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Parking
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Total
						</th>
						<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
							Revert
						</th>
					</tr>
				</thead>
				<tbody>
					{priced
						.slice(
							currentPagePassenger * itemsPerPagePassenger,
							(currentPagePassenger + 1) * itemsPerPagePassenger
						)
						?.map((passengerData, passengerIndex) => {
							const destinationGroups =
								passengerData.pickupGroups?.flatMap((pickup) =>
									pickup.destinationGroups?.map((group) => ({
										...group,
										pickup: pickup.pickup, // optional if needed
									}))
								) || [];
							return (
								<React.Fragment key={`passenger-${passengerIndex}`}>
									<tr
										className='bg-gray-100 cursor-pointer'
										onClick={() => togglePassenger(passengerData.passenger)}
									>
										<td
											colSpan='15'
											className='border border-gray-300 px-4 py-2 font-semibold'
										>
											<span className='-ms-1 text-gray-700'>
												{expandedPassengers[passengerData.passenger] ? (
													<KeyboardArrowDownIcon />
												) : (
													<KeyboardArrowRightIcon />
												)}{' '}
												{passengerData.passenger}
											</span>
										</td>
									</tr>
									{expandedPassengers[passengerData.passenger] &&
										destinationGroups?.map(
											(destinationGroup, destinationIndex) => (
												<React.Fragment key={`destination-${destinationIndex}`}>
													<tr
														className='bg-gray-100 cursor-pointer'
														onClick={() =>
															toggleDestinationGroup(
																passengerData.passenger,
																destinationGroup.destination
															)
														}
													>
														<td
															colSpan='15'
															className='border border-gray-300 px-4 py-2 font-semibold'
														>
															<span className='-ms-1 ml-6 text-gray-700'>
																{expandedDestinationGroups[
																	`${passengerData.passenger}-${destinationGroup.destination}`
																] ? (
																	<KeyboardArrowDownIcon />
																) : (
																	<KeyboardArrowRightIcon />
																)}{' '}
																{destinationGroup.destination}
															</span>
														</td>
													</tr>
													{expandedDestinationGroups[
														`${passengerData.passenger}-${destinationGroup.destination}`
													] && (
														<>
															{destinationGroup.jobs
																?.slice(
																	currentPage * itemsPerPage,
																	(currentPage + 1) * itemsPerPage
																)
																?.map((booking) => (
																	<tr
																		key={`booking-${booking.bookingId}`}
																		className={`${booking?.coa ? ' bg-orange-500 hover:bg-orange-400' : 'bg-white dark:bg-[#14151A] hover:bg-gray-100'} border-t`}
																	>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking.bookingId}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking.date
																				? new Date(
																						booking.date
																					).toLocaleDateString('en-GB') +
																					' ' +
																					booking.date.split('T')[1].slice(0, 5)
																				: 'N/A'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking.accNo}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking.userId}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking.passengers}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{(booking.vias.length > 0 &&
																				booking.vias
																					.map((via) => via.address)
																					.join(', ')) ||
																				'-'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking?.waitingMinutes || '0'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			£
																			{booking.waitingPriceDriver?.toFixed(2) ||
																				'0.00'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			{booking.miles?.toFixed(1) || '0.0'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			£{booking?.price?.toFixed(2) || '0.00'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			£
																			{booking?.priceAccount?.toFixed(2) ||
																				'0.00'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			£
																			{booking?.parkingCharge?.toFixed(2) ||
																				'0.00'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			£
																			{(
																				Number(booking?.parkingCharge || 0) +
																				Number(
																					booking?.waitingPriceAccount || 0
																				) +
																				Number(booking?.priceAccount || 0)
																			).toFixed(2) || '0.00'}
																		</td>
																		<td className='border border-gray-300 px-4 py-2'>
																			<EmailOutlined
																				className={`${booking?.coa ? `${booking.postedForInvoicing ? 'text-red-500 dark:text-red-900' : 'text-blue-500 dark:text-white'}` : `${booking.postedForInvoicing ? 'text-red-500 dark:text-red-600' : 'text-blue-500 dark:text-cyan-400'}`} cursor-pointer `}
																				onClick={() => handleRevert(booking)}
																			/>
																		</td>
																	</tr>
																))}
															{destinationGroup.jobs?.length > itemsPerPage && (
																<tr>
																	<td
																		colSpan='15'
																		className='border border-gray-300 px-4 py-2'
																	>
																		<div className='flex justify-end items-center gap-2'>
																			<div>
																				Showing {currentPage * itemsPerPage + 1}{' '}
																				-{' '}
																				{Math.min(
																					(currentPage + 1) * itemsPerPage,
																					destinationGroup.jobs.length
																				)}{' '}
																				of {destinationGroup.jobs.length} jobs
																			</div>
																			<div className='flex space-x-2'>
																				<button
																					onClick={(e) => {
																						e.stopPropagation();
																						setCurrentPage((prev) =>
																							Math.max(prev - 1, 0)
																						);
																					}}
																					disabled={currentPage === 0}
																					className='px-1 py-1 border rounded-full disabled:opacity-50'
																				>
																					<KeyboardArrowLeftIcon />
																				</button>
																				<button
																					onClick={(e) => {
																						e.stopPropagation();
																						setCurrentPage((prev) =>
																							(prev + 1) * itemsPerPage <
																							destinationGroup.jobs.length
																								? prev + 1
																								: prev
																						);
																					}}
																					disabled={
																						(currentPage + 1) * itemsPerPage >=
																						destinationGroup.jobs.length
																					}
																					className='px-1 py-1 border rounded-full disabled:opacity-50'
																				>
																					<KeyboardArrowRightIcon />
																				</button>
																			</div>
																		</div>
																	</td>
																</tr>
															)}
														</>
													)}
												</React.Fragment>
											)
										)}
								</React.Fragment>
							);
						})}
				</tbody>
			</table>
			{priced?.length > itemsPerPagePassenger && (
				<div>
					<div
						colSpan='15'
						className='border border-gray-300 px-4 py-2'
					>
						<div className='flex justify-end items-center gap-2'>
							<div>
								Showing {currentPagePassenger * itemsPerPagePassenger + 1} -{' '}
								{Math.min(
									(currentPagePassenger + 1) * itemsPerPagePassenger,
									priced.length
								)}{' '}
								of {priced.length} passengers
							</div>
							<div className='flex space-x-2'>
								<button
									onClick={(e) => {
										e.stopPropagation();
										setCurrentPagePassenger((prev) => Math.max(prev - 1, 0));
									}}
									disabled={currentPagePassenger === 0}
									className='px-1 py-1 border rounded-full disabled:opacity-50'
								>
									<KeyboardArrowLeftIcon />
								</button>
								<button
									onClick={(e) => {
										e.stopPropagation();
										setCurrentPagePassenger((prev) =>
											(prev + 1) * itemsPerPagePassenger < priced.length
												? prev + 1
												: prev
										);
									}}
									disabled={
										(currentPagePassenger + 1) * itemsPerPagePassenger >=
										priced.length
									}
									className='px-1 py-1 border rounded-full disabled:opacity-50'
								>
									<KeyboardArrowRightIcon />
								</button>
							</div>
						</div>
					</div>
				</div>
			)}
		</div>
	);
}
