import 'package:flutter_test/flutter_test.dart';
import 'package:mousewold/best.dart';
import 'package:mousewold/chase/grounds.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/chase.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the wold of grounds', () {
    testWidgets('names the game and every ground', (tester) async {
      await open(tester);
      expect(find.text('Mousewold'), findsOne);
      for (var number = 0; number < Grounds.count; number++) {
        expect(find.text(Grounds.at(number).name), findsOne);
      }
    });

    testWidgets('the ring fence is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('the mouse escapes forever'),
        findsOne,
      );
    });

    testWidgets('a cornered ground wears its count', (tester) async {
      await open(tester,
          best: await keeper({'cornered.The Hedgerow': 2}));
      expect(find.text('cornered in 2'), findsOne);
    });

    testWidgets('a row opens its ground', (tester) async {
      await open(tester);
      await tester.tap(find.text(Grounds.at(2).name));
      await tester.pump();
      expect(state(tester).play.ground.name, Grounds.at(2).name);
    });

    testWidgets('leaving a ground lands back on the wold',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the grounds'));
      await tester.pump();
      expect(find.text('Mousewold'), findsOne);
    });
  });
}
