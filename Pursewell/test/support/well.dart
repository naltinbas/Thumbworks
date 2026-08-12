import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pursewell/purse/purses.dart';
import 'package:pursewell/ui/app.dart';
import 'package:pursewell/ui/purse_screen.dart';
import 'package:pursewell/ui/purseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a purse, or on the well when [which] is null.
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
  await tester.pumpWidget(const PursewellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Purses.at(which).name));
    await tester.pumpAndSettle();
  }
}

PurseScreenState state(WidgetTester tester) =>
    tester.state<PurseScreenState>(find.byType(PurseScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The well board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a counter coin through the painter's metrics.
Future<void> tapCoin(WidgetTester tester, int coin) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.coinAt(coin));
  await tester.pumpAndSettle();
}

/// Pays a whole handful.
Future<void> payAll(WidgetTester tester, List<int> coins) async {
  for (final coin in coins) {
    await tapCoin(tester, coin);
  }
}
