// lib/providers/bill_provider.dart
import 'package:flutter/material.dart';
import 'package:instapay/core/services/api_service.dart';
import 'package:instapay/models/bill_model.dart';

class BillProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _error;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('bills');
      _bills = (response['bills'] as List)
          .map((json) => Bill.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> payBill(String billId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('bills/pay', {
        'bill_id': billId,
      });

      await fetchBills(); // Refresh bills after payment
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

  Future<Bill?> getBillDetails(String accountNumber, String billType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        'bills/details?account_number=$accountNumber&type=$billType',
      );

      final bill = Bill.fromJson(response['bill']);
      _isLoading = false;
      notifyListeners();
      return bill;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
