import 'package:flutter_test/flutter_test.dart';
import 'package:pegbourne/code/riddles.dart';

import '../support/code.dart';

void main() {
  group('the list of riddles', () {
    testWidgets('names the game and every riddle', (tester) async {
      await open(tester);
      expect(find.text('Pegbourne'), findsOne);
      for (var number = 0; number < Riddles.count; number++) {
        expect(find.text(Riddles.at(number).name), findsOne);
      }
    });

    testWidgets('the flawed riddles are labelled on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no code earns them all'), findsOne);
      expect(find.textContaining('2 codes answer them'), findsOne);
    });

    testWidgets('a row opens its riddle', (tester) async {
      await open(tester);
      await tester.tap(find.text(Riddles.at(2).name));
      await tester.pump();
      expect(state(tester).play.riddle.name, Riddles.at(2).name);
    });

    testWidgets('leaving a riddle lands back on the list',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the riddles'));
      await tester.pump();
      expect(find.text('Pegbourne'), findsOne);
    });
  });
}
