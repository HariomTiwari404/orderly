import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // Adjust the border radius
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur effect
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2), // Semi-transparent color
              borderRadius: BorderRadius.circular(24), // Same radius as above
              border: Border.all(
                  color: Colors.white.withOpacity(0.2), width: 1.0), // Border
            ),
            child: GNav(
              selectedIndex: selectedIndex,
              color: Colors.grey[700],
              activeColor: Colors.grey[700],
              backgroundColor:
                  Colors.transparent, // Transparent background for GNav
              mainAxisAlignment: MainAxisAlignment.center,
              tabBackgroundColor: Colors.grey.shade300
                  .withOpacity(0.3), // Semi-transparent tab background
              onTabChange: onTabChange,
              tabBorderRadius: 24,
              tabActiveBorder: Border.all(color: Colors.black),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5), // Adjust padding to avoid overflow
              tabs: const [
                GButton(icon: Icons.inventory_2, text: "Inventory"),
                GButton(icon: Icons.bar_chart, text: "Statistics"),
                GButton(icon: Icons.book, text: "Khata"),
                GButton(icon: Icons.chat, text: "Contact"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 