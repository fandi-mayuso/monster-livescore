import 'package:flutter/material.dart';
import '../config/flavor_config.dart';
import '../app.dart';

void main() async {
  // Initialize Flutter bindings before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure for dev environment and load .env.dev file
  await FlavorConfig.setFlavor(Flavor.dev);
  
  // Run the shared app widget
  runApp(const MyApp());
}
