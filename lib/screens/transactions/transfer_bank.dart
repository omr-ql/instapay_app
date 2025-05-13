// lib/screens/transactions/transfer_bank.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:instapay/providers/user_provider.dart';
import 'package:instapay/utils/helpers.dart';
import 'package:instapay/utils/validators.dart';
import 'package:instapay/widgets/custom_button.dart';
import 'package:instapay/widgets/custom_input.dart';

class TransferBankScreen extends StatefulWidget {
  const TransferBankScreen({Key? key}) : super(key: key);

  @override
  State<TransferBankScreen> createState() => _TransferBankScreenState();
}

class _TransferBankScreenState extends State<TransferBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedBank;
  bool _isTransferring = false;
  bool _isVerifying = false;

  // List of banks available for transfer
  final List<String> _banks = [
    'Credit Agricole Bank',
    'CIB',
    'National Bank of Egypt',
    'HSBC',
    'Banque Misr',
    'QNB',
    'Bank of Alexandria',
    'Arab African International Bank',
  ];

  @override
  void dispose() {
    _bankAccountController.dispose();
    _accountNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _verifyBankAccount() async {
    if (_bankAccountController.text.isEmpty || _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter bank account number and select a bank'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // In a real app, this would make an API call to verify the bank account
    // For now, we'll simulate a verification process with a delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a successful verification
    setState(() {
      _isVerifying = false;
      _accountNameController.text = "John Doe"; // This would come from the API
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bank account verified successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _transferToBank() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify the bank account first'),
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

      final success = await userProvider.transferToBank(
        _bankAccountController.text.trim(),
        amount,
        _descriptionController.text.trim(),
      );

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          'Successfully transferred ${Helpers.formatCurrency(amount)} to ${_accountNameController.text} (${_selectedBank})',
        );

        // Clear form
        _bankAccountController.clear();
        _accountNameController.clear();
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedBank = null;
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
        title: const Text('Transfer to Bank Account'),
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
                  color: Colors.purple.withOpacity(0.1),
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
                        color: Colors.purple,
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

              // Bank Selection Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bank',
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
                      prefixIcon: const Icon(Icons.account_balance),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    hint: const Text('Select bank'),
                    value: _selectedBank,
                    items: _banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBank = value;
                        _accountNameController.clear(); // Clear account name when bank changes
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bank Account Number with Verify Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomInput(
                      label: 'Bank Account Number',
                      hint: 'Enter bank account number',
                      controller: _bankAccountController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateBankAccount,
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyBankAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Verify'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Account Name (Read Only)
              CustomInput(
                label: 'Account Name',
                hint: 'Account name will appear after verification',
                controller: _accountNameController,
                readOnly: true,
                prefixIcon: const Icon(Icons.person),
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
                onPressed: _transferToBank,
                isLoading: _isTransferring,
                backgroundColor: Colors.purple,
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
                      '• Bank transfers may take 1-3 business days to process\n'
                          '• Make sure the account details are correct before proceeding\n'
                          '• Transfer fees may apply depending on the bank\n'
                          '• You cannot cancel a transfer once it\'s initiated',
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
