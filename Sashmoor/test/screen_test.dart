import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/moor.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh sash names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Casement'), findsOneWidget);
    expect(
      find.textContaining('set 5 panes in the 3-by-3 sash'),
      findsOneWidget,
    );
    expect(
      find.text('0 set, 5 to go; nothing framed yet.'),
      findsOneWidget,
    );
  });

  testWidgets('five free panes glaze the casement', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (0, 1), (1, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Glazed.'), findsOneWidget);
    expect(find.textContaining('5 touches'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('a framed window is called out and counted',
      (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (2, 0), (0, 2), (2, 2)]);
    expect(find.text('windows 1'), findsOneWidget);
    expect(
      find.text('1 window framed: lift a rust corner.'),
      findsOneWidget,
    );
    expect(state(tester).play.isDone, isFalse);
  });

  testWidgets('tapping a pane lifts it again', (tester) async {
    await open(tester, which: 0);
    await tapLight(tester, 1, 1);
    expect(state(tester).play.panes, hasLength(1));
    await tapLight(tester, 1, 1);
    expect(state(tester).play.panes, isEmpty);
    expect(state(tester).play.moves, 2);
  });

  testWidgets('back takes back a touch and unfreezes the sash',
      (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (0, 1), (1, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.panes, hasLength(4));
    expect(find.text('Glazed.'), findsNothing);
  });

  testWidgets('show me rings a light and says which way',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.text('Set a pane in the ringed light.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the ways', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(find.textContaining('all 32,564 placings'), findsOneWidget);
    expect(
      find.textContaining('96 placings land this sash'),
      findsOneWidget,
    );
    expect(
      find.textContaining('every pair of rows sharing exactly one '
          'column'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless sash admits it and speaks the arithmetic',
      (tester) async {
    await open(tester, which: 4);
    final lights = state(tester).play.rules.lights;
    for (final (x, y) in lights.take(10)) {
      await tapLight(tester, x, y);
    }
    for (var touch = 10; touch < 16; touch++) {
      await tapLight(tester, 0, 0);
    }
    expect(state(tester).play.moves, 16);
    expect(find.text('The tenth pane stays out.'), findsOneWidget);
    expect(
      find.textContaining('ten panes spend eight row-pairs'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('that arithmetic alone bars the tenth'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the sash over', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (0, 1), (1, 2)]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Glazed.'), findsNothing);
  });
}
