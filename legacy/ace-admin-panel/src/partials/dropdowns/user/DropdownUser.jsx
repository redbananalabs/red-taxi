/** @format */

import { Fragment, useState } from 'react';
import { Link } from 'react-router-dom';
import { FormattedMessage } from 'react-intl';
// import { useAuthContext } from '@/auth';
// import { useLanguage } from '@/i18n';
import { toAbsoluteUrl } from '@/utils';
import { DropdownUserLanguages } from './DropdownUserLanguages';
import { useSettings } from '@/providers/SettingsProvider';
import {
	// DefaultTooltip,
	KeenIcon,
} from '@/components';
import {
	MenuItem,
	// MenuLink,
	MenuSub,
	// MenuTitle,
	MenuSeparator,
	// MenuArrow,
	// MenuIcon,
} from '@/components/menu';
import { useSelector, useDispatch } from 'react-redux'; // Import useSelector
import { logout } from '../../../service/operations/authApi';
import { useNavigate } from 'react-router-dom'; // Import useLocation
import { setIsNotifications } from '../../../slices/authSlice';
import { removeFCM } from '../../../service/operations/gpsApi';
import toast from 'react-hot-toast';
import { setMuteNotification } from '../../../slices/notificationSlice';
import TicketRaiseModal from './TicketRaiseModal';
const DropdownUser = ({ menuItemRef }) => {
	const { user, isNotifications } = useSelector((state) => state.auth);
	const { muteNotification } = useSelector((state) => state.notification);
	const { settings, storeSettings } = useSettings();
	const [isDarkSidebar, setIsDarkSidebar] = useState(false);
	const [isTicketRaiseModalOpen, setIsTicketRaiseModalOpen] = useState(false);

	// const {
	//   logout
	// } = logout();
	// const { isRTL } = useLanguage();
	const handleThemeMode = (event) => {
		const newThemeMode = event.target.checked ? 'dark' : 'light';
		storeSettings({
			themeMode: newThemeMode,
		});
		if (menuItemRef.current) {
			menuItemRef.current.hide(); // Call the closeMenu method to hide the submenu
		}
	};

	const dispatch = useDispatch();
	const navigate = useNavigate();

	const handleNotificationToggle = async () => {
		const newValue = !isNotifications;
		dispatch(setIsNotifications(newValue));
		localStorage.setItem('FCM', newValue);
		localStorage.setItem('isNotification', newValue);
		if (!newValue) {
			// user just turned notifications OFF
			try {
				const response = await removeFCM();
				if (response?.status === 'success') {
					toast.success('Notifications turned off successfully');
				}
			} catch (error) {
				console.log(error);
				toast.error('Failed to turn off notifications');
			} finally {
				if (menuItemRef.current) {
					menuItemRef.current.hide(); // Call the closeMenu method to hide the submenu
				}
			}
		}
	};

	// 🔹 Fetch user data from Redux

	// 🔹 Safely get fullName (fallback if undefined)
	const fullName = user?.fullName || 'Guest User';
	const email = user?.email || '';

	const buildHeader = () => {
		return (
			<div className='flex items-center justify-between px-5 py-1.5 gap-1.5'>
				<div className='flex items-center gap-2'>
					<img
						className='size-9 rounded-full border-2 border-success'
						src={toAbsoluteUrl('/media/app/favicon.ico')}
						alt=''
					/>
					<div className='flex flex-col gap-1.5'>
						<Link
							to='/account/hoteme/get-stard'
							className='text-sm text-gray-800 hover:text-primary font-semibold leading-none'
						>
							{fullName} {/* ✅ Dynamic fullName from Redux */}
						</Link>
						<a
							href='mailto:c.fisher@gmail.com'
							className='text-xs text-gray-600 hover:text-primary font-medium leading-none'
						>
							{email} {/* ✅ Dynamic email */}
						</a>
					</div>
				</div>
				<span className='badge badge-xs badge-primary badge-outline'>Pro</span>
			</div>
		);
	};
	const buildMenu = () => {
		return (
			<Fragment>
				<MenuSeparator />
				<div className='flex flex-col'>
					<MenuItem>
						{/* <MenuLink path="/public-profile/profiles/default">
              <MenuIcon className="menu-icon">
                <KeenIcon icon="badge" />
              </MenuIcon>
              <MenuTitle>
                <FormattedMessage id="USER.MENU.PUBLIC_PROFILE" />
              </MenuTitle>
            </MenuLink> */}
					</MenuItem>
					<MenuItem>
						{/* <MenuLink path="/account/home/user-profile">
              <MenuIcon>
                <KeenIcon icon="profile-circle" />
              </MenuIcon>
              <MenuTitle>
                <FormattedMessage id="USER.MENU.MY_PROFILE" />
              </MenuTitle>
            </MenuLink> */}
					</MenuItem>
					{/* <MenuItem toggle="dropdown" trigger="hover" dropdownProps={{
          placement: isRTL() ? 'left-start' : 'right-start',
          modifiers: [{
            name: 'offset',
            options: {
              offset: isRTL() ? [50, 0] : [-50, 0] // [skid, distance]
            }
          }]
        }}>
            <MenuLink>
              <MenuIcon>
                <KeenIcon icon="setting-2" />
              </MenuIcon>
              <MenuTitle>
                <FormattedMessage id="USER.MENU.MY_ACCOUNT" />
              </MenuTitle>
              <MenuArrow>
                <KeenIcon icon="right" className="text-3xs rtl:transform rtl:rotate-180" />
              </MenuArrow>
            </MenuLink>
            <MenuSub className="menu-default light:border-gray-300 w-[200px]] md:w-[220px]">
              <MenuItem>
                <MenuLink path="/account/home/get-started">
                  <MenuIcon>
                    <KeenIcon icon="coffee" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.GET_STARTED" />
                  </MenuTitle>
                </MenuLink>
              </MenuItem>
              <MenuItem>
                <MenuLink path="/account/home/user-profile">
                  <MenuIcon>
                    <KeenIcon icon="some-files" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.MY_PROFILE" />
                  </MenuTitle>
                </MenuLink>
              </MenuItem>
              <MenuItem>
                <MenuLink path="/account/billing/basic">
                  <MenuIcon>
                    <KeenIcon icon="icon" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.BILLING" />
                  </MenuTitle>
                  <DefaultTooltip title={<FormattedMessage id="USER.MENU.PAYMENT_&_SUBSCRIPTION_INFO" />} placement="top" className="max-w-48">
                    <KeenIcon icon="information-2" className="text-gray-500 text-md" />
                  </DefaultTooltip>
                </MenuLink>
              </MenuItem>
              <MenuItem>
                <MenuLink path="/account/security/overview">
                  <MenuIcon>
                    <KeenIcon icon="medal-star" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.SECURITY" />
                  </MenuTitle>
                </MenuLink>
              </MenuItem>
              <MenuItem>
                <MenuLink path="/account/members/teams">
                  <MenuIcon>
                    <KeenIcon icon="setting" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.MEMBERS_&_ROLES" />
                  </MenuTitle>
                </MenuLink>
              </MenuItem>
              <MenuItem>
                <MenuLink path="/account/integrations">
                  <MenuIcon>
                    <KeenIcon icon="switch" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.INTEGRATIONS" />
                  </MenuTitle>
                </MenuLink>
              </MenuItem>
              <MenuSeparator />
              <MenuItem>
                <MenuLink path="/account/security/overview">
                  <MenuIcon>
                    <KeenIcon icon="shield-tick" />
                  </MenuIcon>
                  <MenuTitle>
                    <FormattedMessage id="USER.MENU.NOTIFICATIONS" />
                  </MenuTitle>
                  <label className="switch switch-sm">
                    <input name="check" type="checkbox" checked onChange={() => {}} value="1" />
                  </label>
                </MenuLink>
              </MenuItem>
            </MenuSub>
          </MenuItem> */}
					<MenuItem>
						{/* <MenuLink path="https://devs.keenthemes.com">
              <MenuIcon>
                <KeenIcon icon="message-programming" />
              </MenuIcon>
              <MenuTitle>
                <FormattedMessage id="USER.MENU.DEV_FORUM" />
              </MenuTitle>
            </MenuLink> */}
					</MenuItem>
					<DropdownUserLanguages menuItemRef={menuItemRef} />
					<MenuSeparator />
				</div>
			</Fragment>
		);
	};
	const buildFooter = () => {
		return (
			<div className='flex flex-col'>
				<div className='menu-item mb-0.5'>
					<div className='menu-link'>
						<span className='menu-icon'>
							<KeenIcon icon='moon' />
						</span>
						<span className='menu-title'>
							<FormattedMessage id='USER.MENU.DARK_MODE' />
						</span>
						<label className='switch switch-sm'>
							<input
								name='theme'
								type='checkbox'
								checked={settings.themeMode === 'dark'}
								onChange={handleThemeMode}
								value='1'
							/>
						</label>
					</div>
				</div>

				<div className='menu-item mb-0.5'>
					<div className='menu-link'>
						<span className='menu-icon'>
							<KeenIcon icon='element-3' />
						</span>
						<span className='menu-title'>
							<FormattedMessage id='Dark Sidebar' />
						</span>
						<label className='switch switch-sm'>
							<input
								name='theme'
								type='checkbox'
								checked={isDarkSidebar}
								onChange={() => {
									setIsDarkSidebar(!isDarkSidebar);
									!isDarkSidebar ? navigate('/dark-sidebar') : navigate('/');
									if (menuItemRef.current) {
										menuItemRef.current.hide(); // Call the closeMenu method to hide the submenu
									}
								}}
								value='1'
							/>
						</label>
					</div>
				</div>

				<div className='menu-item mb-0.5'>
					<div className='menu-link'>
						<span className='menu-icon'>
							<KeenIcon icon='notification-bing' />
						</span>
						<span className='menu-title'>
							<FormattedMessage id='Notifications' />
						</span>
						<label className='switch switch-sm'>
							<input
								name='theme'
								type='checkbox'
								checked={isNotifications}
								onChange={handleNotificationToggle}
								value='1'
							/>
						</label>
					</div>
				</div>

				<div className='menu-item mb-0.5'>
					<div className='menu-link'>
						<span className='menu-icon'>
							<KeenIcon icon='notification-on' />
						</span>
						<span className='menu-title'>
							<FormattedMessage id='Mute Notifications' />
						</span>
						<label className='switch switch-sm'>
							<input
								name='theme'
								type='checkbox'
								checked={muteNotification}
								onChange={() => {
									console.log('Mute notification toggled', muteNotification);
									dispatch(setMuteNotification(!muteNotification));
									if (menuItemRef.current) {
										menuItemRef.current.hide(); // Call the closeMenu method to hide the submenu
									}
								}}
								value='1'
							/>
						</label>
					</div>
				</div>

				<div className='menu-item mb-0.5'>
					<div className='menu-link'>
						<span className='menu-icon'>
							<KeenIcon icon='receipt-square' />
						</span>
						<span
							className='menu-title'
							onClick={() => setIsTicketRaiseModalOpen(true)}
						>
							<FormattedMessage id='Ticket Raise' />
						</span>
					</div>
				</div>

				<div className='menu-item px-4 py-1.5'>
					<a
						onClick={() => {
							console.log('Logout button clicked');
							dispatch(logout(navigate));
						}}
						className='btn btn-sm btn-light justify-center'
					>
						<FormattedMessage id='USER.MENU.LOGOUT' />
					</a>
				</div>
			</div>
		);
	};

	const handleClose = () => {
		setIsTicketRaiseModalOpen(false);
		if (menuItemRef.current) {
			menuItemRef.current.hide(); // Call the closeMenu method to hide the submenu
		}
	};

	return (
		<MenuSub
			className='menu-default light:border-gray-300 w-[200px] md:w-[250px]'
			rootClassName='p-0'
		>
			{buildHeader()}
			{buildMenu()}
			{buildFooter()}
			{isTicketRaiseModalOpen && (
				<TicketRaiseModal
					open={isTicketRaiseModalOpen}
					onClose={handleClose}
				/>
			)}
		</MenuSub>
	);
};
export { DropdownUser };
