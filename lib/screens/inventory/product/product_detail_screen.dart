// screens/product_detail_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String imagePath;

  const ProductDetailScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Image')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
