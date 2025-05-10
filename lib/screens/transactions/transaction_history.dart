// lib/screens/transactions/transaction_history.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapay/models/transaction_model.dart';
import 'package:instapay/providers/user_provider.dart';
import 'package:instapay/utils/helpers.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filterType = 'all';
  final List<String> _filterOptions = ['all', 'instapay_transfer', 'bank_transfer', 'wallet_transfer', 'bill_payment'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchTransactions();
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    if (_filterType == 'all') {
      return transactions;
    }
    return transactions.where((transaction) => transaction.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final allTransactions = userProvider.transactions;
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Transactions'),
              ),
              const PopupMenuItem(
                value: 'instapay_transfer',
                child: Text('InstaPay Transfers'),
              ),
              const PopupMenuItem(
                value: 'bank_transfer',
                child: Text('Bank Transfers'),
              ),
              const PopupMenuItem(
                value: 'wallet_transfer',
                child: Text('Wallet Transfers'),
              ),
              const PopupMenuItem(
                value: 'bill_payment',
                child: Text('Bill Payments'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredTransactions.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredTransactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionCard(filteredTransactions[index]);
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
            Icons.history,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _filterType == 'all'
                ? 'No transactions found'
                : 'No ${Helpers.getTransactionTypeLabel(_filterType).toLowerCase()} found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isOutgoing = transaction.type != 'bill_payment' &&
        transaction.receiverUsername != null;

    String title = '';
    String subtitle = '';

    switch (transaction.type) {
      case 'instapay_transfer':
        title = isOutgoing
            ? 'To: ${transaction.receiverUsername}'
            : 'From: ${transaction.senderUsername}';
        subtitle = transaction.description ?? 'InstaPay Transfer';
        break;
      case 'bank_transfer':
        title = 'Bank Transfer';
        subtitle = transaction.receiverBankAccount != null
            ? 'To Account: ${_maskAccountNumber(transaction.receiverBankAccount!)}'
            : 'Bank Transfer';
        break;
      case 'wallet_transfer':
        title = 'Wallet Transfer';
        subtitle = transaction.receiverMobileNumber != null
            ? 'To: ${_maskPhoneNumber(transaction.receiverMobileNumber!)}'
            : 'Wallet Transfer';
        break;
      case 'bill_payment':
        title = 'Bill Payment';
        subtitle = transaction.description ?? 'Bill Payment';
        break;
      default:
        title = 'Transaction';
        subtitle = transaction.description ?? '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Helpers.getTransactionColor(transaction.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTransactionIcon(transaction.type),
                    color: Helpers.getTransactionColor(transaction.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isOutgoing ? '-' : '+'} ${Helpers.formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isOutgoing ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      Helpers.formatDate(transaction.timestamp),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                transaction.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(transaction.status),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'instapay_transfer':
        return Icons.swap_horiz;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'wallet_transfer':
        return Icons.account_balance_wallet;
      case 'bill_payment':
        return Icons.receipt_long;
      default:
        return Icons.payments;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 4) return phoneNumber;
    return '****${phoneNumber.substring(phoneNumber.length - 4)}';
  }
}
