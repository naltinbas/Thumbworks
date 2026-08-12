import 'package:flutter_test/flutter_test.dart';
import 'package:chainhurst/chain/fields.dart';

import 'support/fonts.dart';
import 'support/hurst.dart';

/// The hurst, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the hurst lists every field by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Chainhurst'), findsOneWidget);
    for (final field in Fields.all) {
      expect(find.text(field.name), findsOneWidget);
      expect(find.textContaining(field.task), findsOneWidget);
    }
  });

  testWidgets('a field opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap to set or lift: set 4 stones'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the hurst',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Chain'));
    await tester.pumpAndSettle();
    await setAll(tester, const [(1, 1), (2, 2), (3, 3)]);
    await press(tester, 'The hurst');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
