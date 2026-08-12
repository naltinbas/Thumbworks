import 'package:flutter_test/flutter_test.dart';
import 'package:leystone/best.dart';
import 'package:leystone/ley/greens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/ley.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the moor of greens', () {
    testWidgets('names the game and every green', (tester) async {
      await open(tester);
      expect(find.text('Leystone'), findsOne);
      for (var number = 0; number < Greens.count; number++) {
        expect(find.text(Greens.at(number).name), findsOne);
      }
    });

    testWidgets('the odd stone is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('seven never stand'),
        findsOne,
      );
    });

    testWidgets('a stood green wears its askings', (tester) async {
      await open(tester,
          best: await keeper({'stood.The Close': 0}));
      expect(find.text('stood, asking 0'), findsOne);
    });

    testWidgets('a row opens its green', (tester) async {
      await open(tester);
      await tester.tap(find.text(Greens.at(2).name));
      await tester.pump();
      expect(state(tester).play.green.name, Greens.at(2).name);
    });

    testWidgets('leaving a green lands back on the moor',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the greens'));
      await tester.pump();
      expect(find.text('Leystone'), findsOne);
    });
  });
}
