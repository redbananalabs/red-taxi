/** @format */
import {
	Dialog,
	DialogBody,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/components/ui/dialog';

function AddAccounts({ open, onOpenChange }) {
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
				<DialogBody className='flex flex-col items-center pt-10 pb-10'>
					<div className='mb-10'></div>

					<h3 className='text-lg font-medium text-gray-900 text-center mb-3'>
						Welcome to Metronic
					</h3>

					<div className='text-2sm text-center text-gray-700 mb-7'>
						We&apos;re thrilled to have you on board and excited for <br />
						the journey ahead together.
					</div>

					<div className='flex justify-center mb-2'></div>
				</DialogBody>
			</DialogContent>
		</Dialog>
	);
}

export { AddAccounts };
