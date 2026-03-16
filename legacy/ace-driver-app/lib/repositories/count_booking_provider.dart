import 'package:ace_taxis/repositories/booking_repository.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';

class CountBookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  int jobReceivedCount = 0;
  int jobUpcomingCount = 0;
  int jobCompletedCount = 0;
  int jobRejectedCount = 0;
  int jobOffersCount = 0;

  double totalReceivedPrice = 0;
  double totalUpcomingPrice = 0;
  double totalCompletedPrice = 0;
  double totalRejectedPrice = 0;

  //Daily / Weekly / Monthly totals
  double totalDailyEarnings = 0;
  double totalWeeklyEarnings = 0;
  double totalMonthlyEarnings = 0;

  bool loadingCounts = false;

  // Main function to load booking stats
  Future<void> loadBookingCounts() async {
    loadingCounts = true;
    notifyListeners();

    try {
      // Always reset before fresh load
      _resetCounts();

      // Fetch data from API
      final todayJobs = await _repository.getTodaysJobs();
      final futureJobs = await _repository.getFutureJobs();
      final completedJobs = await _repository.getCompletedJobs();
      final joboffers = await _repository.getJobOffers();

      final rejectedJobs = <Bookings>[];

      // ✅ Count totals
      jobReceivedCount = todayJobs.length;
      jobUpcomingCount = futureJobs.length;
      jobCompletedCount = completedJobs.length;
      jobRejectedCount = rejectedJobs.length;
      jobOffersCount = joboffers.length;

      // ✅ Calculate total prices
      totalReceivedPrice = _calculateTotal(todayJobs);
      totalUpcomingPrice = _calculateTotal(futureJobs);
      totalCompletedPrice = _calculateTotal(completedJobs);
      totalRejectedPrice = _calculateTotal(rejectedJobs);

      // ✅ Combine all jobs for earnings period calculation
      final allJobs = [...todayJobs, ...futureJobs, ...completedJobs];

      _calculateEarningsByPeriod(allJobs);

      // ✅ Debug log summary
      debugPrint("📊 ===== Booking Totals =====");
      debugPrint(
        "🟦 Received: $jobReceivedCount | £${totalReceivedPrice.toStringAsFixed(2)}",
      );
      debugPrint(
        "🟩 Upcoming: $jobUpcomingCount | £${totalUpcomingPrice.toStringAsFixed(2)}",
      );
      debugPrint(
        "🟥 Completed: $jobCompletedCount | £${totalCompletedPrice.toStringAsFixed(2)}",
      );
      debugPrint(
        "⬜ Rejected: $jobRejectedCount | £${totalRejectedPrice.toStringAsFixed(2)}",
      );
      debugPrint("📅 Daily Total: £${totalDailyEarnings.toStringAsFixed(2)}");
      debugPrint("📆 Weekly Total: £${totalWeeklyEarnings.toStringAsFixed(2)}");
      debugPrint(
        "🗓️ Monthly Total: £${totalMonthlyEarnings.toStringAsFixed(2)}",
      );
      debugPrint("=============================");
    } catch (e, stack) {
      debugPrint("❌ Error loading booking counts: $e");
      debugPrint(stack.toString());
    }

    loadingCounts = false;
    notifyListeners();
  }

  // ✅ Reset all counts before each refresh
  void _resetCounts() {
    jobReceivedCount = 0;
    jobUpcomingCount = 0;
    jobCompletedCount = 0;
    jobRejectedCount = 0;
    jobOffersCount = 0;

    totalReceivedPrice = 0;
    totalUpcomingPrice = 0;
    totalCompletedPrice = 0;
    totalRejectedPrice = 0;

    totalDailyEarnings = 0;
    totalWeeklyEarnings = 0;
    totalMonthlyEarnings = 0;
  }

  // ✅ Calculate total amount for a list of jobs
  double _calculateTotal(List<Bookings> jobs) {
    double total = 0;
    for (final job in jobs) {
      final price = double.tryParse(job.price?.toString() ?? '0') ?? 0;
      total += price;
    }
    return total;
  }

  // ✅ Calculate daily, weekly, and monthly earnings correctly
  void _calculateEarningsByPeriod(List<Bookings> jobs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfToday = today.add(const Duration(days: 1));

    double daily = 0;
    double weekly = 0;
    double monthly = 0;

    for (final job in jobs) {
      if (job.dateCreated == null || job.dateCreated!.isEmpty) continue;

      DateTime? jobDate;
      try {
        jobDate = DateTime.parse(job.dateCreated!);
      } catch (_) {
        continue;
      }

      final price = double.tryParse(job.price?.toString() ?? '0') ?? 0;

      // Daily
      if (jobDate.isAfter(today) && jobDate.isBefore(endOfToday)) {
        daily += price;
      }

      // Weekly
      if (jobDate.isAfter(startOfWeek) && jobDate.isBefore(endOfToday)) {
        weekly += price;
      }

      // Monthly
      if (jobDate.isAfter(startOfMonth) && jobDate.isBefore(endOfToday)) {
        monthly += price;
      }
    }

    totalDailyEarnings = daily;
    totalWeeklyEarnings = weekly;
    totalMonthlyEarnings = monthly;
  }
}
