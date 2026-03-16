class StatementModel {
  final int statementId;
  final DateTime dateCreated;
  final DateTime? dateUpdated;
  final DateTime startDate;
  final DateTime endDate;
  final double earningsCash;
  final double earningsAccount;
  final double earningsCard;
  final double earningsRank;
  final double commissionDue;
  final double subTotal;
  final double totalEarned;
  final double paymentDue;
  final int totalJobCount;
  final int accountJobsTotalCount;
  final int cashJobsTotalCount;
  final int rankJobsTotalCount;
  final bool paidInFull;
  final int userId;
  final String? identifier;
  final String? colorCode;
  final List<dynamic> jobs;

  StatementModel({
    required this.statementId,
    required this.dateCreated,
    this.dateUpdated,
    required this.startDate,
    required this.endDate,
    required this.earningsCash,
    required this.earningsAccount,
    required this.earningsCard,
    required this.earningsRank,
    required this.commissionDue,
    required this.subTotal,
    required this.totalEarned,
    required this.paymentDue,
    required this.totalJobCount,
    required this.accountJobsTotalCount,
    required this.cashJobsTotalCount,
    required this.rankJobsTotalCount,
    required this.paidInFull,
    required this.userId,
    this.identifier,
    this.colorCode,
    required this.jobs,
  });

  factory StatementModel.fromJson(Map<String, dynamic> json) {
    return StatementModel(
      statementId: json['statementId'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateUpdated: json['dateUpdated'] != null
          ? DateTime.parse(json['dateUpdated'])
          : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      earningsCash: (json['earningsCash'] ?? 0).toDouble(),
      earningsAccount: (json['earningsAccount'] ?? 0).toDouble(),
      earningsRank: (json['earningsRank'] as num?)?.toDouble() ?? 0.0,
      earningsCard: (json['earningsCard'] ?? 0).toDouble(),
      commissionDue: (json['commissionDue'] ?? 0).toDouble(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      paymentDue: (json['paymentDue'] ?? 0).toDouble(),
      totalJobCount: json['totalJobCount'] ?? 0,
      accountJobsTotalCount: json['accountJobsTotalCount'] ?? 0,
      cashJobsTotalCount: json['cashJobsTotalCount'] ?? 0,
      rankJobsTotalCount: json['rankJobsTotalCount'] ?? 0,
      paidInFull: json['paidInFull'] ?? false,
      userId: json['userId'] ?? 0,
      identifier: json['identifier'],
      colorCode: json['colorCode'],
      jobs: json['jobs'] ?? [],
    );
  }
}
