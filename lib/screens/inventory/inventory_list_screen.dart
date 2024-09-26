import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lottie/lottie.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/inventory.dart';
import 'package:orderly/screens/inventory/product/product_list_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  _InventoryListScreenState createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  List<Inventory> _inventories = [];

  @override
  void initState() {
    super.initState();
    _loadInventories();
  }

  Future<void> _loadInventories() async {
    final inventories = await DatabaseHelper().fetchInventories();
    setState(() {
      _inventories = inventories;
    });
  }

  void _navigateToProductList(Inventory inventory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(inventory: inventory),
      ),
    ).then((_) => _loadInventories());
  }

  void _deleteInventory(Inventory inventory) async {
    await DatabaseHelper().deleteInventory(inventory.id!);
    setState(() {
      _inventories.remove(inventory);
    });
  }

  void _showAddInventoryDialog({Inventory? inventory}) {
    final TextEditingController nameController = TextEditingController(
      text: inventory != null ? inventory.name : '',
    );
    Color pickerColor = inventory != null
        ? Color(inventory.color)
        : const Color(0xFF00796B); // Default color

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(inventory == null ? 'Add Inventory' : 'Edit Inventory'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Color.fromARGB(
                        255, 0, 0, 0), // Change the text color here
                    fontSize: 16, // Optional: change the font size
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Inventory Name',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Pick a color for the inventory:'),
                BlockPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    pickerColor = color;
                  },
                ),
              ],
            ),
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
                final name = nameController.text;
                if (name.isNotEmpty) {
                  final newInventory = Inventory(
                    id: inventory?.id,
                    name: name,
                    color: pickerColor.value,
                  );

                  if (inventory == null) {
                    await DatabaseHelper().insertInventory(newInventory);
                  } else {
                    await DatabaseHelper().updateInventory(newInventory);
                  }

                  Navigator.of(context).pop();
                  _loadInventories();
                }
              },
              child: Text(inventory == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Inventory inventory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Inventory'),
          content:
              const Text('Are you sure you want to delete this inventory?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ), // <-- Added closing parenthesis here
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteInventory(inventory);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
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
            decoration: backgroundGradient,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 5,
                ),
                itemCount: _inventories.length,
                itemBuilder: (context, index) {
                  final inventory = _inventories[index];
                  return GestureDetector(
                    onLongPress: () => _showDeleteConfirmation(inventory),
                    onTap: () => _navigateToProductList(inventory),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(inventory.color),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                inventory.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white70),
                                onPressed: () => _showAddInventoryDialog(
                                    inventory: inventory), // Edit functionality
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 5, // Give some space from the top
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Curve only the AppBar
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Lottie.network(
                          'https://lottie.host/b9ae347d-84a0-4989-a940-1a9c17e28152/jwrTrcGvBG.json',
                          width: 60,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddInventoryDialog(),
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
