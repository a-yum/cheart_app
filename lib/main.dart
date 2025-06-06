import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/config/cheart_routes.dart';
import 'package:cheart/database/database_helper.dart';
import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_session_provider.dart';
import 'package:cheart/providers/respiratory_history_provider.dart';
import 'package:cheart/providers/pet_landing_provider.dart';
import 'package:cheart/services/csv_export_service.dart';
import 'package:cheart/services/xml_export_service.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/utils/respiratory_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit(); // for non-mobile emulating/testing
    databaseFactory = databaseFactoryFfi;
  }

  final db = await DatabaseHelper().database;
  final petDao = PetProfileDAO(db);
  final respDao = RespiratorySessionDAO(db);

  runApp(
    MultiProvider(
      providers: [
        // Provide data access objects (DAOs) globally for interacting with the database
        Provider<PetProfileDAO>(create: (_) => petDao),
        Provider<RespiratorySessionDAO>(create: (_) => respDao),

        Provider<CsvExportService>(
          create: (ctx) => CsvExportService(ctx.read<RespiratorySessionDAO>()),
        ),

        Provider<XmlExportService>(
          create: (context) => XmlExportService(
            context.read<RespiratorySessionDAO>(),
          ),
        ),

        // PetProfileProvider manages pet profile data and depends on PetProfileDAO
        // Responsible for loading and updating pet profiles.
        ChangeNotifierProxyProvider<PetProfileDAO, PetProfileProvider>(
          create: (_) => PetProfileProvider(),
          update: (_, dao, provider) => provider!
            ..setDao(dao) // Set DAO for PetProfileProvider
            ..loadPetProfiles(), // Load pet profiles once DAO is available
        ),

        // RespiratoryRateProvider handles the respiratory rate data and depends on RespiratorySessionDAO
        // Responsible for managing and updating respiratory rate information.
        ChangeNotifierProxyProvider<RespiratorySessionDAO, RespiratoryRateProvider>(
          create: (_) => RespiratoryRateProvider(),
          update: (_, dao, provider) => provider!..setDao(dao), // Update the provider with the DAO
        ),

        // RespiratoryHistoryProvider manages historical respiratory data and depends on both:
        // - PetProfileProvider (for the currently selected pet)
        // - RespiratorySessionDAO (for respiratory session data)
        // Reloads respiratory history data whenever the selected pet changes (and is non-null).
        ChangeNotifierProxyProvider2<PetProfileProvider, RespiratorySessionDAO, RespiratoryHistoryProvider>(
          create: (context) => RespiratoryHistoryProvider(
            petId: 0, // Initial dummy pet ID; real value is set during update
            dao: context.read<RespiratorySessionDAO>(), // Inject DAO into provider
            highThreshold: RespiratoryConstants.highBpmThreshold, // Set high BPM threshold for alerts
          ),
          update: (_, petProv, dao, historyProv) {
            final selectedPet = petProv.selectedPetProfile;
            if (selectedPet != null && selectedPet.id != null) {
              historyProv!.updatePet(selectedPet.id!); // Use non-nullable id
            }
            return historyProv!;
          },
        ),

        // PetLandingProvider supplies “Most Recent”, “Today’s Avg + Δ”, and “Current Streak”
        // Depends on:
        // - PetProfileProvider (to know which pet is selected)
        // - RespiratorySessionDAO (for raw session queries)
        // Reloads landing‐screen stats whenever the selected pet changes (and is non-null).
        ChangeNotifierProxyProvider2<PetProfileProvider, RespiratorySessionDAO, PetLandingProvider>(
          create: (context) {
            // Create with dummy petId; will be overridden in update().
            final dao = context.read<RespiratorySessionDAO>();
            return PetLandingProvider(sessionDao: dao, petId: 0);
          },
          update: (_, petProv, dao, landingProv) {
            final selectedPet = petProv.selectedPetProfile;
            if (selectedPet != null && selectedPet.id != null) {
              final id = selectedPet.id!;
              landingProv!..petId = id;
              landingProv.loadAll(); // Fetch “Most Recent”, “Today’s Avg”, and “Streak”
            }
            return landingProv!;
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
