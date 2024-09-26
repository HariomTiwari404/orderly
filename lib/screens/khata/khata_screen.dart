import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:orderly/components/components/blurred_card.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/customer.dart';

import 'customer_transaction_screen.dart';

class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key});

  @override
  _KhataScreenState createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  List<Customer> _customers = [];
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await DatabaseHelper().fetchCustomers();
      setState(() {
        _customers = customers;
      });
      _calculateTotalBalance(); // Calculate the total balance after loading customers
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  Future<void> _calculateTotalBalance() async {
    double totalBalance = 0.0;
    for (var customer in _customers) {
      final transactions =
          await DatabaseHelper().fetchTransactionsForCustomer(customer.id!);
      double customerBalance = transactions.fold(0, (sum, item) {
        return sum + (item.isCredit ? item.amountPaid : -item.amountPaid);
      });
      totalBalance += customerBalance;
    }
    setState(() {
      _totalBalance = totalBalance;
    });
  }

  void _removeCustomer(Customer customer) async {
    await DatabaseHelper().deleteCustomer(customer.id!);
    await _loadCustomers(); // Reload customers and recalculate balance
  }

  void _viewCustomerKhata(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerTransactionScreen(customer: customer),
      ),
    );
    _calculateTotalBalance(); // Recalculate total balance when returning from transaction screen
  }

  void _addCustomer() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Customer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String name = nameController.text.trim();
                  final String phoneNumber = phoneController.text.trim();

                  if (name.isNotEmpty && phoneNumber.isNotEmpty) {
                    final Customer newCustomer = Customer(
                      name: name,
                      phoneNumber: phoneNumber,
                    );

                    try {
                      await DatabaseHelper().insertCustomer(newCustomer);
                      print('Customer added: $name');
                      await _loadCustomers(); // Reload the customer list
                    } catch (e) {
                      print('Failed to add customer: $e');
                    }

                    Navigator.of(context).pop(); // Close the bottom sheet
                  }
                },
                child: const Text('Add Customer'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
                const SizedBox(
                    height:
                        120), // Adjust this to move content below the AppBar
                BlurredCard(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Balance:',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '₹$_totalBalance',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final customer = _customers[index];
                      return BlurredCard(
                        child: ListTile(
                          title: Text(
                            customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Phone: ${customer.phoneNumber}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => _removeCustomer(customer),
                          ),
                          onTap: () => _viewCustomerKhata(customer),
                        ),
                      );
                    },
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
                      title: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(
                            5.0), // Padding inside the container
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Lottie.network(
                          'https://lottie.host/3bc8e676-45cc-4bf7-981c-93013c67bfe9/Jvit7qIOgL.json',
                          width: 40, // Width of the Lottie animation
                          height: 40, // Height of the Lottie animation
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addCustomer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
