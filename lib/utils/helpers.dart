// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String formatCurrency(double amount) {
    return 'EGP ${amount.toStringAsFixed(2)}';
  }

  static String getTransactionTypeLabel(String type) {
    switch (type) {
      case 'instapay_transfer':
        return 'InstaPay Transfer';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'wallet_transfer':
        return 'Wallet Transfer';
      case 'bill_payment':
        return 'Bill Payment';
      default:
        return 'Transaction';
    }
  }

  static Color getTransactionColor(String type) {
    switch (type) {
      case 'instapay_transfer':
        return Colors.blue;
      case 'bank_transfer':
        return Colors.purple;
      case 'wallet_transfer':
        return Colors.green;
      case 'bill_payment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static String getBillTypeLabel(String type) {
    switch (type) {
      case 'gas':
        return 'Gas Bill';
      case 'electricity':
        return 'Electricity Bill';
      case 'water':
        return 'Water Bill';
      default:
        return 'Bill';
    }
  }

  static IconData getBillTypeIcon(String type) {
    switch (type) {
      case 'gas':
        return Icons.local_fire_department;
      case 'electricity':
        return Icons.electric_bolt;
      case 'water':
        return Icons.water_drop;
      default:
        return Icons.receipt;
    }
  }
}
