import 'package:flutter_test/flutter_test.dart';
import 'package:tablesham/table/parties.dart';

import 'support/fonts.dart';
import 'support/shamland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every party by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Tablesham'), findsOneWidget);
    for (final party in Parties.all) {
      expect(find.text(party.name), findsOneWidget);
      expect(
        find.textContaining(party.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a party opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Couples'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a husband on the bench'),
      findsOneWidget,
    );
  });

  testWidgets('a parting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Couples'));
    await tester.pumpAndSettle();
    await seat(tester, 2, 0);
    await seat(tester, 0, 1);
    await seat(tester, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
