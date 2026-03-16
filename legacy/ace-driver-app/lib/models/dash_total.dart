class DashTotal {
  final bool? success;
  final Map<String, dynamic>? totals;
  final String? message;

  // Job counts remain int
  final int? totalJobCountToday;
  final int? totalJobCountWeek;
  final int? totalJobCountMonth;

  // Earnings should be double
  final double? earningsTotalToday;
  final double? earningsTotalWeek;
  final double? earningsTotalMonth;

  DashTotal({
    this.success,
    this.totals,
    this.message,
    this.totalJobCountToday,
    this.totalJobCountWeek,
    this.totalJobCountMonth,
    this.earningsTotalToday,
    this.earningsTotalWeek,
    this.earningsTotalMonth,
  });

  factory DashTotal.fromJson(Map<String, dynamic> json) {
    return DashTotal(
      success: json['success'] ?? false,
      totals: json['totals'] ?? {},
      message: json['message'] ?? '',
      totalJobCountToday: json['totalJobCountToday'] ?? 0,
      totalJobCountWeek: json['totalJobCountWeek'] ?? 0,
      totalJobCountMonth: json['totalJobCountMonth'] ?? 0,

      // Convert earnings safely to double
      earningsTotalToday: (json['earningsTotalToday'] as num?)?.toDouble() ?? 0.0,
      earningsTotalWeek: (json['earningsTotalWeek'] as num?)?.toDouble() ?? 0.0,
      earningsTotalMonth: (json['earningsTotalMonth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "totals": totals,
      "message": message,
      "totalJobCountToday": totalJobCountToday,
      "totalJobCountWeek": totalJobCountWeek,
      "totalJobCountMonth": totalJobCountMonth,
      "earningsTotalToday": earningsTotalToday,
      "earningsTotalWeek": earningsTotalWeek,
      "earningsTotalMonth": earningsTotalMonth,
    };
  }
}
