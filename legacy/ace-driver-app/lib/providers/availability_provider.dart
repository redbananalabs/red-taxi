import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:ace_taxis/models/driver_availiblities_model.dart';
import 'package:flutter/material.dart';
import '../models/availability_model.dart';
import '../repositories/availability_repository.dart';

class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityRepository repository;

  AvailabilityProvider({required this.repository});

  List<Availability> availabilities = [];
  List<DriverAvailability> allDriversAvailabilities = [];
  bool allDriversLoading = false;
  bool loading = false;
  String error = '';

  /// 🟢 Fetch all availabilities
  Future<void> getAvailabilities() async {
    loading = true;
    error = '';
    notifyListeners();

    try {
      availabilities = await repository.fetchAvailabilities();
    } catch (e) {
      error = 'Failed to load availabilities: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🗑️ Delete an availability by ID
  Future<void> deleteAvailability(String id) async {
    error = '';
    notifyListeners();

    try {
      await repository.deleteAvailability(
        int.parse(id),
      ); // ✅ match repository’s int parameter

      // ✅ Remove from local list after successful deletion
      availabilities.removeWhere((a) => a.id.toString() == id);
      notifyListeners();

      debugPrint("✅ Availability removed locally for id=$id");
    } catch (e) {
      // Only show real errors
      error = 'Failed to delete availability: $e';
      debugPrint("❌ $error");
      notifyListeners();
      rethrow; // Let UI handle (e.g., show snackbar)
    }
  }

  Future<void> getAllDriversAvailabilities(DateTime date) async {
    allDriversLoading = true;
    error = '';
    notifyListeners();
    try {
      allDriversAvailabilities = await repository.fetchAllDriversAvailability(
        date,
      );
      debugPrint(
        "✅ Fetched ${allDriversAvailabilities.length} drivers for $date",
      );
    } catch (e) {
      allDriversAvailabilities = [];
      error = 'Failed to fetch drivers: $e';
      debugPrint("❌ $error");
    } finally {
      allDriversLoading = false;
      notifyListeners();
    }
  }

  /// 🟢 Set driver availability
  Future<void> setAvailability({
    required DateTime date,
    required String from,
    required String to,
    required bool giveOrTake,
    required int type,
    required String note,
  }) async {
    loading = true;
    error = '';
    notifyListeners();

    try {
      // ✅ Get user info from shared preferences
      final userData = await SharedPrefHelper.getUser();
      final userId = userData?['userId'] ?? 0;

      debugPrint("👤 Retrieved userId: $userId");

      // ✅ Call repository method
      await repository.setAvailability(
        userId: userId,
        date: date,
        from: from,
        to: to,
        giveOrTake: giveOrTake,
        type: type,
        note: note,
      );

      debugPrint("✅ Availability successfully set for date: $date");

      // Refresh availability list
      await getAvailabilities();
    } catch (e) {
      error = 'Failed to set availability: $e';
      debugPrint("❌ Error setting availability: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
