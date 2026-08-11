import 'package:flutter_test/flutter_test.dart';

import '../support/post.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the letter bare', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.total, 0);
      expect(find.text('0 / 24d'), findsOne);
      expect(find.text('stamps of 5d and 7d only'), findsOne);
    });

    testWidgets('licking stamps runs the total', (tester) async {
      await open(tester, which: 0);
      await lick(tester, true);
      await lick(tester, false);
      expect(state(tester).play.total, 12);
      expect(find.text('12 / 24d'), findsOne);
    });

    testWidgets('Back takes the last stamp off', (tester) async {
      await open(tester, which: 0);
      await lick(tester, true);
      await press(tester, 'Back');
      expect(state(tester).play.total, 0);
    });

    testWidgets('Again clears the letter', (tester) async {
      await open(tester, which: 0);
      await lick(tester, true);
      await press(tester, 'Again');
      expect(state(tester).play.total, 0);
    });
  });

  group('the words under the counter', () {
    testWidgets('a stranding stamp is called out at once', (tester) async {
      await open(tester, which: 1);
      await lick(tester, true);
      await lick(tester, true);
      expect(state(tester).play.canStill, isFalse);
      expect(find.textContaining('stranded the letter'), findsOne);
    });

    testWidgets('overshooting is called with both sides of the sum',
        (tester) async {
      await open(tester, which: 3);
      await lick(tester, false);
      await lick(tester, false);
      expect(find.textContaining('over is as wrong as under'), findsOne);
    });

    testWidgets('Show me names the stamp that keeps it payable',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).hints, 1);
      expect(find.textContaining('7d stamp keeps the letter payable'),
          findsOne);
    });

    testWidgets('Why lays out the remainder walk', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(state(tester).showWalk, isTrue);
      expect(find.textContaining('23, 16, 9, 2'), findsOne);
      expect(find.textContaining('cannot be paid'), findsOne);
    });

    testWidgets('and finds the hit when there is one', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(find.textContaining('divides by 5'), findsOne);
    });

    testWidgets('the unpayable letter says what it is for', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('can never be paid with these stamps'),
          findsOne);
      await press(tester, 'Show me');
      expect(find.textContaining('nothing to show'), findsOne);
    });
  });

  group('a letter paid', () {
    testWidgets('following the game pays every payable letter',
        (tester) async {
      for (final number in const [0, 1, 3]) {
        await open(tester, which: number);
        await payItAll(tester);
        expect(state(tester).play.isPaid, isTrue,
            reason: 'letter $number');
        expect(find.textContaining('Paid to the penny'), findsOne);
      }
    });

    testWidgets('the card counts the stamps', (tester) async {
      await open(tester, which: 0);
      await payItAll(tester);
      expect(find.textContaining('2 at 5d and 2 at 7d'), findsOne);
    });

    testWidgets('Next opens the letter after', (tester) async {
      await open(tester, which: 0);
      await payItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.letter.name, 'The Odd Parcel');
    });
  });
}
