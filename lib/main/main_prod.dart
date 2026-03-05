import 'package:flutter/material.dart';
import '../config/flavor_config.dart';
import '../app.dart';

void main() async {
  // Initialize Flutter bindings before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure for production environment and load .env.prod file
  await FlavorConfig.setFlavor(Flavor.prod);
  
  // Run the shared app widget
  runApp(const MyApp());
}
