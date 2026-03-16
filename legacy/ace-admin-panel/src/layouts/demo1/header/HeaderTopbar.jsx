/** @format */

import { useEffect, useRef, useState } from 'react';
import { KeenIcon } from '@/components/keenicons';
import { toAbsoluteUrl } from '@/utils';
import { Menu, MenuItem, MenuToggle } from '@/components';
import { DropdownUser } from '@/partials/dropdowns/user';
import { DropdownNotifications } from '@/partials/dropdowns/notifications';
import { DropdownApps } from '@/partials/dropdowns/apps';
import { DropdownChat } from '@/partials/dropdowns/chat';
// import { ModalSearch } from '@/partials/modals/search/ModalSearch';
import { useLanguage } from '@/i18n';
import { useDispatch, useSelector } from 'react-redux';
import { refreshSmsHeartBeat } from '../../../slices/dashboardSlice';
import { clearUnreadCount } from '../../../slices/notificationSlice';
const HeaderTopbar = () => {
	const dispatch = useDispatch();
	const { unreadCount } = useSelector((state) => state.notification);
	const { smsHeartBeat } = useSelector((state) => state.dashboard);
	const [smsHeartBeatColor, setSmsHeartBeatColor] = useState();
	const { isRTL } = useLanguage();
	const itemChatRef = useRef(null);
	const itemAppsRef = useRef(null);
	const itemUserRef = useRef(null);
	const itemNotificationsRef = useRef(null);
	const handleShow = () => {
		window.dispatchEvent(new Event('resize'));
	};
	// const [searchModalOpen, setSearchModalOpen] = useState(false);
	// const handleOpen = () => setSearchModalOpen(true);
	// const handleClose = () => {
	// 	setSearchModalOpen(false);
	// };

	useEffect(() => {
		dispatch(refreshSmsHeartBeat());
	}, [dispatch]);

	useEffect(() => {
		const interval = setInterval(() => {
			dispatch(refreshSmsHeartBeat());
		}, 15000); // 1 minute interval
		return () => clearInterval(interval); // Cleanup on unmount
	}, [dispatch]);

	useEffect(() => {
		const checkHeartBeat = () => {
			if (!smsHeartBeat) return;

			const now = new Date();
			const heartBeatTime = new Date(smsHeartBeat);
			const diffInSeconds = (now - heartBeatTime) / 1000;

			if (diffInSeconds > 120 || diffInSeconds < -120) {
				setSmsHeartBeatColor({ light: 'bg-danger', dark: 'bg-danger' });
			} else {
				setSmsHeartBeatColor({ light: 'bg-green-400', dark: 'bg-green-700' });
			}
		};

		checkHeartBeat();
	}, [smsHeartBeat]);

	return (
		<div className='flex items-center gap-2 lg:gap-3.5'>
			{/* <button onClick={handleOpen} className="btn btn-icon btn-icon-lg size-9 rounded-full hover:bg-primary-light hover:text-primary text-gray-500">
        <KeenIcon icon="magnifier" />
      </button>
      <ModalSearch open={searchModalOpen} onOpenChange={handleClose} /> */}

			<Menu>
				<MenuItem
					ref={itemChatRef}
					onShow={handleShow}
					toggle='dropdown'
					trigger='click'
					dropdownProps={{
						placement: isRTL() ? 'bottom-start' : 'bottom-end',
						modifiers: [
							{
								name: 'offset',
								options: {
									offset: isRTL() ? [-170, 10] : [170, 10],
								},
							},
						],
					}}
				>
					{/* <MenuToggle className='btn btn-icon btn-icon-lg size-9 rounded-full hover:bg-primary-light hover:text-primary dropdown-open:bg-primary-light dropdown-open:text-primary text-gray-500'>
						<KeenIcon icon='messages' />
					</MenuToggle> */}

					{DropdownChat({
						menuTtemRef: itemChatRef,
					})}
				</MenuItem>
			</Menu>

			<Menu>
				<MenuItem
					ref={itemAppsRef}
					toggle='dropdown'
					trigger='click'
					dropdownProps={{
						placement: isRTL() ? 'bottom-start' : 'bottom-end',
						modifiers: [
							{
								name: 'offset',
								options: {
									offset: isRTL() ? [-10, 10] : [10, 10],
								},
							},
						],
					}}
				>
					{/* <MenuToggle className="btn btn-icon btn-icon-lg size-9 rounded-full hover:bg-primary-light hover:text-primary dropdown-open:bg-primary-light dropdown-open:text-primary text-gray-500">
            <KeenIcon icon="element-11" />
          </MenuToggle> */}

					{DropdownApps()}
				</MenuItem>
			</Menu>

			{smsHeartBeat && (
				<div
					className={`flex justify-center items-center ${smsHeartBeatColor?.light} dark:${smsHeartBeatColor?.dark} text-2xs sm:text-sm text-white px-2 sm:px-3 py-1 sm:py-2 rounded-md`}
				>
					SMS HEARTBEAT{' '}
					{new Date(smsHeartBeat?.split('T')[0]).toLocaleDateString('en-GB')}{' '}
					{smsHeartBeat?.split('T')[1].split('.')[0]}
				</div>
			)}

			<Menu>
				<MenuItem
					ref={itemNotificationsRef}
					toggle='dropdown'
					trigger='click'
					onClick={() => dispatch(clearUnreadCount())}
					dropdownProps={{
						placement: isRTL() ? 'bottom-start' : 'bottom-end',
						modifiers: [
							{
								name: 'offset',
								options: {
									offset: isRTL() ? [-70, 10] : [70, 10], // [skid, distance]
								},
							},
						],
					}}
				>
					<MenuToggle className='btn btn-icon btn-icon-lg relative cursor-pointer size-9 rounded-full hover:bg-primary-light hover:text-primary dropdown-open:bg-primary-light dropdown-open:text-primary text-gray-500'>
						<div
							className={`relative ${unreadCount > 0 ? 'animate-pulse' : ''}`}
						>
							<KeenIcon
								icon='notification-status'
								className='text-gray-500'
							/>
							{unreadCount > 0 && (
								<span className='absolute -top-2 right-0 bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full'>
									{unreadCount}
								</span>
							)}
						</div>
					</MenuToggle>

					{DropdownNotifications({
						menuTtemRef: itemNotificationsRef,
					})}
				</MenuItem>
			</Menu>

			<Menu>
				<MenuItem
					ref={itemUserRef}
					toggle='dropdown'
					trigger='click'
					dropdownProps={{
						placement: isRTL() ? 'bottom-start' : 'bottom-end',
						modifiers: [
							{
								name: 'offset',
								options: {
									offset: isRTL() ? [-20, 10] : [20, 10], // [skid, distance]
								},
							},
						],
					}}
				>
					<MenuToggle className='btn btn-icon rounded-full'>
						<img
							className='size-9 rounded-full border-2 border-success shrink-0'
							src={toAbsoluteUrl('/media/app/mini-logo.svg')}
							alt=''
						/>
					</MenuToggle>
					{DropdownUser({
						menuItemRef: itemUserRef,
					})}
				</MenuItem>
			</Menu>
		</div>
	);
};
export { HeaderTopbar };
