/** @format */

// import { useLanguage } from '@/i18n';
import { KeenIcon } from '@/components';
import { MenuSub } from '@/components/menu';
import { Tab, TabPanel, Tabs, TabsList } from '@/components/tabs';
// import { DropdownCrud2 } from '@/partials/dropdowns/general';
import { DropdownNotificationsAll } from './DropdownNotificationsAll';
import { DropdownNotificationsInbox } from './DropdownNotificationsInbox';
import { DropdownNotificationsTeam } from './DropdownNotificationsTeam';
import { DropdownNotificationsFollowing } from './DropdownNotificationsFollowing';
import { useEffect, useRef } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { refreshNotifications } from '../../../slices/notificationSlice';
const DropdownNotifications = ({ menuTtemRef }) => {
	const dispatch = useDispatch();
	const { systemNotifications, driverNotifications, muteNotification } =
		useSelector((state) => state.notification);

	const lastSystemId = useRef(
		new Set(JSON.parse(localStorage.getItem('lastSystemId') || '[]'))
	);
	const lastDriverId = useRef(
		new Set(JSON.parse(localStorage.getItem('lastDriverId') || '[]'))
	);

	const addSeenId = (ref, storageKey, id) => {
		ref.current.add(id);
		localStorage.setItem(storageKey, JSON.stringify([...ref.current]));
	};
	// const systemAudio = useRef(new Audio(/media/audio/system_audio.mp3))
	const systemAudio = useRef(new Audio('/media/audio/new_web_booking.mp3'));
	const driverAudio = useRef(new Audio('/media/audio/driver_audio.mp3'));
	// const { isRTL } = useLanguage();

	// play sound helper
	const playSound = (type) => {
		if (type === 'system') {
			systemAudio.current
				.play()
				.catch((e) => console.log('System audio failed', e));
		} else if (type === 'driver') {
			driverAudio.current
				.play()
				.catch((e) => console.log('Driver audio failed', e));
		}
	};

	const checkNewNotifications = () => {
		if (systemNotifications?.length > 0) {
			const newestSystem = [...systemNotifications]
				.filter((n) => n.status === 0)
				.sort(
					(a, b) => new Date(b.dateTimeStamp) - new Date(a.dateTimeStamp)
				)[0];
			if (newestSystem && !lastSystemId.current.has(newestSystem.id)) {
				lastSystemId.current.add(newestSystem.id);
				if (!muteNotification) playSound('system');
				addSeenId(lastSystemId, 'lastSystemId', newestSystem.id);
			}
		}

		if (driverNotifications?.length > 0) {
			const newestDriver = [...driverNotifications]
				.filter((n) => n.status === 0)
				.sort(
					(a, b) => new Date(b.dateTimeStamp) - new Date(a.dateTimeStamp)
				)[0];
			if (newestDriver && !lastDriverId.current.has(newestDriver.id)) {
				lastDriverId.current.add(newestDriver.id);
				if (!muteNotification) playSound('driver');
				addSeenId(lastDriverId, 'lastDriverId', newestDriver.id);
			}
		}
	};

	const handleClose = () => {
		if (menuTtemRef.current) {
			menuTtemRef.current.hide(); // Call the closeMenu method to hide the submenu
		}
	};

	useEffect(() => {
		dispatch(refreshNotifications());
	}, [dispatch]);

	useEffect(() => {
		const intervalId = setInterval(() => {
			dispatch(refreshNotifications());
		}, 15000);

		return () => clearInterval(intervalId); // Cleanup function to clear timeout on unmount
	}, [dispatch]);

	useEffect(() => {
		checkNewNotifications();
	}, [systemNotifications, driverNotifications]);

	const buildHeader = () => {
		return (
			<div className='flex items-center justify-between gap-2.5 text-sm text-gray-900 font-semibold px-5 py-2.5 border-b border-b-gray-200'>
				Notifications
				<button
					className='btn btn-sm btn-icon btn-light btn-clear shrink-0'
					onClick={handleClose}
				>
					<KeenIcon icon='cross' />
				</button>
			</div>
		);
	};
	const buildTabs = () => {
		return (
			<Tabs
				defaultValue={1}
				className=''
			>
				<TabsList className='justify-between px-5 mb-2'>
					<div className='flex items-center gap-5'>
						<Tab value={1}>All</Tab>
						<Tab
							value={2}
							className='relative'
						>
							System
							<span className='badge badge-dot badge-success size-[5px] absolute top-2 rtl:start-0 end-0 transform translate-y-1/2 translate-x-full'></span>
						</Tab>
						<Tab value={3}>Driver</Tab>
						{/* <Tab value={4}>Following</Tab> */}
					</div>
					{/* <Menu>
						<MenuItem
							toggle='dropdown'
							trigger='click'
							dropdownProps={{
								placement: isRTL() ? 'bottom-start' : 'bottom-end',
								modifiers: [
									{
										name: 'offset',
										options: {
											offset: isRTL() ? [0, -10] : [0, 10], // [skid, distance]
										},
									},
								],
							}}
						>
							<MenuToggle className='btn btn-sm btn-icon btn-light btn-clear'>
								<KeenIcon icon='setting-2' />
							</MenuToggle>
							{DropdownCrud2()}
						</MenuItem>
					</Menu> */}
				</TabsList>
				<TabPanel value={1}>
					<DropdownNotificationsAll />
				</TabPanel>
				<TabPanel value={2}>
					<DropdownNotificationsInbox />
				</TabPanel>
				<TabPanel value={3}>
					<DropdownNotificationsTeam />
				</TabPanel>
				<TabPanel value={4}>
					<DropdownNotificationsFollowing />
				</TabPanel>
			</Tabs>
		);
	};
	return (
		<MenuSub
			rootClassName='w-full max-w-[460px]'
			className='light:border-gray-300'
		>
			{buildHeader()}
			{buildTabs()}
		</MenuSub>
	);
};
export { DropdownNotifications };
