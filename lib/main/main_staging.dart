import 'package:flutter/material.dart';
import '../config/flavor_config.dart';
import '../app.dart';

void main() async {
  // Initialize Flutter bindings before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure for staging environment and load .env.staging file
  await FlavorConfig.setFlavor(Flavor.staging);
  
  // Run the shared app widget
  runApp(const MyApp());
}
