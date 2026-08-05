import 'package:flutter_test/flutter_test.dart';
import 'package:rungwick/ladder/climbs.dart';
import 'package:rungwick/ladder/graph.dart';
import 'package:rungwick/ladder/words.dart';
import 'package:rungwick/ui/climb_screen.dart';
import 'package:rungwick/ui/title_screen.dart';

import '../support/climb.dart';

void main() {
  late Ladder four;

  setUpAll(() => four = Ladder.of(kFour));

  group('getting in', () {
    testWidgets('the list shows every climb and what it takes',
        (tester) async {
      await open(tester, ladder: four);
      expect(find.byType(TitleScreen), findsOne);
      for (final climb in Climbs.all) {
        expect(find.text(climb.from), findsWidgets);
        expect(find.text(climb.to), findsWidgets);
      }
      expect(find.text('${Climbs.count} climbs'), findsOne);
    });

    testWidgets('and a climb opens when its row is tapped', (tester) async {
      await open(tester, ladder: four);
      await tester.tap(find.text('bush').first);
      await tester.pump();

      expect(find.byType(ClimbScreen), findsOne);
      expect(state(tester).climb.from, 'bush');
    });

    testWidgets('a climb starts on the first word with nothing climbed',
        (tester) async {
      await open(tester, ladder: four, which: 0);
      expect(state(tester).play.here, 'rake');
      expect(state(tester).play.taken, 0);
      expect(find.text('0 / 4'), findsOne);
      expect(find.text('4 to go'), findsOne);
    });
  });

  group('changing a letter', () {
    testWidgets('takes two taps: which letter, and what to put there',
        (tester) async {
      await open(tester, ladder: four, which: 0);

      await tester.tap(find.bySemanticsLabel(RegExp('change the first letter')));
      await tester.pump();
      expect(state(tester).changing, 0);
      expect(find.text('Now pick what to change it to.'), findsOne);

      await tester.tap(find.bySemanticsLabel('the letter c'));
      await tester.pump();
      expect(state(tester).play.here, 'cake');
      expect(state(tester).play.taken, 1);
      expect(state(tester).changing, -1, reason: 'and lets go of the letter');
    });

    testWidgets('says so when what it makes is not a word', (tester) async {
      await open(tester, ladder: four, which: 0);
      await change(tester, 0, 'q');

      expect(state(tester).play.here, 'rake', reason: 'nothing moved');
      expect(state(tester).saying, contains('not in the list'));
    });

    testWidgets('and when it is a word already on the ladder', (tester) async {
      await open(tester, ladder: four, which: 0);
      await climbTo(tester, 'cake');
      await change(tester, 0, 'r');

      expect(state(tester).play.here, 'cake');
      expect(state(tester).saying, contains('been to rake already'));
    });

    testWidgets('takes a rung back off again', (tester) async {
      await open(tester, ladder: four, which: 0);
      await climbTo(tester, 'cake');
      await climbTo(tester, 'cane');
      expect(state(tester).play.taken, 2);

      await press(tester, 'Take back');
      expect(state(tester).play.here, 'cake');
      expect(state(tester).play.taken, 1);
    });
  });

  group('stepping off the shortest way', () {
    testWidgets('is said at once, not five rungs later', (tester) async {
      // rake -> lake is a word and a rung, and it is not on any shortest way
      // to cons.
      await open(tester, ladder: four, which: 0);
      await climbTo(tester, 'lake');

      expect(state(tester).play.onShortest, isFalse);
      expect(state(tester).saying, contains('not on any shortest way'));
      expect(find.textContaining('more than it had to be'), findsOne);
    });

    testWidgets('and taking the rung back puts it right', (tester) async {
      await open(tester, ladder: four, which: 0);
      await climbTo(tester, 'lake');
      await press(tester, 'Take back');

      expect(state(tester).play.onShortest, isTrue);
      expect(state(tester).saying, isNull);
    });
  });

  group('being shown', () {
    testWidgets('names a word that really is one step nearer', (tester) async {
      await open(tester, ladder: four, which: 2);
      await press(tester, 'Show me');

      final said = state(tester).saying!;
      expect(said, contains('From here it is'));

      final next = state(tester).play.nextRung!;
      expect(said, contains(next));
      final was = state(tester).play.stepsLeft;
      await climbTo(tester, next);
      expect(state(tester).play.stepsLeft, was - 1);
    });

    testWidgets('climbs every ladder in par, from the bottom to the top',
        (tester) async {
      // The claim the game is sold on, made through the screen: the number on
      // every climb is reachable, and following what the game says reaches it.
      for (var which = 0; which < Climbs.count; which++) {
        await open(tester, ladder: four, which: which);
        await climbIt(tester);

        final climb = Climbs.at(which);
        expect(state(tester).play.isDone, isTrue,
            reason: '$climb was not finished');
        expect(state(tester).play.taken, climb.rungs,
            reason: '$climb took more rungs than it had to');
        expect(find.text('Not a rung wasted'), findsOne);
      }
    });
  });

  group('finishing', () {
    testWidgets('the long way says how much longer', (tester) async {
      await open(tester, ladder: four, which: 0);
      for (final word in ['lake', 'lane', 'cane', 'cans', 'cons']) {
        await climbTo(tester, word);
      }

      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.taken, greaterThan(Climbs.at(0).rungs));
      expect(find.text('Up'), findsOne);
      expect(find.textContaining('more than it had to be'), findsOne);
    });

    testWidgets('and the next one opens after it', (tester) async {
      await open(tester, ladder: four, which: 0);
      await climbIt(tester);

      await press(tester, 'The next one');
      expect(state(tester).climb.from, Climbs.at(1).from);
      expect(state(tester).play.taken, 0);
    });

    testWidgets('the last one leads back to the list', (tester) async {
      await open(tester, ladder: four, which: Climbs.count - 1);
      await climbIt(tester);

      await press(tester, 'The next one');
      expect(find.byType(TitleScreen), findsOne);
    });
  });
}
