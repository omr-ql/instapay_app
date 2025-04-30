// lib/core/config/constants.dart
class AppConstants {
  static const String appName = 'InstaPay';
  static const String baseUrl = 'https://api.instapay.example.com'; // Will be replaced with actual API
  static const String userPreferenceKey = 'user_data';
  static const String tokenKey = 'auth_token';

  // Registration types
  static const String bankRegistration = 'bank';
  static const String walletRegistration = 'wallet';

  // Transaction types
  static const String transferInstapay = 'instapay_transfer';
  static const String transferBank = 'bank_transfer';
  static const String transferWallet = 'wallet_transfer';
  static const String billPayment = 'bill_payment';

  // Bill types
  static const String gasType = 'gas';
  static const String electricityType = 'electricity';
  static const String waterType = 'water';
}
