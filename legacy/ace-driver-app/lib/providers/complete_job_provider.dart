import 'package:ace_taxis/repositories/complete_job_repository.dart';
import 'package:flutter/material.dart';

class CompleteJobProvider extends ChangeNotifier {
  final CompleteJobRepository repository;

  CompleteJobProvider(this.repository);

  bool isLoading = false;
  String? errorMessage;

  Future<String?> submitCompleteJob({
    required int bookingId,
    required int waitingTime,
    required int parkingCharge,
    required double driverPrice,
    required double accountPrice,
    required double tip,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.completeJob(
        bookingId: bookingId,
        waitingTime: waitingTime,
        parkingCharge: parkingCharge,
        driverPrice: driverPrice,
        accountPrice: accountPrice,
        tip: tip,
      );

      // Return API response body
      return response.body;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
