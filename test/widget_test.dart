// Basic Megidai widget test placeholder.
import 'package:flutter_test/flutter_test.dart';
import 'package:megidai/services/app.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MegidaiApp(isBackendOnline: true));
    expect(find.text('Megidai'), findsAny);
  });
}
