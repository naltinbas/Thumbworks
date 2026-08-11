import 'package:flutter_test/flutter_test.dart';
import 'package:pinderwell/drive/fields.dart';

import '../support/drive.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the ewe where the carter lost her', (tester) async {
      await open(tester, which: 1);
      expect(state(tester).play.made, 0);
      expect(find.text('0 / 3'), findsOne);
      expect(find.text('8 east, 6 north of the pen'), findsOne);
    });

    testWidgets('a push she cannot give is refused with the reason',
        (tester) async {
      await open(tester, which: 1);
      await push(tester, 7, 4);
      expect(state(tester).play.made, 0);
      expect(find.textContaining('cannot be pushed there'), findsOne);
    });

    testWidgets('a push brings the pinder\'s answer on its heels',
        (tester) async {
      await open(tester, which: 1);
      final next = state(tester).play.next!;
      await push(tester, next.$1, next.$2);
      expect(state(tester).play.made, 1);
      expect(state(tester).play.theirFrom, isNotNull);
      expect(state(tester).play.winnable, isTrue);
    });

    testWidgets('Back takes the push and the answer together', (tester) async {
      await open(tester, which: 1);
      final next = state(tester).play.next!;
      await push(tester, next.$1, next.$2);
      await press(tester, 'Back');
      expect(state(tester).play.made, 0);
      expect(state(tester).play.east, Fields.at(1).east);
    });

    testWidgets('Again starts the drive over', (tester) async {
      await open(tester, which: 1);
      final next = state(tester).play.next!;
      await push(tester, next.$1, next.$2);
      await press(tester, 'Again');
      expect(state(tester).play.made, 0);
    });
  });

  group('the words under the field', () {
    testWidgets('a wrong push is called out the moment the pinder answers',
        (tester) async {
      await open(tester, which: 0);
      // One pace south leaves her hot, and the answer is not the pen: the
      // pinder steps her to the rung at two east one north instead.
      await push(tester, 4, 1);
      expect(state(tester).play.winnable, isFalse);
      expect(state(tester).play.isOver, isFalse);
      expect(find.textContaining('The fee is his now'), findsOne);
      expect(find.textContaining('Take the push back'), findsOne);
    });

    testWidgets('Show me points at the rung the pinder cannot answer',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      final pointed = state(tester).pointing;
      expect(pointed, isNotNull);
      expect(pointed, state(tester).play.next);
      expect(state(tester).hints, 1);
      expect(find.textContaining('cannot answer'), findsOne);
    });

    testWidgets('Why marks the ladder and says its shape', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showRungs, isTrue);
      expect(find.textContaining('golden ratio'), findsOne);
      expect(find.textContaining('every row, every column'), findsOne);
    });

    testWidgets('the hopeless field says what it is for', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('here to be felt'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
    });
  });

  group('a drive ended', () {
    testWidgets('following the game wins every field that can be won, at par',
        (tester) async {
      for (var number = 0; number < Fields.count; number++) {
        final field = Fields.at(number);
        if (field.hopeless) continue;
        await open(tester, which: number);
        await winItAll(tester);
        final play = state(tester).play;
        expect(play.won, isTrue, reason: field.name);
        expect(play.made, field.fewest, reason: field.name);
      }
    });

    testWidgets('the card says no drive does it on fewer', (tester) async {
      await open(tester, which: 0);
      await winItAll(tester);
      expect(find.textContaining('no drive here does it on fewer'), findsOne);
      expect(find.text('the ewe is penned'), findsOne);
    });

    testWidgets('the pinder pens her on the hopeless field, and the card '
        'says whose fee it is', (tester) async {
      await open(tester, which: 4);
      var guard = 0;
      while (!state(tester).play.isOver && guard++ < 20) {
        final play = state(tester).play;
        var pushed = false;
        for (var east = play.east; east >= 0 && !pushed; east--) {
          for (var north = play.north; north >= 0 && !pushed; north--) {
            if (play.mayPush(east, north)) {
              await push(tester, east, north);
              pushed = true;
            }
          }
        }
      }
      expect(state(tester).play.isOver, isTrue);
      expect(state(tester).play.won, isFalse);
      expect(find.textContaining('the fee is his'), findsOne);
    });

    testWidgets('Next opens the field after', (tester) async {
      await open(tester, which: 0);
      await winItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.field.name, Fields.at(1).name);
    });
  });
}
