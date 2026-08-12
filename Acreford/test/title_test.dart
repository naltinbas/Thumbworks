import 'package:acreford/acre/fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fieldland.dart';
import 'support/fonts.dart';

/// The fieldland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fieldland lists every field by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Acreford'), findsOneWidget);
    for (final field in Fields.all) {
      expect(find.text(field.name), findsOneWidget);
      expect(
        find.text(
          '${field.task[0].toUpperCase()}${field.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a field opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half Acre'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap post after post'),
      findsOneWidget,
    );
  });

  testWidgets('a fencing writes its fewest onto the fieldland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half Acre'));
    await tester.pumpAndSettle();
    await fence(tester, const [(0, 0), (1, 0), (0, 1)]);
    await press(tester, 'The fields');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
