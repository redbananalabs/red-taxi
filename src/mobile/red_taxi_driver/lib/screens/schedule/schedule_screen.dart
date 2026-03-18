import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/booking_tile.dart';

/// Tab 1: Calendar view showing allocated bookings for the selected day.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          // Online/Offline toggle
          Consumer<ShiftProvider>(
            builder: (_, shift, __) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ShiftToggle(shift: shift),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          return Column(
            children: [
              _CalendarStrip(
                selectedDate: bp.selectedDate,
                onDateSelected: bp.selectDate,
              ),
              const Divider(
                  height: 1, color: Color(0xFF2A2D3A), thickness: 1),
              // Today header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      _formatDateHeader(bp.selectedDate),
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: RedTaxiColors.brandRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${bp.bookingsForSelectedDate.length} jobs',
                        style: const TextStyle(
                          color: RedTaxiColors.brandRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Booking list
              Expanded(
                child: bp.bookingsForSelectedDate.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        onRefresh: bp.refresh,
                        color: RedTaxiColors.brandRed,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: bp.bookingsForSelectedDate.length,
                          itemBuilder: (context, i) {
                            final booking = bp.bookingsForSelectedDate[i];
                            return BookingTile(
                              booking: booking,
                              onTap: () =>
                                  context.push('/schedule/${booking.id}'),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(dt.year, dt.month, dt.day);

    if (selected == today) return 'Today';
    if (selected == today.add(const Duration(days: 1))) return 'Tomorrow';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]}';
  }
}

class _ShiftToggle extends StatelessWidget {
  final ShiftProvider shift;
  const _ShiftToggle({required this.shift});

  @override
  Widget build(BuildContext context) {
    final isOn = shift.isOnline;
    return GestureDetector(
      onTap: () => isOn ? shift.goOffline() : shift.goOnline(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOn
              ? RedTaxiColors.success.withOpacity(0.15)
              : RedTaxiColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn ? RedTaxiColors.success : RedTaxiColors.textSecondary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOn ? RedTaxiColors.success : RedTaxiColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOn ? 'Online' : 'Offline',
              style: TextStyle(
                color: isOn ? RedTaxiColors.success : RedTaxiColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling date strip (7-day window).
class _CalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
        14, (i) => DateTime(today.year, today.month, today.day + i));

    return Container(
      height: 80,
      color: RedTaxiColors.backgroundSurface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i];
          final isSelected = d.year == selectedDate.year &&
              d.month == selectedDate.month &&
              d.day == selectedDate.day;
          final isToday = d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;

          const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

          return GestureDetector(
            onTap: () => onDateSelected(d),
            child: Container(
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? RedTaxiColors.brandRed
                    : RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: RedTaxiColors.brandRed, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdays[d.weekday - 1],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : RedTaxiColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : RedTaxiColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: RedTaxiColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No bookings for this day',
            style: TextStyle(
              color: RedTaxiColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
