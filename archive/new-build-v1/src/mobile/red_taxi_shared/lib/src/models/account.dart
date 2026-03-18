/// Represents a financial account / payment method.
enum AccountType {
  cash,
  card,
  wallet,
  corporate,
}

/// Account model shared across all Red Taxi apps.
class Account {
  final String id;
  final String name;
  final AccountType type;
  final String? lastFourDigits;
  final String? bankName;
  final double balance;
  final bool isDefault;
  final DateTime createdAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.lastFourDigits,
    this.bankName,
    required this.balance,
    required this.isDefault,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values.byName(json['type'] as String),
      lastFourDigits: json['last_four_digits'] as String?,
      bankName: json['bank_name'] as String?,
      balance: (json['balance'] as num).toDouble(),
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'last_four_digits': lastFourDigits,
      'bank_name': bankName,
      'balance': balance,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Account(id: $id, name: $name, type: ${type.name})';
}
