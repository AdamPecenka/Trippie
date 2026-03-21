import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippie_frontend/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // one-time bootstrap: Firebase.initializeApp(), env config, etc.
  runApp(
    ProviderScope(
      child: App(),
    ),
  );
}