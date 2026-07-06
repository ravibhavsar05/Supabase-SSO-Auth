import 'package:flutter_test/flutter_test.dart';
import 'package:sso/main.dart';
import 'package:sso/routes/app_routes.dart';

void main() {
  testWidgets('App renders Login Screen correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.login));
    await tester.pumpAndSettle();

    // Verify that welcome texts and SSO buttons are displayed
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });
}
