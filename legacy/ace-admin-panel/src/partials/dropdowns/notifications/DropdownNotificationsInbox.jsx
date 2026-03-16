/** @format */

import { useEffect, useRef, useState } from 'react';
import { getHeight } from '@/utils';
import { useViewport } from '@/hooks';
import { useDispatch, useSelector } from 'react-redux';
import {
	markAsAllReadNotifications,
	markAsReadNotification,
} from '../../../slices/notificationSlice';
import { DropdownNotificationsItem } from './items';
// import { DropdownNotificationsItem10, DropdownNotificationsItem11, DropdownNotificationsItem12, DropdownNotificationsItem13, DropdownNotificationsItem3, DropdownNotificationsItem5 } from './items';
const DropdownNotificationsInbox = () => {
	const dispatch = useDispatch();
	const { systemNotifications } = useSelector((state) => state.notification);
	const footerRef = useRef(null);
	const [listHeight, setListHeight] = useState(0);
	const [viewportHeight] = useViewport();
	const offset = 300;

	const latestSystemNotification = [...systemNotifications].sort(
		(a, b) => new Date(b?.dateTimeStamp) - new Date(a?.dateTimeStamp)
	);

	// console.log(
	// 	'notifications---',
	// 	systemNotifications,
	// 	latestSystemNotification
	// );

	useEffect(() => {
		if (footerRef.current) {
			const footerHeight = getHeight(footerRef.current);
			const availableHeight = viewportHeight - footerHeight - offset;
			setListHeight(availableHeight);
		}
	}, [viewportHeight]);

	const markAsRead = async (id) => {
		dispatch(markAsReadNotification(id));
	};

	const markAsAllRead = () => {
		const type = 1;
		dispatch(markAsAllReadNotifications(type));
	};

	const buildList = () => {
		return (
			<div className='flex flex-col gap-5 pt-3 pb-4 divider-y divider-gray-200'>
				{latestSystemNotification.length > 0 ? (
					latestSystemNotification.map((notification) => (
						<DropdownNotificationsItem
							key={notification.id}
							notification={notification}
							markAsRead={markAsRead}
						/>
					))
				) : (
					<div className='text-center text-gray-500 p-4'>No notifications</div>
				)}
				{/* <DropdownNotificationsItem10 />

        <div className="border-b border-b-gray-200"></div>

        <DropdownNotificationsItem11 />

        <div className="border-b border-b-gray-200"></div>

        <DropdownNotificationsItem12 />

        <div className="border-b border-b-gray-200"></div>

        <DropdownNotificationsItem13 />

        <div className="border-b border-b-gray-200"></div>

        <DropdownNotificationsItem3 userName="Benjamin Harris" avatar="300-30.png" badgeColor="bg-gray-400" description="requested to upgrade plan" link="" day="" date="4 days ago" info="Marketing" />

        <div className="border-b border-b-gray-200"></div>

        <DropdownNotificationsItem5 userName="Isaac Morgan" avatar="300-24.png" badgeColor="badge-success" description="mentioned you in" link="Data Transmission" day="topic" date="6 days ago" info="Dev Team" /> */}
			</div>
		);
	};
	const buildFooter = () => {
		return (
			<>
				<div className='border-b border-b-gray-200'></div>
				<div className='grid grid-cols-2 p-5 gap-2.5'>
					{/* <button className='btn btn-sm btn-light justify-center'>
						Archive all
					</button> */}
					<button
						className='btn btn-sm btn-light justify-center'
						onClick={markAsAllRead}
					>
						Mark all as Read
					</button>
				</div>
			</>
		);
	};
	return (
		<div className='grow'>
			<div
				className='scrollable-y-auto'
				style={{
					maxHeight: `${listHeight}px`,
				}}
			>
				{buildList()}
			</div>
			<div ref={footerRef}>{buildFooter()}</div>
		</div>
	);
};
export { DropdownNotificationsInbox };
