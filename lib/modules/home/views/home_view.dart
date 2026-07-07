import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = controller.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              const SizedBox(height: 16),
              Text(
                'No authenticated user sessions found.',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.logout(),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'SSO Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: () {
                Get.changeThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await controller.logout();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background Gradient Glow (Visual consistency with Login)
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Header section
                  _buildHeader(context, isDark, user),
                  
                  // Tab selection pill container
                  _buildTabSelection(isDark),

                  // Tab View contents
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOverviewTab(context, isDark, user),
                        _ClaimsTab(rawMetadata: user.rawMetadata, isDark: isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.googleBlue.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Get.toNamed(AppRoutes.chat),
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.googleBlue,
                    Colors.purpleAccent,
                    AppColors.googleRed,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppUserModel user) {
    return Column(
      children: [
        // Glowing double-ring avatar stack
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildAvatarRing(isDark, user),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: user.provider == 'google'
                      ? AppColors.googleRed
                      : user.provider == 'apple'
                          ? (isDark ? Colors.white : Colors.black)
                          : AppColors.supabaseGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  user.provider == 'google'
                      ? Icons.g_mobiledata_rounded
                      : user.provider == 'apple'
                          ? Icons.apple_rounded
                          : Icons.security_rounded,
                  size: 16,
                  color: user.provider == 'apple' && isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Welcoming name
        Text(
          user.displayName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Secondary Email text
        Text(
          user.email,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAvatarRing(bool isDark, AppUserModel user) {
    final provider = user.provider.toLowerCase();
    List<Color> gradientColors;

    if (provider == 'google') {
      gradientColors = const [
        AppColors.googleBlue,
        AppColors.googleRed,
        AppColors.googleYellow,
        AppColors.googleGreen,
      ];
    } else if (provider == 'apple') {
      gradientColors = isDark
          ? const [Colors.white, Colors.grey]
          : const [Colors.black, Colors.grey];
    } else {
      gradientColors = const [
        AppColors.supabaseGreen,
        AppColors.success,
      ];
    }

    return Container(
      padding: const EdgeInsets.all(4), // Ring thickness spacing
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: gradientColors,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2), // Outer edge spacing
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : AppColors.bgLight,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 46,
          backgroundColor: AppColors.supabaseGreen.withOpacity(0.1),
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.displayName.isNotEmpty ? user.displayName.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.supabaseGreen,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTabSelection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppColors.supabaseGreen.withOpacity(isDark ? 0.15 : 0.2),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.supabaseGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.supabaseGreen,
        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline_rounded, size: 18),
                SizedBox(width: 8),
                Text('Overview'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code_rounded, size: 18),
                SizedBox(width: 8),
                Text('JWT Claims'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isDark, AppUserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info tiles card list
          _buildInfoTile(
            context: context,
            label: 'Full Name',
            value: user.displayName,
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          _buildInfoTile(
            context: context,
            label: 'Email Address',
            value: user.email,
            icon: Icons.alternate_email_rounded,
            isDark: isDark,
          ),
          _buildInfoTile(
            context: context,
            label: 'User ID (UID)',
            value: user.uid,
            icon: Icons.fingerprint_rounded,
            isDark: isDark,
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: AppColors.supabaseGreen,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: user.uid));
                Get.snackbar(
                  'Copied to Clipboard',
                  'User ID copied successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  colorText: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  borderColor: AppColors.supabaseGreen.withOpacity(0.3),
                  borderWidth: 1,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ),
          _buildInfoTile(
            context: context,
            label: 'Identity Provider',
            value: '${user.provider.toUpperCase()} Single Sign-On',
            icon: Icons.api_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Security Status banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supabase Session Secured',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your access token is valid, verified, and protected by end-to-end encryption.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign Out Button
          OutlinedButton(
            onPressed: () async {
              await controller.logout();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.supabaseGreen.withOpacity(0.08)
                  : AppColors.supabaseGreen.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.supabaseGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class _ClaimsTab extends StatefulWidget {
  final Map<String, dynamic> rawMetadata;
  final bool isDark;

  const _ClaimsTab({
    required this.rawMetadata,
    required this.isDark,
  });

  @override
  State<_ClaimsTab> createState() => _ClaimsTabState();
}

class _ClaimsTabState extends State<_ClaimsTab> {
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    
    // Filter metadata based on search query
    final filteredEntries = widget.rawMetadata.entries.where((entry) {
      final key = entry.key.toLowerCase();
      final val = entry.value.toString().toLowerCase();
      return key.contains(_searchQuery) || val.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Search & Copy Row
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search claims...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      filled: true,
                      fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.supabaseGreen,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: IconButton(
                  tooltip: 'Copy all claims as JSON',
                  icon: const Icon(Icons.copy_all_rounded, size: 20),
                  color: AppColors.supabaseGreen,
                  onPressed: () {
                    final jsonString = const JsonEncoder.withIndent('  ').convert(widget.rawMetadata);
                    Clipboard.setData(ClipboardData(text: jsonString));
                    Get.snackbar(
                      'JSON Copied',
                      'Decoded JWT Claims copied as JSON',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                      colorText: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      borderColor: AppColors.supabaseGreen.withOpacity(0.3),
                      borderWidth: 1,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Claims list
        Expanded(
          child: filteredEntries.isEmpty
              ? Center(
                  child: Text(
                    'No matching claims found',
                    style: TextStyle(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
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
                                fontSize: 12,
                                fontFamily: 'Courier',
                                color: isDark ? AppColors.supabaseGreen : const Color(0xFF0F766E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: SelectionArea(
                              child: Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Courier',
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: entry.value.toString()));
                              Get.snackbar(
                                'Copied Value',
                                '"${entry.key}" claim value copied',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                colorText: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                duration: const Duration(seconds: 1),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
