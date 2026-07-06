class AppUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String provider;
  final Map<String, dynamic> rawMetadata;

  AppUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.provider,
    required this.rawMetadata,
  });

  factory AppUserModel.fromSupabase(dynamic user, {String? activeProvider}) {
    final meta = user.userMetadata ?? {};
    final fullName = meta['full_name'] ?? meta['name'] ?? user.email?.split('@').first ?? 'User';
    final avatar = meta['avatar_url'] ?? meta['picture'];
    
    // Determine the active provider
    // Order of priority:
    // 1. Explicit activeProvider passed from login session
    // 2. last_login_provider saved in user metadata
    // 3. Most recently logged-in identity from user.identities
    // 4. Primary appMetadata provider
    // 5. Default fallback 'supabase'
    String provider = activeProvider ?? meta['last_login_provider'] ?? user.appMetadata?['provider'] ?? 'supabase';
    try {
      if (activeProvider == null && meta['last_login_provider'] == null) {
        final List<dynamic>? identities = user.identities;
        if (identities != null && identities.isNotEmpty) {
          dynamic latestIdentity;
          DateTime? latestSignIn;
          for (final identity in identities) {
            final lastSignInStr = identity.lastSignInAt;
            if (lastSignInStr != null) {
              final signInTime = DateTime.tryParse(lastSignInStr);
              if (signInTime != null) {
                if (latestSignIn == null || signInTime.isAfter(latestSignIn)) {
                  latestSignIn = signInTime;
                  latestIdentity = identity;
                }
              }
            }
          }
          if (latestIdentity != null) {
            provider = latestIdentity.provider;
          }
        }
      }
    } catch (_) {
      // Fallback to default provider
    }

    return AppUserModel(
      uid: user.id,
      email: user.email ?? '',
      displayName: fullName,
      avatarUrl: avatar,
      provider: provider,
      rawMetadata: meta,
    );
  }
}
