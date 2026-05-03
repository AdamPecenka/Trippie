import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/core/theme/app_theme.dart';

class ActivitySuccessScreen extends StatefulWidget {
  const ActivitySuccessScreen({super.key, required this.tripId});
  final String tripId;

  @override
  State<ActivitySuccessScreen> createState() => _ActivitySuccessScreenState();
}

class _ActivitySuccessScreenState extends State<ActivitySuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppGradients.backgroundDark
              : AppGradients.background,
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('It\'s on the plan ✅', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Your activity has been added.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}