import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orderly/components/components/blurred_card.dart';

import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final bool isHighlighted;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;
  final VoidCallback onTap; // This will now open the product stats
  final VoidCallback onStats;

  const ProductTile({
    super.key,
    required this.product,
    required this.isHighlighted,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDelete,
    required this.onTap,
    required this.onStats,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStats, // Updated to open product stats
      child: BlurredCard(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (product.imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(product.imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(Icons.image, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Cost: ₹${product.costPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Selling Price: ₹${product.sellingPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Color.fromARGB(255, 221, 0, 255),
                    ),
                    onPressed: onDecrement,
                  ),
                  Text('${product.quantity}',
                      style: Theme.of(context).textTheme.bodyLarge),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color.fromARGB(255, 0, 255, 9),
                    ),
                    onPressed: onIncrement,
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: onTap, // Opens the product edit screen
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
