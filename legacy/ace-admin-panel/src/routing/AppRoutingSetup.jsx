/** @format */

import { Navigate, Route, Routes } from 'react-router';
import { DefaultPage, Demo1DarkSidebarPage } from '@/pages/dashboards';
import {
	NewBooking,
	BookingDispatch,
	DriverTracking,
	Availability,
	AvailabilityLogs,
	AvailabilityReport,
	// SearchBooking,
	AirportRuns,
	CardBookings,
	RejectedBookings,
	AcceptedBookings,
	AmendmentBookings,
	AuditBooking,
	CancelByRange,
	CancelByRangeReport,
	Tariff,
	TurndownBookings,
} from '@/pages/booking';
import { UnAllocated } from '@/pages/dispatch';
import { AuthPage } from '@/auth';
import { Demo1Layout } from '@/layouts/demo1';
import { ErrorsRouting } from '@/errors';
import { RequireAuth } from '../auth';
import { ListLocalPoi } from '@/pages/localPoi';
import { ListAccounts } from '@/pages/accounts';
import { ListDriver } from '@/pages/drivers';
import {
	StateProcessing,
	StatementHistory,
	InvoiceProcessor,
	InvoiceProcessorGroups,
	InvoiceHistory,
	InvoiceDelete,
	CreditNotes,
	VatOutputs,
	CreditJourneys,
} from '@/pages/billing&Payments';
import { DriverEarningReport } from '@/pages/driverEarningReport';
import { CompanySetting, MsgSettings } from '@/pages/bookingSettings';
import { DriverExpenses } from '@/pages/driverExpenses';
import { DriverExpiryList } from '@/pages/drivers/driverExpiry';
import {
	AvergeDuration,
	ByVehicleType,
	CountByScope,
	DuplicateBookings,
	GrowthByPeriod,
	PayoutsByMonth,
	PickupsByPostcode,
	ProfitabilityByDateRange,
	ProfitabilityOnInvoice,
	QrScansAdverts,
	RevenueByMonth,
	TopCustomer,
	TotalProfitabilityByPeriod,
} from '../pages/reports';
import { HvsAccountChanges } from '@/pages/bookingUtilities';
import { ListAccountTariffs } from '@/pages/accountTariffs';

const AppRoutingSetup = () => {
	const userRole = JSON.parse(localStorage.getItem('userData'))?.roleId || 0;
	return (
		<Routes>
			<Route element={<RequireAuth />}>
				<Route element={<Demo1Layout />}>
					<Route
						path='/'
						element={<DefaultPage />}
					/>
					<Route
						path='/dark-sidebar'
						element={<Demo1DarkSidebarPage />}
					/>
					<Route
						path='/bookings/booking-dispatch'
						element={<BookingDispatch />}
					/>
					<Route
						path='/bookings/web-booking'
						element={<NewBooking />}
					/>
					<Route
						path='/bookings/amend-booking'
						element={<AmendmentBookings />}
					/>
					<Route
						path='/bookings/accept-booking'
						element={<AcceptedBookings />}
					/>
					<Route
						path='/bookings/reject-booking'
						element={<RejectedBookings />}
					/>
					<Route
						path='/booking/driver-tracking'
						element={<DriverTracking />}
					/>
					<Route
						path='/booking/availability'
						element={<Availability />}
					/>
					<Route
						path='/booking/availability-logs'
						element={<AvailabilityLogs />}
					/>
					<Route
						path='/booking/availability-report'
						element={<AvailabilityReport />}
					/>

					{/* <Route
						path='/bookings/search-booking'
						element={<SearchBooking />}
					/> */}
					{userRole === 1 && (
						<Route
							path='/bookings/audit-view'
							element={<AuditBooking />}
						/>
					)}
					{userRole === 1 && (
						<Route
							path='/bookings/cancelbyrange'
							element={<CancelByRange />}
						/>
					)}
					{userRole === 1 && (
						<Route
							path='/bookings/cancelbyrangereport'
							element={<CancelByRangeReport />}
						/>
					)}
					<Route
						path='/bookings/turndown'
						element={<TurndownBookings />}
					/>
					<Route
						path='/bookings/airport-runs'
						element={<AirportRuns />}
					/>
					{userRole === 1 && (
						<Route
							path='/bookings/card-bookings'
							element={<CardBookings />}
						/>
					)}
					<Route
						path='/bookings/global-search'
						element={<UnAllocated />}
					/>
					{/* <Route
						path='/dispatch/allocated-jobs'
						element={<Allocated />}
					/> */}
					{/* <Route
						path='/dispatch/cancelled-jobs'
						element={<Cancelled />}
					/> */}
					{/* <Route
						path='/dispatch/completed-jobs'
						element={<Completed />}
					/> */}
					<Route
						path='/localPOIs/list-local-Poi'
						element={<ListLocalPoi />}
					/>
					{userRole !== 2 && (
						<Route
							path='/accounts/list-account'
							element={<ListAccounts />}
						/>
					)}

					{userRole !== 2 && (
						<Route
							path='/drivers/expires'
							element={<DriverExpiryList />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/drivers/list-driver'
							element={<ListDriver />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/driver-expenses'
							element={<DriverExpenses />}
						/>
					)}

					{userRole !== 2 && (
						<Route
							path='/billing/driver/statement-processing'
							element={<StateProcessing />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/driver/statement-history'
							element={<StatementHistory />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/account/invoice-processor'
							element={<InvoiceProcessor />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/account/invoice-processor-grp'
							element={<InvoiceProcessorGroups />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/account/invoice-history'
							element={<InvoiceHistory />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/account/credit-invoice'
							element={<InvoiceDelete />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/account/credit-journeys'
							element={<CreditJourneys />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/account/credit-notes'
							element={<CreditNotes />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/billing/vat-outputs'
							element={<VatOutputs />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/tariffs'
							element={<Tariff />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/accountTariffs'
							element={<ListAccountTariffs />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/driver-earning-report'
							element={<DriverEarningReport />}
						/>
					)}
					{
						<Route
							path='/bookings/duplicate-bookings'
							element={<DuplicateBookings />}
						/>
					}
					{
						<Route
							path='/bookings/count-by-scope'
							element={<CountByScope />}
						/>
					}
					{userRole !== 2 && (
						<Route
							path='/bookings/top-customer'
							element={<TopCustomer />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/bookings/growth-by-period'
							element={<GrowthByPeriod />}
						/>
					)}
					{
						<Route
							path='/bookings/pickups-by-postcode'
							element={<PickupsByPostcode />}
						/>
					}
					{
						<Route
							path='/bookings/by-vehicle-type'
							element={<ByVehicleType />}
						/>
					}
					{
						<Route
							path='/bookings/average-duration'
							element={<AvergeDuration />}
						/>
					}
					{userRole !== 2 && (
						<Route
							path='/financial/payouts-by-month'
							element={<PayoutsByMonth />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/financial/revenue-by-month'
							element={<RevenueByMonth />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/financial/profitability-on-invoice'
							element={<ProfitabilityOnInvoice />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/financial/total-profitability-by-period'
							element={<TotalProfitabilityByPeriod />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/financial/profitability-by-date-range'
							element={<ProfitabilityByDateRange />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/financial/qr-code-adverts'
							element={<QrScansAdverts />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/setting/company-settings'
							element={<CompanySetting />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/setting/msg-settings'
							element={<MsgSettings />}
						/>
					)}
					{userRole !== 2 && (
						<Route
							path='/utilities/hvs-account-changes'
							element={<HvsAccountChanges />}
						/>
					)}
				</Route>
			</Route>
			<Route
				path='error/*'
				element={<ErrorsRouting />}
			/>
			<Route
				path='auth/*'
				element={<AuthPage />}
			/>
			<Route
				path='*'
				element={<Navigate to='/error/404' />}
			/>
		</Routes>
	);
};
export { AppRoutingSetup };
