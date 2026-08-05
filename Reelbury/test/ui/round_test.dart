import 'package:flutter_test/flutter_test.dart';
import 'package:reelbury/reel/rounds.dart';
import 'package:reelbury/reel/stable.dart';

import '../support/reel.dart';

void main() {
  testWidgets('a round opens with nobody paired', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.paired, 0);
    expect(find.text(Rounds.at(0).name), findsOneWidget);
    expect(find.textContaining('${play.count} still to pair'), findsOneWidget);
  });

  testWidgets('tapping a caller then a dancer makes a couple', (tester) async {
    await open(tester, which: 0);
    await pair(tester, 0, 1);

    final play = state(tester).play;
    expect(play.dancerOf(0), 1);
    expect(play.paired, 1);
    expect(state(tester).holding, -1);
  });

  testWidgets('and tapping a dancer first says to take a caller',
      (tester) async {
    await open(tester, which: 0);
    await touch(tester, 0, caller: false);
    expect(find.textContaining('Tap one of the callers'), findsOneWidget);
    expect(state(tester).play.paired, 0);
  });

  testWidgets('a caller tapped twice is put down again', (tester) async {
    await open(tester, which: 0);
    await touch(tester, 0, caller: true);
    expect(state(tester).holding, 0);
    await touch(tester, 0, caller: true);
    expect(state(tester).holding, -1);
  });

  testWidgets('and a dancer tapped alone is parted from whoever has them',
      (tester) async {
    await open(tester, which: 0);
    await pair(tester, 0, 1);
    await touch(tester, 1, caller: false);

    expect(state(tester).play.paired, 0);
  });

  testWidgets('pairing somebody who is taken breaks the old couple',
      (tester) async {
    await open(tester, which: 0);
    await pair(tester, 0, 1);
    await pair(tester, 1, 1);

    final play = state(tester).play;
    expect(play.dancerOf(0), -1);
    expect(play.dancerOf(1), 1);
    expect(play.paired, 1);
  });

  testWidgets('a full floor that does not hold names two who would swap',
      (tester) async {
    // The whole game, in one message. It waits until everybody is paired,
    // because before that every pair would rather have each other.
    await open(tester, which: 0);
    await pairThemWrong(tester);

    final play = state(tester).play;
    expect(play.isFull, isTrue);
    expect(play.isDone, isFalse);
    expect(play.blocking, isNotEmpty);
    expect(find.textContaining('would both rather have each other'),
        findsOneWidget);
    expect(find.textContaining('would rather swap'), findsOneWidget);
  });

  testWidgets('Again clears the floor', (tester) async {
    await open(tester, which: 0);
    await pair(tester, 0, 1);
    await press(tester, 'Again');

    expect(state(tester).play.paired, 0);
    expect(state(tester).holding, -1);
  });

  testWidgets('Show me puts one couple of the answer down and names it',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');

    final screen = state(tester);
    final answer = Stable.byAsking(screen.round.hall);
    expect(screen.hints, 1);
    expect(screen.play.paired, 1);
    expect(screen.play.dancerOf(0), answer[0]);
    expect(find.textContaining('is in the pairing that holds'), findsOneWidget);
  });

  testWidgets('every round can be paired up through the screen',
      (tester) async {
    // The proof that the game is playable: every round put together by the
    // same taps a finger makes, and holding at the end of it.
    for (var which = 0; which < Rounds.count; which++) {
      await open(tester, which: which);
      await pairThemUp(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Rounds.at(which).name);
      expect(play.blocking, isEmpty, reason: Rounds.at(which).name);
      expect(find.bySemanticsLabel('it holds'), findsOneWidget,
          reason: Rounds.at(which).name);
    }
  });

  testWidgets('and pressing Show me over and over also finishes it',
      (tester) async {
    await open(tester, which: 1);
    for (var press = 0; press < 20; press++) {
      if (state(tester).play.isDone) break;
      await pressShowMe(tester);
    }
    expect(state(tester).play.isDone, isTrue);
  });
}

Future<void> pressShowMe(WidgetTester tester) => press(tester, 'Show me');
