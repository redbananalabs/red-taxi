/** @format */

import { useEffect, useState } from 'react';

import {
	getCompanyConfig,
	setCompanyConfig,
} from '../../../service/operations/settingsApi';

const CompanySetting = () => {
	// ✅ State to manage form data
	const [companyData, setCompanyData] = useState({
		id: 0,
		companyName: '',
		address1: '',
		address2: '',
		address3: '',
		address4: '',
		postcode: '',
		email: '',
		website: '',
		phone: '',
		companyNumber: '',
		vatNumber: '',
		cardTopupRate: 0,
		revoluttSecretKey: '',
		browserFCMs: [],
	});

	async function fetchCompanySettings() {
		const response = await getCompanyConfig();
		setCompanyData(response);
	}

	useEffect(() => {
		fetchCompanySettings();
	}, []);

	// ✅ Handle Input Changes
	const handleChange = (e) => {
		setCompanyData({ ...companyData, [e.target.name]: e.target.value });
	};

	// ✅ Handle Form Submission
	const handleSubmit = async (e) => {
		e.preventDefault();
		try {
			const payload = {
				id: companyData?.id || 0,
				companyName: companyData?.companyName || '',
				address1: companyData?.address1 || '',
				address2: companyData?.address2 || '',
				address3: companyData?.address3 || '',
				address4: companyData?.address4 || '',
				postcode: companyData?.postcode || '',
				email: companyData?.email || '',
				website: companyData?.website || '',
				phone: companyData?.phone || '',
				companyNumber: companyData?.companyNumber || '',
				vatNumber: companyData?.vatNumber || '',
				cardTopupRate: companyData?.cardTopupRate || 0,
				revoluttSecretKey: companyData?.revoluttSecretKey || '',
				browserFCMs: companyData?.browserFCMs || [],
			};
			const response = await setCompanyConfig(payload);
			if (response?.status === 'success') {
				fetchCompanySettings();
			}
		} catch (error) {
			console.error(error);
		}
	};

	return (
		<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
			{/* ✅ Card Header */}
			<div className=' pb-4'>
				<h3 className='text-xl leading-none font-medium text-gray-900'>
					Company Setup
				</h3>
			</div>

			{/* ✅ Card Body */}
			<div className='card card-body grid gap-6'>
				<form className='grid grid-cols-1 md:grid-cols-2 gap-6'>
					{/* ✅ Left Section - Company Details */}
					<div className='space-y-4'>
						<div>
							<label className='form-label font-medium text-gray-900'>
								Company Name
							</label>
							<input
								type='text'
								name='companyName'
								value={companyData?.companyName}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2  focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Address
							</label>
							<input
								type='text'
								name='address1'
								value={companyData?.address1}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Line 2
							</label>
							<input
								type='text'
								name='address2'
								value={companyData?.address2}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Line 3
							</label>
							<input
								type='text'
								name='address3'
								value={companyData?.address3}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Line 4
							</label>
							<input
								type='text'
								name='address4'
								value={companyData?.address4}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Postcode
							</label>
							<input
								type='text'
								name='postcode'
								value={companyData?.postcode}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>
					</div>

					{/* ✅ Right Section - Contact Details */}
					<div className='space-y-4'>
						<div>
							<label className='form-label font-medium text-gray-900'>
								Email
							</label>
							<input
								type='email'
								name='email'
								value={companyData?.email}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Web
							</label>
							<input
								type='text'
								name='website'
								value={companyData?.website}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2 focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Phone
							</label>
							<input
								type='text'
								name='phone'
								value={companyData?.phone}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2  focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								Company No
							</label>
							<input
								type='text'
								name='companyNumber'
								value={companyData?.companyNumber}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2  focus:ring-blue-600'
							/>
						</div>

						<div>
							<label className='form-label font-medium text-gray-900'>
								VAT No
							</label>
							<input
								type='text'
								name='vatNumber'
								value={companyData?.vatNumber}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2  focus:ring-blue-600'
							/>
						</div>

						{/* ✅ Card Rate Dropdown */}
						<div>
							<label className='form-label font-medium text-gray-900'>
								Card Rate %
							</label>
							<input
								type='number'
								name='cardTopupRate'
								value={companyData.cardTopupRate}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2  focus:ring-blue-600'
							/>
						</div>

						{/* ✅ Revolut Secret Key */}
						<div>
							<label className='form-label font-medium text-gray-900'>
								Revolut Secret Key
							</label>
							<input
								type='text'
								name='revoluttSecretKey'
								value={companyData.revoluttSecretKey}
								onChange={handleChange}
								className='input border border-gray-300 rounded-md p-2  focus:ring-blue-600'
							/>
						</div>
					</div>
				</form>
			</div>

			{/* ✅ Submit Button (Sticky at Bottom) */}
			<div className=' mt-6 flex justify-end'>
				<button
					onClick={handleSubmit}
					className='btn btn-sm btn-primary px-4 py-4'
				>
					Submit
				</button>
			</div>
		</div>
	);
};

export { CompanySetting };
