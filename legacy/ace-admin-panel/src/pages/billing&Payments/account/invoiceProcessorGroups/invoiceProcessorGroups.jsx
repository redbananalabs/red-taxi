/** @format */
import { Fragment, useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';

import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
import {
	Popover,
	PopoverTrigger,
	PopoverContent,
} from '@/components/ui/popover';
import { KeenIcon } from '@/components';
import { cn } from '@/lib/utils';
import { Calendar } from '@/components/ui/calendar';
import { format, subDays } from 'date-fns';
import { refreshAllAccounts } from '../../../../slices/accountSlice';
import {
	// refreshAccountChargeableGroupJobs,
	refreshAccountChargeableGroupSplitJobs,
} from '../../../../slices/billingSlice';
// import NotPriced from './notPriced';
// import Priced from './priced';
import SinglesTab from './SinglesTab';
import SharedTab from './SharedTab';

function InvoiceProcessorGroups() {
	const dispatch = useDispatch();
	const { accounts } = useSelector((state) => state.account);
	const {
		// accountChargeableGroupJobs,
		accountChargeableGroupSplitJobs,
		loading,
	} = useSelector((state) => state.billing);
	// const { priced, notPriced } = accountChargeableGroupJobs;
	const { shared, singles } = accountChargeableGroupSplitJobs;
	const [selectedAccount, setSelectedAccount] = useState(0);
	const [activeTab, setActiveTab] = useState('singles');
	const [open, setOpen] = useState(false);

	const [dateRange, setDateRange] = useState({
		from: subDays(new Date(), 30), // January 31, 2025
		to: new Date(), // Same default date
	});
	const [tempRange, setTempRange] = useState(dateRange);
	const tabs = [
		{ id: 1, label: 'singles', value: 'Singles' },
		{ id: 2, label: 'shared', value: 'Shared' },
	];

	useEffect(() => {
		if (open) {
			setTempRange({ from: null, to: null });
		}
	}, [open]);

	const handleDateSelect = (range) => {
		setTempRange(range);
		if (range?.from && range?.to) {
			setDateRange(range);
			setOpen(false);
		}
	};

	const toggleActiveTab = (tab) => {
		setActiveTab(tab);
	};

	// const handleShow = () => {
	// 	dispatch(
	// 		refreshAccountChargeableGroupJobs(
	// 			selectedAccount,
	// 			format(new Date(dateRange?.from), 'yyyy-MM-dd'),
	// 			format(new Date(dateRange?.to), 'yyyy-MM-dd')
	// 		)
	// 	);
	// };

	const handleShowGroupSplit = () => {
		dispatch(
			refreshAccountChargeableGroupSplitJobs(
				selectedAccount,
				format(new Date(dateRange?.from), 'yyyy-MM-dd'),
				format(new Date(dateRange?.to), 'yyyy-MM-dd')
			)
		);
	};

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
							Account Job Processor (Grp){' '}
						</ToolbarDescription>
					</ToolbarHeading>
				</Toolbar>
				<div className='ms-auto me-auto max-w-[1850px] w-full'>
					<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
						<div className='flex flex-wrap items-center gap-5 justify-between'>
							<div className='card card-grid min-w-full'>
								<div className='card-header flex-wrap gap-2'>
									<div className='flex flex-wrap gap-2 lg:gap-5'>
										{/* <div className='flex'>
											<label
												className='input input-sm hover:shadow-lg mt-4'
												style={{ height: '40px' }}
											>
												<KeenIcon icon='magnifier' />
												<input
													type='text'
													placeholder='Search'
													value={search}
													onChange={(e) => setSearch(e.target.value)}
												/>
											</label>
										</div> */}
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

											<div className='flex flex-col'>
												<label className='form-label'>Select Date Range</label>
												<Popover
													open={open}
													onOpenChange={setOpen}
												>
													<PopoverTrigger asChild>
														<button
															id='date'
															className={cn(
																'btn btn-sm btn-light data-[state=open]:bg-light-active',
																!dateRange && 'text-gray-400'
															)}
															style={{ height: '40px' }}
														>
															<KeenIcon
																icon='calendar'
																className='me-0.5'
															/>
															{dateRange?.from ? (
																dateRange.to ? (
																	<>
																		{format(dateRange.from, 'LLL dd, y')} -{' '}
																		{format(dateRange.to, 'LLL dd, y')}
																	</>
																) : (
																	format(dateRange.from, 'LLL dd, y')
																)
															) : (
																<span>Pick a date range</span>
															)}
														</button>
													</PopoverTrigger>

													<PopoverContent
														className='w-auto p-0'
														align='end'
													>
														<Calendar
															mode='range'
															selected={tempRange}
															onSelect={handleDateSelect}
															numberOfMonths={2}
															initialFocus
														/>
													</PopoverContent>
												</Popover>
											</div>

											{/* <div className='flex items-center gap-2'>
												<label className='switch switch-sm flex-1 sm:flex-none mt-4'>
													<span className='switch-label'>
														Auto Email Invoices
													</span>
													<input
														type='checkbox'
														name='check'
														checked={autoEmailInvoices} // Controlled value
														onChange={(e) =>
															setAutoEmailInvoices(e.target.checked)
														} // Update state on change
													/>
												</label>
											</div> */}

											<button
												className='btn btn-primary flex justify-center mt-4'
												onClick={handleShowGroupSplit}
												disabled={loading}
											>
												{loading ? 'Searching...' : 'Show Jobs'}
											</button>
										</div>
									</div>
								</div>
								<div className='flex justify-start items-center gap-3 ml-4 mt-2 mb-2'>
									{tabs?.map((tab) => (
										<>
											<button
												className={`btn ${activeTab === tab.label ? 'btn-primary' : 'btn-secondary'} `}
												key={tab.id}
												onClick={() => toggleActiveTab(tab.label)}
											>
												{tab.value}
											</button>
										</>
									))}
								</div>
								{activeTab === 'singles' && (
									<SinglesTab
										singles={singles}
										handleShow={handleShowGroupSplit}
									/>
								)}

								{activeTab === 'shared' && (
									<SharedTab
										shared={shared}
										handleShow={handleShowGroupSplit}
									/>
								)}
							</div>
						</div>
					</div>
				</div>
			</div>
		</Fragment>
	);
}

export { InvoiceProcessorGroups };
