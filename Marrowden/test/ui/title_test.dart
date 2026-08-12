import 'package:flutter_test/flutter_test.dart';
import 'package:marrowden/best.dart';
import 'package:marrowden/show/shows.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/show.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the den of benches', () {
    testWidgets('names the game and every bench', (tester) async {
      await open(tester);
      expect(find.text('Marrowden'), findsOne);
      for (var number = 0; number < Shows.count; number++) {
        expect(find.text(Shows.at(number).name), findsOne);
      }
    });

    testWidgets('the sure pick is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no rule ever does'),
        findsOne,
      );
    });

    testWidgets('a landed bench wears its count', (tester) async {
      await open(tester,
          best: await keeper({'landed.The Four Marrows': 9}));
      expect(find.text('landed in 9'), findsOne);
    });

    testWidgets('a row opens its bench', (tester) async {
      await open(tester);
      await tester.tap(find.text(Shows.at(2).name));
      await tester.pump();
      expect(state(tester).play.show.name, Shows.at(2).name);
    });

    testWidgets('leaving a bench lands back on the den',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the benches'));
      await tester.pump();
      expect(find.text('Marrowden'), findsOne);
    });
  });
}
