import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shamland.dart';

/// One party on the screen, seated as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a party opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('seat the 5 husbands so no couple'),
      findsOneWidget,
    );
    expect(find.text('seated 0 of 5'), findsOneWidget);
    expect(find.text('couples together 0'), findsOneWidget);
    expect(find.text('Husbands seated 0 of 5.'), findsOneWidget);
  });

  testWidgets('the seated host opens with him in his chair',
      (tester) async {
    await open(tester, which: 2);
    expect(state(tester).play.seated[2], 0);
    expect(find.text('seated 1 of 5'), findsOneWidget);
    // His chair refuses the tap.
    await tapGap(tester, 2);
    expect(state(tester).play.seated[2], 0);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a pick and a chair seat a husband, and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await pickBench(tester, 0);
    expect(state(tester).play.picked, 0);
    expect(find.text('Husband 1 picked; tap a chair.'), findsOneWidget);
    await tapGap(tester, 0);
    expect(state(tester).play.seated[0], 0);
    expect(find.text('seated 1 of 3'), findsOneWidget);
    expect(find.text('couples together 1'), findsOneWidget);
    expect(find.text('1 couple sits together.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.seated[0], isNull);
    expect(find.text('seated 0 of 3'), findsOneWidget);
  });

  testWidgets('a lift sends a husband back to the bench',
      (tester) async {
    await open(tester, which: 0);
    await seat(tester, 1, 0);
    expect(state(tester).play.bench, [0, 2]);
    await tapGap(tester, 0);
    expect(state(tester).play.bench, [0, 1, 2]);
    expect(state(tester).play.moves, 2);
  });

  testWidgets('the three couples part by hand and show the card',
      (tester) async {
    await open(tester, which: 0);
    await seat(tester, 2, 0);
    await seat(tester, 0, 1);
    await seat(tester, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Parted.'), findsOneWidget);
    expect(
      find.textContaining('Every couple parted round the table; 3 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Parted.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a chair and names the husband',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('in the ringed chair'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer seats the host\'s party', (tester) async {
    await open(tester, which: 2);
    await partByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(state(tester).play.seated[2], 0);
  });

  testWidgets('the hopeless party cracks at twelve moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 6; dither++) {
      await seat(tester, 0, 0);
      await tapGap(tester, 0);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two couples never part.'), findsOneWidget);
    expect(
      find.textContaining('a circle of four seats both wives'),
      findsOneWidget,
    );
  });

  testWidgets('the why names the circle of four', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('a circle of four seats alternates'),
      findsOneWidget,
    );
    expect(
      find.textContaining('two quarrels apiece'),
      findsOneWidget,
    );
  });

  testWidgets('the why of a winnable party counts the turns',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Touchard\'s arithmetic'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Three of them turn the whole table'),
      findsOneWidget,
    );
  });
}
