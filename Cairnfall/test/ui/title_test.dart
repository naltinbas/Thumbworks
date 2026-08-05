import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cairnfall/best.dart';
import 'package:cairnfall/stones/rounds.dart';

import '../support/table.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many rounds there are', (tester) async {
    await open(tester);
    expect(find.text('${Rounds.count} rounds'), findsOne);
  });

  testWidgets('and how many have been won', (tester) async {
    await open(tester, best: await keeper({'won.Two heaps': 2}));
    expect(find.text('1 of ${Rounds.count} won'), findsOne);
  });

  testWidgets('writes down a round, once it is actually won', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.won, 0);

    await playItOut(tester);
    await tester.pump();

    expect(state(tester).play.won, isNotNull);
    expect(best.has('Two heaps'), isTrue);
    expect(best.isClean('Two heaps'), isTrue,
        reason: 'played by the arithmetic, nothing was given away');
  });

  testWidgets('and a round walked out of writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await takeFrom(tester, 0, 1);
    await tester.pump();

    expect(best.won, 0);
  });
}
