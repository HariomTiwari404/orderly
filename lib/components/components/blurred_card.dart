import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigmaX;
  final double blurSigmaY;
  final double opacity;
  final Color color;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const BlurredCard({
    super.key,
    required this.child,
    this.borderRadius = 10.0,
    this.blurSigmaX = 10.0,
    this.blurSigmaY = 10.0,
    this.opacity = 0.2,
    this.color = Colors.black,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, // Apply margin around the card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(opacity),
                width: borderWidth,
              ),
            ),
            padding: padding, // Apply padding inside the card
            child: DefaultTextStyle(
              style: const TextStyle(
                  color: Colors.white), // Set text color to white
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
