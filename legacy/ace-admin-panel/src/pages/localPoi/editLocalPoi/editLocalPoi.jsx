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
import { useDispatch, useSelector } from 'react-redux';
import { updatePoi } from '../../../service/operations/localPOIApi';
import { refreshAllLocalPOIS } from '../../../slices/localPOISlice';
function EditLocalPoi({ open, onOpenChange }) {
	const { localPOI } = useSelector((state) => state.localPoi);
	const dispatch = useDispatch();
	const addLocalSchema = Yup.object().shape({
		address: Yup.string().required('Address is required'),
		postcode: Yup.string().required('Postcode is required'),
		type: Yup.string().required('Type is required'),
	});

	const initialValues = {
		name: localPOI?.name || '',
		address: localPOI?.address || '',
		postcode: localPOI?.postcode || '',
		type: localPOI?.type || 0, // Placeholder username
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			const payload = {
				...values,
				id: localPOI?.id,
			};
			const result = await updatePoi(payload);
			if (result.status === 'success') {
				onOpenChange(); // Reset Formik's submitting state
				dispatch(refreshAllLocalPOIS());
				setSubmitting(false);
			}
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
						Edit Local POI {localPOI?.id}
					</h3>

					<form onSubmit={formik.handleSubmit}>
						<div className='flex flex-col gap-1 pb-2'>
							<label className='form-label text-gray-900'>Name</label>
							<label className='input'>
								<input
									placeholder='Enter name'
									autoComplete='off'
									{...formik.getFieldProps('name')}
									className={clsx('form-control', {
										'is-invalid': formik.touched.name && formik.errors.name,
									})}
								/>
							</label>
							{formik.touched.name && formik.errors.name && (
								<span
									role='alert'
									className='text-danger text-xs mt-1'
								>
									{formik.errors.name}
								</span>
							)}
						</div>
						<div className='flex flex-col gap-1 pb-2'>
							<label className='form-label text-gray-900'>Address</label>
							<label className='input'>
								<input
									placeholder='Enter address'
									autoComplete='off'
									{...formik.getFieldProps('address')}
									className={clsx('form-control', {
										'is-invalid':
											formik.touched.address && formik.errors.address,
									})}
								/>
							</label>
							{formik.touched.address && formik.errors.address && (
								<span
									role='alert'
									className='text-danger text-xs mt-1'
								>
									{formik.errors.address}
								</span>
							)}
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2'>
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
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>Type</label>

								<Select
									defaultValue='1'
									value={formik.values.type}
									onValueChange={(value) =>
										formik.setFieldValue('type', Number(value))
									}
								>
									<SelectTrigger className=' w-52'>
										<SelectValue placeholder='Select' />
									</SelectTrigger>
									<SelectContent>
										<SelectItem value={0}>Not Set</SelectItem>
										<SelectItem value={1}>Train Station</SelectItem>
										<SelectItem value={2}>Super Market</SelectItem>
										<SelectItem value={3}>House</SelectItem>
										<SelectItem value={4}>Pub</SelectItem>
										<SelectItem value={5}>Restaurant</SelectItem>
										<SelectItem value={6}>Doctors</SelectItem>
										<SelectItem value={7}>Airport</SelectItem>
										<SelectItem value={8}>Ferry Port</SelectItem>
										<SelectItem value={9}>Hotel</SelectItem>
										<SelectItem value={10}>School</SelectItem>
										<SelectItem value={11}>Hospital</SelectItem>
										<SelectItem value={12}>Wedding Venue</SelectItem>
										<SelectItem value={13}>Miscellaneous</SelectItem>
										<SelectItem value={14}>Shopping Center</SelectItem>
									</SelectContent>
								</Select>
								{formik.touched.type && formik.errors.type && (
									<span
										role='alert'
										className='text-danger text-xs mt-1'
									>
										{formik.errors.type}
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

export { EditLocalPoi };
