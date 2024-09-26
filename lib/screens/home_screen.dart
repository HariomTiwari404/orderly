import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:orderly/screens/inventory/inventory_list_screen.dart';
import 'package:orderly/screens/inventory/inventory_search_delegate.dart';
import 'package:orderly/screens/khata/khata_screen.dart';
import 'package:orderly/screens/statistics/statistics_screen.dart';
import 'package:orderly/services/auth/auth_gate.dart';
import 'package:orderly/voice_assistant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final VoiceAssistant _voiceAssistant = VoiceAssistant();
  Offset _fabPosition = const Offset(100, 500); // Initial FAB position

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _voiceAssistant.stop(); // Stop any ongoing TTS or STT
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMicButtonPressed() {
    _voiceAssistant
        .reset(); // Reset the voice assistant when the button is pressed
    _voiceAssistant.startListening(); // Start listening again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF004D40), // Dark Green
                Color(0xFF00796B), // Dark Teal
                Color(0xFF004349), // Very Dark Teal// Dark Blue
              ],
            ),
          ),
          child: AppBar(
            backgroundColor:
                Colors.transparent, // Set background to transparent
            centerTitle: true,
            title: const Text(
              'Orderly',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), fontSize: 40),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: InventorySearchDelegate(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              InventoryListScreen(), // Inventory screen
              StatisticsScreen(), // Statistics screen
              KhataScreen(), // Khata screen
              AuthGate(), // Contact screen (authentication gate)
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 6, sigmaY: 6), // Further reduced blur
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1.0),
                  ),
                  child: GNav(
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
                    gap: 8, // Adjust gap between icons
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5), // Reduce icon padding
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
          ),
          // Draggable Floating Action Button
          Positioned(
            left: _fabPosition.dx,
            top: _fabPosition.dy,
            child: Draggable(
              feedback: Material(
                color: Colors.transparent,
                child: FloatingActionButton(
                  onPressed: _onMicButtonPressed,
                  backgroundColor: const Color(0xFF00796B), // Dark Teal color
                  child: const Icon(Icons.mic),
                ),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _fabPosition = details.offset;
                });
              },
              child: FloatingActionButton(
                onPressed: _onMicButtonPressed,
                backgroundColor: const Color(0xFF00796B), // Dark Teal color
                child: const Icon(Icons.mic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
