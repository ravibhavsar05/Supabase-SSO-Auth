import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase Configurations
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Deep Link Redirection URL
  static final String redirectUrl = dotenv.env['REDIRECT_URL'] ?? 'io.supabase.sso://login-callback/';
}
