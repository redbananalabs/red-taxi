class EarningModel {
  final DateTime date;
  final double cashTotal;
  final double accTotal;
  final double rankTotal;
  final double commsTotal;
  final double grossTotal;
  final double netTotal;
  final int cashJobsCount;
  final int accJobsCount;
  final int rankJobsCount;
  final double? rankMilesCount;

  EarningModel({
    required this.date,
    required this.cashTotal,
    required this.accTotal,
    required this.rankTotal,
    required this.commsTotal,
    required this.grossTotal,
    required this.netTotal,
    required this.cashJobsCount,
    required this.accJobsCount,
    required this.rankJobsCount,
    this.rankMilesCount,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      date: DateTime.parse(json['date']),
      cashTotal: (json['cashTotal'] ?? 0).toDouble(),
      accTotal: (json['accTotal'] ?? 0).toDouble(),
      rankTotal: (json['rankTotal'] ?? 0).toDouble(),
      commsTotal: (json['commsTotal'] ?? 0).toDouble(),
      grossTotal: (json['grossTotal'] ?? 0).toDouble(),
      netTotal: (json['netTotal'] ?? 0).toDouble(),
      cashJobsCount: (json['cashJobsCount'] ?? 0).toInt(),
      accJobsCount: (json['accJobsCount'] ?? 0).toInt(),
      rankJobsCount: (json['rankJobsCount'] ?? 0).toInt(),
      rankMilesCount: (json['rankMilesCount'] ?? 0).toDouble(),
    );
  }
}
