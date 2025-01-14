import 'package:flutter/material.dart';
import './theme/cheart_theme.dart';
import './screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Health Tracker',
      theme: CheartTheme.theme,
      home: const HomeScreen(),
    );
  }
}
