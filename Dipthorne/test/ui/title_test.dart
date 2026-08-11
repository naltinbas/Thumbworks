import 'package:flutter_test/flutter_test.dart';
import 'package:dipthorne/best.dart';
import 'package:dipthorne/ring/rings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dip.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Dipthorne'), findsOne);
    expect(
      find.text('Pick where to stand before the rhyme starts. Last in is '
          'safe.'),
      findsOne,
    );
  });

  testWidgets('lists every ring with its size and its rhyme', (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('8 in the ring, a 2-beat rhyme'), findsOne);
    expect(find.text('10 in the ring, a 7-beat rhyme'), findsOne);
  });

  testWidgets('shows a ring stood safe', (tester) async {
    await open(tester, best: await keeper({'stood.$_first': 0}));
    expect(find.text('stood unasked'), findsOne);
  });

  testWidgets('tapping a ring opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.ring.name, _first);
  });

  testWidgets('writes a survived dip down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await stand(tester, 1);
    await countItOut(tester);
    await tester.pump();

    expect(best.askingsFor(_first), 0);
  });

  testWidgets('and a lost dip writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await stand(tester, 2);
    await countItOut(tester);
    await tester.pump();

    expect(state(tester).play.won, isFalse);
    expect(best.done, 0);
  });
}

String get _first => Rings.at(0).name;
