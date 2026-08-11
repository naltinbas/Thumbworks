import 'package:flutter_test/flutter_test.dart';
import 'package:pennygill/best.dart';
import 'package:pennygill/toss/wagers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/toss.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its trick', (tester) async {
    await open(tester);
    expect(find.text('Pennygill'), findsOne);
    expect(
      find.text('Call three flips. The house calls after you, and that is '
          'the whole trick.'),
      findsOne,
    );
  });

  testWidgets('lists every table with its seat', (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.textContaining('the sucker\'s seat'), findsOne);
    expect(find.textContaining('the one table to play'), findsOne);
    expect(find.textContaining('even at last'), findsOne);
  });

  testWidgets('shows a table taken', (tester) async {
    await open(tester, best: await keeper({'won.$_first': 0}));
    expect(find.text('taken, 0 conceded'), findsOne);
  });

  testWidgets('tapping a table opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.wager.name, _first);
  });

  testWidgets('a match left uncalled writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);
  });
}

String get _first => Wagers.at(0).name;
