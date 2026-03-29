import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';

void main() {
  // Preserve the native splash until the app signals it is ready.
  // AppStartupGate calls FlutterNativeSplash.remove() once the first frame
  // has been determined (user exists → MainScreen, or new user → WelcomeScreen).
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  tz.initializeTimeZones();
  runApp(const ProviderScope(child: MyApp()));
}
