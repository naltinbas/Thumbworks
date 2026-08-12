import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardring.dart';

/// One flock on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a flock opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('so exactly 3 wear crowns'),
      findsOneWidget,
    );
    expect(find.text('crowns 1, asked 3'), findsOneWidget);
    expect(find.text('busiest pecks 3'), findsOneWidget);
    expect(find.textContaining('1 crown stands'), findsOneWidget);
  });

  testWidgets('a tapped arrow flips and the chips follow',
      (tester) async {
    await open(tester, which: 4);
    await tapPair(tester, 0);
    expect(state(tester).play.pecking[0], isTrue);
    expect(state(tester).play.moves, 1);
    await tapPair(tester, 0);
    expect(state(tester).play.pecking[0], isFalse);
  });

  testWidgets('one flip crowns the round and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await tapPair(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('crowns 3, asked 3'), findsOneWidget);
    expect(find.text('Crowned.'), findsOneWidget);
    expect(
      find.textContaining('Every chicken crowned'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Crowned.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a pair and the flip lands it',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Flip who pecks whom on the ringed pair'),
      findsOneWidget,
    );
    await tapPair(tester, state(tester).pointing!);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the pointer crowns the four of five', (tester) async {
    await open(tester, which: 2);
    await crownByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.kings, hasLength(4));
  });

  testWidgets('back takes the flip back', (tester) async {
    await open(tester, which: 4);
    await tapPair(tester, 3);
    await press(tester, 'Back');
    expect(state(tester).play.pecking[3], isFalse);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the hopeless flock cracks at twelve flips',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 12; dither++) {
      await tapPair(tester, dither % 2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Crowns never pair.'), findsOneWidget);
    expect(
      find.textContaining('crowns never stop at two'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the laws and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Two crowns cannot stand'),
      findsOneWidget,
    );
    expect(find.textContaining('never a pair'), findsOneWidget);
  });
}
