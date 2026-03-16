/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarActions,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import { KeenIcon } from '@/components';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';

// import { Container } from '@/components/container';
// import {
// 	Popover,
// 	PopoverContent,
// 	PopoverTrigger,
// } from '@/components/ui/popover';
// import { Calendar } from '@/components/ui/calendar';
// import { format } from 'date-fns';
// import { cn } from '@/lib/utils';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import { Link } from 'react-router-dom';
// import { CancelModal } from './cancelModal';
import RefreshIcon from '@mui/icons-material/Refresh';
import { refreshCreditNotes } from '../../../../slices/billingSlice';
import { refreshAllAccounts } from '../../../../slices/accountSlice';
import { downloadCreditNotes } from '../../../../service/operations/billing&Payment';
import toast from 'react-hot-toast';
import { IconButton } from '@mui/material';
import DownloadOutlinedIcon from '@mui/icons-material/DownloadOutlined';

function CreditNotes() {
	// const navigate = useNavigate();
	const dispatch = useDispatch();
	const { accounts } = useSelector((state) => state.account);
	const { creditNotes } = useSelector((state) => state.billing);
	const [searchInput, setSearchInput] = useState('');
	const [selectedAccount, setSelectedAccount] = useState(0);

	const filteredBookings = useMemo(() => {
		// if No filtration is applied
		if (!searchInput) {
			return creditNotes;
		}

		return creditNotes?.filter((booking) => {
			const searchValue = searchInput?.toLowerCase();

			const isMatch =
				booking?.accountNo?.toLowerCase().includes(searchValue) ||
				booking?.invoiceNumber
					.toString()
					?.toLowerCase()
					.includes(searchValue) ||
				booking?.reason?.toLowerCase().includes(searchValue);

			return isMatch;
		});
	}, [creditNotes, searchInput]);

	const ColumnInputFilter = ({ column }) => {
		return (
			<Input
				placeholder='Filter...'
				value={column.getFilterValue() ?? ''}
				onChange={(event) => column.setFilterValue(event.target.value)}
				className='h-9 w-full max-w-40'
			/>
		);
	};

	const downloadCreditNotesPDF = async (row) => {
		try {
			const response = await downloadCreditNotes(row?.id);
			if (!response || response.size === 0) {
				console.error('Invalid or empty file received from API.');
				toast.error('Error downloading credit notes.');
				return;
			}

			const blob = new Blob([response], { type: 'application/pdf' });
			const link = document.createElement('a');
			link.href = URL.createObjectURL(blob);
			link.setAttribute('download', `credit-notes-${row.id}.pdf`);
			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
		} catch (error) {
			console.error('Error handling credit notes download:', error);
			toast.error('Error downloading credit notes. Please try again.');
		}
	};

	const columns = useMemo(
		() => [
			{
				accessorKey: 'id',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Id #</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row?.original?.id}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'invoiceNumber',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Invoice #</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>
						{row?.original?.invoiceNumber}
					</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'accountNo',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Account No.</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row?.original?.accountNo}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'invoiceDate',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Date/Time</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{new Date(
							row.original.invoiceDate?.split('T')[0]
						)?.toLocaleDateString('en-GB')}{' '}
						{row.original.invoiceDate?.split('T')[1].split('.')[0]?.slice(0, 5)}
					</span>
				),
				meta: { headerClassName: 'min-w-[160px]' },
			},

			{
				accessorKey: 'vatTotal',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>VAT Total</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row?.original?.vatTotal?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'netTotal',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Net Total</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.netTotal?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'total',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Total</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.total?.toFixed(2)}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'numberOfJourneys',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>No. of Journeys</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row?.original?.numberOfJourneys}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'reason',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Reason</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>{row?.original?.reason}</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			// {
			// 	accessorKey: 'action',
			// 	header: ({ column }) => (
			// 		<DataGridColumnHeader
			// 			title=<span className='font-bold'>Block</span>
			// 			column={column}
			// 		/>
			// 	),
			// 	enableSorting: true,
			// 	cell: ({ row }) => (
			// 		<span className={row.original.color}>
			// 			{row?.original?.applyToBlock ? 'True' : 'False'}
			// 		</span>
			// 	),
			// 	meta: { headerClassName: 'w-18' },
			// },
			{
				accessorKey: 'action',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Actions</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div className='w-full flex justify-start items-center gap-2'>
						<IconButton
							size='small'
							onClick={() => downloadCreditNotesPDF(row?.original)}
							// disabled={
							// 	buttonLoading.rowId === row?.id &&
							// 	buttonLoading.button === 'downloadPdf'
							// }
						>
							<DownloadOutlinedIcon
								className={`${row?.coa ? `text-red-500 dark:text-red-900 ` : `text-red-500 dark:text-red-600`}`}
							/>
						</IconButton>
					</div>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
		],
		[]
	);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	useEffect(() => {
		dispatch(refreshCreditNotes(selectedAccount));
	}, [dispatch, selectedAccount]);

	useEffect(() => {
		dispatch(refreshAllAccounts());
	}, [dispatch]);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Total {`${creditNotes.length}`} Amend Web Request(s){' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<Link to='/bookings/web-booking'>
							<button className='btn btn-sm btn-primary px-4 py-4'>
								<KeenIcon icon='arrow-left' /> Back
							</button>
						</Link>
					</ToolbarActions>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							<div className='card-header flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'>
									<div className='flex'>
										<label
											className='input input-sm'
											style={{ height: '40px', marginTop: '17px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Jobs'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div>
									<div className='flex flex-wrap items-center gap-2.5'>
										<div className='flex flex-col'>
											<label className='form-label'>Accounts</label>
											<Select
												value={selectedAccount}
												onValueChange={(value) => setSelectedAccount(value)}
											>
												<SelectTrigger
													className='w-40 hover:shadow-lg'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-40'>
													<SelectItem value={0}>All</SelectItem>
													{accounts?.length > 0 &&
														accounts?.map((acc) => (
															<>
																<SelectItem value={acc?.accNo}>
																	{acc?.accNo} - {acc?.businessName}
																</SelectItem>
															</>
														))}
												</SelectContent>
											</Select>
										</div>
										{/* <Popover
											open={open}
											onOpenChange={setOpen}
										>
											<PopoverTrigger asChild>
												<div className='relative'>
													<button
														id='date'
														className={cn(
															'input data-[state=open]:border-primary',
															!date && 'text-muted-foreground'
														)}
														style={{ width: '13rem' }}
													>
														<KeenIcon
															icon='calendar'
															className='-ms-0.5'
														/>
														{date ? (
															format(date, 'LLL dd, y')
														) : (
															<span>Pick a date</span>
														)}
													</button>
													{date && (
														<button
															onClick={(e) => {
																e.stopPropagation(); // Prevent closing popover
																setDate(null); // Clear date
															}}
															className='absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700'
														>
															<KeenIcon
																icon='cross-circle'
																className=''
															/>
														</button>
													)}
												</div>
											</PopoverTrigger>
											<PopoverContent
												className='w-auto p-0'
												align='start'
											>
												<Calendar
													initialFocus
													mode='single' // Single date selection
													defaultMonth={date}
													selected={date}
													onSelect={handleDateSelect}
													numberOfMonths={1}
												/>
											</PopoverContent>
										</Popover> */}

										<button
											className='btn btn-sm btn-outline btn-primary mt-[17px]'
											style={{ height: '40px' }}
											onClick={() =>
												dispatch(refreshCreditNotes(selectedAccount))
											}
										>
											<RefreshIcon sx={{ fontSize: '12px' }} /> Refresh
										</button>
									</div>
								</div>
							</div>
							<div className='card-body'>
								<DataGrid
									columns={columns}
									data={filteredBookings}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'id', desc: false }]}
									layout={{ card: true }}
								/>
							</div>
						</div>
					</div>
				</div>
				{/* {cancelModal && (
					<CancelModal
						open={cancelModal}
						onOpenChange={handleClose}
					/>
				)} */}
			</div>
		</Fragment>
	);
}

export { CreditNotes };
