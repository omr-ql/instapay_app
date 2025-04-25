// lib/core/config/app_routes.dart
import 'package:flutter/material.dart';
import 'package:instapay/screens/auth/login_screen.dart';
import 'package:instapay/screens/auth/otp_verification.dart';
import 'package:instapay/screens/auth/signup_screen.dart';
import 'package:instapay/screens/dashboard/home_screen.dart';
import 'package:instapay/screens/dashboard/profile_screen.dart';
import 'package:instapay/screens/transactions/transfer_instapay.dart';
import 'package:instapay/screens/transactions/transfer_wallet.dart';
import 'package:instapay/screens/transactions/transfer_bank.dart';
import 'package:instapay/screens/transactions/transaction_history.dart';
import 'package:instapay/screens/bills/bill_payment.dart';
import 'package:instapay/screens/bills/bill_history.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';

  // Dashboard routes
  static const String home = '/home';
  static const String profile = '/profile';

  // Transaction routes
  static const String transferInstapay = '/transfer-instapay';
  static const String transferWallet = '/transfer-wallet';
  static const String transferBank = '/transfer-bank';
  static const String transactionHistory = '/transaction-history';

  // Bill routes
  static const String billPayment = '/bill-payment';
  static const String billHistory = '/bill-history';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    otpVerification: (context) => const OtpVerificationScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    transferInstapay: (context) => const TransferInstapayScreen(),
    transferWallet: (context) => const TransferWalletScreen(),
    transferBank: (context) => const TransferBankScreen(),
    transactionHistory: (context) => const TransactionHistoryScreen(),
    billPayment: (context) => const BillPaymentScreen(),
    billHistory: (context) => const BillHistoryScreen(),
  };

  // Navigation helpers
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void navigateToOtpVerification(BuildContext context, Map<String, dynamic> args) {
    Navigator.pushNamed(
      context,
      otpVerification,
      arguments: args,
    );
  }
}
