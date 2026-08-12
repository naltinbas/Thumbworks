import 'package:flutter_test/flutter_test.dart';
import 'package:copestone/best.dart';
import 'package:copestone/wall/pitches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/wall.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the fell of pitches', () {
    testWidgets('names the game and every pitch', (tester) async {
      await open(tester);
      expect(find.text('Copestone'), findsOne);
      for (var number = 0; number < Pitches.count; number++) {
        expect(find.text(Pitches.at(number).name), findsOne);
      }
    });

    testWidgets('the fourth course is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no wall ever has'),
        findsOne,
      );
    });

    testWidgets('a coped pitch wears its askings', (tester) async {
      await open(tester,
          best: await keeper({'coped.The Two Kinds': 0}));
      expect(find.text('coped, asking 0'), findsOne);
    });

    testWidgets('a row opens its pitch', (tester) async {
      await open(tester);
      await tester.tap(find.text(Pitches.at(2).name));
      await tester.pump();
      expect(state(tester).play.pitch.name, Pitches.at(2).name);
    });

    testWidgets('leaving a pitch lands back on the fell',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the pitches'));
      await tester.pump();
      expect(find.text('Copestone'), findsOne);
    });
  });
}
