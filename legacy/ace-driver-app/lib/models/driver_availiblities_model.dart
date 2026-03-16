class DriverAvailability {
  final int userId;
  final String fullName;
  final DateTime date;
  final String colorCode;
  final int vehicleType;
  final List<HourSlot> availableHours;
  final List<HourSlot> unAvailableHours;
  final List<HourSlot> allocatedHours;

  DriverAvailability({
    required this.userId,
    required this.fullName,
    required this.date,
    required this.colorCode,
    required this.vehicleType,
    required this.availableHours,
    required this.unAvailableHours,
    required this.allocatedHours,
  });

  factory DriverAvailability.fromJson(Map<String, dynamic> json) {
    List<HourSlot> parseSlots(List<dynamic>? list) {
      if (list == null) return [];
      return list.map((e) => HourSlot.fromJson(e)).toList();
    }

    return DriverAvailability(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      date: DateTime.parse(json['date']),
      colorCode: json['colorCode'] ?? '#000000',
      vehicleType: json['vehicleType'] ?? 0,
      availableHours: parseSlots(json['availableHours']),
      unAvailableHours: parseSlots(json['unAvailableHours']),
      allocatedHours: parseSlots(json['allocatedHours']),
    );
  }
}

class HourSlot {
  final String from;
  final String to;
  final String note;

  HourSlot({required this.from, required this.to, required this.note});

  factory HourSlot.fromJson(Map<String, dynamic> json) {
    return HourSlot(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      note: json['note'] ?? '',
    );
  }
}
