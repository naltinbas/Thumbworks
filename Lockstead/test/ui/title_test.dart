import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lockstead/best.dart';
import 'package:lockstead/lock/boards.dart';
import 'package:lockstead/lock/marks.dart';

import '../support/bench.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  late Marks gate;

  setUpAll(() => gate = Marks.of(Boards.at(0).lock));

  testWidgets('the rack says how many locks there are', (tester) async {
    await open(tester);
    expect(find.text('${Boards.count} locks'), findsOne);
  });

  testWidgets('and how few guesses each has been opened in', (tester) async {
    await open(tester, best: await keeper({'best.The garden gate': 4}));
    expect(find.text('4'), findsWidgets);
    expect(find.text('1 of ${Boards.count} opened'), findsOne);
  });

  testWidgets('writes down an opening, once the lock is actually open',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, marks: gate, best: best);
    expect(best.opened, 0);

    await pickIt(tester);
    await tester.pump();

    expect(state(tester).play!.isOpen, isTrue);
    expect(best.guessesFor('The garden gate'),
        state(tester).play!.tries.length);
  });

  testWidgets('and a lock that beat you writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, marks: gate, secret: 0, best: best);
    for (var i = 0; i < 5; i++) {
      await tryCode(tester, [1, 2, 3, 4]);
    }
    await tester.pump();

    expect(state(tester).play!.isLost, isTrue);
    expect(best.opened, 0);
  });
}
