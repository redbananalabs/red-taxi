/** @format */

import { Fragment } from 'react';
import { toAbsoluteUrl } from '@/utils/Assets';
import { useSelector } from 'react-redux';
import { KeenIcon } from '../../../../../components';
const ChannelStats = () => {
	const { data } = useSelector((state) => state.dashboard);

	const items = [
		{
			icon: 'car',
			info: data?.bookingsTodayCount || 0,
			desc: 'Today Bookings',
			color: 'bg-danger',
		},
		{
			icon: 'briefcase',
			info: data?.jobsBookedTodayCount || 0,
			desc: 'Jobs Booked Today',
			color: 'bg-primary',
		},
		{
			icon: 'users',
			info: data?.driversCount || 0,
			desc: 'Drivers',
			color: 'bg-cyan-400',
		},
		{
			icon: 'map',
			info: data?.poisCount || 0,
			desc: 'POIs',
			color: 'bg-success',
		},
		{
			icon: 'underlining',
			info: data?.unallocatedTodayCount || 0,
			desc: 'Today Unallocated',
			color: 'bg-purple-400',
		},
		{
			icon: 'user',
			info:
				data?.customerAquireCounts?.find((entry) => entry.periodWhen === 0) // ✅ Find the correct object
					?.new || 0,
			desc: 'Day New Customer',
			color: 'bg-danger',
		},
		{
			icon: 'user-tick',
			info:
				data?.customerAquireCounts?.find((entry) => entry.periodWhen === 1) // ✅ Find the correct object
					?.new || 0,
			desc: 'Week New Customer',
			color: 'bg-sky-400',
		},
		{
			icon: 'user-square',
			info:
				data?.customerAquireCounts?.find((entry) => entry.periodWhen === 2) // ✅ Find the correct object
					?.new || 0,
			desc: 'Month New Customer',
			color: 'bg-teal-400',
		},
		{
			icon: 'users',
			info:
				data?.customerAquireCounts?.find((entry) => entry.periodWhen === 0) // ✅ Find the correct object
					?.returning || 0,
			desc: 'Day Returning Customer',
			color: 'bg-success',
		},
		{
			icon: 'user-edit',
			info:
				data?.customerAquireCounts?.find((entry) => entry.periodWhen === 1) // ✅ Find the correct object
					?.returning || 0,
			desc: 'Week Returning Customer',
			color: 'bg-orange-400',
		},
		{
			icon: 'user',
			info:
				data?.customerAquireCounts?.find((entry) => entry.periodWhen === 2) // ✅ Find the correct object
					?.returning || 0,
			desc: 'Month Returning Customer',
			color: 'bg-cyan-400',
		},
	];
	const renderItem = (item, index) => {
		return (
			<div
				key={index}
				className={`card flex-col justify-between gap-6 h-full bg-cover rtl:bg-[left_top_-1.7rem] bg-[right_top_-1.7rem] bg-no-repeat channel-stats-bg ${item?.color}`}
			>
				<div className='w-7 mt-4 ms-5'>
					<KeenIcon
						icon={item.icon}
						className="text-3xl font-bold text-white"
					/>
				</div>

				<div className='flex flex-col gap-1 pb-4 px-5'>
					<span className='text-3xl font-bold text-white'>
						{item.info}
					</span>
					<span className='text-2sm font-semibold text-white'>
						{item.desc}
					</span>
				</div>
			</div>
		);
	};
	return (
		<Fragment>
			<style>
				{`
          .channel-stats-bg {
            background-image: url('${toAbsoluteUrl('/media/images/2600x1600/bg-3.png')}');
          }
          .dark .channel-stats-bg {
            background-image: url('${toAbsoluteUrl('/media/images/2600x1600/bg-3-dark.png')}');
          }
        `}
			</style>

			{items.map((item, index) => {
				return renderItem(item, index);
			})}
		</Fragment>
	);
};
export { ChannelStats };
