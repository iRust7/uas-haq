// Widget test untuk Book Library app
//
// Test dasar untuk memverifikasi aplikasi berjalan dengan benar.

import 'package:flutter_test/flutter_test.dart';
import 'package:uas_haq/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());
    
    // Verify SplashScreen is shown (app icon)
    expect(find.text('Book Library'), findsOneWidget);
  });
}
