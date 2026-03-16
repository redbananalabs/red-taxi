/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';
import { useDispatch, useSelector } from 'react-redux';
import { deleteDriver } from '../../../service/operations/driverApi';
import toast from 'react-hot-toast';
import { refreshAllDrivers } from '../../../slices/driverSlice';
function DeleteDriver({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { driver } = useSelector((state) => state.driver);
	const handleDelete = async () => {
		try {
			const response = await deleteDriver(driver?.id);
			if (response.status === 'success') {
				toast.success('Driver Deleted Successfully');
				dispatch(refreshAllDrivers());
				onOpenChange(); // Close the modal after deletion
			} else {
				console.error('Failed to delete driver', response.error);
				toast.error('Failed to delete driver');
			}
		} catch (error) {
			console.error('Failed to delete driver', error);
		}
	};
	return (
		<Dialog
			open={open}
			onOpenChange={onOpenChange}
		>
			<DialogContent className='max-w-[400px]'>
				<DialogHeader className='border-0'>
					<DialogTitle></DialogTitle>
					<DialogDescription></DialogDescription>
				</DialogHeader>
				<DialogBody className='flex flex-col items-center pt-2 pb-4'>
					<h3 className='text-lg font-medium text-gray-900 text-center mb-2'>
						Delete Driver
					</h3>

					<div className='text-2sm text-center text-gray-700 mb-7'>
						Are you sure you want to delete this driver ?
					</div>

					<div className='flex justify-center mb-2'>
						<button
							className='btn btn-light'
							onClick={() => onOpenChange()}
						>
							Cancel
						</button>
						<button
							className='btn btn-danger ml-2'
							onClick={handleDelete}
						>
							Delete
						</button>
					</div>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { DeleteDriver };
