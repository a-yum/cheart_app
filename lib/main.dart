import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/database/database_helper.dart';
import 'package:cheart/config/cheart_routes.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';

Future<void> main() async {
  databaseFactory = databaseFactoryFfi; // toDo: for running app on linux/desktop
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = await DatabaseHelper().database;
  final respDao = RespiratorySessionDAO(db);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PetProfileProvider()),

        // 1) Make DAO available:
        Provider<RespiratorySessionDAO>(
          create: (_) => RespiratorySessionDAO(db),
        ),

        // 2) Create ChangeNotifier and inject DAO into it
        ChangeNotifierProvider<RespiratoryRateProvider>(
          create: (_) => RespiratoryRateProvider(),
        ),

        ChangeNotifierProxyProvider<RespiratorySessionDAO, RespiratoryRateProvider>(
          create: (_) => RespiratoryRateProvider(),
          update: (_, dao, prev) => prev!..setDao(dao),
        ),
      ],
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
