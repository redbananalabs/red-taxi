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
import { deletePoi } from '../../../service/operations/localPOIApi';
import { refreshAllLocalPOIS } from '../../../slices/localPOISlice';
function DeleteLocalPoi({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { localPOI } = useSelector((state) => state.localPoi);
	const handleDelete = async () => {
		console.log('local Poi deleted', localPOI);
		const response = await deletePoi(localPOI?.id);
		if (response.status === 'success') {
			onOpenChange();
			dispatch(refreshAllLocalPOIS());
		} // Close the modal after deletion
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
						Delete Local POI {localPOI?.id}
					</h3>

					<div className='text-2sm text-center text-gray-700 mb-7'>
						Are you sure you want to delete this local POI ?
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

export { DeleteLocalPoi };
