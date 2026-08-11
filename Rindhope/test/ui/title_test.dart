import 'package:flutter_test/flutter_test.dart';
import 'package:rindhope/best.dart';
import 'package:rindhope/cheese/blocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/cheese.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Rindhope'), findsOne);
    expect(
      find.text('Bite the cheese and leave the grey mouse the mouldy '
          'crumb.'),
      findsOne,
    );
  });

  testWidgets('lists every block, and labels the one that cannot be won',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('5 by 2 crumbs, the win in 5'), findsOne);
    expect(find.textContaining('it cannot be beaten'), findsOne);
  });

  testWidgets('shows what a block has been won in', (tester) async {
    await open(tester, best: await keeper({'eaten.$_first': 5}));
    expect(find.text('won in 5'), findsOne);
  });

  testWidgets('tapping a block opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.block.name, _first);
  });

  testWidgets('writes a won block down', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await winItAll(tester);
    await tester.pump();

    expect(best.bitesFor(_first), Blocks.at(0).fewest);
  });

  testWidgets('and a lost block writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await bite(tester, 0, 0);
    await tester.pump();

    expect(state(tester).play.won, isFalse);
    expect(best.done, 0);
  });
}

String get _first => Blocks.at(0).name;
