import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orderly/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final bool isHighlighted;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.isHighlighted,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDelete,
    required this.onTap,
    required void Function() onStats,
  });

  @override
  Widget build(BuildContext context) {
    final borderGlow = isHighlighted
        ? const BorderSide(
            color: Colors.yellow,
            width: 3,
            style: BorderStyle.solid,
          )
        : const BorderSide(
            color: Colors.transparent,
          );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        side: borderGlow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: product.imagePath.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(product.imagePath),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.image, size: 60),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Quantity: ${product.quantity}',
          style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onDecrement,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.red,
              ),
              child: const Icon(Icons.remove, color: Colors.white),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onIncrement,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.green,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
