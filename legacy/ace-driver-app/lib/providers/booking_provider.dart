// import 'package:flutter/material.dart';
// import '../repositories/booking_repository.dart';
// import '../helpers/shared_pref_helper.dart';
// import '../models/booking.dart';

// class BookingProvider extends ChangeNotifier {
//   final BookingRepository _repository = BookingRepository();

//   bool isLoading = false;

//   List<Bookings> todaysJobs = [];
//   List<Bookings> futureJobs = [];
//   List<Bookings> completedJobs = [];
//   Bookings? activeBooking;

//   int? get activeBookingId => activeBooking?.bookingId;

//   BookingProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _init();
//     });
//   }

//   // -------------------------------------------------
//   // INITIALIZATION
//   // -------------------------------------------------
//   Future<void> _init() async {
//     await loadJobsFromLocal();
//     await fetchActiveJob(); // now safe
//   }

//   // -------------------------------------------------
//   // LOAD LOCAL DATA
//   // -------------------------------------------------
//   Future<void> loadJobsFromLocal() async {
//     todaysJobs = (await SharedPrefHelper.getJobs()).cast<Bookings>();
//     notifyListeners();
//   }

//   // -------------------------------------------------
//   // FETCH TODAY'S JOBS
//   // -------------------------------------------------
//   Future<void> fetchTodaysJobs() async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       todaysJobs = await _repository.getTodaysJobs();
//       await SharedPrefHelper.saveJobs(
//         todaysJobs.map((e) => e.toJson()).toList(),
//       );
//     } catch (e) {
//       debugPrint("❌ Fetch Today's Jobs Error: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // -------------------------------------------------
//   // FETCH FUTURE JOBS
//   // -------------------------------------------------
//   Future<void> fetchFutureJobs() async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       futureJobs = await _repository.getFutureJobs();
//     } catch (e) {
//       debugPrint("❌ Fetch Future Jobs Error: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // -------------------------------------------------
//   // FETCH COMPLETED JOBS
//   // -------------------------------------------------
//   Future<void> fetchCompletedJobs() async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       completedJobs = await _repository.getCompletedJobs();
//     } catch (e) {
//       debugPrint("❌ Fetch Completed Jobs Error: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // -------------------------------------------------
//   // FETCH ACTIVE JOB
//   // Handles 204 & empty list correctly
//   // -------------------------------------------------
//   Future<void> fetchActiveJob() async {
//     try {
//       final activeJobs = await _repository.getActiveJobs();

//       if (activeJobs.isEmpty) {
//         // No active job → show nothing
//         activeBooking = null;
//         debugPrint("ℹ️ No active job found.");
//       } else {
//         final bookingId = activeJobs.first.bookingId;

//         if (bookingId != null) {
//           final details = await _repository.getBookingById(bookingId);
//           activeBooking = details;
//           debugPrint("🟢 Active job loaded: $bookingId");
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Fetch Active Job Error: $e");
//     } finally {
//       notifyListeners();
//     }
//   }

//   // -------------------------------------------------
//   // SET ACTIVE BOOKING
//   // -------------------------------------------------
//   Future<void> setActiveBooking(int bookingId) async {
//     try {
//       await _repository.setActiveJobs(bookingId);
//       await fetchActiveJob();
//       debugPrint("🟢 Active booking set to ID: $bookingId");
//     } catch (e) {
//       debugPrint("❌ Set Active Booking Error: $e");
//     }
//   }

//   // -------------------------------------------------
//   // ARRIVED STATUS UPDATE
//   // -------------------------------------------------
//   Future<void> getArrivedById(int bookingId) async {
//     try {
//       await _repository.getArrivedById(bookingId);
//       await fetchActiveJob();
//       debugPrint("🟢 Arrived updated for booking: $bookingId");
//     } catch (e) {
//       debugPrint("❌ Arrived API Error: $e");
//     }
//   }

//   // -------------------------------------------------
//   // FETCH BOOKING BY ID
//   // -------------------------------------------------
//   Future<Bookings?> getBookingById(int bookingId) async {
//     try {
//       return await _repository.getBookingById(bookingId);
//     } catch (e) {
//       debugPrint("❌ Fetch Booking By ID Error: $e");
//       return null;
//     }
//   }

//   // -------------------------------------------------
//   // MANUAL ACTIVE BOOKING CONTROL
//   // -------------------------------------------------
//   void startBooking(Bookings booking) {
//     activeBooking = booking;
//     notifyListeners();
//   }

//   void endBooking() {
//     activeBooking = null;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import '../repositories/booking_repository.dart';
import '../helpers/shared_pref_helper.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  bool isLoading = false;

  List<Bookings> todaysJobs = [];
  List<Bookings> futureJobs = [];
  List<Bookings> completedJobs = [];
  Bookings? activeBooking;
  List<Bookings> jobOffers = [];
  bool isJobOffersLoading = false;

  int? get activeBookingId => activeBooking?.bookingId;

  BookingProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  // ------------------ INITIALIZATION ------------------
  Future<void> _init() async {
    await loadJobsFromLocal();
    await fetchActiveJob();
  }

  // ------------------ LOAD LOCAL DATA ------------------
  Future<void> loadJobsFromLocal() async {
    todaysJobs = (await SharedPrefHelper.getJobs()).cast<Bookings>();
    notifyListeners();
  }

  // ------------------ FETCH JOBS ------------------
  Future<void> fetchTodaysJobs() async => _fetchJobs(
    fetchFunction: _repository.getTodaysJobs,
    assignList: (jobs) => todaysJobs = jobs,
    saveLocal: true,
  );

  Future<void> fetchFutureJobs() async => _fetchJobs(
    fetchFunction: _repository.getFutureJobs,
    assignList: (jobs) => futureJobs = jobs,
  );

  Future<void> fetchJobOffers() async {
    isJobOffersLoading = true;
    notifyListeners();

    try {
      // 1️⃣ Get job offers (HAS GUID)
      final offers = await _repository.getJobOffers();

      List<Bookings> mergedList = [];

      for (final offer in offers) {
        if (offer.bookingId == null) continue;

        // 2️⃣ Get full booking details (NO GUID)
        final details = await _repository.getBookingById(offer.bookingId!);

        if (details != null) {
          // 3️⃣ MERGE GUID into booking details
          mergedList.add(details.copyWith(guid: offer.guid));
        }
      }

      jobOffers = mergedList;

      // 🔍 DEBUG (optional)
      for (final b in jobOffers) {
        debugPrint("BookingId=${b.bookingId}, GUID=${b.guid}");
      }
    } catch (e) {
      debugPrint("Error fetching job offers: $e");
    } finally {
      isJobOffersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompletedJobs() async => _fetchJobs(
    fetchFunction: _repository.getCompletedJobs,
    assignList: (jobs) => completedJobs = jobs,
  );

  Future<void> _fetchJobs({
    required Future<List<Bookings>> Function() fetchFunction,
    required void Function(List<Bookings>) assignList,
    bool saveLocal = false,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final jobs = await fetchFunction();
      assignList(jobs);

      if (saveLocal) {
        await SharedPrefHelper.saveJobs(jobs.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      debugPrint("Fetch Jobs Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------ FETCH ACTIVE JOB ------------------
  Future<void> fetchActiveJob() async {
    try {
      final activeJobs = await _repository.getActiveJobs();
      if (activeJobs.isEmpty) {
        activeBooking = null;
        debugPrint("ℹ️ No active job found.");
      } else {
        final bookingId = activeJobs.first.bookingId;
        if (bookingId != null) {
          activeBooking = await _repository.getBookingById(bookingId);
          debugPrint("Active job loaded: $bookingId");
        }
      }
    } catch (e) {
      debugPrint("Fetch Active Job Error: $e");
    } finally {
      notifyListeners();
    }
  }

  // ------------------ SET ACTIVE BOOKING ------------------
  Future<void> setActiveBooking(int bookingId) async {
    try {
      await _repository.setActiveJobs(bookingId);
      await fetchActiveJob();
      debugPrint("Active booking set to ID: $bookingId");
    } catch (e) {
      debugPrint("Set Active Booking Error: $e");
    }
  }

// ------------------ ARRIVED STATUS ------------------
// Changed Future<void> to Future<dynamic>
  Future<dynamic> getArrivedById(int bookingId) async {
    try {
      // 1. Capture the response from the repository
      final response = await _repository.getArrivedById(bookingId);

      // 2. Refresh local state
      await fetchActiveJob();

      debugPrint("Arrived updated for booking: $bookingId");

      // 3. Return the response so the UI Logger can see it
      return response;
    } catch (e) {
      debugPrint("Arrived API Error: $e");
      rethrow; // Important: rethrow so the UI catch block can log the error
    }
  }

  // ------------------ FETCH BOOKING BY ID ------------------
  Future<Bookings?> getBookingById(int bookingId) async {
    try {
      return await _repository.getBookingById(bookingId);
    } catch (e) {
      debugPrint("Fetch Booking By ID Error: $e");
      return null;
    }
  }

  // ------------------ MANUAL ACTIVE BOOKING ------------------
  void startBooking(Bookings booking) {
    activeBooking = booking;
    notifyListeners();
  }

  void endBooking() {
    activeBooking = null;
    notifyListeners();
  }

  // ------------------ AUTO UPDATE METHODS ------------------

  /// Update an existing booking in all lists
  void updateBooking(Bookings updatedBooking) {
    todaysJobs = todaysJobs
        .map(
          (b) => b.bookingId == updatedBooking.bookingId ? updatedBooking : b,
        )
        .toList();

    futureJobs = futureJobs
        .map(
          (b) => b.bookingId == updatedBooking.bookingId ? updatedBooking : b,
        )
        .toList();

    completedJobs = completedJobs
        .map(
          (b) => b.bookingId == updatedBooking.bookingId ? updatedBooking : b,
        )
        .toList();

    if (activeBooking?.bookingId == updatedBooking.bookingId) {
      activeBooking = updatedBooking;
    }

    //  auto update without loader
    notifyListeners();
  }

  /// Remove a booking from all lists
  void removeBooking(int bookingId) {
    todaysJobs.removeWhere((b) => b.bookingId == bookingId);
    futureJobs.removeWhere((b) => b.bookingId == bookingId);
    completedJobs.removeWhere((b) => b.bookingId == bookingId);

    if (activeBooking?.bookingId == bookingId) {
      activeBooking = null;
    }

    // auto update without loader
    notifyListeners();
  }

  /// Add a new booking to the correct list
  void addBooking(Bookings newBooking) {
    final now = DateTime.now();
    final pickup = DateTime.tryParse(newBooking.pickupDateTime ?? '');

    if (pickup != null) {
      if (pickup.isBefore(DateTime(now.year, now.month, now.day + 1))) {
        todaysJobs.add(newBooking);
      } else if (pickup.isAfter(now)) {
        futureJobs.add(newBooking);
      } else {
        completedJobs.add(newBooking);
      }
    } else {
      todaysJobs.add(newBooking);
    }
    notifyListeners();
  }
}
