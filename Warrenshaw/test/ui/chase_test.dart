import 'package:flutter_test/flutter_test.dart';
import 'package:warrenshaw/chase/maps.dart';

import '../support/chase.dart';

void main() {
  testWidgets('a map opens with the two of them where it says', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.seeker, Warrens.at(0).seeker);
    expect(play.runner, Warrens.at(0).runner);
    expect(play.moves, 0);
    expect(find.text(Warrens.at(0).name), findsOneWidget);
    expect(find.textContaining('${Warrens.at(0).par} more'), findsOneWidget);
  });

  testWidgets('tapping a place along a path moves there, and it answers',
      (tester) async {
    await open(tester, which: 0);
    final was = state(tester).play;
    final next = was.next!;

    await touch(tester, next);

    final play = state(tester).play;
    expect(play.seeker, next);
    expect(play.moves, 1);
    expect(play.left, was.left - 1);
  });

  testWidgets('and a place with no path to it says so', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;
    final far = [
      for (var place = 0; place < play.chart.count; place++)
        if (!play.chart.beside[play.seeker].contains(place)) place,
    ];

    await touch(tester, far.first);
    expect(find.textContaining('no path'), findsOneWidget);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a move that wastes time says how much', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;
    final wrong = [
      for (final place in play.canGo)
        if (place != play.next) place,
    ];
    expect(wrong, isNotEmpty);

    await touch(tester, wrong.first);
    expect(find.textContaining('not on any quickest way'), findsOneWidget);
    expect(state(tester).play.wasted, greaterThan(0));
  });

  testWidgets('Take back undoes the move and its answer', (tester) async {
    await open(tester, which: 0);
    final was = state(tester).play;
    await touch(tester, was.next!);
    await press(tester, 'Take back');

    expect(state(tester).play.seeker, was.seeker);
    expect(state(tester).play.runner, was.runner);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('Again puts everybody back where they started', (tester) async {
    await open(tester, which: 0);
    await touch(tester, state(tester).play.next!);
    await press(tester, 'Again');

    expect(state(tester).play.moves, 0);
    expect(state(tester).play.seeker, Warrens.at(0).seeker);
  });

  testWidgets('Show me names a place and says how many are left',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, isNonNegative);
    expect(screen.hints, 1);
    expect(find.textContaining('Go to '), findsOneWidget);
  });

  testWidgets('and on the map nobody can win it says why', (tester) async {
    await open(tester, which: Warrens.count - 1);
    await press(tester, 'Show me');

    expect(find.textContaining('no move that catches it'), findsOneWidget);
    expect(state(tester).pointing, -1);
  });

  testWidgets('every map that can be won is won in its par through the screen',
      (tester) async {
    for (var which = 0; which < Warrens.count; which++) {
      if (Warrens.at(which).hopeless) continue;
      await open(tester, which: which);
      await chaseItDown(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Warrens.at(which).name);
      expect(play.moves, Warrens.at(which).par,
          reason: Warrens.at(which).name);
      expect(find.bySemanticsLabel('chase over'), findsOneWidget,
          reason: Warrens.at(which).name);
    }
  });

  testWidgets('and the map nobody can win is not won by the screen either',
      (tester) async {
    await open(tester, which: Warrens.count - 1);
    for (var turn = 0; turn < 12; turn++) {
      final play = state(tester).play;
      await touch(tester, play.canGo.firstWhere((at) => at != play.seeker));
    }
    expect(state(tester).play.isDone, isFalse);
    expect(find.textContaining('keeps the far side'), findsOneWidget);
  });
}
