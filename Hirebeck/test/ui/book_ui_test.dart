import 'package:flutter_test/flutter_test.dart';
import 'package:hirebeck/book/days.dart';

import '../support/book.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the book empty', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.bookedCount, 0);
      expect(find.text('book 3; 0 stand booked'), findsOne);
      expect(find.text('0 moved'), findsOne);
    });

    testWidgets('a tap books a hiring, another cancels it',
        (tester) async {
      await open(tester, which: 0);
      await tapHiring(tester, 0);
      expect(state(tester).play.isBooked(0), isTrue);
      await tapHiring(tester, 0);
      expect(state(tester).play.isBooked(0), isFalse);
      expect(find.text('2 moved'), findsOne);
    });

    testWidgets('Back unmoves the last move', (tester) async {
      await open(tester, which: 0);
      await tapHiring(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.bookedCount, 0);
    });

    testWidgets('Again clears the book', (tester) async {
      await open(tester, which: 0);
      await tapHiring(tester, 0);
      await tapHiring(tester, 2);
      await press(tester, 'Again');
      expect(state(tester).play.moves, 0);
    });
  });

  group('the words under the day', () {
    testWidgets('a clash is called out by name the moment it stands',
        (tester) async {
      await open(tester, which: 0);
      await tapHiring(tester, 0);
      await tapHiring(tester, 1);
      expect(state(tester).play.clashes, isNotEmpty);
      expect(find.textContaining('both want the hall at once'),
          findsOne);
      expect(find.textContaining('clash on the book'), findsOne);
    });

    testWidgets('Show me mends toward the full book', (tester) async {
      await open(tester, which: 1);
      await tapHiring(tester, 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 0);
      expect(find.textContaining('no room for that hiring'), findsOne);
    });

    testWidgets('Why strikes the o\'clocks in gold', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).strikes, isNotEmpty);
      expect(find.textContaining('ceiling'), findsOne);
      expect(find.textContaining('earliest finish'), findsOne);
    });

    testWidgets('the extra guest says so as it opens, and Why counts '
        'the o\'clocks', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('cannot hold 5 bookings'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(state(tester).strikes, hasLength(4));
      expect(find.textContaining('only 4'), findsOne);
    });
  });

  group('a book filled', () {
    testWidgets('following the game fills every winnable day',
        (tester) async {
      for (var number = 0; number < Days.count; number++) {
        final day = Days.at(number);
        if (!day.winnable) continue;
        await open(tester, which: number);
        await bookItFull(tester);
        expect(state(tester).play.isDone, isTrue, reason: day.name);
      }
    });

    testWidgets('the card owns the ways', (tester) async {
      await open(tester, which: 1);
      await bookItFull(tester);
      expect(find.text('the book is full, no clash in it'), findsOne);
      expect(find.textContaining('the only full one'), findsOne);
    });

    testWidgets('Next opens the day after', (tester) async {
      await open(tester, which: 0);
      await bookItFull(tester);
      await press(tester, 'Next');
      expect(state(tester).play.day.name, Days.at(1).name);
    });
  });
}
