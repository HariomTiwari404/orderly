import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/inventory.dart';
import 'package:orderly/models/product.dart';
import 'package:orderly/screens/inventory/product/add_product_screen.dart';
import 'package:orderly/screens/inventory/product/product_statistics_screen.dart';
import 'package:orderly/services/announcement_service.dart';
import 'package:orderly/widgets/product_tile.dart';

class ProductListScreen extends StatefulWidget {
  final Inventory inventory;

  const ProductListScreen({super.key, required this.inventory});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with TickerProviderStateMixin {
  List<Product> _products = [];
  AnnouncementService? _announcementService;
  String _selectedLanguage = "hi-IN"; // Default language set to Hindi
  bool _isAnnouncing = false;
  late AnimationController _animationController;
  late AnimationController _borderAnimationController;
  Product? _currentlyAnnouncedProduct;

  @override
  void initState() {
    super.initState();
    _announcementService =
        AnnouncementService(initialLanguage: _selectedLanguage);
    _announcementService?.initialize();
    _loadProducts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _borderAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper().fetchProducts(widget.inventory.id!);
    setState(() {
      _products = products;
    });
  }

  void _navigateToAddProduct(Product? product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          product: product,
          inventoryId: widget.inventory.id!,
        ),
      ),
    ).then((_) => _loadProducts());
  }

  void _deleteProduct(Product product) async {
    await DatabaseHelper().deleteProduct(product.id!);
    setState(() {
      _products.remove(product);
    });
  }

  void _incrementQuantity(Product product) async {
    final updatedProduct = product.copyWith(
      quantity: product.quantity + 1,
      investmentHistory: [
        ...product.investmentHistory,
        InvestmentRecord(
          date: DateTime.now(),
          amount: product.costPrice,
        ),
      ],
    );
    await DatabaseHelper().updateProduct(updatedProduct);
    _loadProducts();
  }

  void _decrementQuantity(Product product) async {
    if (product.quantity > 0) {
      final updatedProduct = product.copyWith(
        quantity: product.quantity - 1,
        salesHistory: [
          ...product.salesHistory,
          SaleRecord(
            date: DateTime.now(),
            quantitySold: 1,
            sellingPrice: product.sellingPrice,
          ),
        ],
      );
      await DatabaseHelper().updateProduct(updatedProduct);
      _loadProducts();
    }
  }

  void _navigateToProductStats(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductStatisticsScreen(product: product),
      ),
    );
  }

  void _announceAllStock() async {
    setState(() {
      _isAnnouncing = true;
    });
    for (var product in _products) {
      setState(() {
        _currentlyAnnouncedProduct = product;
        _borderAnimationController.forward().then((_) {
          _borderAnimationController.reverse();
        });
      });
      _announcementService?.announceStock(product.name, product.quantity);
      await Future.delayed(const Duration(seconds: 2));
    }
    setState(() {
      _isAnnouncing = false;
      _currentlyAnnouncedProduct = null;
    });
  }

  void _changeLanguage(String? languageCode) {
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = languageCode;
        _announcementService?.setLanguage(_selectedLanguage);
      });
    }
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
              padding: const EdgeInsets.only(
                  top: kToolbarHeight + 20,
                  bottom:
                      60), // Adjust to prevent overlap with AppBar and to add space for the bottom button
              child: _products.isEmpty
                  ? const Center(child: Text('No products available.'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ProductTile(
                          product: product,
                          isHighlighted: product == _currentlyAnnouncedProduct,
                          onDecrement: () => _decrementQuantity(product),
                          onIncrement: () => _incrementQuantity(product),
                          onDelete: () => _deleteProduct(product),
                          onTap: () => _navigateToAddProduct(
                              product), // Opens the product edit screen
                          onStats: () => _navigateToProductStats(product),
                        );
                      },
                    ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 5,
            // Adjust as needed to position the AppBar correctly
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
                        child: Text(
                          widget.inventory.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: _isAnnouncing ? null : _announceAllStock,
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: _selectedLanguage,
                          icon: const Icon(Icons.language,
                              color: Colors.white, size: 28),
                          dropdownColor: Colors.black.withOpacity(
                              0.8), // Dropdown background color to match the theme
                          onChanged: _changeLanguage,
                          items: const [
                            DropdownMenuItem(
                              value: 'hi-IN',
                              child: Text('Hindi',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'en-US',
                              child: Text('English',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'bn-IN',
                              child: Text('Bengali',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Adding a Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.orange, // Button background color
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: InkWell(
                onTap: () =>
                    _navigateToAddProduct(null), // Handle the button press
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Add Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
