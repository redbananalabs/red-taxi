/** @format */

const BASE = import.meta.env.VITE_BASE_URL;

export const authEndpoints = {
  LOGIN: `${BASE}/api/UserProfile/Login`,
  REGISTER: `${BASE}/api/UserProfile/Register`,
  GET_USER: (username) =>
    `${BASE}/api/UserProfile/GetUser?username=${username}`,
  RESET_PASSWORD: (userId) =>
    `${BASE}/api/UserProfile/ResetPassword?userId=${userId}`,
};

export const LocalPoiEndpoints = {
  CREATE_LOCAL_POI: `${BASE}/api/AdminUI/AddPOI`,
  UPDATE_LOCAL_POI: `${BASE}/api/AdminUI/UpdatePOI`,
  DELETE_LOCAL_POI: (id) => `${BASE}/api/AdminUI/DeletePOI?id=${id}`,
  GET_ALL_POIS: `${BASE}/api/AdminUI/GetPOIs`,
};

export const availabilityEndpoints = {
  GET_AVAILABILITY_LOG: (userId, date) =>
    `${BASE}/api/AdminUI/AvailabilityLog?userid=${userId}&date=${date}`,
  GET_AVAILABILITY: (userId, date) =>
    `${BASE}/api/AdminUI/GetAvailability?userid=${userId}&date=${date}`,
  DELETE_AVAILABILITY: (id) =>
    `${BASE}/api/AdminUI/DeleteAvailability?availabilityId=${id}`,
  SET_AVAILABILITY: `${BASE}/api/AdminUI/SetAvailability`,
  AVAILABILITY_REPORT: `${BASE}/api/AdminUI/AvailabilityReport`,
};

export const accountEndpoints = {
  CREATE_ACCOUNTS: `${BASE}/api/AdminUI/AddAccount`,
  GET_ACCOUNTS: `${BASE}/api/AdminUI/GetAccounts`,
  UPDATE_ACCOUNTS: `${BASE}/api/AdminUI/UpdateAccount`,
  DELETE_ACCOUNTS: (accno) =>
    `${BASE}/api/AdminUI/DeleteAccount?accno=${accno}`,
  REGISTER_ACCOUNT_WEB_BOOKER: `${BASE}/api/AdminUI/RegisterAccountWebBooker`,
  GET_CLEAR_INVOICE: (invoiceNo) =>
    `${BASE}/api/Accounts/ClearInvoice?invoiceno=${invoiceNo}`,
};

export const bookingsEndpoints = {
  GET_CARD_BOOKINGS: `${BASE}/api/AdminUI/CardBookings`,
  CANCEL_BOOKING_DATE_RANGE: `${BASE}/api/AdminUI/CancelBookingsInRange`,
  CANCEL_REPORT_DATE_RANGE: `${BASE}/api/AdminUI/CancelBookingsInRangeReport`,
  SEND_REMINDER_CARD_PAYMENT: `${BASE}/api/AdminUI/SendCardPaymentReminder`,
  BOOKING_AUDIT: (id) => `${BASE}/api/AdminUI/BookingAudit?bookingId=${id}`,
  BOOKING_STATUS: (date, scope, status) =>
    `${BASE}/api/AdminUI/BookingsByStatus?date=${date}&scope=${scope}${status !== undefined ? `&status=${status}` : ""}`,
  ALLOCATE_BOOKING: `${BASE}/api/Bookings/Allocate`,
  AIRPORT_RUNS: (months) => `${BASE}/api/AdminUI/AirportRuns?months=${months}`,
  TURNDOWN_BOOKINGS: (from, to) =>
    `${BASE}/api/AdminUI/GetTurndowns?from=${from}&to=${to}`,
  RESTORE_CANCELLED: (id) =>
    `${BASE}/api/Bookings/RestoreCancelled?bookingId=${id}`,
};

export const gpsEndpoints = {
  GET_ALL_GPS: `${BASE}/api/UserProfile/GetAllGPS`,
  UPDATE_FCM: (fcm) => `${BASE}/api/AdminUI/UpdateBrowserFCM?fcm=${fcm}`,
  REMOVE_FCM: `${BASE}/api/AdminUI/RemoveBrowserFCM`,
  HVS_ACCOUNT_CHANGES: (from, to, action) =>
    `${BASE}/api/AdminUI/Move9014To10026?from=${from}&to=${to}&action=${action}`,
};

export const dashBoardEndpoints = {
  GET_DASHBOARD: `${BASE}/api/AdminUI/Dashboard`,
  GET_SMS_HEART_BEAT: `${BASE}/api/AdminUI/GetSMSHeartBeat`,
  SEND_DIRECT_MSG_TO_DRIVER: (driver, msg) =>
    `${BASE}/api/AdminUI/SendMessageToDriver?driver=${driver}&message=${encodeURIComponent(msg)}`,
  SEND_GLOBAL_MSG_TO_DRIVER: (msg) =>
    `${BASE}/api/AdminUI/SendMessageToAllDrivers?message=${encodeURIComponent(msg)}`,
};

export const driverEarningEndpoints = {
  GET_DRIVER_EARNINGS_REPORT: `${BASE}/api/AdminUI/DriverEarningsReport`,
};

export const settingsEndpoints = {
  GET_MSG_CONFIG: `${BASE}/api/AdminUI/GetMessageConfig`,
  UPDATE_MSG_CONFIG: `${BASE}/api/AdminUI/UpdateMessageConfig`,
  GET_COMPANY_CONFIG: `${BASE}/api/AdminUI/GetCompanyConfig`,
  UPDATE_COMPANY_CONFIG: `${BASE}/api/AdminUI/UpdateCompanyConfig`,
  GET_TARIFF_CONFIG: `${BASE}/api/AdminUI/GetTariffConfig`,
  SET_TARIFF_CONFIG: `${BASE}/api/AdminUI/SetTariffConfig`,
  GET_ACCOUNT_TARIFFS: `${BASE}/api/accounts/GetAccountTariffs`,
  UPDATE_ACCOUNT_TARIFFS: `${BASE}/api/Accounts/CreateOrUpdateAccountTariff`,
};

export const billingAndPaymentEndpoints = {
  GET_VATOUTPUTS: `${BASE}/api/Accounts/VATOutputs`,
  DRIVER_PRICE_JOB_BY_MILEAGE: `${BASE}/api/Bookings/GetPrice`, // i need to replace this Api with getPrices /api/Accounts/DriverPriceJobByMileage
  DRIVER_POST_OR_UNPOST_JOBS: (postJob) =>
    `${BASE}/api/Accounts/DriverPostOrUnPostJobs?postJob=${postJob}`,
  DRIVER_GET_CHARGEABLE_JOBS: (userId, scope, lastDate) =>
    `${BASE}/api/Accounts/DriverGetChargableJobs?scope=${scope}${userId ? `&userId=${userId}` : ""}&lastDate=${lastDate}`,
  DRIVER_UPDATE_CHARGES_DATA: `${BASE}/api/Accounts/DriverUpdateChargesData`,
  DRIVER_CREATE_STATEMENTS: `${BASE}/api/Accounts/DriverCreateStatments`,
  DRIVER_GET_STATEMENTS: (from, to, userId) =>
    `${BASE}/api/Accounts/DriverGetStatments?from=${from}&to=${to}${userId ? `&userId=${userId}` : ""}`,
  RESEND_DRIVER_STATEMENT: (statementNo) =>
    `${BASE}/api/Accounts/ResendDriverStatement?statementNo=${statementNo}`,
  MARK_STATEMENT_AS_PAID: (statementNo) =>
    `${BASE}/api/Accounts/MarkStatementAsPaid?statementNo=${statementNo}`,
  ACCOUNT_PRICE_MANUALLY: `${BASE}/api/Accounts/AccountPriceManually`,
  ACCOUNT_PRICE_JOB_BY_MILEAGE: `${BASE}/api/Accounts/AccountPriceJobByMileage`,
  ACCOUNT_PRICE_JOB_HVS: `${BASE}/api/Bookings/GetPrice`, // /api/Accounts/AccountPriceJobHVS this api is replaced
  ACCOUNT_PRICE_JOB_HVS_BULK: `${BASE}/api/Accounts/PriceBulk`, // /api/Accounts/AccountPriceJobHVSBulk this api is replaced
  ACCOUNT_POST_OR_UNPOST_JOBS: (postJob) =>
    `${BASE}/api/Accounts/AccountPostOrUnPostJobs?postJob=${postJob}`,
  ACCOUNT_DRIVER_POST_OR_UNPOST_JOBS: (postJob) =>
    `${BASE}/api/Accounts/PostOrUnPostJobsAccountDriver?postJob=${postJob}`,
  ACCOUNT_GET_CHARGEABLE_JOBS: (accno, from, to) =>
    `${BASE}/api/Accounts/AccountGetChargableJobs?from=${from}&to=${to}${accno ? `&accno=${accno}` : ""}`,
  ACCOUNT_GET_CHARGEABLE_GROUP_JOBS: (accno, from, to) =>
    `${BASE}/api/Accounts/AccountGetChargableJobsGrouped?from=${from}&to=${to}${accno ? `&accno=${accno}` : ""}`,
  ACCOUNT_GET_CHARGEABLE_GROUP_SPLIT_JOBS: (accno, from, to) =>
    `${BASE}/api/Accounts/AccountGetChargableJobsGroupedSplit?from=${from}&to=${to}${accno ? `&accno=${accno}` : ""}`,
  ACCOUNT_UPDATE_CHARGES_DATA: `${BASE}/api/Accounts/AccountUpdateChargesData`,
  ACCOUNT_CREATE_INVOICE: (emailInvoices) =>
    `${BASE}/api/Accounts/AccountCreateInvoice?emailInvoices=${emailInvoices}`,
  MARK_INVOICE_AS_PAID: (invoiceNo) =>
    `${BASE}/api/Accounts/MarkInvoiceAsPaid?invoiceNo=${invoiceNo}`,
  DELETE_INVOICE: (invoiceNo) =>
    `${BASE}/api/Accounts/DeleteInvoice?invoiceNo=${invoiceNo}`,
  CREDIT_INVOICE: (invoiceNo, reason) =>
    `${BASE}/api/Accounts/CreditInvoice?invoiceNo=${invoiceNo}&reason=${encodeURIComponent(reason)}`,
  CREDIT_JOURNEYS: `${BASE}/api/Accounts/CreditJourneys`,
  GET_CREDIT_NOTES: (accno) =>
    `${BASE}/api/Accounts/GetCreditNotes?accno=${accno}`,
  DOWNLOAD_CREDIT_NOTES: (creditnoteId) =>
    `${BASE}/api/Accounts/DownloadCreditNote?creditnoteId=${creditnoteId}`,
  CLEAR_INVOICE: (invoiceNo) =>
    `${BASE}/api/Accounts/ClearInvoice?invoiceNo=${invoiceNo}`,
  GET_INVOICES: (from, to, accno) =>
    `${BASE}/api/Accounts/GetInvoices?from=${from}&to=${to}${accno ? `&accno=${accno}` : ""}`,
  RESEND_ACCOUNT_INVOICE: (invoiceNo) =>
    `${BASE}/api/Accounts/ResendInvoice?invoiceNo=${invoiceNo}`,
  DOWNLOAD_INVOICE_CSV: (invoiceNo) =>
    `${BASE}/api/Accounts/DownloadInvoiceCSV?invoiceNo=${invoiceNo}`,
  DOWNLOAD_INVOICE: (invoiceNo) =>
    `${BASE}/api/Accounts/DownloadInvoice?invoiceNo=${invoiceNo}`,
};

export const webBookingEndpoints = {
  GET_WEB_BOOKINGS: `${BASE}/api/WeBooking/GetWebBookings`,
  GET_WEB_CHANGE_REQUEST: `${BASE}/api/AdminUI/GetWebChangeRequests`,
  UPDATE_WEB_CHANGE_REQUEST: (id) =>
    `${BASE}/api/AdminUI/UpdateWebChangeRequest?reqId=${id}`,
  ACCEPT_WEB_BOOKING: `${BASE}/api/WeBooking/Accept`,
  REJECT_WEB_BOOKING: `${BASE}/api/WeBooking/Reject`,
  GET_DURATION: (id) => `${BASE}/api/WeBooking/GetDuration?wid=${id}`,
  CANCEL_BOOKING: `${BASE}/api/Bookings/Cancel`,
  AMEND_ACCEPT_REJECTED_BOOKING: `${BASE}/api/WeBooking/AmendAccept`,
};

export const notificationEndpoints = {
  GET_NOTIFICATIONS: `${BASE}/api/AdminUI/GetNotifications`,
  CLEAR_NOTIFICATIONS: (id) => `${BASE}/api/AdminUI/ClearNotification?id=${id}`,
  CLEAR_ALL_NOTIFICATIONS: (type) =>
    `${BASE}/api/AdminUI/ClearAllNotifications?type=${type}`,
  CLEAR_ALL_NOTIFICATIONS_WITHOUT_TYPE: `${BASE}/api/AdminUI/ClearAllNotifications`,
};

export const driverEndpoints = {
  DRIVER_EXPENSES: `${BASE}/api/AdminUI/DriverExpenses`,
  GET_DRIVER_LIST: `${BASE}/api/AdminUI/DriversList`,
  ADD_DRIVER: `${BASE}/api/AdminUI/DriverAdd`,
  UPDATE_DRIVER: `${BASE}/api/AdminUI/DriverUpdate`,
  DELETE_DRIVER: (userId) =>
    `${BASE}/api/AdminUI/DriverDelete?userId=${userId}`,
  GET_DRIVER_RESEND_LOGIN: (userId) =>
    `${BASE}/api/AdminUI/DriverResendLogin?userId=${userId}`,
  GET_DRIVER_SHOW_ALL_JOBS: (userId, turnOn) =>
    `${BASE}/api/AdminUI/DriverShowAllJobs?userId=${userId}&turnOn=${turnOn}`,
  GET_DRIVER_SHOW_HVS_JOBS: (userId, turnOn) =>
    `${BASE}/api/AdminUI/DriverShowHVSJobs?userId=${userId}&turnOn=${turnOn}`,
  GET_DRIVER_LOCKOUT: (userId, lockout) =>
    `${BASE}/api/AdminUI/DriverLockout?userId=${userId}&lockout=${lockout}`,
  GET_DRIVER_EXPIRYS: `${BASE}/api/AdminUI/GetDriverExpirys`,
  UPDATE_DRIVER_EXPIRYS: `${BASE}/api/AdminUI/UpdateDriverExpiry`,
};

export const reportsEndpoints = {
  DUPLICATE_BOOKINGS: (startDate) =>
    `${BASE}/api/Reporting/DuplicateBookingsReport?startDate=${startDate}`,
  GET_BOOKING_SCOPE_BREAKDOWN: (from, to, period, compare) =>
    `${BASE}/api/Reporting/GetBookingScopeBreakdown?from=${from}&to=${to}&period=${period}${compare ? `&compare=${compare}` : ""}`,
  GET_TOP_CUSTOMER: (from, to, scope, depth) =>
    `${BASE}/api/Reporting/GetTopCustomers?from=${from}&to=${to}&scope=${scope}${depth ? `&depth=${depth}` : ""}`,
  GET_PICKUP_POSTCODES: (from, to, scope) =>
    `${BASE}/api/Reporting/GetPickupPostcodes?from=${from}&to=${to}&scope=${scope}`,
  GET_VEHICLE_TYPE_COUNTS: (from, to, scope) =>
    `${BASE}/api/Reporting/GetVehicleTypeCounts?from=${from}&to=${to}&scope=${scope}`,
  GET_AVERAGE_DURATION: (from, to, period, scope) =>
    `${BASE}/api/Reporting/GetAverageDuration?from=${from}&to=${to}&period=${period}&scope=${scope}`,
  GET_GROWTH_BY_PERIOD: (startMonth, startYear, endMonth, endYear, viewBy) =>
    `${BASE}/api/Reporting/GetGrowthByPeriod?startMonth=${startMonth}&startYear=${startYear}&endMonth=${endMonth}&endYear=${endYear}&viewBy=${viewBy}`,
  GET_REVENUE_BY_MONTH: (from, to) =>
    `${BASE}/api/Reporting/RevenueByMonth?from=${from}&to=${to}`,
  GET_PAYOUTS_BY_MONTH: (from, to) =>
    `${BASE}/api/Reporting/PayoutsByMonth?from=${from}&to=${to}`,
  GET_PROFITABILITY_ON_INVOICE: (from, to) =>
    `${BASE}/api/Reporting/ProfitabilityOnInvoices?from=${from}&to=${to}`,
  GET_TOTAL_PROFITABILITY_BY_PERIOD: (from, to) =>
    `${BASE}/api/Reporting/TotalProfitabilityByPeriod?from=${from}&to=${to}`,
  GET_PROFITABILITY_BY_DATE_RANGE: (from, to) =>
    `${BASE}/api/Reporting/ProfitsByDateRange?from=${from}&to=${to}`,
  GET_QR_SCANS: `${BASE}/api/Reporting/GetQRScans`,
  SUBMIT_TICKET: `${BASE}/api/AdminUI/SubmitTicket`,
};
