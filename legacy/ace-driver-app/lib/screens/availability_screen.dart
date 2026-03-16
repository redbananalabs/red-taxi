import 'package:ace_taxis/models/driver_availiblities_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/availability_model.dart';
import '../providers/availability_provider.dart';
import '../helpers/shared_pref_helper.dart';
import 'home_screen.dart';

enum DriverAvailabilityType { NotSet, Available, Unavailable }

enum VehicleType { Unknown, Saloon, Estate, MPV, MPVPlus, SUV }

String getVehicleTypeName(int type) {
  switch (type) {
    case 1:
      return VehicleType.Saloon.toString().split('.').last;
    case 2:
      return VehicleType.Estate.toString().split('.').last;
    case 3:
      return VehicleType.MPV.toString().split('.').last;
    case 4:
      return VehicleType.MPVPlus.toString().split('.').last;
    case 5:
      return VehicleType.SUV.toString().split('.').last;
    default:
      return VehicleType.Unknown.toString().split('.').last;
  }
}

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

String _statusLabel(String status) {
  switch (status) {
    case 'available':
      return 'Available';
    case 'unavailable':
      return 'Unavailable';
    case 'allocated':
      return 'Allocated';
    default:
      return 'Not Set';
  }
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTimeRange? selectedDateRange;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  DateTime? selectedDate;
  String selectedAvailability = "Unavailable All Day";
  bool giveOrTake = false;
  bool showMyAvailability = true;
  bool showCustomTime = false;
  String? token;
  // AvailabilityProvider? provider; // single instance kept (if needed)

  // controller for custom note field
  final TextEditingController _noteController = TextEditingController();

  // Additional selectedType variable for custom buttons (kept for UI state)
  int selectedTypeForCustom = DriverAvailabilityType.Available.index;

  List<String> get days {
    List<String> allDays = ["M", "T", "W", "T", "F", "S", "S"];

    if (selectedDateRange == null) return allDays;

    int startIndex = selectedDateRange!.start.weekday - 1;
    return [...allDays.sublist(startIndex), ...allDays.sublist(0, startIndex)];
  }

  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadToken();

    _initializeProvider();

    DateTime today = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: today,
      end: today.add(const Duration(days: 6)),
    );

    selectedDate = selectedDateRange!.start;
    selectedDayIndex = 0;
  }

  String _formatHourMin(String time) {
    final parts = time.split(":");
    if (parts.length >= 2) {
      // Ensure two digits for hour and minute, 24-hour format
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }
    return time;
  }

  Future<void> _fetchAllDriversForDate(DateTime date) async {
    try {
      final provider = Provider.of<AvailabilityProvider>(
        context,
        listen: false,
      );

      print(
        "🟢 Fetching all drivers for date: ${DateFormat('yyyy-MM-dd').format(date)}",
      );

      // ✅ Fetch DriverAvailability list
      await provider.getAllDriversAvailabilities(date);

      // ✅ Wait for provider update to complete
      if (mounted) {
        setState(() {
          // Trigger UI rebuild
        });
      }

      // ✅ Debug: confirm data in provider
      print("✅ All drivers availability for $date:");
      for (var item in provider.allDriversAvailabilities) {
        print(
          "Driver: ${item.fullName}, Date: ${item.date}, Vehicle Type: ${item.vehicleType}, "
          "Available Slots: ${item.availableHours.length}, "
          "Unavailable Slots: ${item.unAvailableHours.length}, "
          "Allocated Slots: ${item.allocatedHours.length}",
        );
      }
    } catch (e) {
      print("❌ Error fetching all drivers for $date → $e");
    }
  }

  Future<void> _initializeProvider() async {
    token = await SharedPrefHelper.getToken();

    if (!mounted) return;

    if (token != null && token!.isNotEmpty) {
      final prov = context.read<AvailabilityProvider>();

      // 🟢 Fetch MY availabilities
      await prov.getAvailabilities();
      if (!mounted) return; // 👈 check after await

      // 🟢 Fetch ALL drivers for each date in range
      if (selectedDateRange != null) {
        DateTime current = selectedDateRange!.start;

        while (!current.isAfter(selectedDateRange!.end)) {
          await prov.getAllDriversAvailabilities(current);
          if (!mounted) return; // 👈 check here as well

          print("✅ All drivers availability for ${current.toIso8601String()}:");

          for (var a in prov.allDriversAvailabilities) {
            print(
              "Driver: ${a.fullName}, Date: ${a.date}, Vehicle Type: ${a.vehicleType}, "
              "Available Slots: ${a.availableHours.map((s) => '${s.from}-${s.to} (${s.note})').join(', ')}, "
              "Unavailable Slots: ${a.unAvailableHours.map((s) => '${s.from}-${s.to} (${s.note})').join(', ')}, "
              "Allocated Slots: ${a.allocatedHours.map((s) => '${s.from}-${s.to} (${s.note})').join(', ')}",
            );
          }

          current = current.add(const Duration(days: 1));
        }
      }

      if (!mounted) return;

      setState(() {});
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    token = await SharedPrefHelper.getToken();
    if (token != null && token!.isNotEmpty) {
      setState(() {});
    }
  }

  void _moveDateRangeForward() async {
    setState(() {
      selectedDateRange = DateTimeRange(
        start: selectedDateRange!.start.add(const Duration(days: 7)),
        end: selectedDateRange!.end.add(const Duration(days: 7)),
      );
      selectedDayIndex = 0;
      selectedDate = selectedDateRange!.start;
    });

    // ✅ Hit All Drivers API when week changes (for first date)
    if (!showMyAvailability && selectedDateRange != null) {
      final prov = context.read<AvailabilityProvider>();
      final firstDate = selectedDateRange!.start;

      debugPrint("🟢 Week changed → fetching all drivers for $firstDate");

      await prov.getAllDriversAvailabilities(firstDate);

      setState(() {}); // refresh UI
    }
  }

  void _moveDateRangeBackward() async {
    setState(() {
      selectedDateRange = DateTimeRange(
        start: selectedDateRange!.start.subtract(const Duration(days: 7)),
        end: selectedDateRange!.end.subtract(const Duration(days: 7)),
      );
      selectedDayIndex = 0;
      selectedDate = selectedDateRange!.start;
    });

    // ✅ Hit All Drivers API when week changes (for first date)
    if (!showMyAvailability && selectedDateRange != null) {
      final prov = context.read<AvailabilityProvider>();
      final firstDate = selectedDateRange!.start;

      debugPrint("🟢 Week changed → fetching all drivers for $firstDate");

      await prov.getAllDriversAvailabilities(firstDate);

      setState(() {});
    }
  }

  String _formatDateRange() {
    if (selectedDateRange == null) {
      return "Select date range";
    }
    return "${selectedDateRange!.start.day.toString().padLeft(2, '0')}/"
        "${selectedDateRange!.start.month.toString().padLeft(2, '0')}/"
        "${selectedDateRange!.start.year}  to  "
        "${selectedDateRange!.end.day.toString().padLeft(2, '0')}/"
        "${selectedDateRange!.end.month.toString().padLeft(2, '0')}/"
        "${selectedDateRange!.end.year}";
  }

  Future<void> _pickDateRangeAndTime() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        selectedDayIndex = 0;
        selectedDate = picked.start;
      });

      if (!showMyAvailability && selectedDateRange != null) {
        final prov = context.read<AvailabilityProvider>();
        final firstDate = selectedDateRange!.start;

        debugPrint("🟢 New range picked → fetching all drivers for $firstDate");

        await prov.getAllDriversAvailabilities(firstDate);

        setState(() {});
      }
    }
  }

  Map<String, List<String>> predefinedTimes = {
    "am-school": ["07:30", "09:30"],
    "pm-school": ["14:30", "16:30"],
    "am-pm-school": ["07:30", "16:30"],
    "unavailable": ["00:00", "23:59"],
  };

  void _setPredefinedTime(String key) {
    final times = predefinedTimes[key];
    if (times != null) {
      final fromParts = times[0].split(":");
      final toParts = times[1].split(":");
      setState(() {
        fromTime = TimeOfDay(
          hour: int.parse(fromParts[0]),
          minute: int.parse(fromParts[1]),
        );
        toTime = TimeOfDay(
          hour: int.parse(toParts[0]),
          minute: int.parse(toParts[1]),
        );
      });
    }
  }

  /// Filter both My Availability and All Drivers based on selected day and range
  List<Availability> _filterBySelectedDay(List<Availability> data) {
    if (selectedDateRange == null) return data;
    final DateTime expectedDate = selectedDateRange!.start.add(
      Duration(days: selectedDayIndex),
    );
    return data.where((a) {
      final date = DateTime(a.date.year, a.date.month, a.date.day);
      return date.year == expectedDate.year &&
          date.month == expectedDate.month &&
          date.day == expectedDate.day;
    }).toList();
  }

  Future<void> _pickTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFrom
          ? (fromTime ?? const TimeOfDay(hour: 7, minute: 0))
          : (toTime ?? const TimeOfDay(hour: 8, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromTime = picked;
        } else {
          toTime = picked;
        }
      });
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Availability availability,
  ) async {
    final provider = Provider.of<AvailabilityProvider>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Availability"),
        content: const Text(
          "Are you sure you want to delete this availability?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.deleteAvailability(availability.id.toString());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Availability deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete availability: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Keep original signature — used elsewhere
  Future<void> _saveAvailability(BuildContext context) async {
    if (fromTime == null || toTime == null || selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    final provider = Provider.of<AvailabilityProvider>(context, listen: false);
    final DateTime date = selectedDateRange!.start;

    final String from =
        "${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}";
    final String to =
        "${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}";

    // Use _getAvailabilityType to get the proper enum index for basic buttons
    await provider.setAvailability(
      date: date,
      from: from,
      to: to,
      giveOrTake: giveOrTake,
      type: _getAvailabilityType(selectedAvailability),
      note: selectedAvailability,
    );

    if (provider.error.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Availability updated successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (provider.error.toLowerCase().contains(
      "overlaps with an existing availability",
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ This availability is already added."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error), backgroundColor: Colors.red),
      );
    }
  }
  Future<void> _saveAvailabilityWithType(int type) async {
    if (fromTime == null || toTime == null || selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    final providerLocal = Provider.of<AvailabilityProvider>(
      context,
      listen: false,
    );

    // ✅ FIX: date now follows selected day button (Mon–Sun)
    final DateTime date = selectedDateRange!.start.add(
      Duration(days: selectedDayIndex),
    );

    final String from =
        "${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}";
    final String to =
        "${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}";

    final String noteToSend = _noteController.text.isNotEmpty
        ? _noteController.text
        : selectedAvailability;

    await providerLocal.setAvailability(
      date: date,
      from: from,
      to: to,
      giveOrTake: giveOrTake,
      type: type,
      note: noteToSend,
    );

    if (providerLocal.error.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == DriverAvailabilityType.Available.index
                ? "Availability added successfully ✅"
                : "Marked unavailable ❌",
          ),
          backgroundColor: type == DriverAvailabilityType.Available.index
              ? Colors.green
              : Colors.red,
        ),
      );

      // 🔹 FIX: Removed time resets so it doesn't jump back to default (7AM-8AM)
      setState(() {
        // fromTime = null;  <-- DELETE or COMMENT OUT
        // toTime = null;    <-- DELETE or COMMENT OUT

        // You can keep these if you want to clear the note/checkbox,
        // otherwise remove them too if you want to keep all inputs.
        giveOrTake = false;
        _noteController.clear();
        selectedTypeForCustom = DriverAvailabilityType.Available.index;
      });

      await providerLocal.getAvailabilities();
    } else if (providerLocal.error.toLowerCase().contains(
      "overlaps with an existing availability",
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This availability is already added."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(providerLocal.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  int _getAvailabilityType(String availability) {
    switch (availability) {
      case "Unavailable All Day":
        return DriverAvailabilityType.Unavailable.index;
      case "AM School Only":
      case "PM School Only":
      case "AM-PM School Only":
        return DriverAvailabilityType.Available.index;
      case "Custom Set Manually":
        // For custom we will rely on explicit button press (Add Available / Unavailable)
        return DriverAvailabilityType.NotSet.index;
      default:
        return DriverAvailabilityType.NotSet.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (token == null || token!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Token not found. Please log in.")),
      );
    }
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          "Availability Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(initialIndex: 0),
              ),
            );
          },
        ),
      ),

      body: Consumer<AvailabilityProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty && provider.availabilities.isEmpty) {
            return Center(child: Text(provider.error));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRangeSelector(),
                const SizedBox(height: 16),
                _buildDayButtons(),
                const SizedBox(height: 20),
                _buildAvailabilityOptions(provider),
                const SizedBox(height: 25),
                if (showCustomTime) _buildCustomTimeSection(context),
                const SizedBox(height: 25),
                _buildTabSwitch(provider),
                const SizedBox(height: 10),

                /// 🟢 Now this will correctly show your ALL DRIVERS LIST
                _buildAvailabilityTable(
                  showMyAvailability: showMyAvailability,
                  allDriversAvailabilities: provider.allDriversAvailabilities,
                  myAvailabilities: provider.availabilities,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- Updated _filterAllDriversByDate ----------------
  List<DriverAvailability> _filterAllDriversByDate(
    List<DriverAvailability> data,
  ) {
    if (selectedDate == null) return data;

    // Filter based on selected day (selectedDate)
    final DateTime selected = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    return data.where((a) {
      final date = DateTime(a.date.year, a.date.month, a.date.day);
      return date == selected;
    }).toList();
  }

  // ---------------- UI Helpers Below ----------------

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: _moveDateRangeBackward,
          ),
          Expanded(
            // ✅ allows text to shrink or wrap instead of overflowing
            child: GestureDetector(
              onTap: () => _pickDateRangeAndTime(),
              child: Text(
                _formatDateRange(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: _moveDateRangeForward,
          ),
        ],
      ),
    );
  }

  Widget _buildDayButtons([AvailabilityProvider? provider]) {
    final theme = Theme.of(context);

    final List<String> dayLetters = days;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(dayLetters.length, (index) {
        final isSelected = selectedDayIndex == index;

        return GestureDetector(
          onTap: () async {
            setState(() {
              selectedDayIndex = index;
              // ✅ Calculate date based on the selectedDateRange start + index
              selectedDate = selectedDateRange!.start.add(
                Duration(days: index),
              );
            });

            // ✅ If currently showing All Drivers, fetch data for this date
            if (!showMyAvailability && selectedDate != null) {
              print("🟢 Day changed → fetching All Drivers for $selectedDate");
              await _fetchAllDriversForDate(selectedDate!);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red),
            ),
            child: Text(
              dayLetters[index],
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvailabilityOptions(AvailabilityProvider provider) => Column(
    children: [
      _buildAvailabilityButton(provider, "Unavailable All Day", "unavailable"),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _buildAvailabilityButton(
              provider,
              "AM School Only",
              "am-school",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildAvailabilityButton(
              provider,
              "PM School Only",
              "pm-school",
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _buildAvailabilityButton(provider, "AM-PM School Only", "am-pm-school"),
      const SizedBox(height: 10),
      _buildAvailabilityButton(provider, "Custom Set Manually", "custom"),
    ],
  );

  Widget _buildAvailabilityButton(
    AvailabilityProvider provider,
    String text,
    String key,
  ) {
    final theme = Theme.of(context);

    // Decide button color based on key
    Color buttonColor;
    switch (key) {
      case "unavailable":
      case "custom":
        buttonColor = theme.colorScheme.error;
        break;
      case "am-school":
      case "pm-school":
      case "am-pm-school":
        buttonColor = theme.colorScheme.primary;
        break;
      default:
        buttonColor = theme.colorScheme.primary;
    }

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedAvailability = text;
        });

        // Custom Section (no auto save)
        if (key == "custom") {
          setState(() {
            showCustomTime = !showCustomTime;
            if (!showCustomTime) {
              fromTime = null;
              toTime = null;
              giveOrTake = false;
              _noteController.clear();
            }
          });
          return;
        }

        // Determine date based on selected day button
        final DateTime date = selectedDateRange!.start.add(
          Duration(days: selectedDayIndex),
        );

        // Special Case: AM-PM should save 2 entries (AM + PM)
        if (key == "am-pm-school") {
          final am = predefinedTimes["am-school"]!;
          final pm = predefinedTimes["pm-school"]!;

          await provider.setAvailability(
            date: date,
            from: am[0],
            to: am[1],
            giveOrTake: giveOrTake,
            type: DriverAvailabilityType.Available.index,
            note: "AM School Only",
          );

          await provider.setAvailability(
            date: date,
            from: pm[0],
            to: pm[1],
            giveOrTake: giveOrTake,
            type: DriverAvailabilityType.Available.index,
            note: "PM School Only",
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("AM & PM availability added successfully ✅"),
              backgroundColor: theme.colorScheme.primary,
            ),
          );

          await provider.getAvailabilities();
          return;
        }

        // Normal AM / PM / Unavailable
        _setPredefinedTime(key);

        final String from =
            "${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}";
        final String to =
            "${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}";

        final int typeToSend = _getAvailabilityType(selectedAvailability);

        await provider.setAvailability(
          date: date,
          from: from,
          to: to,
          giveOrTake: giveOrTake,
          type: typeToSend,
          note: selectedAvailability,
        );

        if (provider.error.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$text added successfully ✅"),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }

        await provider.getAvailabilities();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTimeSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // FROM
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "FROM:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _pickTime(context, true),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                          color: theme.cardColor, // theme-aware
                        ),
                        child: Text(
                          fromTime != null
                              ? fromTime!.format(context)
                              : "07:00 ",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // TO
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "TO:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _pickTime(context, false),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                          color: theme.cardColor, // theme-aware
                        ),
                        child: Text(
                          toTime != null ? toTime!.format(context) : "08:00",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Note field
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: "Add a note",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Give or Take
                    Row(
                      children: [
                        Checkbox(
                          value: giveOrTake,
                          onChanged: (val) =>
                              setState(() => giveOrTake = val ?? false),
                        ),
                        const Text("Give or Take (+/-)"),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              selectedTypeForCustom =
                                  DriverAvailabilityType.Available.index;
                              _saveAvailabilityWithType(
                                DriverAvailabilityType.Available.index,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Add Available",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              selectedTypeForCustom =
                                  DriverAvailabilityType.Unavailable.index;
                              _saveAvailabilityWithType(
                                DriverAvailabilityType.Unavailable.index,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Unavailable",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                fromTime = null;
                                toTime = null;
                                giveOrTake = false;
                                _noteController.clear();
                                selectedTypeForCustom =
                                    DriverAvailabilityType.Available.index;
                                showCustomTime = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, VoidCallback onTap) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time != null ? time.format(context) : "Select Time",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );

  Color parseColor(String hexCode) {
    try {
      hexCode = hexCode.replaceAll("#", "");

      if (hexCode.length == 6) {
        // No alpha provided, add FF at start
        hexCode = "FF$hexCode";
      } else if (hexCode.length == 8) {
        // API sends RRGGBBAA, need to convert to AARRGGBB
        final rrggbb = hexCode.substring(0, 6);
        final aa = hexCode.substring(6, 8);
        hexCode = "$aa$rrggbb";
      }

      return Color(int.parse(hexCode, radix: 16));
    } catch (_) {
      return Colors.transparent;
    }
  }

  Widget _buildAvailabilityTable({
    required bool showMyAvailability,
    required List<Availability> myAvailabilities,
    required List<DriverAvailability> allDriversAvailabilities,
  }) {
    if (showMyAvailability) {
      return _buildMyAvailabilityTable(myAvailabilities, context);
    } else {
      if (allDriversAvailabilities.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No availability data found for selected day."),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Text(
              "ALL DRIVERS (${DateFormat('dd/MM/yyyy').format(selectedDate ?? DateTime.now())})",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "#Driver",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Full Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// Driver Availability Cards (Grid/List of Drivers)
          ...allDriversAvailabilities.map((driver) {
            final Color driverColor = parseColor(driver.colorCode);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: driverColor, // 🔥 BACKGROUND COLOR FROM API
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      driver.userId.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// DRIVER NAME AND VEHICLE TYPE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        /// Display Vehicle Type using helper method
                        Text(
                          getVehicleTypeName(driver.vehicleType),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// RIGHT SIDE TIME BOXES (WHITE BOXES)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// AVAILABLE SLOTS
                      ...driver.availableHours.map(
                        (slot) => Container(
                          width: 160,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${_formatHourMin(slot.from)} - ${_formatHourMin(slot.to)}\n(${_statusLabel('available')})",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      /// UNAVAILABLE SLOTS
                      ...driver.unAvailableHours.map(
                        (slot) => Container(
                          width: 160,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${_formatHourMin(slot.from)} - ${_formatHourMin(slot.to)}\n(${_statusLabel('unavailable')})",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
  }

  Widget _buildMyAvailabilityTable(
    List<Availability> data,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    if (selectedDate == null) return const SizedBox.shrink();

    final filteredData = data.where((a) {
      final date = DateTime(a.date.year, a.date.month, a.date.day);
      final selected = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );
      return date == selected;
    }).toList();

    if (filteredData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No availability data found for selected day.",
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    Color getStatusColor(int type) {
      switch (type) {
        case 1:
          return Colors.green;
        case 2:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getStatusText(int type) {
      switch (type) {
        case 1:
          return "Available";
        case 2:
          return "Unavailable";
        default:
          return "Not Set";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "My Availabilities",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy').format(selectedDate!),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Day",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Status",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  "Details",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...filteredData.map((a) {
          final formattedDate = DateFormat('EEE dd/MM').format(a.date);
          final statusColor = getStatusColor(a.availabilityType);
          final statusText = getStatusText(a.availabilityType);
          final detailText =
              "${_formatHourMin(a.from)} - ${_formatHourMin(a.to)} (${a.description})";

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            detailText,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, a),
                          tooltip: "Delete",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTabSwitch(AvailabilityProvider provider) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => showMyAvailability = true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: showMyAvailability
                    ? theme.colorScheme.primary
                    : theme.cardColor,
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "My Availability",
                  style: TextStyle(
                    color: !showMyAvailability
                        ? theme.colorScheme.primary
                        : theme.cardColor,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              setState(() => showMyAvailability = false);

              // ✅ When entering All Drivers tab, call API for current selected date
              if (selectedDate != null) {
                print(
                  "🟢 Switched to All Drivers tab → fetching for $selectedDate",
                );
                await _fetchAllDriversForDate(selectedDate!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !showMyAvailability
                    ? theme.colorScheme.primary
                    : theme.cardColor,
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "All Drivers",
                  style: TextStyle(
                    color: !showMyAvailability
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
