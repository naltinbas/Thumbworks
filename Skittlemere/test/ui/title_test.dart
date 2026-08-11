import 'package:flutter_test/flutter_test.dart';
import 'package:skittlemere/alley/frames.dart';

import '../support/alley.dart';

void main() {
  group('the lane of alleys', () {
    testWidgets('names the game and every alley', (tester) async {
      await open(tester);
      expect(find.text('Skittlemere'), findsOne);
      for (var number = 0; number < Frames.count; number++) {
        expect(find.text(Frames.at(number).name), findsOne);
      }
    });

    testWidgets('the even alley is labelled lost on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('the mover never has it'), findsOne);
    });

    testWidgets('a row opens its alley', (tester) async {
      await open(tester);
      await tester.tap(find.text(Frames.at(2).name));
      await tester.pump();
      expect(state(tester).play.frame.name, Frames.at(2).name);
    });

    testWidgets('leaving an alley lands back on the lane',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the alleys'));
      await tester.pump();
      expect(find.text('Skittlemere'), findsOne);
    });
  });
}
