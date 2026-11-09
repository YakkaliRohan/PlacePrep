import 'package:flutter_test/flutter_test.dart';
import 'package:placeprep_frontend/main.dart';

void main() {
  testWidgets('PlacePrep basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlacePrepApp());
    expect(find.byType(PlacePrepApp), findsOneWidget);
  });
}
