import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinderplot/best.dart';
import 'package:cinderplot/game/plots.dart';

import '../support/plot.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('lists every plot with its shape and what it asks for',
      (tester) async {
    await open(tester);
    for (final plot in Plots.all) {
      expect(find.text(plot.name), findsOne);
      expect(
        find.text('${plot.about} · ${plot.across}×${plot.down}, '
            '${plot.mines} mines'),
        findsOne,
      );
    }
    expect(find.text('${Plots.count} plots'), findsOne);
  });

  testWidgets('shows the quickest time on a plot that has been cleared',
      (tester) async {
    await open(
      tester,
      best: await keeper({
        'best.The commons': 214,
        'cleared.The commons': 3,
      }),
    );
    expect(find.text('3:34'), findsOne);
    expect(find.text('3 cleared'), findsOne);
  });

  testWidgets('writes down a clear, once the board is actually cleared',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.cleared, 0);

    while (!state(tester).play.isOver) {
      await press(tester, 'Why?');
      await press(tester, 'Do it');
    }
    await tester.pump();

    expect(best.clearedOn('The paddock'), 1);
    expect(best.secondsFor('The paddock'), isNotNull);
  });

  testWidgets('and a board that went up writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await tapSquare(tester, aMine(tester));
    await tester.pump();

    expect(best.cleared, 0);
  });
}
