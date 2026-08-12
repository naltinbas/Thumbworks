import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/greenland.dart';

/// One wish list on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a list opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('the 5 farms get 3, 3, 2, 2, 2'),
      findsOneWidget,
    );
    expect(find.text('paths 0'), findsOneWidget);
    expect(find.text('wish sum 12, so 6 paths'), findsOneWidget);
    expect(
      find.textContaining('0 farms of 5 hold the wish'),
      findsOneWidget,
    );
  });

  testWidgets('a tapped path treads and the chips follow',
      (tester) async {
    await open(tester, which: 4);
    await tapPath(tester, 0);
    expect(state(tester).play.trodden[0], isTrue);
    expect(find.text('paths 1'), findsOneWidget);
    await tapPath(tester, 0);
    expect(state(tester).play.trodden[0], isFalse);
  });

  testWidgets('two paths land the four ones and show the card',
      (tester) async {
    await open(tester, which: 0);
    await tapPath(tester, 0);
    await tapPath(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(
      find.textContaining('Every farm holds its wish'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
    expect(state(tester).play.paths, 0);
  });

  testWidgets('show me rings a path and says tread or lift',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Tread the ringed path'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer lands the round wish', (tester) async {
    await open(tester, which: 1);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.paths, 5);
  });

  testWidgets('back takes the tread back', (tester) async {
    await open(tester, which: 4);
    await tapPath(tester, 2);
    await press(tester, 'Back');
    expect(state(tester).play.trodden[2], isFalse);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the hopeless list cracks at twelve moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 12; dither++) {
      await tapPath(tester, dither % 2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Even is not enough.'), findsOneWidget);
    expect(
      find.textContaining('three paths against its one'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks all three voices', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('three ways that share nothing'),
      findsOneWidget,
    );
    expect(find.textContaining('1,024'), findsOneWidget);
  });
}
