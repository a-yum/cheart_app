import 'package:flutter/material.dart';
import 'package:cheart/screens/graph_screen.dart';
import 'package:cheart/screens/home_screen.dart';
import 'package:cheart/screens/pet_landing_screen.dart';
import 'package:cheart/screens/respiratory_rate_screen.dart';
import 'package:cheart/screens/settings_screen.dart';

class AppRoutes {
  static const home = '/';
  static const pet = '/pet';
  static const respiratory = '/respiratory';
  static const graph = '/graph';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    pet: (_) => const PetLandingScreen(),
    respiratory: (_) => const RespiratoryRateScreen(),
    graph: (_) => const GraphScreen(),
    settings: (_) => const SettingsScreen(),
  };
}