import 'package:flutter_test/flutter_test.dart';
import 'package:shelfham/shelf/shelves.dart';

import 'support/fonts.dart';
import 'support/ham.dart';

/// The ham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the ham lists every shelf by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Shelfham'), findsOneWidget);
    for (final shelf in Shelves.all) {
      expect(find.text(shelf.name), findsOneWidget);
      expect(find.textContaining(shelf.task), findsOneWidget);
    }
  });

  testWidgets('a shelf opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Sixty-Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two books to swap'),
      findsOneWidget,
    );
  });

  testWidgets('a shelving writes its fewest onto the ham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Step'));
    await tester.pumpAndSettle();
    await swap(tester, 0, 1);
    await press(tester, 'The ham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
