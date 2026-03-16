/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';
import { useSelector } from 'react-redux';
function DeleteAccounts({ open, onOpenChange }) {
	const { account } = useSelector((state) => state.account);
	const handleDelete = () => {
		console.log('account deleted', account);
		// Delete local POI logic goes here
		onOpenChange(); // Close the modal after deletion
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
						Delete Account
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
							className='btn btn-primary ml-2'
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
