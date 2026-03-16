/** @format */

import {
	ChannelStats,
	// EarningsChart,
	EntryCallout,
	// Highlights,
	// TeamMeeting,
	Teams,
} from './blocks';
import { DayEarning } from './blocks/DriverDaysEarning';
const Demo1LightSidebarContent = () => {
	return (
		<div className='grid gap-5 lg:gap-7.5'>
			<div className='grid lg:grid-cols-2 gap-y-5 lg:gap-7.5 items-stretch'>
				<div className='lg:col-span-1'>
					<DayEarning className='h-full' />
				</div>
				<div className='lg:col-span-1'>
					<EntryCallout className='h-full' />

					<div className='lg:col-span-2 mt-4'>
						<Teams />
					</div>
				</div>
			</div>

			<div className='grid grid-cols-2 md:grid-col-4 lg:grid-cols-5 gap-5 lg:gap-7.5 h-full items-stretch'>
				<ChannelStats />
			</div>

			<div className='grid lg:grid-cols-3 gap-5 lg:gap-7.5 items-stretch'>
				<div className='lg:col-span-1'>{/* <Highlights limit={3} /> */}</div>

				<div className='lg:col-span-2'>{/* <EarningsChart /> */}</div>
			</div>

			{/* <div className='grid lg:grid-cols-3 gap-5 lg:gap-7.5 items-stretch'>
				<div className='lg:col-span-1'><TeamMeeting /></div>
			</div> */}
		</div>
	);
};
export { Demo1LightSidebarContent };
