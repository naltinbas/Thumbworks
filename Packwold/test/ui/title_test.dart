import 'package:flutter_test/flutter_test.dart';
import 'package:packwold/best.dart';
import 'package:packwold/fit/boxes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fit.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many puzzles there are', (tester) async {
    await open(tester);
    expect(find.text('${Puzzles.count} puzzles'), findsOne);
    // Three of the boxes take four pieces, and they all say so.
    expect(
      find.text('${Puzzles.at(0).pieces} pieces · '
          '${Puzzles.at(0).pieces * 5} squares'),
      findsWidgets,
    );
    expect(find.text('10 pieces · 50 squares'), findsOne);
  });

  testWidgets('and which have been packed', (tester) async {
    await open(tester, best: await keeper({'packed.$_first': 0}));
    expect(find.text('1 of ${Puzzles.count} packed'), findsOne);
    expect(find.text('on your own'), findsOne);
  });

  testWidgets('and that one was looked up rather than worked out',
      (tester) async {
    await open(tester, best: await keeper({'packed.$_first': 2}));
    expect(find.text('2 looked at'), findsOne);
  });

  testWidgets('tapping a puzzle opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).puzzle.name, _first);
  });

  testWidgets('writes a puzzle down once the box is packed', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await packIt(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.hintsFor(_first), 0);
    expect(best.alone(_first), isTrue,
        reason: 'nothing was asked for, so it was worked out');
  });

  testWidgets('and counts what was asked for on the way', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await press(tester, 'Show me');
    await packIt(tester);

    expect(best.hintsFor(_first), 1);
    expect(best.alone(_first), isFalse);
  });

  testWidgets('and a box half packed writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await lay(tester, state(tester).guide.answer.first);

    expect(best.done, 0);
  });
}

String get _first => Puzzles.at(0).name;
