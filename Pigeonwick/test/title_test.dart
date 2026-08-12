import 'package:flutter_test/flutter_test.dart';
import 'package:pigeonwick/post/rounds.dart';

import 'support/fonts.dart';
import 'support/wick.dart';

/// The wick, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the wick lists every round by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Pigeonwick'), findsOneWidget);
    for (final round in Rounds.all) {
      expect(find.text(round.name), findsOneWidget);
      expect(find.textContaining(round.task), findsOneWidget);
    }
  });

  testWidgets('a round opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Forty-Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a letter, then a hole'),
      findsOneWidget,
    );
  });

  testWidgets('a posting writes its fewest onto the wick',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Away'));
    await tester.pumpAndSettle();
    await postAll(tester, const [1, 2, 0]);
    await press(tester, 'The wick');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
