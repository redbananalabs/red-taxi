class ExpenseModel {
  final int userId;
  final DateTime date;
  final String category;
  final String description;
  final double amount;

  ExpenseModel({
    required this.userId,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      userId: json['userId'] ?? 0,
      date: DateTime.parse(json['date']),
      category: _mapCategoryIntToName(json['category']),
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  static String _mapCategoryIntToName(int? category) {
    switch (category) {
      case 0:
        return "Fuel";
      case 1:
        return "Parking/ULEZ";
      case 2:
        return "Insurance";
      case 3:
        return "MOT";
      case 4:
        return "DBS";
      case 5:
        return "Vehicle Badge";
      case 6:
        return "Maintenance";
      case 7:
        return "Certification";
      case 8:
        return "Other";
      default:
        return "Unknown";
    }
  }
}
