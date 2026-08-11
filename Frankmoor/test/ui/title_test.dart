import 'package:flutter_test/flutter_test.dart';
import 'package:frankmoor/best.dart';
import 'package:frankmoor/post/letters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/post.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its counter', (tester) async {
    await open(tester);
    expect(find.text('Frankmoor'), findsOne);
    expect(
      find.text('Two stamps on sale, and the postage must come out to '
          'the penny.'),
      findsOne,
    );
  });

  testWidgets('lists every letter, and labels the unpayable ones',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('24d with 5d and 7d stamps'), findsOne);
    expect(find.textContaining('can never be paid'), findsNWidgets(2));
  });

  testWidgets('shows a letter paid clean', (tester) async {
    await open(tester, best: await keeper({'franked.$_first': 0}));
    expect(find.text('paid unasked'), findsOne);
  });

  testWidgets('tapping a letter opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.letter.name, _first);
  });

  testWidgets('writes a paid letter down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await payItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), 0);
  });

  testWidgets('a letter left short writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await lick(tester, true);

    expect(best.done, 0);
  });
}

String get _first => Letters.at(0).name;
