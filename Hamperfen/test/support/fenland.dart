import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamperfen/basket/fens.dart';
import 'package:hamperfen/ui/app.dart';
import 'package:hamperfen/ui/fen_screen.dart';
import 'package:hamperfen/ui/fenview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a fen, or on the fenland when [which] is null.
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
  await tester.pumpWidget(const HamperfenApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Fens.at(which).name));
    await tester.pumpAndSettle();
  }
}

FenScreenState state(WidgetTester tester) =>
    tester.state<FenScreenState>(find.byType(FenScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The fen board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a basket through the painter's metrics.
Future<void> tapBasket(WidgetTester tester, int basket) async {
  final room = board(tester);
  final metrics = Metrics(room.size);
  await tester.tapAt(room.topLeft + metrics.basketAt(basket));
  await tester.pumpAndSettle();
}

/// Takes a whole family.
Future<void> takeAll(WidgetTester tester, List<int> family) async {
  for (final basket in family) {
    await tapBasket(tester, basket);
  }
}
