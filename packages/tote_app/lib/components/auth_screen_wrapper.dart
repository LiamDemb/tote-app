import 'package:flutter/material.dart';
import 'package:tote_app/theme/index.dart';

class AuthScreenWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showAppBar;
  final VoidCallback? onBack;

  const AuthScreenWrapper({
    Key? key,
    required this.child,
    this.title,
    this.showAppBar = false,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null 
                  ? Text(title!, style: AppTypography.titleLarge)
                  : null,
              leading: onBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    )
                  : null,
            )
          : null,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          // Content Container
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                      horizontal: AppSpacing.md,
                    ),
                    child: child,
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