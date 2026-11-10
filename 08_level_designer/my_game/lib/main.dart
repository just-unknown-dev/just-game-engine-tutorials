// My Game — the game, as it ships.
//
// Deliberately does NOT import the editor: keeping it out of this file's
// imports is what keeps it out of a release build (`just check` proves it).
// To author levels, run the editor instead:
//
//     just game run --editor

import 'package:flutter/material.dart';

import 'game/game_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyGameApp());
}

/// The application.
class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My Game',
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Color(0xFF1A1A2E), body: GameApp()),
    );
  }
}
