// lib/screens/dashboard/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapay/models/user_model.dart';
import 'package:instapay/providers/auth_provider.dart';
import 'package:instapay/providers/user_provider.dart';
import 'package:instapay/utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      user.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.type == UserType.bank
                        ? 'Bank Account User'
                        : 'Wallet User',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Balance: ${Helpers.formatCurrency(userProvider.balance)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // User Information
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoItem(
              'Username',
              user.username,
              Icons.person,
            ),
            _buildInfoItem(
              'Mobile Number',
              user.mobileNumber,
              Icons.phone,
            ),
            _buildInfoItem(
              'Account Type',
              user.type == UserType.bank ? 'Bank Account' : 'Mobile Wallet',
              user.type == UserType.bank
                  ? Icons.account_balance
                  : Icons.account_balance_wallet,
            ),

            if (user.type == UserType.bank && user.bankAccount != null)
              _buildInfoItem(
                'Bank Account',
                user.bankAccount!,
                Icons.credit_card,
              )
            else if (user.type == UserType.wallet && user.walletProvider != null)
              _buildInfoItem(
                'Wallet Provider',
                user.walletProvider!,
                Icons.account_balance_wallet,
              ),

            const SizedBox(height: 32),

            // App Information
            const Text(
              'App Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoItem(
              'App Version',
              '1.0.0',
              Icons.info,
            ),
            _buildInfoItem(
              'Terms & Conditions',
              'Tap to view',
              Icons.description,
              onTap: () {
                // Navigate to Terms & Conditions
              },
            ),
            _buildInfoItem(
              'Privacy Policy',
              'Tap to view',
              Icons.privacy_tip,
              onTap: () {
                // Navigate to Privacy Policy
              },
            ),
            _buildInfoItem(
              'Contact Support',
              'Tap to contact',
              Icons.support_agent,
              onTap: () {
                // Navigate to Support
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String title,
      String value,
      IconData icon, {
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black54,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
