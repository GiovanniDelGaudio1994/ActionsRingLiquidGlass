import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/concept_dashboard.dart';

// GlassRing Studio — v0.3.0: avvio dell'applicazione.
// main() prepara le risorse native; la grafica è in ui/concept_dashboard.dart.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1585, 992),
      minimumSize: Size(1100, 730),
      center: true,
      title: 'GlassRing Studio',
      backgroundColor: Colors.transparent,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const GlassRingApp());
}

class GlassRingApp extends StatelessWidget {
  const GlassRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlassRing Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2469D9),
          brightness: Brightness.light,
        ),
      ),
      home: const ConceptDashboard(),
    );
  }
}
