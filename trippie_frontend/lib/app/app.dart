import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trippie',
      // theme: AppTheme.light,
      // darkTheme: AppTheme.dark,
      // routerConfig: AppRouter.config,
    );
  }
}