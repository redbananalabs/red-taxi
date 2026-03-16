class ApiConstants {

  static const String baseUrl = "https://dev.ace-api.1soft.co.uk/api";
  // static const String baseUrl = "https://ace-server.1soft.co.uk/api";

  //login
  static const String loginEndpoint = "$baseUrl/UserProfile/Login";

  // Profile
  static const String updateProfileEndpoint = "$baseUrl/UserProfile/Update";

  // Bookings
  static const String todaysJobsEndpoint = "$baseUrl/DriverApp/TodaysJobs";
  static const String futureJobsEndpoint = "$baseUrl/DriverApp/FutureJobs";
  static const String completedJobsEndpoint =
      "$baseUrl/DriverApp/CompletedJobs";
  static const String getJobOffersEndpoint = "$baseUrl/DriverApp/GetJobOffers";
  static const String setActiveJobEndpoint = "$baseUrl/DriverApp/SetActiveJob";
  static const String getActiveJobEndpoint = "$baseUrl/DriverApp/GetActiveJob";
  static const String completeJobEndpoint = "$baseUrl/DriverApp/CompleteJob";
  static const String findByArrivedEndpoint = "$baseUrl/DriverApp/Arrived";

  //updategps

  static const String updateGpsEndpoint = "$baseUrl/UserProfile/UpdateGPS";

  //dash total
  static const String dashTotalEndpoint = "$baseUrl/DriverApp/dashTotals";

  //UpdateFCM
  static const String updateFcmTotalEndpoint = "$baseUrl/DriverApp/UpdateFCM";
  static const String driverShiftEndpoint = "$baseUrl/DriverApp/DriverShift";

  //Update
  static const String jobOfferReplyEndpoint =
      "$baseUrl/DriverApp/JobOfferReply";

  //getbookingid
  static const String findByIdEndpoint = "$baseUrl/Bookings/FindById";

  //getjoboffer
  static const String retrieveJobOfferEndpoint =
      "$baseUrl/DriverApp/RetrieveJobOffer";

  //Earning report
  static const String earningsEndpoint = "$baseUrl/DriverApp/Earnings";

  //statements
  static const String statementEndpoint = "$baseUrl/DriverApp/Statements";

  static const String getProfileEndpoint = "$baseUrl/DriverApp/GetProfile";

  //my avaiability
  static const String availabilitiesEndpoint =
      "$baseUrl/DriverApp/Availabilities";
  static const String deleteAvailabilityEndpoint =
      "$baseUrl/DriverApp/DeleteAvailability";
  static const String setAvailabilityEndpoint =
      "$baseUrl/DriverApp/SetAvailability";

  static const String generalEndpoint = "$baseUrl/Availability/General";

  //upload documents
  static const String uploadDocumentEndpoint =
      "$baseUrl/DriverApp/UploadDocument";

  // Expenses
  static const String addExpenseEndpoint = "$baseUrl/DriverApp/AddExpense";

  // Create Booking
  static const String createBookingEndpoint = "$baseUrl/Bookings/RankCreate";

  // Inside class ApiConstants
  static const String dispatchSearchEndpoint = "$baseUrl/address/dispatchsearch";

  // Suggestions
  static const String addressSuggestionEndpoint =
      "$baseUrl/WeBooking/GetAdressSuggestions";

  static const String resolveAddressEndpoint = "$baseUrl/address/resolve";

  // Price
  static const String getPriceEndpoint = "$baseUrl/Bookings/GetPrice";


  //download Report
  static const String getDownloadStatementEndpoint =
      "$baseUrl/Accounts/DownloadStatement";
}
