import 'package:flutter_test/flutter_test.dart';
import 'package:matchcote/round/cotes.dart';

import 'support/coteland.dart';
import 'support/fonts.dart';

/// The coteland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the coteland lists every cote by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Matchcote'), findsOneWidget);
    for (final cote in Cotes.all) {
      expect(find.text(cote.name), findsOneWidget);
      expect(find.textContaining(cote.task), findsOneWidget);
    }
  });

  testWidgets('a cote opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two players to pair them'),
      findsOneWidget,
    );
  });

  testWidgets('a fixture writes its fewest onto the coteland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    await pairAll(tester, const [
      [(0, 1), (2, 3)],
      [(0, 2), (1, 3)],
      [(0, 3), (1, 2)],
    ]);
    await press(tester, 'The cote');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}
