import 'package:flutter_test/flutter_test.dart';
import 'package:shiftwell/rota/rotas.dart';
import 'package:shiftwell/rota/rules.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every rota by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Shiftwell'), findsOneWidget);
    for (final rota in Rotas.all) {
      expect(find.text(rota.name), findsOneWidget);
      expect(
        find.textContaining(rota.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a rota opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Fixed'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a shift to turn its hand up'),
      findsOneWidget,
    );
  });

  testWidgets('a finishing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Fixed'));
    await tester.pumpAndSettle();
    final aim = Rules(4, Rotas.at(3).fixed).landing()!;
    var taps = 0;
    for (final entry in aim.entries) {
      if (Rotas.at(3).fixed.containsKey(entry.key)) continue;
      await setHand(tester, entry.key, entry.value);
      taps += entry.value;
    }
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: $taps'), findsOneWidget);
  });
}
