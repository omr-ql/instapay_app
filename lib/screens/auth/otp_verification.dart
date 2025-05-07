// lib/screens/auth/otp_verification.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:instapay/core/config/app_routes.dart';
import 'package:instapay/core/services/otp_service.dart';
import 'package:instapay/providers/auth_provider.dart';
import 'package:instapay/widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  final OtpService _otpService = OtpService();

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  int _remainingSeconds = 60;
  late Map<String, dynamic> _registrationData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startResendTimer();
      _registrationData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _remainingSeconds = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          }
        });
        return _remainingSeconds > 0;
      }
      return false;
    });
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();
    if (otpCode.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final isVerified = await _otpService.verifyOtp(
        _registrationData['mobile_number'],
        otpCode,
      );

      if (isVerified) {
        // Complete registration
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.signup(
          registrationType: _registrationData['registration_type'],
          mobileNumber: _registrationData['mobile_number'],
          bankAccount: _registrationData['bank_account'],
          walletProvider: _registrationData['wallet_provider'],
          username: _registrationData['username'],
          password: _registrationData['password'],
        );

        if (success && mounted) {
          // Navigate to login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
                (route) => false,
          );
        } else if (mounted) {
          setState(() {
            _errorMessage = authProvider.error ?? 'Registration failed';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await _otpService.sendOtp(_registrationData['mobile_number']);
      _startResendTimer();

      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verify Your Mobile Number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification code to ${_registrationData != null ? _registrationData['mobile_number'] : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Custom OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                      (index) => _buildOtpDigitField(index),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),

              // Verify Button
              CustomButton(
                text: 'Verify',
                onPressed: _verifyOtp,
                isLoading: _isVerifying,
              ),

              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: _remainingSeconds > 0 ? null : _resendOtp,
                    child: Text(
                      _remainingSeconds > 0
                          ? 'Resend in $_remainingSeconds s'
                          : 'Resend OTP',
                      style: TextStyle(
                        color: _remainingSeconds > 0 ? Colors.grey : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isResending)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 12,
                      height: 12,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigitField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }

          // Auto-verify when all digits are entered
          if (index == 5 && value.isNotEmpty) {
            if (_getOtpCode().length == 6) {
              _verifyOtp();
            }
          }
        },
      ),
    );
  }
}
