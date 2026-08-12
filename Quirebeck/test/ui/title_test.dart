import 'package:flutter_test/flutter_test.dart';
import 'package:quirebeck/best.dart';
import 'package:quirebeck/quire/quires.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/quire.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the bench of quires', () {
    testWidgets('names the game and every quire', (tester) async {
      await open(tester);
      expect(find.text('Quirebeck'), findsOne);
      for (var number = 0; number < Quires.count; number++) {
        expect(find.text(Quires.at(number).name), findsOne);
      }
    });

    testWidgets('the turned pair is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no weaving ever mends it'),
        findsOne,
      );
    });

    testWidgets('a settled quire wears its count', (tester) async {
      await open(tester,
          best: await keeper({'woven.The Second Leaf': 1}));
      expect(find.text('woven in 1'), findsOne);
    });

    testWidgets('a row opens its quire', (tester) async {
      await open(tester);
      await tester.tap(find.text(Quires.at(2).name));
      await tester.pump();
      expect(state(tester).play.quire.name, Quires.at(2).name);
    });

    testWidgets('leaving a quire lands back on the bench',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the quires'));
      await tester.pump();
      expect(find.text('Quirebeck'), findsOne);
    });
  });
}
