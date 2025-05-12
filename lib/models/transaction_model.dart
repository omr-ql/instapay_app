// lib/models/transaction_model.dart
import 'package:instapay/core/config/constants.dart';

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String senderUsername;
  final String? receiverUsername;
  final String? receiverMobileNumber;
  final String? receiverBankAccount;
  final DateTime timestamp;
  final String status;
  final String? description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.senderUsername,
    this.receiverUsername,
    this.receiverMobileNumber,
    this.receiverBankAccount,
    required this.timestamp,
    required this.status,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      senderUsername: json['sender_username'],
      receiverUsername: json['receiver_username'],
      receiverMobileNumber: json['receiver_mobile_number'],
      receiverBankAccount: json['receiver_bank_account'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'sender_username': senderUsername,
      'receiver_username': receiverUsername,
      'receiver_mobile_number': receiverMobileNumber,
      'receiver_bank_account': receiverBankAccount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}