import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/pet_landing_screen.dart';
import '/screens/respiratory_rate_screen.dart';
import '/screens/settings_screen.dart';

class AppRoutes {
  static const home = '/';
  static const pet = '/pet';
  static const respiratory = '/respiratory';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    pet: (_) => const PetLandingScreen(),
    respiratory: (_) => const RespiratoryRateScreen(),
    settings: (_) => const SettingsScreen(),
  };
}