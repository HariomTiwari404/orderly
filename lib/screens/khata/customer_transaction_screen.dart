import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/customer.dart';
import 'package:orderly/models/transaction.dart' as app_transaction;

class CustomerTransactionScreen extends StatefulWidget {
  final Customer customer;

  const CustomerTransactionScreen({super.key, required this.customer});

  @override
  _CustomerTransactionScreenState createState() =>
      _CustomerTransactionScreenState();
}

class _CustomerTransactionScreenState extends State<CustomerTransactionScreen> {
  List<app_transaction.Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper()
        .fetchTransactionsForCustomer(widget.customer.id!);
    setState(() {
      _transactions = transactions;
    });
  }

  String _formatDate(String dateStr) {
    final DateTime date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  void _addTransaction(bool isCredit) async {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCredit ? 'Receive Payment' : 'Make Payment'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double amount =
                    double.parse(amountController.text.trim());

                if (amount > 0) {
                  final app_transaction.Transaction newTransaction =
                      app_transaction.Transaction(
                    khataId: widget.customer.id!,
                    productId: 1,
                    amountPaid: amount,
                    remainingAmount: 0,
                    transactionDate: DateTime.now().toIso8601String(),
                    isCredit: isCredit,
                  );

                  await DatabaseHelper().insertTransaction(newTransaction);
                  _loadTransactions(); // Refresh UI
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(app_transaction.Transaction transaction) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          // Apply animation or effect on long press
        });
      },
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(
            transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.isCredit ? Colors.green : Colors.red,
            size: 32,
          ),
          title: Text(
            '₹${transaction.amountPaid}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: transaction.isCredit ? Colors.green : Colors.red,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${_formatDate(transaction.transactionDate)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                'Remaining Amount: ₹${transaction.remainingAmount}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: transaction.isCredit
              ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
              : const Icon(Icons.cancel, color: Colors.red, size: 32),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    double totalBalance = _transactions.fold(
      0,
      (previousValue, transaction) =>
          previousValue +
          (transaction.isCredit
              ? transaction.amountPaid
              : -transaction.amountPaid),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance: ₹$totalBalance',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _transactions.isNotEmpty
                ? 'Last Transaction: ₹${_transactions.last.amountPaid} on ${_formatDate(_transactions.last.transactionDate)}'
                : 'No transactions available.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: backgroundGradient, // Apply the background gradient
            child: Column(
              children: [
                const SizedBox(height: 120), // Space for the custom app bar
                _buildSummary(),
                Expanded(
                  child: _transactions.isNotEmpty
                      ? ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        )
                      : const Center(
                          child: Text(
                            "No transactions available.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 20, // Adjust as needed to position the AppBar correctly
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: SafeArea(
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(
                        'Khata for ${widget.customer.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _addTransaction(true),
            backgroundColor: Colors.green,
            tooltip: 'Receive Payment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _addTransaction(false),
            backgroundColor: Colors.red,
            tooltip: 'Make Payment',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
