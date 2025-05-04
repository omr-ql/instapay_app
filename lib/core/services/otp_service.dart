// lib/core/services/otp_service.dart
import 'package:instapay/core/services/api_service.dart';

class OtpService {
  final ApiService _apiService = ApiService();

  Future<void> sendOtp(String mobileNumber) async {
    try {
      await _apiService.post('auth/send-otp', {
        'mobile_number': mobileNumber,
      });
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await _apiService.post('auth/verify-otp', {
        'mobile_number': mobileNumber,
        'otp': otp,
      });

      return response['verified'] == true;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
}
