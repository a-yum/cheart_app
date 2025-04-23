import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/database/database_helper.dart';
import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/config/cheart_routes.dart';
import 'package:cheart/themes/cheart_theme.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi; // for desktop
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper().database;
  final petDao = PetProfileDAO(db);
  final respDao = RespiratorySessionDAO(db);

  runApp(
    MultiProvider( // toDo: change to constructor injection?
      providers: [
        // 1) Make DAOs available
        Provider<PetProfileDAO>(create: (_) => petDao),
        Provider<RespiratorySessionDAO>(create: (_) => respDao),

        // 2) Inject PetProfileDAO into its ChangeNotifier
        ChangeNotifierProxyProvider<PetProfileDAO, PetProfileProvider>(
          create: (_) => PetProfileProvider(),
          update: (_, dao, provider) => provider!..setDao(dao),
        ),

        // 3) Inject RespiratorySessionDAO into its ChangeNotifier
        ChangeNotifierProxyProvider<RespiratorySessionDAO, RespiratoryRateProvider>(
          create: (_) => RespiratoryRateProvider(),
          update: (_, dao, provider) => provider!..setDao(dao),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CHeart',
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
        theme: CHeartTheme.theme,
      );
}