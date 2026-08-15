import 'package:flutter_test/flutter_test.dart';
import 'package:brickholme/yard/play.dart';
import 'package:brickholme/yard/levels.dart';

import 'support/fonts.dart';
import 'support/holmeland.dart';

/// One yard on the screen, paved as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('pave the four by four yard with bricks three flags long, the drain in the corner'),
      findsOneWidget,
    );
    expect(find.text('bricks 0 of 5'), findsOneWidget);
    expect(find.text('bare 15'), findsOneWidget);
    expect(find.text('fit 14'), findsOneWidget);
    expect(find.text('Laid 0 of 5; 14 bricks fit; tap a flag to lay one across from it.'), findsOneWidget);
    expect(find.text('Bricks across'), findsOneWidget);
  });

  testWidgets('bricks lay, lift, face down, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapFlag(tester, 1);
    expect(find.text('bricks 1 of 5'), findsOneWidget);
    expect(find.text('bare 12'), findsOneWidget);
    await tapFlag(tester, 2);
    expect(find.text('bricks 0 of 5'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.bricks, [(1, true)]);
    await press(tester, 'Bricks across');
    expect(find.text('Bricks down'), findsOneWidget);
    expect(state(tester).play.across, isFalse);
    await tapFlag(tester, 4);
    expect(state(tester).play.bricks, [(1, true), (4, false)]);
  });

  testWidgets('the four yard paves and shows the card', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [1, 4, 8, 12]);
    await face(tester, false);
    await tapFlag(tester, 7);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Paved: every flag but the drain lies under a brick.'), findsOneWidget);
    expect(
      find.textContaining('Every flag but the drain lies under a brick; 5 layings.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me faces the yard and rings the flag, or the brick to lift', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    final aim = Play.aimFor(Levels.at(1))!;
    expect(state(tester).pointing, ('lay', aim.first));
    expect(state(tester).play.across, aim.first.$2);
    expect(find.text('Lay a brick ${aim.first.$2 ? 'across' : 'down'} from the ringed flag.'), findsOneWidget);
    // A brick laid the wrong way is to be lifted.
    await face(tester, !aim.first.$2);
    final wrong = state(tester).play.openings.firstWhere((b) => !aim.contains(b));
    await face(tester, wrong.$2);
    await tapFlag(tester, wrong.$1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', wrong));
    expect(find.text('Lift the ringed brick; it is off the paving.'), findsOneWidget);
  });

  testWidgets('the pointer paves the eight yard', (tester) async {
    await open(tester, which: 3);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('bricks 21 of 21'), findsOneWidget);
  });

  testWidgets('the hopeless yard sticks and shows the card', (tester) async {
    await open(tester, which: 4);
    await layUntilStuck(tester);
    expect(state(tester).play.stuck, isTrue);
    expect(find.text('The colours never balance.'), findsOneWidget);
    expect(find.textContaining('Stuck, '), findsOneWidget);
    expect(
      find.textContaining('the drain sits on a colour with twenty-one'),
      findsOneWidget,
    );
  });

  testWidgets('the why colours the flags', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the drain must wear the odd colour of both slants, colour 2 and colour 1, and this drain wears colour 1 and colour 1'),
      findsOneWidget,
    );
    expect(
      find.textContaining('So no paving is possible'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the eight yard counts the pavings', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('356 pavings of 21 bricks'),
      findsOneWidget,
    );
  });
}
