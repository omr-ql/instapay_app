// lib/models/bill_model.dart
import 'package:instapay/core/config/constants.dart';

class Bill {
  final String id;
  final String type; // gas, electricity, water
  final String accountNumber;
  final String customerName;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paymentDate;
  final Map<String, dynamic> details; // Specific details based on bill type

  Bill({
    required this.id,
    required this.type,
    required this.accountNumber,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.paymentDate,
    required this.details,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      type: json['type'],
      accountNumber: json['account_number'],
      customerName: json['customer_name'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      isPaid: json['is_paid'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'account_number': accountNumber,
      'customer_name': customerName,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'is_paid': isPaid,
      'payment_date': paymentDate?.toIso8601String(),
      'details': details,
    };
  }
}
