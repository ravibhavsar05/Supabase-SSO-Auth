# Single Sign-On (SSO) Flutter Application with Supabase

A premium-grade Flutter application implementing robust Single Sign-On (SSO) authentication for both **Google** and **Apple** identity providers using **Supabase** backend integration and **GetX** state management.

---

## 🚀 Key Features

*   **Native Apple Sign-In (iOS)**: Leverages native Apple Authorization Controller (`sign_in_with_apple`) for a frictionless FaceID/TouchID prompt (no browser overlays, native cancel handling).
*   **Web OAuth Auth Session (iOS/Android)**: Implements `ASWebAuthenticationSession` on iOS via `flutter_web_auth_2` and Custom Tabs on Android for Google login, ensuring cookie sharing (recent Google accounts) and native cancellation sheet dismissal.
*   **Environment Configs**: Safely extracts URLs and API keys using `flutter_dotenv` to avoid hardcoding secrets.
*   **Automatic Clean Resumes**: Unconditionally cleans up loaders and webviews if the user cancels or dismisses the authentication flow.

---

## 🎬 Demo

Here is a demonstration of the Single Sign-On flow:

![Single Sign-On Demo](sso_login.webp)

*Direct link to high-resolution video file: [sso_login.mp4](sso_login.mp4)*

---

## 🛠️ Prerequisites & Local Configuration

### 1. Configure the Environment
Copy the [.env.example](.env.example) to `.env` in your project root:
```bash
cp .env.example .env
```
Fill in your Supabase variables in the `.env` file:
```env
SUPABASE_URL=https://<your-project-id>.supabase.co
SUPABASE_ANON_KEY=<your-anon-public-key>
REDIRECT_URL=io.supabase.sso://login-callback/
```

> [!WARNING]
> Do NOT commit `.env` to Git. The `.gitignore` has been updated to protect it.

---

## 🖥️ Supabase Console Configurations

To enable Google and Apple SSO, you must configure them in your [Supabase Dashboard](https://supabase.com/dashboard) under **Authentication > Providers**.

### 1. Google Auth Provider Setup
1.  Go to the Google Cloud Console and create a project.
2.  Set up the **OAuth Consent Screen** (select External, fill in app details).
3.  Go to **Credentials** and click **Create Credentials > OAuth client ID**.
    *   Select **Web application** (this client ID is used by Supabase to handle the OAuth backend).
    *   **Authorized redirect URIs**: Copy the callback URL from your Supabase Google Provider dashboard (e.g., `https://<your-project-id>.supabase.co/auth/v1/callback`).
4.  Enter the generated **Client ID** and **Client Secret** into the **Google** configuration inside your Supabase dashboard and toggle it **Enabled**.

### 2. Apple Auth Provider Setup
1.  Go to the [Apple Developer Portal](https://developer.apple.com/).
2.  Enable the **Sign In with Apple** capability on your App ID.
3.  Create an **Apple Private Key** (`.p8`) for Sign in with Apple, and record the **Key ID** and your **Team ID**.
4.  If using Web-based OAuth (fallback/Android/Web):
    *   Create a **Services ID** (e.g., `com.yourcompany.app.signin`).
    *   Configure it with the callback URI provided by Supabase: `https://<your-project-id>.supabase.co/auth/v1/callback`.
5.  In the Supabase Apple Provider settings:
    *   Enter your **Bundle ID** (for native iOS sign-in).
    *   Enter your **Services ID** (for Android/Web fallback).
    *   Upload/paste the **Team ID**, **Key ID**, and the `.p8` private key content.

---

## 🤖 Android Configuration

Android handles deep linking using the Custom Scheme intent filter.

### 1. Android Manifest
The scheme redirect has been registered in your [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) under the `<activity>` tag:
```xml
<intent-filter android:label="supabase_sso_callback">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.sso" android:host="login-callback" />
</intent-filter>
```

---

## 🍏 iOS Configuration

iOS handles deep links and native Apple Sign-in capabilities.

### 1. Info.plist Setup
Ensure your URL Scheme is registered inside [Info.plist](ios/Runner/Info.plist) under `CFBundleURLTypes` to listen to redirects:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.sso</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>http</string>
    <string>https</string>
</array>
```

### 2. Apple Sign-In Entitlements
Ensure your [Runner.entitlements](ios/Runner/Runner.entitlements) file is updated with the capability:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

---

## 🏁 Running the App

Run the following commands in the project directory to clean, resolve dependencies, and launch:

```bash
flutter clean
flutter pub get
flutter run
```
