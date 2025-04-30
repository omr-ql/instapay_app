// lib/screens/bills/bill_payment.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapay/core/config/constants.dart';
import 'package:instapay/models/bill_model.dart';
import 'package:instapay/providers/bill_provider.dart';
import 'package:instapay/providers/user_provider.dart';
import 'package:instapay/utils/helpers.dart';
import 'package:instapay/widgets/custom_button.dart';
import 'package:instapay/widgets/custom_input.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({Key? key}) : super(key: key);

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();

  String _selectedBillType = AppConstants.electricityType;
  Bill? _billDetails;
  bool _isLoading = false;
  bool _isPaying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchBillDetails() async {
    if (_accountNumberController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an account number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _billDetails = null;
    });

    try {
      final billProvider = Provider.of<BillProvider>(context, listen: false);
      final bill = await billProvider.getBillDetails(
        _accountNumberController.text.trim(),
        _selectedBillType,
      );

      setState(() {
        _billDetails = bill;
        _isLoading = false;
        if (bill == null) {
          _errorMessage = 'No bill found for this account number';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _payBill() async {
    if (_billDetails == null) return;

    setState(() {
      _isPaying = true;
    });

    try {
      final billProvider = Provider.of<BillProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final success = await billProvider.payBill(_billDetails!.id);

      if (success) {
        // Refresh balance
        await userProvider.fetchBalance();

        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Successfully paid ${Helpers.formatCurrency(_billDetails!.amount)} for ${Helpers.getBillTypeLabel(_selectedBillType)}',
          );

          // Reset form
          setState(() {
            _billDetails = null;
            _accountNumberController.clear();
          });
        }
      } else if (mounted) {
        Helpers.showSnackBar(
          context,
          billProvider.error ?? 'Payment failed',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Payment failed: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bills'),
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

              // Bill Type Selection
              const Text(
                'Bill Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildBillTypeButton(
                    AppConstants.electricityType,
                    'Electricity',
                    Icons.electric_bolt,
                  ),
                  const SizedBox(width: 12),
                  _buildBillTypeButton(
                    AppConstants.waterType,
                    'Water',
                    Icons.water_drop,
                  ),
                  const SizedBox(width: 12),
                  _buildBillTypeButton(
                    AppConstants.gasType,
                    'Gas',
                    Icons.local_fire_department,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Account Number Input
              CustomInput(
                label: 'Account Number',
                hint: 'Enter your account number',
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.account_circle),
              ),

              const SizedBox(height: 16),

              // Inquiry Button
              CustomButton(
                text: 'Inquire Bill',
                onPressed: _fetchBillDetails,
                isLoading: _isLoading,
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Bill Details
              if (_billDetails != null) ...[
                const Text(
                  'Bill Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildBillDetailRow(
                        'Bill Type',
                        Helpers.getBillTypeLabel(_billDetails!.type),
                        Helpers.getBillTypeIcon(_billDetails!.type),
                      ),
                      const Divider(),
                      _buildBillDetailRow(
                        'Customer Name',
                        _billDetails!.customerName,
                        Icons.person,
                      ),
                      const Divider(),
                      _buildBillDetailRow(
                        'Account Number',
                        _billDetails!.accountNumber,
                        Icons.account_circle,
                      ),
                      const Divider(),
                      _buildBillDetailRow(
                        'Amount Due',
                        Helpers.formatCurrency(_billDetails!.amount),
                        Icons.attach_money,
                      ),
                      const Divider(),
                      _buildBillDetailRow(
                        'Due Date',
                        Helpers.formatDate(_billDetails!.dueDate),
                        Icons.calendar_today,
                      ),

                      // Bill-specific details
                      if (_billDetails!.details.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Consumption Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._billDetails!.details.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Pay Button
                CustomButton(
                  text: 'Pay Bill',
                  onPressed: _payBill,
                  isLoading: _isPaying,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedBillType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBillType = type;
            _billDetails = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
