import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/providers/auth_provider.dart';
import 'package:tote_app/screens/api_diagnostic_screen.dart';
import 'package:tote_app/screens/shopping_list_screen.dart';
import 'package:tote_app/theme/index.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tote'),
        actions: [
          // Diagnostic button
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'API Diagnostics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApiDiagnosticScreen(),
                ),
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              // Navigation will be handled by the auth state listener
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome ${user?.email ?? ""}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'This is your shopping assistant dashboard.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShoppingListScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'New Shopping Trip',
                        style: AppTypography.buttonLarge,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApiDiagnosticScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Check API Connection',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 