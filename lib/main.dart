import 'package:flutter/material.dart';
import '/themes/cheart_theme.dart';
import '/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHeart',
      theme: CHeartTheme.theme,
      home: const HomeScreen(),
    );
  }
}
