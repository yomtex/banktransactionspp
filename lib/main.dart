import 'package:bankapp/pages/login.dart';
import 'package:bankapp/pages/mypages.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  GeocodingPlatform.instance = GeocodingPlatform.instance;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}
