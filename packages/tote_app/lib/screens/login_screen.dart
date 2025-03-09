import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tote_app/providers/auth_provider.dart';
import 'package:tote_app/screens/signup_screen.dart';
import 'package:tote_app/screens/forgot_password_screen.dart';
import 'package:tote_app/components/auth_screen_wrapper.dart';
import 'package:tote_app/components/auth_text_field.dart';
import 'package:tote_app/theme/index.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailError = false;
  bool _isPasswordError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _errorMessage = null;
      _isEmailError = false;
      _isPasswordError = false;
    });
  }

  Future<void> _handleLogin() async {
    _clearErrors();

    if (_emailController.text.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Enter an email address';
        _isEmailError = true;
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Enter a password';
        _isPasswordError = true;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result.error != null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = result.error;
          if (result.error!.contains('password')) {
            _isPasswordError = true;
          }
          if (result.error!.contains('account') || result.error!.contains('email')) {
            _isEmailError = true;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to:',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Tote',
            style: Theme.of(context).textTheme.displayLarge,
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
          SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            isError: _isPasswordError,
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
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Log in',
                    style: AppTypography.buttonLarge,
                  ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: Text('Forgot Password?'),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.neutral[300]!)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Or continue with',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral[600]!,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.neutral[300]!)),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement Google sign in
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide(color: AppColors.neutral[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/google_logo.svg',
                  height: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Sign in with Google',
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.neutral[900]!,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement Facebook sign in
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/facebook_logo.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Sign in with Facebook',
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to Tote? ',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.neutral[900]!,
                ),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Sign Up',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.neutral[900]!,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 