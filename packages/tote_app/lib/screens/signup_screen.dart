import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tote_app/providers/auth_provider.dart';
import 'package:tote_app/components/auth_screen_wrapper.dart';
import 'package:tote_app/components/auth_text_field.dart';
import 'package:tote_app/theme/index.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailError = false;
  bool _isPasswordError = false;
  bool _isConfirmPasswordError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _errorMessage = null;
      _isEmailError = false;
      _isPasswordError = false;
      _isConfirmPasswordError = false;
    });
  }

  Future<void> _handleSignup() async {
    _clearErrors();

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Enter an email address';
        _isEmailError = true;
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a password';
        _isPasswordError = true;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
        _isPasswordError = true;
      });
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isConfirmPasswordError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.createUserWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result.error != null) {
        setState(() {
          _errorMessage = result.error;
          if (result.error!.contains('password')) {
            _isPasswordError = true;
          }
          if (result.error!.contains('email')) {
            _isEmailError = true;
          }
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenWrapper(
      showAppBar: false,
      title: 'Create Account',
      onBack: () => Navigator.pop(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Join Tote',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Create your account to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxl),
          AuthTextField(
            controller: _emailController,
            hintText: 'Email',
            prefixIcon: Icons.mail_outline_rounded,
            isError: _isEmailError,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            onChanged: (_) => _clearErrors(),
          ),
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline_rounded,
            isError: _isPasswordError,
            obscureText: true,
            enabled: !_isLoading,
            onChanged: (_) => _clearErrors(),
          ),
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm Password',
            prefixIcon: Icons.lock_outline_rounded,
            isError: _isConfirmPasswordError,
            obscureText: true,
            enabled: !_isLoading,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: AppSpacing.md),
            AppTheme.buildErrorMessage(_errorMessage!, context),
          ],
          SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignup,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(
                    'Sign Up',
                    style: AppTypography.buttonLarge,
                  ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }
} 