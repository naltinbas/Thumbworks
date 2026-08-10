import 'package:flutter_test/flutter_test.dart';
import 'package:linacre/wire/rounds.dart';

import '../support/wire.dart';

void main() {
  testWidgets('a round opens untouched', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.made, 0);
    expect(play.isOver, isFalse);
    expect(find.text(Rounds.at(2).name), findsOneWidget);
    expect(find.textContaining('you cut, he braces'), findsOneWidget);
  });

  testWidgets('touching a wire cuts it and the machine answers out loud',
      (tester) async {
    await open(tester, which: 2);
    await touch(tester, 4);

    final play = state(tester).play;
    expect(play.isCut(4), isTrue);
    expect(play.theirLast, isNot(-1));
    expect(find.textContaining('He braced'), findsOneWidget);
  });

  testWidgets('a wire already spoken for says so', (tester) async {
    await open(tester, which: 2);
    await touch(tester, 4);
    final held = state(tester).play.theirLast;
    await touch(tester, held);

    expect(find.textContaining('braced. Nothing touches it now'),
        findsOneWidget);
  });

  testWidgets('a slower wire is called out at once', (tester) async {
    // On the loop road the run wires win slower than the loop wires.
    await open(tester, which: 0);
    await touch(tester, 0);
    expect(find.textContaining('more than the 2 it takes'), findsOneWidget);
  });

  testWidgets('Take back undoes the whole exchange', (tester) async {
    await open(tester, which: 2);
    await touch(tester, 4);
    await press(tester, 'Take back');
    expect(state(tester).play.made, 0);
  });

  testWidgets('Show me points at the winning wire', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
  });

  testWidgets('Why shows the two webs on the round that cannot be won',
      (tester) async {
    final hopeless = Rounds.all.indexWhere((round) => round.hopeless);
    await open(tester, which: hopeless);

    expect(find.textContaining('cannot be brought down'), findsOneWidget);
    await press(tester, 'Why');

    expect(state(tester).webs, isNotNull);
    expect(find.textContaining('past cutting'), findsOneWidget);
  });

  testWidgets('and gives the search word when no webs settle it',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(state(tester).webs, isNull);
    expect(find.textContaining('yours in 3'), findsOneWidget);
  });

  testWidgets('as linesman the webs are the strategy, and Why shows them',
      (tester) async {
    final doubled = Rounds.all.indexWhere(
        (round) => round.name == 'The Doubled Line');
    await open(tester, which: doubled);
    await press(tester, 'Why');

    expect(state(tester).webs, isNotNull);
    expect(find.textContaining('the line holds itself'), findsOneWidget);
  });

  testWidgets('the hopeless round always ends with the line held',
      (tester) async {
    final hopeless = Rounds.all.indexWhere((round) => round.hopeless);
    await open(tester, which: hopeless);

    var guard = 0;
    while (!state(tester).play.isOver) {
      if (guard++ > 12) fail('it never ended');
      final play = state(tester).play;
      final free = [
        for (var wire = 0; wire < play.net.many; wire++)
          if (play.isFree(wire)) wire,
      ];
      await touch(tester, free.first);
    }
    expect(state(tester).play.won, isFalse);
    expect(find.textContaining('as the label said it would'), findsOneWidget);
  });

  testWidgets('every winnable round can be won at par through the screen',
      (tester) async {
    // The proof that the game is playable: every round won by tapping wires
    // against a machine that plays as well as the game can be played.
    for (var which = 0; which < Rounds.count; which++) {
      final round = Rounds.at(which);
      if (round.hopeless) continue;
      await open(tester, which: which);
      await winItAll(tester);

      final play = state(tester).play;
      expect(play.won, isTrue, reason: round.name);
      expect(play.made, round.fewest, reason: round.name);
      expect(play.isFewest, isTrue, reason: round.name);
      expect(find.bySemanticsLabel('the round is over'), findsOneWidget,
          reason: round.name);
    }
  });
}
