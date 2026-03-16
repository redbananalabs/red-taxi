/** @format */

import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { Box, TextField, useMediaQuery, Switch, Button } from '@mui/material';
import { useEffect, useRef, useState } from 'react';
import Modal from '../components/Modal';
import CallIcon from '@mui/icons-material/Call';
import Badge from '@mui/material/Badge';
import { useDispatch, useSelector } from 'react-redux';
// import { setActiveTestMode, setIsGoogleApiOn } from '../context/bookingSlice';
import {
	setActiveSectionMobileView,
	// setIsGoogleApiOn,
} from '../context/bookingSlice';

import {
	// changeActiveDate,
	handleSearchBooking,
	makeSearchInactive,
	setMergeMode,
	setSearchKeywords,
	// setDateControl,
	// makeSearchInactive,
} from '../context/schedulerSlice';
// import CancelIcon from '@mui/icons-material/Cancel';
import LogoImg from '../assets/ace_taxis_v4.svg';
import LongButton from '../components/BookingForm/LongButton';
import SearchIcon from '@mui/icons-material/Search';
import { useForm } from 'react-hook-form';
import {
	recordTurnDown,
	submitTicket,
	textMessageDirectly,
} from '../utils/apiReq';
import { openSnackbar } from '../context/snackbarSlice';
import PermPhoneMsgIcon from '@mui/icons-material/PermPhoneMsg';
import MailOutlineIcon from '@mui/icons-material/MailOutline';
import NotificationsNoneOutlinedIcon from '@mui/icons-material/NotificationsNoneOutlined';
import {
	clearUnreadCount,
	refreshNotifications,
} from '../context/notificationSlice';
import { DropdownNotifications } from '../components/Notifications/DropdownNotifications';
import {
	AirplaneTicketOutlined,
	CloudUploadOutlined,
} from '@mui/icons-material';
// import { formatDate } from '../utils/formatDate';
const Navbar = () => {
	const BASE_URL = import.meta.env.VITE_BASE_URL;
	const navigate = useNavigate();
	const { isAuth, logout, currentUser } = useAuth();
	const dispatch = useDispatch();
	const isMobile = useMediaQuery('(max-width:640px)');
	const isTablet = useMediaQuery('(min-width: 768px) and (max-width: 1023px)');

	// console.log(currentUser);
	// const activeTestMode = useSelector(
	// 	(state) => state.bookingForm.isActiveTestMode
	// );
	// const isGoogleApiOn = useSelector((state) => state.bookingForm.isGoogleApiOn);
	const { unreadCount } = useSelector((state) => state.notification);
	const callerId = useSelector((state) => state.caller);
	const { activeSearch, mergeMode } = useSelector((state) => state.scheduler);
	const [openSearch, setOpenSearch] = useState(false);
	const [menuOpen, setMenuOpen] = useState(false);
	const [notificationOpen, setNotificationOpen] = useState(false);
	const [recordTurnModal, setRecordTurnModal] = useState(false);
	const [textMessageModal, setTextMessageModal] = useState(false);
	const [ticketRaiseModal, setTicketRaiseModal] = useState(false);
	// const [searchData, setSearchData] = useState({});
	// const inputRef = useRef(null);

	// const handleKeyPress = (e) => {
	// 	if (e.key === 'Enter') {
	// 		e.preventDefault();
	// 		handleClick(e);
	// 	}
	// };

	const handleCancelSearch = () => {
		setOpenSearch(false);
		setTimeout(() => {
			dispatch(makeSearchInactive());
		}, 200);
	};

	const handleRecordTurnDown = () => {
		setRecordTurnModal(true);
	};

	const handleTextMessage = () => {
		setTextMessageModal(true);
	};

	const { systemNotifications, driverNotifications, muteNotification } =
		useSelector((state) => state.notification);

	const lastSystemId = useRef(
		new Set(JSON.parse(localStorage.getItem('lastSystemId') || '[]')),
	);
	const lastDriverId = useRef(
		new Set(JSON.parse(localStorage.getItem('lastDriverId') || '[]')),
	);

	const addSeenId = (ref, storageKey, id) => {
		ref.current.add(id);
		localStorage.setItem(storageKey, JSON.stringify([...ref.current]));
	};

	const systemAudio = useRef(new Audio('/media/audio/system_audio.mp3'));
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
					(a, b) => new Date(b.dateTimeStamp) - new Date(a.dateTimeStamp),
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
					(a, b) => new Date(b.dateTimeStamp) - new Date(a.dateTimeStamp),
				)[0];
			if (newestDriver && !lastDriverId.current.has(newestDriver.id)) {
				lastDriverId.current.add(newestDriver.id);
				if (!muteNotification) playSound('driver');
				addSeenId(lastDriverId, 'lastDriverId', newestDriver.id);
			}
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

	// console.log('date control---', dateControl);

	return (
		<>
			<>
				{openSearch && (
					<Modal
						open={openSearch}
						setOpen={setOpenSearch}
					>
						<SearchModal
							// handleClick={handleClick}
							openSearch={openSearch}
							// inputRef={inputRef}
							// setSearchData={setSearchData}
							// handleKeyPress={handleKeyPress}
							setOpenSearch={setOpenSearch}
						/>
					</Modal>
				)}
				{recordTurnModal && (
					<Modal
						setOpen={setRecordTurnModal}
						open={recordTurnModal}
					>
						<RecordTurn setRecordTurnModal={setRecordTurnModal} />
					</Modal>
				)}
				{textMessageModal && (
					<Modal
						setOpen={setTextMessageModal}
						open={textMessageModal}
					>
						<TextMessage setTextMessageModal={setTextMessageModal} />
					</Modal>
				)}
				{ticketRaiseModal && (
					<Modal
						setOpen={setTicketRaiseModal}
						open={ticketRaiseModal}
					>
						<TicketRaise setTicketRaiseModal={setTicketRaiseModal} />
					</Modal>
				)}
			</>
			<nav
				className={`sticky top-0 z-50 flex justify-between items-center ${
					BASE_URL.includes('https://ace-server.1soft.co.uk')
						? 'bg-[#424242]'
						: 'bg-[#C74949]'
				}  text-white p-4`}
			>
				<span className='flex sm:gap-10 items-center justify-between gap-2 w-full'>
					<Link
						to='/pusher'
						className='flex justify-center items-center space-x-2 uppercase'
					>
						<img
							src={LogoImg}
							className='flex h-8 w-8'
						/>
						<span className='text-lg font-bold'>Ace Taxis</span>
						<span className='text-lg hidden sm:block'>
							{BASE_URL.includes('https://ace-server.1soft.co.uk')
								? ''
								: 'TEST MODE'}
						</span>
					</Link>

					{/* Mobile Menu Toggle */}
					{isAuth && (
						<div className='md:hidden flex  text-2xl focus:outline-none mr-2 gap-2 justify-center items-center'>
							{currentUser?.roleId !== 3 && (
								<div
									className='md:hidden flex  text-2xl focus:outline-none mr-2 gap-2 justify-center items-center'
									onClick={() => {
										dispatch(clearUnreadCount());
										setNotificationOpen(!notificationOpen);
									}}
								>
									<div
										className={`relative ${
											unreadCount > 0 ? 'animate-pulse' : ''
										}`}
									>
										<NotificationsNoneOutlinedIcon className='text-white' />
										{unreadCount > 0 && (
											<span className='absolute -top-1 right-0 bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full'>
												{unreadCount}
											</span>
										)}
									</div>
								</div>
							)}
							<button
								className='md:hidden block text-2xl focus:outline-none mr-2'
								onClick={() => setMenuOpen(!menuOpen)}
							>
								☰
							</button>
						</div>
					)}
				</span>

				<span
					className={`${
						menuOpen ? 'flex' : 'hidden'
					} flex-col md:flex md:flex-row items-center justify-end gap-4 sm:gap-10 uppercase text-sm  w-[50%]`}
				>
					{!isAuth ? (
						<></>
					) : (
						<div className='flex flex-row items-center align-middle gap-8'>
							{/* test input date */}
							{/* <input
								required
								type='datetime-local'
								className='w-full bg-input text-foreground p-2 rounded-lg border border-border text-black'
								value={formatDate(dateControl)}
								onChange={(event) => {
									const selectedDate = new Date(
										event.target.value
									).toISOString();
									dispatch(setDateControl(selectedDate)); // Update global dateControl
									dispatch(changeActiveDate(selectedDate)); // Update Scheduler's activeDate
								}}
							/> */}

							{currentUser?.roleId !== 3 && (
								<button
									className={`${
										BASE_URL.includes('https://ace-server.1soft.co.uk')
											? 'bg-[#424242] text-[#C74949] border border-[#C74949]'
											: 'bg-[#C74949] text-white border border-white'
									} px-4 py-2 rounded-lg uppercase text-xs sm:text-sm`}
									onClick={() => setTicketRaiseModal(true)}
								>
									Ticket Raise
								</button>
							)}

							{currentUser?.roleId !== 3 && (
								<button
									className={`${
										BASE_URL.includes('https://ace-server.1soft.co.uk')
											? 'bg-[#424242] text-[#C74949] border border-[#C74949]'
											: 'bg-[#C74949] text-white border border-white'
									} px-4 py-2 rounded-lg uppercase text-xs sm:text-sm`}
									onClick={handleRecordTurnDown}
								>
									No
								</button>
							)}
							{currentUser?.roleId !== 3 && (
								<button
									className={`${
										BASE_URL.includes('https://ace-server.1soft.co.uk')
											? 'bg-[#424242] text-[#C74949] border border-[#C74949]'
											: 'bg-[#C74949] text-white border border-white'
									} px-4 py-2 rounded-lg uppercase text-xs sm:text-sm`}
									onClick={handleTextMessage}
								>
									Text Message
								</button>
							)}
							{callerId.length > 0 && (
								<Badge
									badgeContent={callerId.length}
									color='error'
									className='cursor-pointer select-none animate-bounce'
								>
									<CallIcon />
								</Badge>
							)}

							{/* Search Form Started here */}
							{currentUser?.roleId !== 3 && (
								<div className='flex justify-center items-center uppercase'>
									{!activeSearch && (
										<button
											onClick={() => setOpenSearch(true)}
											// className='text-sm'
										>
											Search
										</button>
									)}
									{activeSearch && (
										<button
											onClick={handleCancelSearch}
											// className='text-sm'
										>
											Cancel Search
										</button>
									)}
								</div>
							)}

							{/* Notification  */}
							{currentUser?.roleId !== 3 && (
								<div
									className='flex text-2xl focus:outline-none mr-2 gap-2 justify-center items-center'
									onClick={() => {
										setNotificationOpen(!notificationOpen);
										dispatch(clearUnreadCount());
									}}
								>
									<div
										className={`relative ${
											unreadCount > 0 ? 'animate-pulse' : ''
										}`}
									>
										<NotificationsNoneOutlinedIcon
											className='text-white'
											fontSize='small'
										/>
										{unreadCount > 0 && (
											<span className='absolute -top-1 right-0 bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full'>
												{unreadCount}
											</span>
										)}
									</div>
								</div>
							)}
							{/* {currentUser?.roleId !== 3 && (
								<span className='flex gap-2 items-center'>
									<span className='text-xs sm:text-sm'>Use Google Api</span>
									<Switch
										checked={isGoogleApiOn}
										onChange={(e) => {
											dispatch(setIsGoogleApiOn(e.target.checked));
										}}
										size='small'
									/>
								</span>
							)} */}

							{/* Test Mode Toogle Button */}
							{/* <span className='flex flex-row gap-2 items-center align-middle'>
								<span>Test Mode</span>
								<Switch
									checked={activeTestMode}
									onChange={(e) => {
										dispatch(setActiveTestMode(e.target.checked));
									}}
								/>
							</span> */}

							{/* Logout Button */}
							{isAuth && (
								<button
									className='bg-blue-500 text-white px-4 py-2 rounded-lg uppercase text-xs sm:text-sm'
									onClick={() => {
										logout();
										navigate('/login');
									}}
								>
									logout
								</button>
							)}
						</div>
					)}
				</span>
				<div
					className={`fixed inset-y-0 right-0 z-50 w-[55%] max-w-xs bg-[#C74949] text-white p-4 transform ${
						menuOpen ? 'translate-x-0' : 'translate-x-full'
					} transition-transform duration-300 ease-in-out md:hidden`}
				>
					<div className='flex justify-between items-center mb-6 mr-10'>
						<span className='text-lg font-bold'>Menu</span>
						<button
							onClick={() => {
								setMenuOpen(false);
								setNotificationOpen(false);
							}}
							className='text-2xl'
						>
							✕
						</button>
					</div>

					{/* Caller ID Badge */}
					{(!isMobile || !isTablet || currentUser?.roleId !== 3) &&
						isAuth &&
						callerId.length > 0 && (
							<Badge
								badgeContent={callerId.length}
								color='error'
								className='cursor-pointer animate-bounce mb-4'
							>
								<CallIcon />
							</Badge>
						)}

					<div className='flex gap-4 mb-4'>
						<button
							onClick={() => {
								dispatch(setActiveSectionMobileView('Booking'));
								setMenuOpen(false);
								setNotificationOpen(false);
							}}
						>
							Booking
						</button>
					</div>
					<div className='flex gap-4 mb-4'>
						<button
							onClick={() => {
								dispatch(setActiveSectionMobileView('Scheduler'));
								setMenuOpen(false);
								setNotificationOpen(false);
							}}
						>
							Diary
						</button>
					</div>
					{currentUser?.roleId !== 3 && (
						<div className='flex justify-start items-center gap-2 mb-4'>
							<span>Merge Mode</span>
							<Switch
								checked={mergeMode}
								onChange={() => {
									dispatch(setMergeMode(!mergeMode));
									setMenuOpen(false);
									setNotificationOpen(false);
								}}
							/>
						</div>
					)}
					<div className='flex gap-4 mb-4'>
						<button
							onClick={() => {
								dispatch(setActiveSectionMobileView('BookingLogs'));
								setMenuOpen(false);
								setNotificationOpen(false);
							}}
						>
							Logs
						</button>
					</div>
					<div className='flex gap-4 mb-4'>
						<button
							onClick={() => {
								dispatch(setActiveSectionMobileView('COAEntry'));
								setMenuOpen(false);
								setNotificationOpen(false);
							}}
						>
							COA Entries
						</button>
					</div>

					{/* Search Button */}
					{currentUser?.roleId !== 3 && (
						<div className='flex justify-start items-center uppercase mb-4'>
							{!activeSearch ? (
								<button
									onClick={() => {
										setOpenSearch(true);
										dispatch(setActiveSectionMobileView('Scheduler'));
										setMenuOpen(false);
										setNotificationOpen(false);
									}}
								>
									Search
								</button>
							) : (
								<button
									onClick={() => {
										handleCancelSearch();
										setMenuOpen(false);
										setNotificationOpen(false);
									}}
								>
									Cancel Search
								</button>
							)}
						</div>
					)}

					{currentUser?.roleId !== 3 && (
						<div className='flex gap-4 mb-4'>
							<button
								onClick={() => {
									handleRecordTurnDown();
									setMenuOpen(false);
									setNotificationOpen(false);
								}}
							>
								No
							</button>
						</div>
					)}

					{currentUser?.roleId !== 3 && (
						<div className='flex gap-4 mb-4'>
							<button
								onClick={() => {
									handleTextMessage();
									setMenuOpen(false);
									setNotificationOpen(false);
								}}
							>
								Text Message
							</button>
						</div>
					)}

					{currentUser?.roleId !== 3 && (
						<div className='flex gap-4 mb-4'>
							<button
								onClick={() => {
									setTicketRaiseModal(true);
									setMenuOpen(false);
									setNotificationOpen(false);
								}}
							>
								Ticket Raise
							</button>
						</div>
					)}

					{/* Google API Toggle */}
					{/* {currentUser?.roleId !== 3 && (
						<div className='flex justify-start items-center gap-2 mb-4'>
							<span>Use Google Api</span>
							<Switch
								checked={isGoogleApiOn}
								onChange={(e) => {
									dispatch(setIsGoogleApiOn(e.target.checked));
									setMenuOpen(false);
								}}
							/>
						</div>
					)} */}

					{/* Logout Button */}
					{isAuth && (
						<button
							className='bg-blue-500 px-4 py-2 rounded-md uppercase'
							onClick={() => {
								logout();
								navigate('/login');
								setMenuOpen(false);
								setNotificationOpen(false);
							}}
						>
							Logout
						</button>
					)}
				</div>
				{notificationOpen && !menuOpen && (
					<div
						className={`fixed top-16 md:right-28 right-4 z-50 w-[80%] rounded-md md:w-[80%] max-w-xs md:max-w-md bg-white text-white transform  transition-transform duration-300 ease-in-out`}
					>
						<DropdownNotifications setNotificationOpen={setNotificationOpen} />
					</div>
				)}

				{/* Overlay for closing the panel */}
				{menuOpen && (
					<div
						className='fixed inset-0 z-30 bg-black opacity-50'
						onClick={() => {
							setMenuOpen(false);
							setNotificationOpen(false);
						}}
					></div>
				)}
				{notificationOpen && (
					<div
						className='fixed inset-0 z-30 bg-black opacity-50'
						onClick={() => {
							setMenuOpen(false);
							setNotificationOpen(false);
						}}
					></div>
				)}
			</nav>
		</>
	);
};

export default Navbar;

function TicketRaise({ setTicketRaiseModal }) {
	const dispatch = useDispatch();
	const [file, setFile] = useState(null);
	const [preview, setPreview] = useState(null);
	const {
		register,
		handleSubmit,
		reset,
		watch,
		formState: { isSubmitSuccessful, errors }, // Access form errors
	} = useForm({
		defaultValues: {
			subject: '',
			message: '',
		},
	});

	const attachment = watch('attachment');

	useEffect(() => {
		if (attachment && attachment[0]) {
			const file = attachment[0];
			setPreview(URL.createObjectURL(file));
		}
	}, [attachment]);

	const handleSubmitForm = async (data) => {
		const formData = new FormData();

		formData.append('subject', data.subject);
		formData.append('message', data.message);

		if (file) {
			formData.append('attachment', file);
		} else {
			// send empty value (Swagger "Send empty value")
			formData.append('attachment', '');
		}

		// Dispatch search action only if some data is entered
		if (data?.subject || data.message) {
			const response = await submitTicket(formData);
			if (response.status === 'success') {
				dispatch(openSnackbar('Ticket Send Successfully', 'success'));
				setTicketRaiseModal(false);
			} else {
				setTicketRaiseModal(false);
				dispatch(openSnackbar('Failed to submit ticket', 'error'));
			}
			// Close the modal after search
		} else {
			console.log('Please fill form');
		}
	};

	const handleFileChange = (e) => {
		const selected = e.target.files[0];
		if (!selected) return;

		setFile(selected);

		if (selected.type.startsWith('image/')) {
			setPreview(URL.createObjectURL(selected));
		} else {
			setPreview(null);
		}
	};

	useEffect(() => {
		if (isSubmitSuccessful) {
			reset({
				subject: '',
				message: '',
			});
		}
	}, [reset, isSubmitSuccessful]);

	return (
		<div className='bg-white p-6 rounded-lg shadow-lg w-[90vw] md:w-[45vw] sm:w-[25vw] max-w-md mx-auto'>
			<h2 className='text-2xl font-semibold mb-4 flex gap-1 items-center'>
				<AirplaneTicketOutlined />
				Ticket Raise
			</h2>
			<form onSubmit={handleSubmit(handleSubmitForm)}>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Subject'
						fullWidth
						error={!!errors.subject} // Show error if validation fails
						helperText={errors.subject ? 'Subject is Required' : ''}
						{...register('subject', {
							required: 'Subject field is required',
						})}
					/>
				</Box>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Message'
						fullWidth
						multiline
						minRows={2}
						error={!!errors.message}
						helperText={errors.message ? 'Message is required' : ''}
						{...register('message', {
							required: 'Message field is required',
						})}
					/>
				</Box>
				<Box mt={2}>
					<div
						className='border-2 border-dashed border-gray-400 bg-white rounded-md p-4 text-center cursor-pointer
               hover:border-blue-500 transition'
						onDragOver={(e) => e.preventDefault()}
						onDrop={(e) => {
							e.preventDefault();
							const f = e.dataTransfer.files[0];
							if (!f) return;
							setFile(f);
							if (f.type.startsWith('image/'))
								setPreview(URL.createObjectURL(f));
						}}
					>
						{/* If NO file selected */}
						{!file && (
							<div>
								<CloudUploadOutlined
									style={{ fontSize: 40, color: '#60A5FA' }}
								/>

								<p className='text-gray-600 text-sm font-medium'>
									Drag & Drop to Upload File
								</p>

								<p className='text-gray-500 text-xs my-1'>OR</p>

								<Button
									variant='outlined'
									component='label'
									size='small'
								>
									Browse File
									<input
										hidden
										type='file'
										accept='image/*,.pdf,.doc,.docx'
										{...register('attachment')}
										onChange={handleFileChange}
									/>
								</Button>
							</div>
						)}

						{/* If file is selected → show preview in same box */}
						{file && (
							<div className='flex flex-col items-center'>
								{file.type.startsWith('image/') ? (
									<img
										src={preview}
										alt='Preview'
										className='w-24 h-24 object-cover rounded-md mb-2'
									/>
								) : (
									<p className='text-gray-700 text-sm mb-2'>📄 {file.name}</p>
								)}

								<Button
									variant='outlined'
									color='error'
									size='small'
									onClick={() => {
										setFile(null);
										setPreview(null);
									}}
								>
									Remove File
								</Button>
							</div>
						)}
					</div>
				</Box>

				<div className='mt-4 flex gap-1'>
					<LongButton
						type='submit'
						color='bg-green-700'
					>
						Submit
					</LongButton>
					<LongButton
						color='bg-red-700'
						onClick={() => setTicketRaiseModal(false)} // Close modal on Cancel
					>
						Cancel
					</LongButton>
				</div>
			</form>
		</div>
	);
}

function TextMessage({ setTextMessageModal }) {
	const isMobile = useMediaQuery('(max-width: 640px)');
	const isTablet = useMediaQuery('(min-width: 768px) and (max-width: 1023px)');
	const dispatch = useDispatch();
	const {
		register,
		handleSubmit,
		reset,
		formState: { isSubmitSuccessful, errors }, // Access form errors
	} = useForm({
		defaultValues: {
			message: '',
			telephone: '',
		},
	});

	const handleSubmitForm = async (data) => {
		console.log('form Data', data);

		// Dispatch search action only if some data is entered
		if (data?.message || data.telephone) {
			const response = await textMessageDirectly(data);
			if (response.status === 'success') {
				dispatch(openSnackbar('Message Send Successfully', 'success'));
				if (isMobile || isTablet) {
					setActiveSectionMobileView('Scheduler');
				}
				setTextMessageModal(false);
			}
			// Close the modal after search
		} else {
			console.log('Please fill form');
		}
	};

	useEffect(() => {
		if (isSubmitSuccessful) {
			reset({
				message: '',
				telephone: '',
			});
		}
	}, [reset, isSubmitSuccessful]);

	return (
		<div className='bg-white p-6 rounded-lg shadow-lg w-[90vw] md:w-[45vw] sm:w-[25vw] max-w-md mx-auto'>
			<h2 className='text-2xl font-semibold mb-4 flex gap-1 items-center'>
				<MailOutlineIcon />
				Text Message
			</h2>
			<form onSubmit={handleSubmit(handleSubmitForm)}>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Phone Number'
						fullWidth
						error={!!errors.telephone} // Show error if validation fails
						helperText={errors.telephone ? 'Phone Number is Required' : ''}
						{...register('telephone', {
							required: 'Phone Number field is required',
						})}
					/>
				</Box>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Message'
						fullWidth
						error={!!errors.message}
						helperText={errors.message ? 'Must be at least 3 characters' : ''}
						{...register('message', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 characters',
							},
						})}
					/>
				</Box>

				<div className='mt-4 flex gap-1'>
					<LongButton
						type='submit'
						color='bg-green-700'
					>
						Submit
					</LongButton>
					<LongButton
						color='bg-red-700'
						onClick={() => setTextMessageModal(false)} // Close modal on Cancel
					>
						Cancel
					</LongButton>
				</div>
			</form>
		</div>
	);
}

function RecordTurn({ setRecordTurnModal }) {
	// const dispatch = useDispatch();
	const {
		register,
		handleSubmit,
		reset,
		formState: { isSubmitSuccessful, errors }, // Access form errors
	} = useForm({
		defaultValues: {
			amount: '',
		},
	});

	const handleSubmitForm = async (data) => {
		const newinputData = {
			amount: Number(data.amount) || 0,
		};

		// Dispatch search action only if some data is entered
		if (data.amount) {
			// if (isMobile || isTablet) {
			// 	setActiveSectionMobileView('Scheduler');
			// }
			const response = await recordTurnDown(newinputData);
			console.log('recordTurnDown Response---', response);
			setRecordTurnModal(false);
			openSnackbar('Record Send Successfully', 'success');
			// Close the modal after search
		} else {
			console.log('Please enter search criteria');
		}
	};

	useEffect(() => {
		if (isSubmitSuccessful) {
			reset({
				amount: '',
			});
		}
	}, [reset, isSubmitSuccessful]);

	return (
		<div className='bg-white p-6 rounded-lg shadow-lg w-[90vw] md:w-[45vw] sm:w-[25vw] max-w-md mx-auto'>
			<h2 className='text-2xl font-semibold mb-4 flex gap-1 items-center'>
				<PermPhoneMsgIcon />
				Record Turn Down
			</h2>
			<form onSubmit={handleSubmit(handleSubmitForm)}>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Amount'
						fullWidth
						error={!!errors.amount} // Show error if validation fails
						helperText={errors.amount ? 'Amount is required' : ''}
						{...register('amount')}
					/>
				</Box>

				<div className='mt-4 flex gap-1'>
					<LongButton
						type='submit'
						color='bg-green-700'
					>
						Submit
					</LongButton>
					<LongButton
						color='bg-red-700'
						onClick={() => setRecordTurnModal(false)}
					>
						Cancel
					</LongButton>
				</div>
			</form>
		</div>
	);
}

function SearchModal({ setOpenSearch }) {
	const isMobile = useMediaQuery('(max-width: 640px)');
	const isTablet = useMediaQuery('(min-width: 768px) and (max-width: 1023px)');
	const dispatch = useDispatch();
	const {
		register,
		handleSubmit,
		reset,
		formState: { isSubmitSuccessful, errors }, // Access form errors
	} = useForm({
		defaultValues: {
			booking_id: '',
			pickupAddress: '',
			pickupPostcode: '',
			destinationAddress: '',
			destinationPostcode: '',
			passenger: '',
			phoneNumber: '',
			details: '',
		},
	});

	const handleSubmitForm = async (data) => {
		const newinputData = {
			booking_id: data?.booking_id || null,
			pickupAddress: data?.pickupAddress || '',
			pickupPostcode: data?.pickupPostcode || '',
			destinationAddress: data?.destinationAddress || '',
			destinationPostcode: data?.destinationPostcode || '',
			passenger: data?.passenger || '',
			phoneNumber: data?.phoneNumber || '',
			details: data?.details || '',
		};

		// Dispatch search action only if some data is entered
		if (
			newinputData.pickupAddress ||
			newinputData.pickupPostcode ||
			newinputData.destinationAddress ||
			newinputData.destinationPostcode ||
			newinputData.passenger ||
			newinputData.phoneNumber ||
			newinputData.details ||
			newinputData.booking_id
		) {
			dispatch(setSearchKeywords(newinputData));
			dispatch(handleSearchBooking(newinputData));
			if (isMobile || isTablet) {
				setActiveSectionMobileView('Scheduler');
			}
			setOpenSearch(false);
			// Close the modal after search
		} else {
			console.log('Please enter search criteria');
		}
	};

	useEffect(() => {
		const handleKeyDown = (e) => {
			if (e.key === 'End') {
				handleSubmit(handleSubmitForm)(); // This ensures form validation
			}
		};

		window.addEventListener('keydown', handleKeyDown);
		return () => window.removeEventListener('keydown', handleKeyDown);
	}, [handleSubmit]);

	useEffect(() => {
		if (isSubmitSuccessful) {
			reset({
				booking_id: '',
				pickupAddress: '',
				pickupPostcode: '',
				destinationAddress: '',
				destinationPostcode: '',
				passenger: '',
				phoneNumber: '',
				details: '',
			});
		}
	}, [reset, isSubmitSuccessful]);

	return (
		<div className='bg-white p-6 rounded-lg shadow-lg w-[90vw] md:w-[45vw] sm:w-[25vw] max-w-md mx-auto'>
			<h2 className='text-2xl font-semibold mb-4 flex gap-1 items-center'>
				<SearchIcon />
				Search Bookings
			</h2>
			<form onSubmit={handleSubmit(handleSubmitForm)}>
				<TextField
					label='Booking Id'
					fullWidth
					error={!!errors.booking_id} // Show error if validation fails
					helperText={errors.booking_id ? 'Must be at least 3 characters' : ''}
					{...register('booking_id')}
				/>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Pickup Address'
						fullWidth
						error={!!errors.pickupAddress} // Show error if validation fails
						helperText={
							errors.pickupAddress ? 'Must be at least 3 characters' : ''
						}
						{...register('pickupAddress', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 characters',
							},
						})}
					/>
					<TextField
						label='Pickup Postcode'
						fullWidth
						error={!!errors.pickupPostcode}
						helperText={
							errors.pickupPostcode ? 'Must be at least 3 Numbers' : ''
						}
						{...register('pickupPostcode', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 Numbers',
							},
						})}
					/>
				</Box>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Destination Address'
						fullWidth
						error={!!errors.destinationAddress}
						helperText={
							errors.destinationAddress ? 'Must be at least 3 characters' : ''
						}
						{...register('destinationAddress', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 characters',
							},
						})}
					/>
					<TextField
						label='Destination Postcode'
						fullWidth
						error={!!errors.destinationPostcode}
						helperText={
							errors.destinationPostcode ? 'Must be at least 3 Numbers' : ''
						}
						{...register('destinationPostcode', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 Numbers',
							},
						})}
					/>
				</Box>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Passenger'
						fullWidth
						error={!!errors.passenger}
						helperText={errors.passenger ? 'Must be at least 3 characters' : ''}
						{...register('passenger', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 characters',
							},
						})}
					/>
					<TextField
						label='Phone Number'
						fullWidth
						error={!!errors.phoneNumber}
						helperText={errors.phoneNumber ? 'Must be at least 3 Numbers' : ''}
						{...register('phoneNumber', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 Numbers',
							},
						})}
					/>
				</Box>
				<Box
					mt={2}
					display='flex'
					justifyContent='space-between'
					gap={2}
				>
					<TextField
						label='Details'
						fullWidth
						error={!!errors.details}
						helperText={errors.details ? 'Must be at least 3 characters' : ''}
						{...register('details', {
							minLength: {
								value: 3,
								message: 'Must be at least 3 characters',
							},
						})}
					/>
				</Box>

				<div className='mt-4 flex gap-1'>
					<LongButton
						type='submit'
						color='bg-green-700'
					>
						Search
					</LongButton>
					<LongButton
						color='bg-red-700'
						onClick={() => setOpenSearch(false)} // Close modal on Cancel
					>
						Cancel
					</LongButton>
				</div>
			</form>
		</div>
	);
}
