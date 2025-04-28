// lib/screens/bills/bill_history.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapay/models/bill_model.dart';
import 'package:instapay/providers/bill_provider.dart';
import 'package:instapay/utils/helpers.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBills();
    });
  }

  Future<void> _loadBills() async {
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    await billProvider.fetchBills();
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final bills = billProvider.bills;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill History'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBills,
        child: billProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : bills.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            return _buildBillCard(bills[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No bill history found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your paid bills will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(Bill bill) {
    final isPaid = bill.isPaid;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Helpers.getBillTypeIcon(bill.type),
                      color: _getBillTypeColor(bill.type),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Helpers.getBillTypeLabel(bill.type),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Account Number', bill.accountNumber),
            _buildInfoRow('Customer Name', bill.customerName),
            _buildInfoRow('Amount', Helpers.formatCurrency(bill.amount)),
            _buildInfoRow('Due Date', Helpers.formatDate(bill.dueDate)),
            if (isPaid && bill.paymentDate != null)
              _buildInfoRow('Payment Date', Helpers.formatDate(bill.paymentDate!)),

            const SizedBox(height: 12),

            // Bill Details Expansion
            ExpansionTile(
              title: const Text(
                'Bill Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: [
                ...bill.details.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBillTypeColor(String type) {
    switch (type) {
      case 'gas':
        return Colors.orange;
      case 'electricity':
        return Colors.blue;
      case 'water':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}
