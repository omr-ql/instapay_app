// lib/core/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:instapay/core/config/constants.dart';
import 'package:instapay/core/services/api_service.dart';
import 'package:instapay/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<User> login(String username, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'username': username,
        'password': password,
      });

      if (response['token'] != null) {
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: response['token'],
        );

        final user = User.fromJson(response['user']);

        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.userPreferenceKey,
          user.toJson().toString(),
        );

        return user;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signup({
    required String registrationType,
    required String mobileNumber,
    String? bankAccount,
    String? walletProvider,
    required String username,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'registration_type': registrationType,
        'mobile_number': mobileNumber,
        'username': username,
        'password': password,
      };

      if (registrationType == AppConstants.bankRegistration) {
        data['bank_account'] = bankAccount;
      } else {
        data['wallet_provider'] = walletProvider;
      }

      await _apiService.post('auth/register', data);
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<void> verifyOtp(String mobileNumber, String otp) async {
    try {
      await _apiService.post('auth/verify-otp', {
        'mobile_number': mobileNumber,
        'otp': otp,
      });
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: AppConstants.tokenKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userPreferenceKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}
