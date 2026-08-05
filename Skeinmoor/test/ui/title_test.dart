import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeinmoor/best.dart';
import 'package:skeinmoor/thread/boards.dart';

import '../support/thread.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many boards there are', (tester) async {
    await open(tester);
    expect(find.text('${Boards.count} boards'), findsOne);
    expect(
      find.text('${Boards.at(0).side}×${Boards.at(0).side} · '
          '${Boards.at(0).threads} threads'),
      findsOne,
    );
  });

  testWidgets('and which have been filled', (tester) async {
    await open(tester, best: await keeper({'done.$_first': 0}));
    expect(find.text('1 of ${Boards.count} filled'), findsOne);
    expect(find.text('on your own'), findsOne);
  });

  testWidgets('and that one was looked up rather than worked out',
      (tester) async {
    await open(tester, best: await keeper({'done.$_first': 3}));
    expect(find.text('3 looked at'), findsOne);
  });

  testWidgets('tapping a board opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).board.name, _first);
  });

  testWidgets('writes a board down once it is filled', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await fillIt(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.hintsFor(_first), 0);
    expect(best.alone(_first), isTrue,
        reason: 'nothing was asked for, so it was found');
  });

  testWidgets('and counts what was asked for on the way', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await press(tester, 'Show me');
    await press(tester, 'Show me');
    await fillIt(tester);

    expect(best.hintsFor(_first), 2);
    expect(best.alone(_first), isFalse);
  });

  testWidgets('and a board left half drawn writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await dragThrough(tester, state(tester).guide.answer[0].take(3).toList());

    expect(best.done, 0);
  });
}

String get _first => Boards.at(0).name;
