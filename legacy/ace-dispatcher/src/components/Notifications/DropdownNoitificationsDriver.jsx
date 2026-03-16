/** @format */
/** @format */

import { useEffect, useRef, useState } from "react";
import { useDispatch, useSelector } from "react-redux";

import { useViewport } from "../../hooks/useViewport";
import { getHeight } from "../../utils/dom";
import {
  markAsAllReadNotifications,
  markAsReadNotification,
} from "../../context/notificationSlice";
import { DropdownNotificationsItem } from "./Items/DropdownNotificationsItem";

const DropdownNotificationsDriver = () => {
  const dispatch = useDispatch();
  const { driverNotifications } = useSelector((state) => state.notification);
  const footerRef = useRef(null);
  const [listHeight, setListHeight] = useState(0);
  const [viewportHeight] = useViewport();
  const offset = 300;

  const latestDriverNotification = [...driverNotifications].sort(
    (a, b) => new Date(b?.dateTimeStamp) - new Date(a?.dateTimeStamp)
  );

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
    const type = 2;
    dispatch(markAsAllReadNotifications(type));
  };

  const buildList = () => {
    return (
      <div className="flex flex-col gap-5 pt-3 pb-4 divider-y divider-gray-200">
        {latestDriverNotification.length > 0 ? (
          latestDriverNotification.map((notification) => (
            <DropdownNotificationsItem
              key={notification.id}
              notification={notification}
              markAsRead={markAsRead}
            />
          ))
        ) : (
          <div className="text-center text-gray-500 p-4">No notifications</div>
        )}
      </div>
    );
  };
  const buildFooter = () => {
    return (
      <>
        <div className="border-b border-b-gray-200"></div>
        <div className="grid grid-cols-1 p-5 gap-2.5">
          {/* <button className='btn btn-sm btn-light justify-center'>
						Archive all
					</button> */}
          <button
            className="bg-transparent hover:shadow-lg font-semibold w-full justify-center rounded-md p-2 border-gray-200 border text-gray-900"
            onClick={markAsAllRead}
          >
            Mark all as read
          </button>
        </div>
      </>
    );
  };
  return (
    <div className="grow">
      <div
        className="overflow-y-auto"
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
export { DropdownNotificationsDriver };
