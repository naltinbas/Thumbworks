import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chasegarth/best.dart';
import 'package:chasegarth/forme/chases.dart';

import '../support/forme.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many formes there are', (tester) async {
    await open(tester);
    expect(find.text('${Formes.count} formes'), findsOne);
    expect(
      find.text('${Formes.at(1).chase.reading} · '
          '${Formes.at(1).chase.wide} by ${Formes.at(1).chase.tall} · '
          '${Formes.at(1).fewest} slides'),
      findsOne,
    );
  });

  testWidgets('and labels the dropped forme as impossible', (tester) async {
    await open(tester);
    expect(find.textContaining('cannot be done as it stands'), findsOneWidget);
  });

  testWidgets('and how many have been locked', (tester) async {
    await open(tester, best: await keeper({'locked.$_first': 6}));
    expect(find.text('1 of ${Formes.count} locked'), findsOne);
    expect(find.text('slides'), findsWidgets);
  });

  testWidgets('tapping a forme opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.forme.name, _first);
  });

  testWidgets('writes a forme down once it reads right', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await lockItAll(tester);
    await tester.pump();

    expect(state(tester).play.isLocked, isTrue);
    expect(best.slidesFor(Formes.at(0).name), Formes.at(0).fewest);
  });

  testWidgets('and one left part slid writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);

    await slide(tester, state(tester).play.canSlide.first);

    expect(best.done, 0);
  });
}

String get _first => Formes.at(0).name;
