/** @format */

import NotPriced from './Singles/notPriced';
import Priced from './Singles/priced';

export default function SinglesTab({ singles, handleShow }) {
	const { notPriced, priced } = singles;
	return (
		<>
			<div className='card-body'>
				<div className='flex justify-start items-center gap-4 ml-4 mt-2 mb-2'>
					Awaiting Pricing - {notPriced?.length}
				</div>
				{notPriced?.length > 0 ? (
					<>
						<NotPriced handleShow={handleShow} />
					</>
				) : (
					<div className='text-start ml-4  text-yellow-600 dark:border dark:border-yellow-400 dark:opacity-50 dark:bg-transparent rounded-md bg-yellow-100 p-2 mr-4'>
						⚠️ No Data Available
					</div>
				)}
			</div>
			<div className='card-body mt-10'>
				<div className='flex justify-start items-center gap-4 ml-4 mt-2 mb-2'>
					Ready for Invoicing - {priced?.length}
				</div>
				{priced?.length > 0 ? (
					<>
						<Priced handleShow={handleShow} />
					</>
				) : (
					<div className='text-start ml-4  text-yellow-600 dark:border dark:border-yellow-400 dark:opacity-50 dark:bg-transparent rounded-md bg-yellow-100 p-2 mr-4 mb-2'>
						⚠️ No Data Available
					</div>
				)}
			</div>
		</>
	);
}
