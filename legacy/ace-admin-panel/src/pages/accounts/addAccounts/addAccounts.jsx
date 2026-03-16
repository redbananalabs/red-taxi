/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import clsx from 'clsx';
import { createAccounts } from '../../../service/operations/accountApi';
import { useDispatch, useSelector } from 'react-redux';
import { refreshAllAccounts } from '../../../slices/accountSlice';
function AddAccounts({ open, onOpenChange }) {
	const { accountTariffs } = useSelector((state) => state.tariff);
	const dispatch = useDispatch();
	const addLocalSchema = Yup.object().shape({
		contactName: Yup.string().required('Contact Name is required'),
		businessName: Yup.string().required('Contact Name is required'),
		address1: Yup.string().required('Address is required'),
		address2: Yup.string().required('Address2 is required'),
		postcode: Yup.string().required('Postcode is required'),
		telephone: Yup.string().required('Telephone is required'),
	});

	const initialValues = {
		contactName: '',
		businessName: '',
		address1: '',
		address2: '',
		address3: '',
		address4: '',
		postcode: '',
		telephone: '',
		email: '',
		bookerEmail: '',
		bookerName: '',
		purchaseOrderNo: '',
		reference: '',
		accountTariffId: 0,
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			const response = await createAccounts(values);
			if (response.status === 'success') {
				dispatch(refreshAllAccounts());
				onOpenChange();
				setSubmitting(false);
			}
			// Reset Formik's submitting state
		},
	});
	return (
		<Dialog
			open={open}
			onOpenChange={onOpenChange}
		>
			<DialogContent className='max-w-[500px]'>
				<DialogHeader className='border-0'>
					<DialogTitle></DialogTitle>
					<DialogDescription></DialogDescription>
				</DialogHeader>
				<DialogBody className='flex flex-col items-center pt-0 pb-4'>
					<h3 className='text-lg font-medium text-gray-900 text-center mb-3'>
						Add Accounts
					</h3>

					<form
						onSubmit={formik.handleSubmit}
						className='w-full'
					>
						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Contact Name</label>
								<label className='input'>
									<input
										placeholder='Enter contact name'
										autoComplete='off'
										{...formik.getFieldProps('contactName')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.contactName && formik.errors.contactName,
										})}
									/>
								</label>
								{formik.touched.contactName && formik.errors.contactName && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.contactName}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>
									Business Name
								</label>
								<label className='input'>
									<input
										placeholder='Enter business name'
										autoComplete='off'
										{...formik.getFieldProps('businessName')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.businessName &&
												formik.errors.businessName,
										})}
									/>
								</label>
								{formik.touched.businessName && formik.errors.businessName && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.businessName}
									</span>
								)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Address 1</label>
								<label className='input'>
									<input
										placeholder='Enter address'
										autoComplete='off'
										{...formik.getFieldProps('address1')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.address1 && formik.errors.address1,
										})}
									/>
								</label>
								{formik.touched.address1 && formik.errors.address1 && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.address1}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Address 2</label>
								<label className='input'>
									<input
										placeholder='Enter address'
										autoComplete='off'
										{...formik.getFieldProps('address2')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.address2 && formik.errors.address2,
										})}
									/>
								</label>
								{formik.touched.address2 && formik.errors.address2 && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.address2}
									</span>
								)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Address 3</label>
								<label className='input'>
									<input
										placeholder='Enter address'
										autoComplete='off'
										{...formik.getFieldProps('address3')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.address3 && formik.errors.address3,
										})}
									/>
								</label>
								{formik.touched.address3 && formik.errors.address3 && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.address3}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Address 4</label>
								<label className='input'>
									<input
										placeholder='Enter address'
										autoComplete='off'
										{...formik.getFieldProps('address4')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.address4 && formik.errors.address4,
										})}
									/>
								</label>
								{formik.touched.address4 && formik.errors.address4 && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.address4}
									</span>
								)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Postcode</label>
								<label className='input'>
									<input
										placeholder='Enter postcode'
										autoComplete='off'
										{...formik.getFieldProps('postcode')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.postcode && formik.errors.postcode,
										})}
									/>
								</label>
								{formik.touched.postcode && formik.errors.postcode && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.postcode}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Telephone</label>
								<label className='input'>
									<input
										placeholder='Enter telephone'
										autoComplete='off'
										{...formik.getFieldProps('telephone')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.telephone && formik.errors.telephone,
										})}
									/>
								</label>

								{formik.touched.telephone && formik.errors.telephone && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.telephone}
									</span>
								)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Email</label>
								<label className='input'>
									<input
										placeholder='Enter email'
										autoComplete='off'
										{...formik.getFieldProps('email')}
										className={clsx('form-control', {
											'is-invalid': formik.touched.email && formik.errors.email,
										})}
									/>
								</label>
								{formik.touched.email && formik.errors.email && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.email}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Booker Email</label>
								<label className='input'>
									<input
										placeholder='Enter booker Email'
										autoComplete='off'
										{...formik.getFieldProps('bookerEmail')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.bookerEmail && formik.errors.bookerEmail,
										})}
									/>
								</label>

								{formik.touched.bookerEmail && formik.errors.bookerEmail && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.bookerEmail}
									</span>
								)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Booker Name</label>
								<label className='input'>
									<input
										placeholder='Enter booker Name'
										autoComplete='off'
										{...formik.getFieldProps('bookerName')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.bookerName && formik.errors.bookerName,
										})}
									/>
								</label>
								{formik.touched.bookerName && formik.errors.bookerName && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.bookerName}
									</span>
								)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>
									Account Tariff
								</label>

								<Select
									value={formik.values.accountTariffId}
									onValueChange={(value) =>
										formik.setFieldValue('accountTariffId', Number(value))
									}
								>
									<SelectTrigger className=' w-56'>
										<SelectValue placeholder='Select' />
									</SelectTrigger>
									<SelectContent>
										<SelectItem value={0}>Not Set</SelectItem>
										{accountTariffs.map((acc) => (
											<>
												<SelectItem value={acc.id}>{acc?.name}</SelectItem>
											</>
										))}
									</SelectContent>
								</Select>
								{formik.touched.accountTariffId &&
									formik.errors.accountTariffId && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.accountTariffId}
										</span>
									)}
							</div>
						</div>
						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>PO Number</label>
								<label className='input'>
									<input
										placeholder='Enter po number'
										autoComplete='off'
										{...formik.getFieldProps('purchaseOrderNo')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.purchaseOrderNo &&
												formik.errors.purchaseOrderNo,
										})}
									/>
								</label>

								{formik.touched.purchaseOrderNo &&
									formik.errors.purchaseOrderNo && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.purchaseOrderNo}
										</span>
									)}
							</div>
							<div className='flex flex-col gap-1 pb-2 w-full'>
								<label className='form-label text-gray-900'>Reference</label>
								<label className='input'>
									<input
										placeholder='Enter reference'
										autoComplete='off'
										{...formik.getFieldProps('reference')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.reference && formik.errors.reference,
										})}
									/>
								</label>
								{formik.touched.reference && formik.errors.reference && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.reference}
									</span>
								)}
							</div>
						</div>

						<div className='flex justify-end mb-2 mt-2'>
							<button
								className='btn btn-light'
								onClick={() => onOpenChange()}
							>
								Cancel
							</button>
							<button
								className='btn btn-success ml-2'
								type='submit'
							>
								Submit
							</button>
						</div>
					</form>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { AddAccounts };
