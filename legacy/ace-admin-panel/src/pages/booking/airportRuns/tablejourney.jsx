/** @format */
import KeyboardArrowRightIcon from '@mui/icons-material/KeyboardArrowRight';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import React, { useState } from 'react';
import { useSelector } from 'react-redux';

const Tablejourney = ({ month }) => {
	const [expandedDrivers, setExpandedDrivers] = useState({});
	const { lastJourney } = useSelector((state) => state.booking);

	const groupedJourneys = lastJourney?.reduce((acc, journey) => {
		if (!acc[journey.userId]) {
			acc[journey.userId] = {
				driver: journey.identifier, // "3 - Bex Sims"
				color: journey.color, // Background color
				journeys: [],
			};
		}
		acc[journey.userId].journeys.push({
			date: new Date(journey.date).toLocaleString('en-GB'), // Format date
			from: journey.pickup,
			to: journey.destin,
			price: journey.price.toFixed(2),
		});
		return acc;
	}, {});

	const toggleDriver = (driverId) => {
		setExpandedDrivers((prev) => ({
			...prev,
			[driverId]: !prev[driverId],
		}));
	};

	return (
		<div className='container mx-auto mt-5'>
			<h2 className='text-xl font-bold mb-3'>
				Airport Journeys - {month} Month
			</h2>
			{lastJourney?.length > 0 ? (
				<table className='w-full border-collapse border border-gray-300'>
					<thead>
						<tr>
							<th className='border border-gray-300 px-4 text-start py-2 text-gray-700'>
								<span className='ms-6'>Date</span>
							</th>
							<th className='border border-gray-300 text-start px-4 py-2 text-gray-700'>
								<span className=''>Journey</span>
							</th>
							<th className='border border-gray-300 text-start px-4 py-2 w-28 whitespace-nowrap text-gray-700'>
								<span className=''>Price (£)</span>
							</th>
						</tr>
					</thead>
					<tbody>
						{Object.entries(groupedJourneys).map(([driverId, driver]) => (
							<React.Fragment key={driverId}>
								<tr
									className='bg-gray-100 cursor-pointer'
									onClick={() => toggleDriver(driverId)}
								>
									<td
										colSpan='3'
										className='border border-gray-300 px-4 py-2 font-semibold'
									>
										<span className='-ms-1 text-gray-700'>
											{expandedDrivers[driverId] ? (
												<KeyboardArrowDownIcon />
											) : (
												<KeyboardArrowRightIcon />
											)}{' '}
											Driver #: {driver.driver}
										</span>
									</td>
								</tr>
								{expandedDrivers[driverId] &&
									driver.journeys.map((journey, index) => (
										<tr
											key={index}
											className='border-t'
										>
											<td className='border border-gray-300 px-4 py-2'>
												<span className='ms-6'>{journey.date}</span>
											</td>
											<td className='border border-gray-300 px-4 py-2'>
												{journey.from} → {journey.to}
											</td>
											<td className='border border-gray-300 px-4 py-2'>
												£{journey?.price}
											</td>
										</tr>
									))}
							</React.Fragment>
						))}
					</tbody>
				</table>
			) : (
				<div className='p-3 text-center text-gray-500 dark:text-gray-400'>
					No journeys available
				</div>
			)}
		</div>
	);
};

export { Tablejourney };
