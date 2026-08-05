import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trestlewick/best.dart';
import 'package:trestlewick/raise/frames.dart';

import '../support/raise.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many frames there are', (tester) async {
    await open(tester);
    expect(find.text('${Frames.count} frames'), findsOne);
    expect(
      find.text('${Frames.at(0).count} timbers · '
          '${Frames.at(0).crews} crews · '
          '${Frames.at(0).days} days'),
      findsOne,
    );
  });

  testWidgets('and how many are standing', (tester) async {
    await open(tester, best: await keeper({'raised.$_first': 4}));
    expect(find.text('1 of ${Frames.count} standing'), findsOne);
    expect(find.text('days'), findsWidgets);
  });

  testWidgets('tapping a frame opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.frame.name, _first);
  });

  testWidgets('writes a frame down once it is standing', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await raiseItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.daysFor(Frames.at(1).name), Frames.at(1).days);
  });

  testWidgets('and one left part raised writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await put(tester, 0);
    await press(tester, 'Raise the day');

    expect(best.done, 0);
  });
}

String get _first => Frames.at(0).name;
