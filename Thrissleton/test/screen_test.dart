import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/letonland.dart';

/// One hand on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a hand opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('dial the stones to exactly 0 thirds'),
      findsOneWidget,
    );
    expect(find.text('thirds 10, asked 0'), findsOneWidget);
    expect(find.text('remainders 0-5-0'), findsOneWidget);
  });

  testWidgets('a tapped stone turns and the chips follow',
      (tester) async {
    await open(tester, which: 4);
    await tapStone(tester, 0);
    expect(state(tester).play.faces[0], 2);
    expect(find.text('remainders 0-4-1'), findsOneWidget);
    expect(find.text('thirds 4, asked 0'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.faces[0], 1);
  });

  testWidgets('one tap lands the four thirds and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await tapStone(tester, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Dialled home.'), findsOneWidget);
    expect(
      find.textContaining('Exactly 4 thirds stand'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Dialled home.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the held stone refuses the tap', (tester) async {
    await open(tester, which: 3);
    await tapStone(tester, 0);
    expect(state(tester).play.faces[0], 6);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a stone and the tap obeys',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Tap the ringed stone'),
      findsOneWidget,
    );
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the pointer lands the locked six', (tester) async {
    await open(tester, which: 3);
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.faces[0], 6);
    expect(state(tester).play.thirds, hasLength(1));
  });

  testWidgets('the hopeless hand cracks at fifteen taps',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 15; dither++) {
      await tapStone(tester, dither % 5);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('Five stones always carry one.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('nought, one and two make three'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the two cases and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Sort the five stones by their remainder'),
      findsOneWidget,
    );
    expect(find.textContaining('7,776'), findsOneWidget);
  });
}
