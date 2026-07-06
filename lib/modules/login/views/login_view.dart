import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: Container(
              color: isDark ? AppColors.bgDark : AppColors.bgLight,
            ),
          ),
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.supabaseGreen.withOpacity(
                      isDark ? 0.08 : 0.05,
                    ),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(isDark ? 0.08 : 0.05),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand / Logo Section
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.supabaseGreen.withOpacity(0.12),
                          border: Border.all(
                            color: AppColors.supabaseGreen.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          size: 52,
                          color: AppColors.supabaseGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your secure dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // SSO Buttons Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Single Sign-On',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select an SSO identity provider',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Google SSO Button
                            Obx(() {
                              final loading = controller.isLoading.value;
                              final googleLoading =
                                  controller.isGoogleLoading.value;
                              return OutlinedButton(
                                onPressed: loading
                                    ? null
                                    : () => controller.loginWithGoogle(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.transparent
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (googleLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.supabaseGreen,
                                              ),
                                        ),
                                      )
                                    else
                                      // Render a clean Custom Painted Google Icon
                                      CustomPaint(
                                        size: const Size(20, 20),
                                        painter: GoogleIconPainter(),
                                      ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),

                            // Apple SSO Button
                            Obx(() {
                              final loading = controller.isLoading.value;
                              final appleLoading =
                                  controller.isAppleLoading.value;
                              return ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () => controller.loginWithApple(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.appleWhite
                                      : AppColors.appleBlack,
                                  foregroundColor: isDark
                                      ? AppColors.appleBlack
                                      : AppColors.appleWhite,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (appleLoading)
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isDark
                                                    ? AppColors.appleBlack
                                                    : AppColors.appleWhite,
                                              ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.apple,
                                        size: 22,
                                        color: isDark
                                            ? AppColors.appleBlack
                                            : AppColors.appleWhite,
                                      ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Apple',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.appleBlack
                                            : AppColors.appleWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Security/Footer Notes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secured by Supabase Guard',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Google colored logo to look crisp and authentic without image assets
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final r = size.width / 2;

    // Draw Google colored segments (G shape path)
    // Red segment
    paint.color = AppColors.googleRed;
    final redPath = Path()
      ..moveTo(r, r)
      ..relativeLineTo(-r * 0.95, -r * 0.3)
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        3.14 + 0.3,
        1.1,
        false,
      )
      ..lineTo(r, r);
    canvas.drawPath(redPath, paint);

    // Yellow segment
    paint.color = AppColors.googleYellow;
    final yellowPath = Path()
      ..moveTo(r, r)
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        3.14 + 1.4,
        1.1,
        true,
      )
      ..lineTo(r, r);
    canvas.drawPath(yellowPath, paint);

    // Green segment
    paint.color = AppColors.googleGreen;
    final greenPath = Path()
      ..moveTo(r, r)
      ..arcTo(Rect.fromCircle(center: Offset(r, r), radius: r), 0.0, 1.2, true)
      ..lineTo(r, r);
    canvas.drawPath(greenPath, paint);

    // Blue segment + horizontal bar
    paint.color = AppColors.googleBlue;
    final bluePath = Path()
      ..moveTo(r, r)
      ..relativeLineTo(r, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        0.0,
        -1.3,
        false,
      )
      ..lineTo(r, r);
    canvas.drawPath(bluePath, paint);

    // Mask for inner circle to make it look like G
    paint.color = Colors.transparent;
    // For simple vector representation, we can just overlay standard G arcs
    // A simplified elegant representation is to draw a thick G path.
    // Let's implement an exact G outline
    final path = Path()
      ..moveTo(size.width * 0.95, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.78, size.height * 0.65)
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r * 0.65),
        0.4,
        1.5,
        false,
      )
      ..close();
    // To ensure exact styling, a simpler and cleaner visual in Flutter is drawing Google's "G" shape.
    // Let's clear and write a simple high fidelity path.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
