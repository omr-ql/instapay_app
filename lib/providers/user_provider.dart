// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:instapay/core/services/api_service.dart';
import 'package:instapay/models/transaction_model.dart';
import 'package:instapay/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('user/balance');
      _balance = response['balance'].toDouble();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('user/transactions');
      _transactions = (response['transactions'] as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> transferToInstapay(String receiverUsername, double amount, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('transactions/instapay', {
        'receiver_username': receiverUsername,
        'amount': amount,
        'description': description,
      });

      await fetchBalance(); // Update balance after transaction
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> transferToWallet(String mobileNumber, double amount, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('transactions/wallet', {
        'mobile_number': mobileNumber,
        'amount': amount,
        'description': description,
      });

      await fetchBalance(); // Update balance after transaction
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> transferToBank(String bankAccount, double amount, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('transactions/bank', {
        'bank_account': bankAccount,
        'amount': amount,
        'description': description,
      });

      await fetchBalance(); // Update balance after transaction
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
