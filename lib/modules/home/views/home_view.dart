import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView
    extends
        GetView<
          HomeController
        > {
  const HomeView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SSO Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              Get.changeThemeMode(
                isDark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
            ),
            onPressed: () async {
              await controller.logout();
            },
          ),
        ],
      ),
      body:
          user ==
              null
          ? const Center(
              child: Text(
                'No authenticated user sessions found.',
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(
                24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Summary Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        24.0,
                      ),
                      child: Column(
                        children: [
                          // User Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.supabaseGreen.withOpacity(
                                  0.1,
                                ),
                                backgroundImage:
                                    user.avatarUrl !=
                                        null
                                    ? NetworkImage(
                                        user.avatarUrl!,
                                      )
                                    : null,
                                child:
                                    user.avatarUrl ==
                                        null
                                    ? Text(
                                        user.displayName
                                            .substring(
                                              0,
                                              1,
                                            )
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.supabaseGreen,
                                        ),
                                      )
                                    : null,
                              ),
                              // Provider Badge
                              Container(
                                padding: const EdgeInsets.all(
                                  6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      user.provider ==
                                          'google'
                                      ? AppColors.googleRed
                                      : user.provider ==
                                            'apple'
                                      ? (isDark
                                            ? Colors.white
                                            : Colors.black)
                                      : AppColors.supabaseGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  user.provider ==
                                          'google'
                                      ? Icons.g_mobiledata_rounded
                                      : user.provider ==
                                            'apple'
                                      ? Icons.apple_rounded
                                      : Icons.security_rounded,
                                  size: 16,
                                  color:
                                      user.provider ==
                                              'apple' &&
                                          isDark
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // User Name
                          Text(
                            user.displayName,
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          // User Email
                          Text(
                            user.email,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          // Provider Label
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.supabaseGreen.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                              border: Border.all(
                                color: AppColors.supabaseGreen.withOpacity(
                                  0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Authenticated via ${user.provider.toUpperCase()} SSO',
                              style: const TextStyle(
                                color: AppColors.supabaseGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Session & Mode Details Banner
                  Container(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(
                        0.08,
                      ),
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color: AppColors.success.withOpacity(
                          0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Supabase Session Active',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Secure connection established. User ID is ${user.uid}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Decoded JWT Claims Panel
                  Text(
                    'Identity Provider Claims (Decoded Metadata)',
                    style:
                        Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: user.rawMetadata.entries.map(
                          (
                            entry,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        fontFamily: 'Courier',
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Courier',
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Sign Out Button
                  ElevatedButton(
                    onPressed: () async {
                      await controller.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(
                        0.12,
                      ),
                      foregroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        side: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 20,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Sign Out Session',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
