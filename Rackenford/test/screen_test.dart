import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/pantryland.dart';

/// One pantry on the screen, lifted as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a pantry opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('rack the jars one to 12 on 3 racks'),
      findsOneWidget,
    );
    expect(find.text('racked 0 of 12'), findsOneWidget);
    expect(find.text('quarrels 0'), findsOneWidget);
  });

  testWidgets('a lift racks the jar and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await tapJar(tester, 0);
    expect(state(tester).play.racking[0], 1);
    expect(find.text('racked 1 of 6'), findsOneWidget);
    await tapJar(tester, 1);
    expect(
      find.textContaining('1 quarrel on the racks'),
      findsOneWidget,
    );
    await press(tester, 'Back');
    expect(state(tester).play.racking[1], 0);
  });

  testWidgets('the six racks home and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await rackByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Racked home.'), findsOneWidget);
    expect(
      find.textContaining('no jar above its divisor'),
      findsWidgets,
    );
    await press(tester, 'Again');
    expect(find.text('Racked home.'), findsNothing);
  });

  testWidgets('show me rings a jar', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Lift the ringed jar'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer racks the dozen on four',
      (tester) async {
    await open(tester, which: 3);
    await rackByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the hopeless pantry cracks at twenty-four lifts',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 24; dither++) {
      await tapJar(tester, dither % 12);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The chain wants four.'), findsOneWidget);
    expect(
      find.textContaining('a chain never shares a rack'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the chain and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('chain of four jars'),
      findsOneWidget,
    );
    expect(find.textContaining('531,441'), findsOneWidget);
  });
}
