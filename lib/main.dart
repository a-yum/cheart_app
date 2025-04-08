import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:cheart/database/database_helper.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/config/cheart_routes.dart';
import 'package:cheart/providers/pet_profile_provider.dart';

Future<void> main() async {
  databaseFactory = databaseFactoryFfi; // toDo: for testing on linux/desktop only
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  
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
