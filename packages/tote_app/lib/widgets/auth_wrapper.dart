import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/providers/auth_provider.dart';
import 'package:tote_app/screens/api_diagnostic_screen.dart';
import 'package:tote_app/screens/home_screen.dart';
import 'package:tote_app/screens/login_screen.dart';
import 'package:tote_app/theme/index.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading authentication state'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(authStateProvider);
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApiDiagnosticScreen(),
                    ),
                  );
                },
                child: const Text('Check API Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 