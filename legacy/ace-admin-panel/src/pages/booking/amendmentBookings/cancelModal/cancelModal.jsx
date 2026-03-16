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
import {
	cancelBooking,
	updateAmendRequest,
} from '../../../../service/operations/webBookingsApi';
import toast from 'react-hot-toast';
import { refreshAmendWebBookings } from '../../../../slices/webBookingSlice';
function CancelModal({ open, onOpenChange }) {
	const dispatch = useDispatch();
	const user = JSON.parse(localStorage.getItem('userData'));
	const { amendRequest } = useSelector((state) => state.webBooking);

	const handleDelete = async () => {
		try {
			const payload = {
				bookingId: amendRequest?.bookingId,
				cancelledByName: user?.fullName,
				cancelBlock: amendRequest?.applyToBlock ? true : false,
				cancelledOnArrival: false,
				actionByUserId: user?.userId,
				sendEmail: true,
			};
			const response = await cancelBooking(payload);

			if (response.status === 'success') {
				toast.success('Booking cancelled successfully');
				await updateAmendRequest(amendRequest?.id);
				await dispatch(refreshAmendWebBookings());
				// Close the modal after deletion
			} else {
				toast.error(response?.message);
			}
			onOpenChange();
		} catch (error) {
			console.error(error);
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
						{amendRequest?.applyToBlock
							? 'Cancel Block Booking'
							: 'Cancel Booking'}
					</h3>

					<div className='text-2sm text-center text-gray-700 mb-7'>
						Are you sure you want to cancel the booking for{' '}
						{amendRequest?.passengerName}{' '}
						{amendRequest?.applyToBlock ? 'from' : 'on'}{' '}
						{new Date(amendRequest?.dateTime).toLocaleDateString('en-GB') +
							' ' +
							amendRequest?.dateTime
								?.split('T')[1]
								.split('.')[0]
								?.slice(0, 5)}{' '}
						{amendRequest?.applyToBlock && (
							<>
								and <span className='font-bold'>Future Booking</span>
							</>
						)}{' '}
						?
					</div>

					<div className='flex justify-center mb-2'>
						<button
							className='btn btn-light'
							onClick={() => onOpenChange()}
						>
							No
						</button>
						<button
							className='btn btn-primary ml-2'
							onClick={handleDelete}
						>
							Yes
						</button>
					</div>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { CancelModal };
