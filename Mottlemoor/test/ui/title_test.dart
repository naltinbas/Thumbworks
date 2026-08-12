import 'package:flutter_test/flutter_test.dart';
import 'package:mottlemoor/herd/moors.dart';

import '../support/herd.dart';

void main() {
  group('the moorland', () {
    testWidgets('names the game and every moor', (tester) async {
      await open(tester);
      expect(find.text('Mottlemoor'), findsOne);
      for (var number = 0; number < Moors.count; number++) {
        expect(find.text(Moors.at(number).name), findsOne);
      }
    });

    testWidgets('the dead moors are labelled on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no herding settles it'),
          findsNWidgets(2));
    });

    testWidgets('a row opens its moor', (tester) async {
      await open(tester);
      await tester.tap(find.text(Moors.at(2).name));
      await tester.pump();
      expect(state(tester).play.moor.name, Moors.at(2).name);
    });

    testWidgets('leaving a moor lands back on the moorland',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the moors'));
      await tester.pump();
      expect(find.text('Mottlemoor'), findsOne);
    });
  });
}
