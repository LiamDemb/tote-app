import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tote_app/components/auth_screen_wrapper.dart';
import 'package:tote_app/providers/auth_provider.dart';
import 'package:tote_app/components/auth_text_field.dart';
import 'package:tote_app/theme/index.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailError = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _errorMessage = null;
      _isEmailError = false;
    });
  }

  Future<void> _handleResetPassword() async {
    _clearErrors();

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Enter an email address';
        _isEmailError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      // TODO: Implement password reset in auth service
      // For now, we'll simulate a successful reset
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send reset link. Please try again.';
        _isEmailError = true;
      });
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
      title: 'Reset Password',
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isSuccess) ...[
            Text(
              'Forgot Password',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Enter your email address below and we\'ll send you a link to reset your password.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AuthTextField(
              controller: _emailController,
              hintText: 'Enter your email address',
              prefixIcon: Icons.mail_outline_rounded,
              isError: _isEmailError,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              onChanged: (_) => _clearErrors(),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: AppSpacing.md),
              AppTheme.buildErrorMessage(_errorMessage!, context),
            ],
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
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
                      'Reset Password',
                      style: AppTypography.buttonLarge,
                    ),
            ),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Login'),
            ),
          ] else ...[
            // Success state
            Icon(
              Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Check your email',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'We\'ve sent a password reset link to ${_emailController.text}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back to Login',
                style: AppTypography.buttonLarge,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSuccess = false;
                  _emailController.clear();
                });
              },
              child: Text('Try a different email'),
            ),
          ],
        ],
      ),
    );
  }
} 