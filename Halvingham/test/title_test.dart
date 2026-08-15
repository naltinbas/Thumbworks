import 'package:flutter_test/flutter_test.dart';
import 'package:halvingham/ledger/levels.dart';

import 'support/fonts.dart';
import 'support/hamland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every supper by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Halvingham'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a supper opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('Thirteen by Seven'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('The first number is halved'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Thirteen by Seven'));
    await tester.pumpAndSettle();
    await tapAll(tester, [0, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
