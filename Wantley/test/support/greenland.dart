import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wantley/ui/app.dart';
import 'package:wantley/ui/wish_screen.dart';
import 'package:wantley/ui/wishview.dart';
import 'package:wantley/wish/wishes.dart';

/// Opens the app on a wish list, or on the green when [which]
/// is null.
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
  await tester.pumpWidget(const WantleyApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Wishes.at(which).name));
    await tester.pumpAndSettle();
  }
}

WishScreenState state(WidgetTester tester) =>
    tester.state<WishScreenState>(find.byType(WishScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The green board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a pair's path through the painter's metrics.
Future<void> tapPath(WidgetTester tester, int pair) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.midOf(pair));
  await tester.pumpAndSettle();
}

/// Treads by the pointer until the list lands.
Future<void> landByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    final pair = state(tester).pointing!;
    await tapPath(tester, pair);
  }
}
