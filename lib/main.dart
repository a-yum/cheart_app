import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/database/database_helper.dart';
import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/providers/respiratory_history_provider.dart';
import 'package:cheart/utils/respiratory_constants.dart';
import 'package:cheart/config/cheart_routes.dart';
import 'package:cheart/themes/cheart_theme.dart';

Future<void> main() async {
  // Initialize FFI for sqflite on desktop (or non-mobile) platforms for emulation/testing.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper().database;
  final petDao = PetProfileDAO(db);
  final respDao = RespiratorySessionDAO(db);

  runApp(
    MultiProvider( // TODO: refactor to puew constructor-based injection?
      providers: [
        // Provide data access objects (DAOs) globally for interacting with the database
        Provider<PetProfileDAO>(create: (_) => petDao),
        Provider<RespiratorySessionDAO>(create: (_) => respDao),

        // PetProfileProvider manages pet profile data and depends on PetProfileDAO
        // It is responsible for loading and updating pet profiles.
        ChangeNotifierProxyProvider<PetProfileDAO, PetProfileProvider>(
          create: (_) => PetProfileProvider(),
          update: (_, dao, provider) => provider!
            ..setDao(dao) // Set DAO for PetProfileProvider
            ..loadPetProfiles(), // Load pet profiles once DAO is available
        ),

        // RespiratoryRateProvider handles the respiratory rate data and depends on RespiratorySessionDAO
        // It is responsible for managing and updating respiratory rate information.
        ChangeNotifierProxyProvider<RespiratorySessionDAO, RespiratoryRateProvider>(
          create: (_) => RespiratoryRateProvider(),
          update: (_, dao, provider) => provider!..setDao(dao), // Update the provider with the DAO
        ),

        // RespiratoryHistoryProvider manages historical respiratory data and depends on both:
        // - PetProfileProvider (for the currently selected pet)
        // - RespiratorySessionDAO (for respiratory session data)
        // It reloads respiratory history data whenever the selected pet changes (and is non-null).
        ChangeNotifierProxyProvider2<PetProfileProvider, RespiratorySessionDAO, RespiratoryHistoryProvider>(
          create: (context) => RespiratoryHistoryProvider(
            petId: 0, // Initial dummy pet ID, real value is set during the update phase
            dao: context.read<RespiratorySessionDAO>(), // Inject DAO into provider
            highThreshold: RespiratoryConstants.highBpmThreshold, // Set high BPM threshold for alerts
          ),
          update: (_, petProv, dao, historyProv) {
            final newId = petProv.selectedPetProfile?.id;
            if (newId != null) {
              historyProv!.updatePet(newId); // Update respiratory history when a new pet is selected
            }
            return historyProv!; // Return the updated provider
          },
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
