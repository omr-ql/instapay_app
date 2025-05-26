// lib/screens/transactions/transfer_wallet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:instapay/providers/user_provider.dart';
import 'package:instapay/utils/helpers.dart';
import 'package:instapay/utils/validators.dart';
import 'package:instapay/widgets/custom_button.dart';
import 'package:instapay/widgets/custom_input.dart';

class TransferWalletScreen extends StatefulWidget {
  const TransferWalletScreen({Key? key}) : super(key: key);

  @override
  State<TransferWalletScreen> createState() => _TransferWalletScreenState();
}

class _TransferWalletScreenState extends State<TransferWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedWalletProvider;
  bool _isTransferring = false;

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
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _transferToWallet() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWalletProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wallet provider'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      final success = await userProvider.transferToWallet(
        _mobileNumberController.text.trim(),
        amount,
        _descriptionController.text.trim(),
      );

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          'Successfully transferred ${Helpers.formatCurrency(amount)} to ${_mobileNumberController.text} (${_selectedWalletProvider})',
        );

        // Clear form
        _mobileNumberController.clear();
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedWalletProvider = null;
        });
      } else if (mounted) {
        Helpers.showSnackBar(
          context,
          userProvider.error ?? 'Transfer failed',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Transfer failed: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTransferring = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer to Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatCurrency(userProvider.balance),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transfer Form
              const Text(
                'Transfer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Wallet Provider Dropdown
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

              CustomInput(
                label: 'Mobile Number',
                hint: 'Enter recipient mobile number',
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                validator: Validators.validateMobileNumber,
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Amount',
                hint: 'Enter amount to transfer',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: Validators.validateAmount,
                prefixIcon: const Icon(Icons.attach_money),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Description (Optional)',
                hint: 'Enter transfer description',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: 'Transfer',
                onPressed: _transferToWallet,
                isLoading: _isTransferring,
                backgroundColor: Colors.green,
              ),

              const SizedBox(height: 16),

              // Transfer Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Note:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Transfers to mobile wallets are processed instantly\n'
                          '• Daily transfer limits may apply based on wallet provider\n'
                          '• Make sure the mobile number is registered with the selected wallet provider\n'
                          '• You cannot cancel a transfer once it\'s completed',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
