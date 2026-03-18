import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Availability presets.
enum AvailabilityPreset {
  custom('Custom'),
  srAmOnly('SR AM Only'),
  srPmOnly('SR PM Only'),
  srOnly('SR Only'),
  unavailable('UNAVAILABLE ALL DAY');

  final String label;
  const AvailabilityPreset(this.label);
}

/// A single availability block with start/end times.
class _AvailabilityBlock {
  TimeOfDay start;
  TimeOfDay end;
  _AvailabilityBlock({required this.start, required this.end});
}

/// Tab 4: Set availability for dates with presets and time range pickers.
class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime _selectedDate = DateTime.now();
  AvailabilityPreset _preset = AvailabilityPreset.custom;
  final List<_AvailabilityBlock> _blocks = [
    _AvailabilityBlock(
      start: const TimeOfDay(hour: 6, minute: 0),
      end: const TimeOfDay(hour: 18, minute: 0),
    ),
  ];

  void _applyPreset(AvailabilityPreset preset) {
    setState(() {
      _preset = preset;
      _blocks.clear();
      switch (preset) {
        case AvailabilityPreset.srAmOnly:
          _blocks.add(_AvailabilityBlock(
            start: const TimeOfDay(hour: 5, minute: 0),
            end: const TimeOfDay(hour: 12, minute: 0),
          ));
        case AvailabilityPreset.srPmOnly:
          _blocks.add(_AvailabilityBlock(
            start: const TimeOfDay(hour: 12, minute: 0),
            end: const TimeOfDay(hour: 22, minute: 0),
          ));
        case AvailabilityPreset.srOnly:
          _blocks.add(_AvailabilityBlock(
            start: const TimeOfDay(hour: 5, minute: 0),
            end: const TimeOfDay(hour: 22, minute: 0),
          ));
        case AvailabilityPreset.unavailable:
          // No blocks = unavailable
          break;
        case AvailabilityPreset.custom:
          _blocks.add(_AvailabilityBlock(
            start: const TimeOfDay(hour: 6, minute: 0),
            end: const TimeOfDay(hour: 18, minute: 0),
          ));
      }
    });
  }

  void _addBlock() {
    setState(() {
      _preset = AvailabilityPreset.custom;
      _blocks.add(_AvailabilityBlock(
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 17, minute: 0),
      ));
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
      if (_blocks.isEmpty) _preset = AvailabilityPreset.unavailable;
    });
  }

  Future<void> _pickTime(bool isStart, int blockIndex) async {
    final block = _blocks[blockIndex];
    final initial = isStart ? block.start : block.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: RedTaxiColors.brandRed,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _preset = AvailabilityPreset.custom;
        if (isStart) {
          _blocks[blockIndex].start = picked;
        } else {
          _blocks[blockIndex].end = picked;
        }
      });
    }
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Availability saved'),
        backgroundColor: RedTaxiColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Availability'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: RedTaxiColors.brandRed,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selector strip
            _DateStrip(
              selectedDate: _selectedDate,
              onDateSelected: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 20),

            // Presets
            const Text(
              'PRESETS',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AvailabilityPreset.values.map((p) {
                final isActive = _preset == p;
                return GestureDetector(
                  onTap: () => _applyPreset(p),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? RedTaxiColors.brandRed
                          : RedTaxiColors.backgroundCard,
                      borderRadius: BorderRadius.circular(20),
                      border: isActive
                          ? null
                          : Border.all(
                              color: RedTaxiColors.textSecondary
                                  .withOpacity(0.3)),
                    ),
                    child: Text(
                      p.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : RedTaxiColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Time blocks
            Row(
              children: [
                const Text(
                  'TIME BLOCKS',
                  style: TextStyle(
                    color: RedTaxiColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (_preset != AvailabilityPreset.unavailable)
                  GestureDetector(
                    onTap: _addBlock,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: RedTaxiColors.brandRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: RedTaxiColors.brandRed),
                          SizedBox(width: 4),
                          Text('Add Block',
                              style: TextStyle(
                                  color: RedTaxiColors.brandRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_blocks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: RedTaxiColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: RedTaxiColors.error.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.block, size: 36, color: RedTaxiColors.error),
                    SizedBox(height: 8),
                    Text(
                      'Unavailable All Day',
                      style: TextStyle(
                        color: RedTaxiColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_blocks.length, (i) {
                final block = _blocks[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Start time
                      _TimePill(
                        label: 'From',
                        time: block.start,
                        onTap: () => _pickTime(true, i),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 18, color: RedTaxiColors.textSecondary),
                      ),
                      // End time
                      _TimePill(
                        label: 'To',
                        time: block.end,
                        onTap: () => _pickTime(false, i),
                      ),
                      const Spacer(),
                      // Remove
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: RedTaxiColors.error, size: 20),
                        onPressed: () => _removeBlock(i),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedTaxiColors.brandRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Availability',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
        14, (i) => DateTime(today.year, today.month, today.day + i));
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (_, i) {
          final d = days[i];
          final isSel = d.year == selectedDate.year &&
              d.month == selectedDate.month &&
              d.day == selectedDate.day;
          return GestureDetector(
            onTap: () => onDateSelected(d),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSel
                    ? RedTaxiColors.brandRed
                    : RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weekdays[d.weekday - 1],
                      style: TextStyle(
                          color: isSel
                              ? Colors.white
                              : RedTaxiColors.textSecondary,
                          fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('${d.day}',
                      style: TextStyle(
                          color: isSel
                              ? Colors.white
                              : RedTaxiColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePill({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: RedTaxiColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatted,
              style: const TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
