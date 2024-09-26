// Define a gradient background with colors similar to the uploaded image

// var backgroundGradient = const BoxDecoration(
//   gradient: LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       Color(0xFF833AB4), // Purple
//       Color(0xFFFD1D1D), // Reddish Pink
//       Color(0xFFF56040), // Orange
//     ],
//   ),
// );

// var backgroundGradient = const BoxDecoration(
//   gradient: LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       Color.fromARGB(255, 174, 233, 198), // Bright Green
//       Color.fromARGB(255, 97, 175, 167), // Teal
//       Color(0xFF00796B), // Dark Teal
//     ],
//   ),
// );

import 'package:flutter/material.dart';

var backgroundGradient = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF004D40), // Dark Green
      Color(0xFF00796B), // Dark Teal
      Color(0xFF004349), // Very Dark Teal
    ],
  ),
);

// var backgroundGradient = const BoxDecoration(
//   gradient: LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       Color(0xFF0D47A1), // Dark Blue
//       Color(0xFF5472D3), // Medium Blue
//       Color(0xFFB0BEC5), // Light Blue/Grey
//       Color(0xFFFFFFFF), // White
//     ],
//   ),
// );
