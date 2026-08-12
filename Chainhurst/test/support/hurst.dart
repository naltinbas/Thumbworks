import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chainhurst/chain/fields.dart';
import 'package:chainhurst/ui/app.dart';
import 'package:chainhurst/ui/chain_screen.dart';
import 'package:chainhurst/ui/chainview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a field, or on the hurst when [which] is null.
Future<void> open(
  WidgetTester tester, {
  int? which,
  Size? screen,
}) async {
  SharedPreferences.setMockInitialValues({});
  if (screen != null) {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(const ChainhurstApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Fields.at(which).name));
    await tester.pumpAndSettle();
  }
}

ChainScreenState state(WidgetTester tester) =>
    tester.state<ChainScreenState>(find.byType(ChainScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The field board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a crossing through the same metrics the painter draws by.
Future<void> tapCross(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(room.size);
  await tester.tapAt(room.topLeft + metrics.crossAt(x, y));
  await tester.pumpAndSettle();
}

/// Sets every stone of a placing.
Future<void> setAll(
    WidgetTester tester, List<(int, int)> stones) async {
  for (final (x, y) in stones) {
    await tapCross(tester, x, y);
  }
}
