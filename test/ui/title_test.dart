import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chalkway/done.dart';
import 'package:chalkway/sim/levels.dart';
import 'package:chalkway/ui/title_screen.dart';

import '../support/board.dart';

Future<Done> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Done(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('lists every level, in order', (tester) async {
    await open(tester);
    for (var i = 0; i < Levels.count; i++) {
      expect(find.text(Levels.at(i).name), findsOne,
          reason: '${Levels.at(i).name} is missing from the list');
    }
    expect(find.text('${Levels.count} levels'), findsOne);
  });

  testWidgets('says how much chalk a level gives before it is solved',
      (tester) async {
    await open(tester);
    expect(find.text('13 chalk'), findsOne, reason: 'the first level gives 13');
    expect(find.text('4 chalk · spikes'), findsWidgets);
  });

  testWidgets('shows what has been solved, and with how little chalk',
      (tester) async {
    await open(tester, done: await keeper({'done.The gap': 2.75}));

    expect(find.text('solved with 2.8 chalk'), findsOne);
    expect(find.text('1 of ${Levels.count} solved'), findsOne);
    expect(find.byIcon(Icons.check_rounded), findsOne);
  });

  testWidgets('writes down a win, once it has actually been won',
      (tester) async {
    final done = await keeper();
    await open(tester, level: 3, done: done);
    expect(done.has(Levels.at(3).name), isFalse);

    await drawTheAnswer(tester);
    await letGo(tester);
    await tester.pump();

    expect(done.chalkFor(Levels.at(3).name), isNotNull,
        reason: 'the win never reached the record');
    expect(done.chalkFor(Levels.at(3).name),
        closeTo(Levels.at(3).answer.used, 0.5));
  });

  testWidgets('and a loss writes down nothing', (tester) async {
    final done = await keeper();
    await open(tester, level: 3, done: done);

    await letGo(tester);
    await tester.pump();

    expect(done.count, 0);
  });

  testWidgets('has a mark on it that is drawn, not fetched', (tester) async {
    await open(tester);
    expect(find.byType(TitleScreen), findsOne);
    expect(find.byType(Image), findsNothing,
        reason: 'nothing here loads a picture; the logo is a painter');
  });
}
