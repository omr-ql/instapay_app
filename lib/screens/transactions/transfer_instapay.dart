// lib/screens/transactions/transfer_instapay.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:instapay/providers/user_provider.dart';
import 'package:instapay/utils/helpers.dart';
import 'package:instapay/utils/validators.dart';
import 'package:instapay/widgets/custom_button.dart';
import 'package:instapay/widgets/custom_input.dart';

class TransferInstapayScreen extends StatefulWidget {
  const TransferInstapayScreen({Key? key}) : super(key: key);

  @override
  State<TransferInstapayScreen> createState() => _TransferInstapayScreenState();
}

class _TransferInstapayScreenState extends State<TransferInstapayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isTransferring = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _transferToInstapay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTransferring = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      final success = await userProvider.transferToInstapay(
        _usernameController.text.trim(),
        amount,
        _descriptionController.text.trim(),
      );

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          'Successfully transferred ${Helpers.formatCurrency(amount)} to ${_usernameController.text}',
        );

        // Clear form
        _usernameController.clear();
        _amountController.clear();
        _descriptionController.clear();
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
        title: const Text('Transfer to InstaPay'),
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
                  color: Colors.blue.withOpacity(0.1),
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
                        color: Colors.blue,
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

              CustomInput(
                label: 'Recipient Username',
                hint: 'Enter InstaPay username',
                controller: _usernameController,
                validator: Validators.validateUsername,
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
                onPressed: _transferToInstapay,
                isLoading: _isTransferring,
              ),

              const SizedBox(height: 16),

              // Transfer
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
                      '• Transfers to InstaPay accounts are instant\n'
                          '• Make sure the recipient username is correct\n'
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
