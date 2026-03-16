/** @format */
import { useEffect, useState } from 'react';
import {
	getMsgConfig,
	setMsgConfig,
} from '../../../service/operations/settingsApi';

const MsgSettings = () => {
	const [data, setData] = useState({});
	const typeMap = {
		0: 'None',
		1: 'WhatsApp',
		2: 'Text Message',
	};

	const reverseTypeMap = {
		'None': 0,
		'WhatsApp': 1,
		'Text Message': 2,
	};

	// ✅ Messaging Config Sections (Follows Your Format)
	const messageSections = [
		{ title: 'DRIVER - ON ALLOCATE', stateKey: 'driverOnAllocate' },
		{ title: 'DRIVER - UN-ALLOCATE', stateKey: 'driverOnUnAllocate' },
		{ title: 'DRIVER - ON AMEND BOOKING', stateKey: 'driverOnAmend' },
		{ title: 'DRIVER - ON CANCEL BOOKING', stateKey: 'driverOnCancel' },
		{ title: 'CUSTOMER - ON ALLOCATE', stateKey: 'customerOnAllocate' },
		{ title: 'CUSTOMER - UN-ALLOCATE', stateKey: 'customerOnUnAllocate' },
		{ title: 'CUSTOMER - ON AMEND BOOKING', stateKey: 'customerOnAmend' },
		{ title: 'CUSTOMER - ON CANCEL BOOKING', stateKey: 'customerOnCancel' },
		{
			title: 'CUSTOMER - ON COMPLETE (Request Review)',
			stateKey: 'customerOnComplete',
		},
	];

	// ✅ State for message settings
	const [messageSettings, setMessageSettings] = useState({});

	async function fetchMsgConfig() {
		try {
			const response = await getMsgConfig();
			if (response?.status === 'success') {
				setData(response);
				const formattedSettings = Object.keys(response).reduce((acc, key) => {
					if (messageSections.some((section) => section.stateKey === key)) {
						acc[key] = typeMap[response[key]] || 'None'; // Default to 'None' if missing
					}
					return acc;
				}, {});
				setMessageSettings(formattedSettings);
			}
		} catch (error) {
			console.error('Failed to fetch msg config:', error);
		}
	}

	useEffect(() => {
		fetchMsgConfig();
		// Update messageSettings when fetchMsgConfig resolves
	}, []);

	// ✅ Handle Selection Change
	const handleSelectionChange = (key, value) => {
		setMessageSettings((prev) => ({ ...prev, [key]: value }));
	};

	const handleSaveSettings = async () => {
		// Convert text values back to API numeric values
		const payload = Object.keys(messageSettings).reduce((acc, key) => {
			acc[key] = reverseTypeMap[messageSettings[key]]; // Convert text to number
			return acc;
		}, {});

		try {
			const request = {
				...payload,
				id: data?.id || '',
				ignoreAccountNos: data?.ignoreAccountNos || '',
				smsPhoneHeartBeat:
					data?.smsPhoneHeartBeat || '2025-02-19T09:09:14.208Z',
			};
			const response = await setMsgConfig(request);
			if (response?.status === 'success') {
				fetchMsgConfig();
			}
		} catch (error) {
			console.error('Failed to update message settings:', error);
		}
	};

	return (
		<div className='px-4 md:px-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
			{/* ✅ Page Header */}
			<h3 className='text-xl leading-none font-medium text-gray-900 mb-4'>
				Message Settings
			</h3>

			{/* ✅ Grid Layout for Sections */}
			<div className='grid grid-cols-1 md:grid-cols-2 gap-6'>
				{messageSections.map((section) => (
					<div
						key={section.stateKey}
						className='border rounded-lg p-2 md:p-4 shadow-sm'
					>
						{/* Section Title */}
						<span
							className={`px-2 md:px-4 py-1 rounded-full text-xs md:text-sm font-semibold text-white ${
								section.title.includes('CUSTOMER')
									? 'bg-red-700'
									: 'bg-blue-700'
							}`}
						>
							{section.title}
						</span>

						{/* Selection Box */}
						<div className='mt-4 p-2 md:p-4 border rounded-md'>
							{['None', 'WhatsApp', 'Text Message'].map((type) => (
								<label
									key={type}
									className='flex items-center gap-2 mt-2'
								>
									<input
										type='radio'
										name={section.stateKey}
										value={type}
										checked={messageSettings[section.stateKey] === type}
										onChange={(e) =>
											handleSelectionChange(section.stateKey, e.target.value)
										}
										className='radio'
									/>
									<span
										className={`${
											type === 'WhatsApp'
												? 'text-green-500'
												: type === 'Text Message'
													? 'text-blue-500'
													: 'text-gray-700'
										} font-medium text-xs md:text-sm`}
									>
										{type}
									</span>
								</label>
							))}
						</div>
					</div>
				))}
			</div>

			{/* ✅ Save Settings Button */}
			<div className='my-11 flex justify-start'>
				<button
					className='btn btn-primary flex justify-center'
					onClick={handleSaveSettings}
				>
					SAVE SETTINGS
				</button>
			</div>
		</div>
	);
};

export { MsgSettings };
