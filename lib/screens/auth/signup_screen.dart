// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapay/core/config/app_routes.dart';
import 'package:instapay/core/config/constants.dart';
import 'package:instapay/core/services/otp_service.dart';
import 'package:instapay/providers/auth_provider.dart';
import 'package:instapay/utils/validators.dart';
import 'package:instapay/widgets/custom_button.dart';
import 'package:instapay/widgets/custom_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final OtpService _otpService = OtpService();

  String _registrationType = AppConstants.bankRegistration;
  String? _selectedWalletProvider;
  bool _isLoading = false;

  final List<String> _walletProviders = [
    'Vodafone Cash',
    'Etisalat Cash',
    'Orange Cash',
    'WE Pay',
    'CIB',
    'Fawry',
  ];

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _bankAccountController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleRegistrationType(String type) {
    setState(() {
      _registrationType = type;
    });
  }

  Future<void> _sendOtp() async {
    if (!_validateFirstStep()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _otpService.sendOtp(_mobileNumberController.text.trim());

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.otpVerification,
          arguments: {
            'mobile_number': _mobileNumberController.text.trim(),
            'registration_type': _registrationType,
            'bank_account': _registrationType == AppConstants.bankRegistration
                ? _bankAccountController.text.trim()
                : null,
            'wallet_provider': _registrationType == AppConstants.walletRegistration
                ? _selectedWalletProvider
                : null,
            'username': _usernameController.text.trim(),
            'password': _passwordController.text,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateFirstStep() {
    if (!_formKey.currentState!.validate()) return false;

    if (_registrationType == AppConstants.walletRegistration &&
        _selectedWalletProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wallet provider'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Sign Up with InstaPay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please fill in the details to create your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // Registration Type Selection
                const Text(
                  'Registration Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleRegistrationType(AppConstants.bankRegistration),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _registrationType == AppConstants.bankRegistration
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Bank Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _registrationType == AppConstants.bankRegistration
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleRegistrationType(AppConstants.walletRegistration),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _registrationType == AppConstants.walletRegistration
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Mobile Wallet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _registrationType == AppConstants.walletRegistration
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mobile Number
                CustomInput(
                  label: 'Mobile Number',
                  hint: 'Enter your mobile number',
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateMobileNumber,
                  prefixIcon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 16),

                // Bank Account or Wallet Provider based on registration type
                if (_registrationType == AppConstants.bankRegistration)
                  CustomInput(
                    label: 'Bank Account Number',
                    hint: 'Enter your bank account number',
                    controller: _bankAccountController,
                    keyboardType: TextInputType.number,
                    validator: Validators.validateBankAccount,
                    prefixIcon: const Icon(Icons.account_balance),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Provider',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.account_balance_wallet),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        hint: const Text('Select wallet provider'),
                        value: _selectedWalletProvider,
                        items: _walletProviders.map((provider) {
                          return DropdownMenuItem<String>(
                            value: provider,
                            child: Text(provider),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWalletProvider = value;
                          });
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Username and Password
                CustomInput(
                  label: 'Username',
                  hint: 'Create a unique username',
                  controller: _usernameController,
                  validator: Validators.validateUsername,
                  prefixIcon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'Password',
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 30),

                // Continue Button
                CustomButton(
                  text: 'Continue',
                  onPressed: _sendOtp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
