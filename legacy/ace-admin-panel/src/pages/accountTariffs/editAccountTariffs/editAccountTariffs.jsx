/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';
// import {
// 	Select,
// 	SelectContent,
// 	SelectItem,
// 	SelectTrigger,
// 	SelectValue,
// } from '@/components/ui/select';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import clsx from 'clsx';
import { useDispatch, useSelector } from 'react-redux';
import { updateAccountTariffs } from '../../../service/operations/settingsApi';
import { refreshAllAccountTariffs } from '../../../slices/tariffsSlice';

function EditAccountTariff({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { accountTariff } = useSelector((state) => state.tariff);
	const addLocalSchema = Yup.object().shape({
		name: Yup.string().required('Name is required'),
	});

	const initialValues = {
		name: accountTariff?.name || '',
		accountInitialCharge: accountTariff?.accountInitialCharge || 0,
		driverInitialCharge: accountTariff?.driverInitialCharge || 0,
		accountFirstMileCharge: accountTariff?.accountFirstMileCharge || 0,
		driverFirstMileCharge: accountTariff?.driverFirstMileCharge || 0,
		accountAdditionalMileCharge:
			accountTariff?.accountAdditionalMileCharge || 0,
		driverAdditionalMileCharge: accountTariff?.driverAdditionalMileCharge || 0,
	};

	const formik = useFormik({
		initialValues,
		validationSchema: addLocalSchema,
		onSubmit: async (values, { setSubmitting }) => {
			console.log('Submitted Values:', values);
			const payload = {
				...values,
				id: accountTariff?.id,
			};
			const response = await updateAccountTariffs(payload);
			if (response.status === 'success') {
				onOpenChange(); // Reset Formik's submitting state
				setSubmitting(false);
				dispatch(refreshAllAccountTariffs());
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
						Edit Account Tariff {accountTariff?.id}
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

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Account Initial Charge
								</label>
								<label className='input'>
									<input
										placeholder='Enter Initial Charge'
										autoComplete='off'
										{...formik.getFieldProps('accountInitialCharge')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.accountInitialCharge &&
												formik.errors.accountInitialCharge,
										})}
									/>
								</label>
								{formik.touched.accountInitialCharge &&
									formik.errors.accountInitialCharge && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.accountInitialCharge}
										</span>
									)}
							</div>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Driver Initial Charge
								</label>
								<label className='input'>
									<input
										placeholder='Enter Initial Charge'
										autoComplete='off'
										{...formik.getFieldProps('driverInitialCharge')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.driverInitialCharge &&
												formik.errors.driverInitialCharge,
										})}
									/>
								</label>
								{formik.touched.driverInitialCharge &&
									formik.errors.driverInitialCharge && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.driverInitialCharge}
										</span>
									)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Account First Mile Charge
								</label>
								<label className='input'>
									<input
										placeholder='Enter First Mile Charge'
										autoComplete='off'
										{...formik.getFieldProps('accountFirstMileCharge')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.accountFirstMileCharge &&
												formik.errors.accountFirstMileCharge,
										})}
									/>
								</label>
								{formik.touched.accountFirstMileCharge &&
									formik.errors.accountFirstMileCharge && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.accountFirstMileCharge}
										</span>
									)}
							</div>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Driver First Mile Charge
								</label>
								<label className='input'>
									<input
										placeholder='Enter First Mile Charge'
										autoComplete='off'
										{...formik.getFieldProps('driverFirstMileCharge')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.driverFirstMileCharge &&
												formik.errors.driverFirstMileCharge,
										})}
									/>
								</label>
								{formik.touched.driverFirstMileCharge &&
									formik.errors.driverFirstMileCharge && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.driverFirstMileCharge}
										</span>
									)}
							</div>
						</div>

						<div className='w-full flex justify-center items-center gap-2'>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Account Additional Mile Charge
								</label>
								<label className='input'>
									<input
										placeholder='Enter Additional Charge'
										autoComplete='off'
										{...formik.getFieldProps('accountAdditionalMileCharge')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.accountAdditionalMileCharge &&
												formik.errors.accountAdditionalMileCharge,
										})}
									/>
								</label>
								{formik.touched.accountAdditionalMileCharge &&
									formik.errors.accountAdditionalMileCharge && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.accountAdditionalMileCharge}
										</span>
									)}
							</div>
							<div className='flex flex-col gap-1 pb-2'>
								<label className='form-label text-gray-900'>
									Driver Additional Mile Charge
								</label>
								<label className='input'>
									<input
										placeholder='Enter Additional Charge'
										autoComplete='off'
										{...formik.getFieldProps('driverAdditionalMileCharge')}
										className={clsx('form-control', {
											'is-invalid':
												formik.touched.driverAdditionalMileCharge &&
												formik.errors.driverAdditionalMileCharge,
										})}
									/>
								</label>
								{formik.touched.driverAdditionalMileCharge &&
									formik.errors.driverAdditionalMileCharge && (
										<span
											role='alert'
											className='text-danger text-xs mt-1'
										>
											{formik.errors.driverAdditionalMileCharge}
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

export { EditAccountTariff };
