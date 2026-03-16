/** @format */

// import { useLanguage } from '@/i18n';
import CloseOutlinedIcon from '@mui/icons-material/CloseOutlined';
import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { setMuteNotification } from '../../context/notificationSlice';
import { DropdownNotificationsSystem } from './DropdownNoitificationsSystem';
import { DropdownNotificationsDriver } from './DropdownNoitificationsDriver';
import { DropdownNotificationsAll } from './DropdownNotificationsAll';
import { Box, Tab, Tabs } from '@mui/material';
import VolumeUpOutlinedIcon from '@mui/icons-material/VolumeUpOutlined';
import VolumeMuteOutlinedIcon from '@mui/icons-material/VolumeMuteOutlined';
const DropdownNotifications = ({ setNotificationOpen }) => {
	const dispatch = useDispatch();
	const [secondaryTab, setSecondaryTab] = useState(0);
	const { muteNotification } = useSelector((state) => state.notification);

	return (
		<Box className='border-gray-300 border rounded-md max-w-[460px] overflow-hidden mt-0 mb-0 mx-auto'>
			<div className='flex items-center justify-between gap-2.5  md:text-md text-sm text-gray-900 font-semibold px-2 py-2.5 border-b border-b-gray-200'>
				<span className='ml-5 flex justify-center items-center gap-2'>
					<span>Notifications</span>
					<button
						className='cursor-pointer'
						onClick={() => dispatch(setMuteNotification(!muteNotification))}
					>
						{!muteNotification ? (
							<VolumeUpOutlinedIcon
								fontSize='small'
								className='text-blue-500'
							/>
						) : (
							<VolumeMuteOutlinedIcon
								fontSize='small'
								className='text-gray-500'
							/>
						)}
					</button>
				</span>

				<button
					className='btn btn-sm btn-icon btn-light btn-clear shrink-0'
					onClick={() => setNotificationOpen(false)}
				>
					<CloseOutlinedIcon />
				</button>
			</div>
			<Tabs
				value={secondaryTab}
				sx={{
					position: 'sticky',
					top: 0,
					zIndex: 10,
					fontSize: '12px',
					padding: 0,
					textTransform: 'lowercase !important',
				}}
				className='text-gray-900 rounded-md border-b border-b-gray-200'
				onChange={(event, newValue) => setSecondaryTab(newValue)}
				// variant='scrollable'
				scrollButtons
				allowScrollButtonsMobile
				// aria-label='scrollable force tabs example'
			>
				<Tab label={<span style={{ textTransform: 'none' }}>All</span>} />
				<Tab label={<span style={{ textTransform: 'none' }}>System</span>} />
				<Tab label={<span style={{ textTransform: 'none' }}>Driver</span>} />
			</Tabs>
			{secondaryTab === 0 && <DropdownNotificationsAll />}
			{secondaryTab === 1 && <DropdownNotificationsSystem />}
			{secondaryTab === 2 && <DropdownNotificationsDriver />}
		</Box>
	);
};
export { DropdownNotifications };
