/** @format */

import { useState } from 'react';
import {
	creditInvoice,
	// deleteInvoice,
} from '../../../../service/operations/billing&Payment';
import toast from 'react-hot-toast';

const InvoiceDelete = () => {
	const [invoiceNo, setInvoiceNo] = useState('');
	const [invoiceReason, setInvoiceReason] = useState('');

	const handleDelete = async () => {
		try {
			// const response = await deleteInvoice(invoiceNo);
			const response = await creditInvoice(invoiceNo, invoiceReason);
			if (response.status === 'success') {
				toast.success('Invoice credited successfully');
				setInvoiceNo('');
				setInvoiceReason('');
			} else {
				toast.error('Failed to credit invoice');
				setInvoiceNo('');
				setInvoiceReason('');
			}
		} catch (error) {
			console.error('Error crediting invoice:', error);
			toast.error('Error crediting invoice');
		}
	};
	return (
		<div className='px-6 py-4 ms-auto me-auto max-w-[1850px] w-full'>
			{/* Header Section */}
			<h2 className='text-xl leading-none font-medium text-gray-900'>
				Credit Invoice
			</h2>

			{/* Filter Inputs */}
			<div className='flex flex-wrap items-center gap-6 mt-4'>
				<div className='flex flex-col items-baseline flex-wrap lg:flex-nowrap gap-2'>
					<label className='form-label'>Invoice Number</label>
					<input
						type='text'
						className='input'
						placeholder='Invoice Number'
						value={invoiceNo}
						onChange={(e) => setInvoiceNo(+e.target.value)}
					/>
				</div>
				<div className='flex flex-col items-baseline flex-wrap lg:flex-nowrap gap-2'>
					<label className='form-label'>Reason</label>
					<input
						type='text'
						className='input'
						placeholder='Reason'
						value={invoiceReason}
						onChange={(e) => setInvoiceReason(e.target.value)}
					/>
				</div>

				<button
					className='btn btn-primary flex justify-center mt-6'
					onClick={handleDelete}
				>
					CONTINUE
				</button>
			</div>
		</div>
	);
};

export { InvoiceDelete };
