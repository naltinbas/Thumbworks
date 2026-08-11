import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staplemere/best.dart';
import 'package:staplemere/yard/deals.dart';

import '../support/yard.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Staplemere'), findsOne);
    expect(
      find.text('Pile the wool as it comes, in the fewest piles it takes.'),
      findsOne,
    );
  });

  testWidgets('lists every deal with its size and its number', (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('5 bales, fewest 2'), findsOne);
    expect(find.text('The Nine Tods'), findsOne);
  });

  testWidgets('shows what a deal has been piled in', (tester) async {
    await open(tester, best: await keeper({'piled.$_first': 2}));
    expect(find.text('piled in 2'), findsOne);
  });

  testWidgets('tapping a deal opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.deal.name, _first);
  });

  testWidgets('writes a morning down when the last bale goes down',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await pileItAll(tester);
    await tester.pump();

    expect(best.pilesFor(_first), Deals.at(0).fewest);
  });

  testWidgets('and a worse morning never writes over a better one',
      (tester) async {
    final best = await keeper({'piled.$_first': 2});
    await open(tester, which: 0, best: best);

    // Every bale on the ground: five piles.
    for (var bale = 0; bale < Deals.at(0).many; bale++) {
      await put(tester, state(tester).play.standing);
    }
    await tester.pump();

    expect(best.pilesFor(_first), 2);
  });

  testWidgets('a morning left part played writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await put(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Deals.at(0).name;
