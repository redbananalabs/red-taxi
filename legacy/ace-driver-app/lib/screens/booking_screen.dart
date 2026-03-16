import 'dart:async';
import 'package:ace_taxis/helpers/firebase_helper.dart';
import 'package:ace_taxis/models/booking.dart';
import 'package:ace_taxis/screens/completed_job_screen.dart';
import 'package:ace_taxis/screens/job_offer_screen.dart';
import 'package:ace_taxis/screens/trip_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/booking_provider.dart';
import 'home_screen.dart';

class BookingScreen extends StatefulWidget {
  final int? initialTabIndex; // ← new
  final String? initialTabName;
  const BookingScreen({super.key, this.initialTabIndex, this.initialTabName});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late String selectedTab;
  late PageController _pageController;

  // Separate loading states for each tab
  bool _isTodayLoading = false;
  bool _isFutureLoading = false;
  bool _isCompletedLoading = false;
  bool _isJobOffersLoading = false;

  Timer? _autoRefreshTimer;
  @override
  void initState() {
    super.initState();
    // Decide initial tab
    if (widget.initialTabName != null) {
      selectedTab = widget.initialTabName!;
    } else if (widget.initialTabIndex != null) {
      selectedTab = _indexToTabName(widget.initialTabIndex!);
    } else {
      selectedTab = "Job offers"; // fallback
    }

    _pageController = PageController(initialPage: _tabNameToIndex(selectedTab));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });

    // Initialize Firebase
    FirebaseHelper().initFirebase(context);

    // ---- AUTO REFRESH TIMER ----
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshAll(),
    );
  }

  int _tabNameToIndex(String name) {
    return switch (name) {
      "Job offers" => 0,
      "To do" => 1,
      "Future" => 2,
      "Completed" => 3,
      _ => 0,
    };
  }

  String _indexToTabName(int index) {
    return switch (index) {
      0 => "Job offers",
      1 => "To do",
      2 => "Future",
      3 => "Completed",
      _ => "Job offers",
    };
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ===================== NEW OPEN MAP ==========================
  Future<void> openMap(BuildContext context, String? address) async {
    if (address == null || address.trim().isEmpty) return;

    try {
      final encodedAddress = Uri.encodeComponent(address);

      final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$encodedAddress",
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Google Maps")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Map Error: $e")));
    }
  }

  Future<void> _refreshAll() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    await Future.wait([
      provider.fetchTodaysJobs(),
      provider.fetchFutureJobs(),
      provider.fetchCompletedJobs(),
      provider.fetchActiveJob(),
      provider.fetchJobOffers(),
    ]);
    // setState(() {});
  }

  Future<void> _refreshToday() async {
    setState(() => _isTodayLoading = true);
    try {
      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).fetchTodaysJobs();
    } finally {
      if (mounted) setState(() => _isTodayLoading = false);
    }
  }

  Future<void> _refreshFuture() async {
    setState(() => _isFutureLoading = true);
    try {
      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).fetchFutureJobs();
    } finally {
      if (mounted) setState(() => _isFutureLoading = false);
    }
  }

  Future<void> _refreshJobOffers() async {
    setState(() => _isJobOffersLoading = true);
    try {
      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).fetchJobOffers();
    } finally {
      if (mounted) setState(() => _isJobOffersLoading = false);
    }
  }

  Future<void> _refreshCompleted() async {
    setState(() => _isCompletedLoading = true);
    try {
      await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).fetchCompletedJobs();
    } finally {
      if (mounted) setState(() => _isCompletedLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
        title: const Text(
          "Bookings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton("Job offers", 0),
                        const SizedBox(width: 10),
                        _buildTabButton("To do", 1),
                        const SizedBox(width: 10),
                        _buildTabButton("Future", 2),
                        const SizedBox(width: 10),
                        _buildTabButton("Completed", 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selectedTab = switch (index) {
                            0 => "Job offers",
                            1 => "To do",
                            2 => "Future",
                            _ => "Completed",
                          };
                        });
                      },
                      children: [
                        _buildTabWithRefresh(
                          _buildJobOffersUIOnly(),
                          _refreshJobOffers,
                        ),

                        _buildTabWithRefresh(_buildTodayList(), _refreshToday),

                        _buildTabWithRefresh(
                          _buildFutureList(),
                          _refreshFuture,
                        ),
                        _buildTabWithRefresh(
                          _buildCompletedList(),
                          _refreshCompleted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabWithRefresh(Widget child, Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.red,
      child: child,
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCD1A21) : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected ? const Color(0xFFCD1A21) : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildJobOffersUIOnly() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final bookings = provider.jobOffers;

        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              "No job offers",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            String formattedDate = "--";
            if (booking.pickupDateTime != null) {
              try {
                formattedDate = DateFormat(
                  "d MMM yyyy, HH:mm",
                ).format(DateTime.parse(booking.pickupDateTime!));
              } catch (_) {}
            }

            return _buildBookingCard(
              booking: booking,
              formattedDate: formattedDate,
              isActive: false,
              showStartButton: false,
              provider: provider,
              isJobOffer: true,
            );
          },
        );
      },
    );
  }

  // ==================== TODAY TAB ====================
  Widget _buildTodayList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final bookings = provider.todaysJobs;
        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              "No today bookings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final bool isActive = provider.activeBookingId == booking.bookingId;

            String formattedDate = "--";
            if (booking.pickupDateTime != null) {
              try {
                formattedDate = DateFormat(
                  "d MMM yyyy, HH:mm",
                ).format(DateTime.parse(booking.pickupDateTime!));
              } catch (_) {}
            }

            return _buildBookingCard(
              booking: booking,
              formattedDate: formattedDate,
              isActive: isActive,
              showStartButton: true,
              provider: provider,
            );
          },
        );
      },
    );
  }

  // ==================== FUTURE TAB ====================
  Widget _buildFutureList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final bookings = provider.futureJobs;
        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              "No future bookings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            String formattedDate = "--";
            if (booking.pickupDateTime != null) {
              try {
                formattedDate = DateFormat(
                  "d MMM yyyy, HH:mm",
                ).format(DateTime.parse(booking.pickupDateTime!));
              } catch (_) {}
            }
            return _buildBookingCard(
              booking: booking,
              formattedDate: formattedDate,
              isActive: false,
              showStartButton: false,
              provider: provider,
            );
          },
        );
      },
    );
  }

  // ==================== COMPLETED TAB ====================
  Widget _buildCompletedList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final bookings = provider.completedJobs;
        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              "No completed bookings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            String formattedDate = "--";
            if (booking.pickupDateTime != null) {
              try {
                formattedDate = DateFormat(
                  "d MMM yyyy, HH:mm",
                ).format(DateTime.parse(booking.pickupDateTime!));
              } catch (_) {}
            }
            return _buildBookingCard(
              booking: booking,
              formattedDate: formattedDate,
              isActive: false,
              showStartButton: false,
              provider: provider,
              // isJobOffer: true,
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard({
    required Bookings booking,
    required String formattedDate,
    required bool isActive,
    required bool showStartButton,
    required BookingProvider provider,
    bool isJobOffer = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.dividerColor,
                    child: const Icon(
                      Icons.person,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.passengerName ?? "Passenger",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                booking.price != null
                    ? "£${booking.price!.toStringAsFixed(2)}"
                    : "--",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(color: theme.dividerColor, thickness: 1),
          const SizedBox(height: 12),

          // Pickup & Drop
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _addressRow(
                "Pickup --",
                booking.pickupAddress,
                booking.pickupPostCode,
                color: Colors.green,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _addressRow(
                "Drop --",
                booking.destinationAddress,
                booking.destinationPostCode,
                color: Colors.red,
                theme: theme,
              ),
            ],
          ),

          Divider(color: theme.dividerColor, height: 32, thickness: 1),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // START / ACTIVE button
              showStartButton
                  ? InkWell(
                      onTap: () async {
                        // CASE 1: End current active booking
                        if (isActive) {
                          provider.endBooking();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking has been ended."),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // CASE 2: Another booking already active → show dialog
                        if (provider.activeBookingId != null && !isActive) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        20,
                                        16,
                                        16,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Active Booking Exists",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "Another booking is currently running.\n"
                                            "What would you like to do?",
                                          ),
                                          const SizedBox(height: 20),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // START ANYWAYS - LEFT
                                              SizedBox(
                                                width: 120,
                                                height: 40,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    try {
                                                      await provider
                                                          .setActiveBooking(
                                                            booking.bookingId!,
                                                          );
                                                      provider.startBooking(
                                                        booking,
                                                      );

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Booking set as active successfully!",
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Failed to set active booking: $e",
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Start Anyways",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // COMPLETE - RIGHT
                                              SizedBox(
                                                width: 120,
                                                height: 40,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                  onPressed: () {
                                                    final activeBooking =
                                                        provider.activeBooking;

                                                    if (activeBooking == null) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "No active booking found.",
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    Navigator.pop(context);

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            CompleteJobScreen(
                                                              bookingId:
                                                                  activeBooking
                                                                      .bookingId!,
                                                              price:
                                                                  activeBooking
                                                                      .price ??
                                                                  0.0,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    "Complete",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ❌ CLOSE ICON
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          return;
                        }

                        // CASE 3: No active booking → start directly
                        try {
                          await provider.setActiveBooking(booking.bookingId!);
                          provider.startBooking(booking);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking started successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to start booking: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isActive ? "ACTIVE" : "START",
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color.fromARGB(255, 33, 141, 38),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 100),

              // Details button
              InkWell(
                onTap: () {
                  if (isJobOffer) {
                    // ✅ JOB OFFER → FULL SCREEN OFFER (GUID FIX)
                    debugPrint(
                      "➡️ Job Offer Opened with GUID: ${booking.guid}",
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenJobOffer(
                          booking: booking,
                          overrideGuid: booking.guid,
                        ),
                      ),
                    );
                  } else {
                    // ✅ NORMAL BOOKINGS → DETAILS
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(booking: booking),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      isJobOffer ? "Open" : "Details",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Updated _addressRow to use theme
  Widget _addressRow(
    String label,
    String? address,
    String? postcode, {
    required Color color,
    required ThemeData theme,
  }) {
    final displayAddress = [
      address,
      postcode,
    ].where((e) => e != null && e.isNotEmpty).join(", ");

    return InkWell(
      onTap: () {
        if (postcode != null && postcode.trim().isNotEmpty) {
          openMap(context, postcode);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayAddress,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
