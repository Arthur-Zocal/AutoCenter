import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AppAutoCenter());
    await tester.pump();
  });
}
