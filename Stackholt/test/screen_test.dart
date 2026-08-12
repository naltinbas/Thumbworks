import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holt.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh stack names itself and its task', (tester) async {
    await open(tester, which: 3);
    expect(find.text('The Old Four'), findsOneWidget);
    expect(
      find.textContaining('Stand 4 boxes so every wall'),
      findsOneWidget,
    );
    expect(find.textContaining('No wall doubles yet'), findsNothing);
    expect(
      find.textContaining('still double'),
      findsOneWidget,
    );
  });

  testWidgets('spin and tip turn a box and speak the walls',
      (tester) async {
    await open(tester, which: 3);
    final before = state(tester).play.walls[0];
    await spin(tester, 0);
    expect(state(tester).play.moves, 1);
    expect(state(tester).play.walls[0], isNot(before));
    await tip(tester, 1);
    expect(state(tester).play.moves, 2);
  });

  testWidgets('the two boxes settle by one spin', (tester) async {
    await open(tester, which: 0);
    // The opening stands the second box matching the first; two
    // spins of either box un-double every wall.
    expect(state(tester).play.isDone, isFalse);
    await spin(tester, 1);
    if (!state(tester).play.isDone) {
      await spin(tester, 1);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Settled.'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a turn and unfreezes', (tester) async {
    await open(tester, which: 0);
    await spin(tester, 1);
    await spin(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.moves, 1);
    expect(find.text('Settled.'), findsNothing);
  });

  testWidgets('show me rings a box and names its wanted walls',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(find.textContaining('Box ${aim!.$1 + 1} wants'),
        findsOneWidget);
    expect(find.textContaining('forward'), findsOneWidget);
  });

  testWidgets('why speaks the sweep and the factoring', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(find.textContaining('counts 24 settlings'), findsOneWidget);
    expect(
      find.textContaining('pencil factoring'),
      findsOneWidget,
    );
    expect(
      find.textContaining('five fair picks'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless stack admits it and counts the red',
      (tester) async {
    await open(tester, which: 4);
    for (var turn = 0; turn < 16; turn++) {
      await (turn.isEven ? spin(tester, turn % 4) : tip(tester, turn % 4));
    }
    expect(state(tester).play.moves, 16);
    expect(find.text('The red stack stays wrong.'), findsOneWidget);
    expect(
      find.textContaining('thirteen faces wear red'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('twelve faces at most'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the stack over', (tester) async {
    await open(tester, which: 0);
    await spin(tester, 1);
    await spin(tester, 1);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Settled.'), findsNothing);
  });
}
