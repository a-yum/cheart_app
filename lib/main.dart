import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/config/cheart_routes.dart';
import 'package:cheart/providers/pet_profile_provider.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PetProfileProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHeart',
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      theme: CHeartTheme.theme,
    );
  }
}
