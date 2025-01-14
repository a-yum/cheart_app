import 'package:flutter/material.dart';
import 'package:cheart/widgets/navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canine Heart Tracker'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Welcome to Canine Heart Tracker!'), // Placeholder content
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}
