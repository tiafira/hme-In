import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_in_mobile/main.dart';

void main() {
  testWidgets('Home-In app renders design system title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HomeInApp()));
    expect(find.text('Home-In'), findsWidgets);
  });
}
