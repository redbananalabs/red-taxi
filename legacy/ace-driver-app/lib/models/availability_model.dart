// class Availability {
//   final int id;
//   final int userId;
//   final String fullName;
//   final DateTime date;
//   final String description;
//   final String colorCode;
//   final int availabilityType;
//   final String from;
//   final String to;
//   final bool giveOrTake;
//   final String availableHours;

//   Availability({
//     required this.id,
//     required this.userId,
//     required this.fullName,
//     required this.date,
//     required this.description,
//     required this.colorCode,
//     required this.availabilityType,
//     required this.from,
//     required this.to,
//     required this.giveOrTake,
//     required this.availableHours,
//   });

//   factory Availability.fromJson(Map<String, dynamic> json) {
//     return Availability(
//       id: json['id'] ?? json['availabilityId'] ?? 0,
//       userId: json['userId'] ?? 0,
//       fullName: json['fullName'] ?? '',
//       date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
//       description: json['description'] ?? json['note'] ?? '',
//       colorCode: json['colorCode'] ?? '#000000',
//       availabilityType: json['availabilityType'] ?? json['type'] ?? 0,
//       from: json['from'] ?? '',
//       to: json['to'] ?? '',
//       giveOrTake: json['giveOrTake'] ?? false,
//       availableHours: json['availableHours'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'fullName': fullName,
//       'date': date.toIso8601String(),
//       'description': description,
//       'colorCode': colorCode,
//       'availabilityType': availabilityType,
//       'from': from,
//       'to': to,
//       'giveOrTake': giveOrTake,
//       'availableHours': availableHours,
//     };
//   }
// }


class AvailableHour {
  final String from;
  final String to;
  final String note;

  AvailableHour({
    required this.from,
    required this.to,
    required this.note,
  });

  factory AvailableHour.fromJson(Map<String, dynamic> json) {
    return AvailableHour(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'note': note,
      };
}

class UnavailableHour {
  final String from;
  final String to;
  final String note;

  UnavailableHour({
    required this.from,
    required this.to,
    required this.note,
  });

  factory UnavailableHour.fromJson(Map<String, dynamic> json) {
    return UnavailableHour(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'note': note,
      };
}

class Availability {
  final int id;
  final int userId;
  final String fullName;
  final DateTime date;
  final String description;
  final String colorCode;
  final int availabilityType;
  final String from;
  final String to;
  final bool giveOrTake;
  final int vehicleType;
  final String availableHoursRaw;
  final List<AvailableHour> availableHoursList;
  final List<UnavailableHour> unAvailableHoursList;

  Availability({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.date,
    required this.description,
    required this.colorCode,
    required this.availabilityType,
    required this.from,
    required this.to,
    required this.giveOrTake,
    required this.vehicleType,
    required this.availableHoursRaw,
    required this.availableHoursList,
    required this.unAvailableHoursList,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    // Parse availableHours safely
    List<AvailableHour> availableList = [];
    if (json['availableHours'] is List) {
      availableList = (json['availableHours'] as List)
          .map((e) => AvailableHour.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse unAvailableHours safely
    List<UnavailableHour> unavailableList = [];
    if (json['unAvailableHours'] is List) {
      unavailableList = (json['unAvailableHours'] as List)
          .map((e) => UnavailableHour.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fallback if both lists empty
    if (availableList.isEmpty && unavailableList.isEmpty) {
      unavailableList.add(UnavailableHour(
        from: "00:00",
        to: "23:59",
        note: "Unavailable All Day",
      ));
    }

    return Availability(
      id: json['id'] ?? json['availabilityId'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      colorCode: json['colorCode'] ?? '#ef8c56ff',
      availabilityType: json['availabilityType'] ?? 0,
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      giveOrTake: json['giveOrTake'] ?? false,
      vehicleType: json['vehicleType'] ?? 0,
      availableHoursRaw: json['availableHours']?.toString() ?? '',
      availableHoursList: availableList,
      unAvailableHoursList: unavailableList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'date': date.toIso8601String(),
        'description': description,
        'colorCode': colorCode,
        'availabilityType': availabilityType,
        'from': from,
        'to': to,
        'giveOrTake': giveOrTake,
        'vehicleType': vehicleType,
        'availableHours': availableHoursRaw,
        'availableHoursList': availableHoursList.map((e) => e.toJson()).toList(),
        'unAvailableHoursList': unAvailableHoursList.map((e) => e.toJson()).toList(),
      };
}
