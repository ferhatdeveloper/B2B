import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.customerId,
    this.customerCode,
    this.customerTitle,
    this.roleName,
    this.balance = 0,
    this.creditLimit = 0,
    this.pastDueBalance = 0,
  });

  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? customerId;
  final String? customerCode;
  final String? customerTitle;
  final String? roleName;
  final double balance;
  final double creditLimit;
  final double pastDueBalance;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      customerId: json['customer_id'] as String?,
      customerCode: json['customer_code'] as String?,
      customerTitle: json['customer_title'] as String?,
      roleName: json['role_name'] as String?,
      balance: _toDouble(json['balance']),
      creditLimit: _toDouble(json['credit_limit']),
      pastDueBalance: _toDouble(json['past_due_balance']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        'email': email,
        'customer_id': customerId,
        'customer_code': customerCode,
        'customer_title': customerTitle,
        'role_name': roleName,
        'balance': balance,
        'credit_limit': creditLimit,
        'past_due_balance': pastDueBalance,
      };

  static double _toDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [id, username];
}
