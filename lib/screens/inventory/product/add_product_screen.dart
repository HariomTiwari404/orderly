import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/product.dart' as models;
import 'package:orderly/models/product.dart';

class AddProductScreen extends StatefulWidget {
  final models.Product? product;
  final int inventoryId;

  const AddProductScreen({super.key, this.product, required this.inventoryId});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitValueController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  String? _selectedUnit = 'none';
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _quantityController.text = widget.product!.quantity.toString();
      _unitValueController.text = widget.product!.unitValue.toString();
      _costPriceController.text = widget.product!.costPrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _selectedUnit = widget.product!.unit;
      _imageFile = File(widget.product!.imagePath);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void _addOrUpdateProduct() async {
    final name = _nameController.text;
    final quantity = int.tryParse(_quantityController.text);
    final unitValue = double.tryParse(_unitValueController.text);
    final costPrice = double.tryParse(_costPriceController.text);
    final sellingPrice = double.tryParse(_sellingPriceController.text);

    if (name.isNotEmpty &&
        quantity != null &&
        unitValue != null &&
        costPrice != null &&
        sellingPrice != null &&
        _imageFile != null) {
      final initialInvestment = costPrice * quantity;

      final models.Product product = models.Product(
        id: widget.product?.id,
        name: name,
        imagePath: _imageFile!.path,
        quantity: quantity,
        unitValue: unitValue,
        unit: _selectedUnit ?? 'none',
        costPrice: costPrice,
        sellingPrice: sellingPrice,
        lastUpdated: DateTime.now(),
        inventoryId: widget.inventoryId,
        investmentHistory: [
          InvestmentRecord(
            date: DateTime.now(),
            amount: initialInvestment,
          )
        ],
      );

      if (widget.product == null) {
        await DatabaseHelper().insertProduct(product);
      } else {
        await DatabaseHelper().updateProduct(product);
      }

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: backgroundGradient, // Use your background here
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                              height: 120), // Space for custom AppBar
                          _buildTextField(_nameController, 'Product Name'),
                          const SizedBox(height: 10),
                          _buildTextField(_quantityController, 'Quantity',
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 10),
                          _buildTextField(_unitValueController, 'Unit Value',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white24,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUnit = newValue;
                              });
                            },
                            items: <String>[
                              'kg',
                              'box',
                              'dz',
                              'g',
                              'in',
                              'lb',
                              'mg',
                              'ml',
                              'm',
                              'pcs',
                              'cm',
                              'none',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(_costPriceController, 'Cost Price',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                          const SizedBox(height: 10),
                          _buildTextField(
                              _sellingPriceController, 'Selling Price',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                          const SizedBox(height: 20),
                          if (_imageFile != null) // Preview selected image
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera),
                                label: const Text('Take Picture'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo),
                                label: const Text('Pick from Gallery'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _addOrUpdateProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(widget.product == null
                        ? 'Add Product'
                        : 'Update Product'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 0, // Adjust as needed for status bar height
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.product == null
                                ? 'Add Product'
                                : 'Edit Product',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
