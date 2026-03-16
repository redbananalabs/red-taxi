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
import { deleteAccounts } from '../../../service/operations/accountApi';
import { refreshAllAccounts } from '../../../slices/accountSlice';
function DeleteAccounts({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const { account } = useSelector((state) => state.account);
	const handleDelete = async () => {
		const response = await deleteAccounts(account?.accNo);
		if (response.status === 'success') {
			onOpenChange();
			dispatch(refreshAllAccounts());
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
						Delete Account {account?.accNo}
					</h3>

					<div className='text-2sm text-center text-gray-700 mb-7'>
						Are you sure you want to delete this account ?
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

export { DeleteAccounts };
