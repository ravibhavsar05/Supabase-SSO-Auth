import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/values/constants.dart';
import '../../routes/app_routes.dart';
import '../models/user_model.dart';

class AuthService
    extends
        GetxService
    with
        WidgetsBindingObserver {
  final Rxn<
    AppUserModel
  >
  currentUser =
      Rxn<
        AppUserModel
      >();
  final RxBool isLoading = true.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isAppleLoading = false.obs;
  String? _activeProvider;

  AppUserModel? get user => currentUser.value;
  bool get isAuthenticated =>
      user !=
      null;

  StreamSubscription<
    AuthState
  >?
  _authSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(
      this,
    );
    _initSupabaseAuth();
  }

  void _initSupabaseAuth() {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      if (session !=
          null) {
        currentUser.value = AppUserModel.fromSupabase(
          session.user,
        );
      }
      isLoading.value = false;

      // Listen to Supabase Auth State changes
      _authSubscription = client.auth.onAuthStateChange.listen(
        (
          data,
        ) {
          final event = data.event;
          final user = data.session?.user;

          if (user !=
              null) {
            if (event == AuthChangeEvent.signedIn && _activeProvider != null) {
              final providerToUpdate = _activeProvider!;
              _activeProvider = null;
              
              // Persist last_login_provider in Supabase user metadata
              _updateLastLoginProvider(client.auth, providerToUpdate);

              currentUser.value = AppUserModel.fromSupabase(
                user,
                activeProvider: providerToUpdate,
              );
            } else {
              currentUser.value = AppUserModel.fromSupabase(
                user,
              );
            }
          } else {
            currentUser.value = null;
          }

          if (event ==
                  AuthChangeEvent.signedIn ||
              event ==
                  AuthChangeEvent.signedOut) {
            isLoading.value = false;
            isGoogleLoading.value = false;
            isAppleLoading.value = false;

            if (event ==
                AuthChangeEvent.signedIn) {
              closeInAppWebView().catchError(
                (
                  e,
                ) {
                  debugPrint(
                    'Error closing webview: $e',
                  );
                },
              );
            }
            Get.offAllNamed(
              event ==
                      AuthChangeEvent.signedIn
                  ? AppRoutes.home
                  : AppRoutes.login,
            );
          }
        },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error initializing Supabase Auth: $e',
      );
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );
    _authSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state ==
        AppLifecycleState.resumed) {
      Future.delayed(
        const Duration(
          seconds: 1,
        ),
        () {
          isLoading.value = false;
          isGoogleLoading.value = false;
          isAppleLoading.value = false;
          closeInAppWebView().catchError(
            (
              e,
            ) {
              debugPrint(
                'Error closing webview on resume: $e',
              );
            },
          );
        },
      );
    }
  }

  Future<
    void
  >
  signInWithOAuth(
    OAuthProvider provider,
  ) async {
    isLoading.value = true;
    _activeProvider = provider.name;
    if (provider ==
        OAuthProvider.google) {
      isGoogleLoading.value = true;
    } else if (provider ==
        OAuthProvider.apple) {
      isAppleLoading.value = true;
    }

    try {
      if (GetPlatform.isIOS &&
          provider ==
              OAuthProvider.apple) {
        // Native Apple Sign-In on iOS (uses native authorization sheet, no browser, closes cleanly)
        final rawNonce = Supabase.instance.client.auth.generateRawNonce();
        final hashedNonce = sha256
            .convert(
              utf8.encode(
                rawNonce,
              ),
            )
            .toString();

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        );

        final idToken = credential.identityToken;
        if (idToken ==
            null) {
          throw const AuthException(
            'Could not find ID token from Apple credential.',
          );
        }

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        );
      } else if (GetPlatform.isIOS ||
          GetPlatform.isAndroid) {
        // Use flutter_web_auth_2 for Google OAuth on iOS and Android to get a clean ASWebAuthenticationSession / Custom Tab
        // that handles cancellation and redirects natively and enforces an ephemeral session to prevent caching accounts.
        final res = await Supabase.instance.client.auth.getOAuthSignInUrl(
          provider: provider,
          redirectTo: AppConstants.redirectUrl,
          queryParams:
              provider ==
                  OAuthProvider.google
              ? {
                  'prompt': 'select_account',
                }
              : null,
        );

        final callbackUrl = await FlutterWebAuth2.authenticate(
          url: res.url,
          callbackUrlScheme: 'io.supabase.sso',
          options: const FlutterWebAuth2Options(
            preferEphemeral: false,
          ),
        );

        final uri = Uri.parse(
          callbackUrl,
        );
        await Supabase.instance.client.auth.getSessionFromUrl(
          uri,
        );
      } else {
        // Fallback for other platforms
        await Supabase.instance.client.auth.signInWithOAuth(
          provider,
          redirectTo: AppConstants.redirectUrl,
          authScreenLaunchMode: LaunchMode.inAppWebView,
          queryParams:
              provider ==
                  OAuthProvider.google
              ? {
                  'prompt': 'select_account',
                }
              : null,
        );
      }
    } catch (
      e
    ) {
      isLoading.value = false;
      isGoogleLoading.value = false;
      isAppleLoading.value = false;

      final errorMsg = e.toString();
      if (!errorMsg.contains(
            'canceled',
          ) &&
          !errorMsg.contains(
            'cancelled',
          ) &&
          !errorMsg.contains(
            'NoWindow',
          )) {
        Get.snackbar(
          'SSO Error',
          'Failed ${provider.name.capitalizeFirst} SSO: $errorMsg',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<
    void
  >
  signOut() async {
    isLoading.value = true;
    try {
      await Supabase.instance.client.auth.signOut();
      currentUser.value = null;
      isLoading.value = false;
      isGoogleLoading.value = false;
      isAppleLoading.value = false;
    } catch (
      e
    ) {
      isLoading.value = false;
      isGoogleLoading.value = false;
      isAppleLoading.value = false;
      Get.snackbar(
        'Sign Out Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updateLastLoginProvider(GoTrueClient authClient, String provider) async {
    try {
      await authClient.updateUser(
        UserAttributes(
          data: {'last_login_provider': provider},
        ),
      );
    } catch (e) {
      debugPrint('Error updating user metadata: $e');
    }
  }
}
