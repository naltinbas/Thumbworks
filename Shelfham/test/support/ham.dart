import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelfham/shelf/shelves.dart';
import 'package:shelfham/ui/app.dart';
import 'package:shelfham/ui/shelf_screen.dart';
import 'package:shelfham/ui/shelfview.dart';

/// Opens the app on a shelf, or on the ham when [which] is null.
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
  await tester.pumpWidget(const ShelfhamApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Shelves.at(which).name));
    await tester.pumpAndSettle();
  }
}

ShelfScreenState state(WidgetTester tester) =>
    tester.state<ShelfScreenState>(find.byType(ShelfScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The shelf board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps the book at a place through the painter's metrics.
Future<void> tapPlace(WidgetTester tester, int place) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.bookAt(place).center);
  await tester.pumpAndSettle();
}

/// Swaps the books at two places.
Future<void> swap(WidgetTester tester, int one, int two) async {
  await tapPlace(tester, one);
  await tapPlace(tester, two);
}

/// Shelves the books to a target ordering by following the pointer.
Future<void> shelveByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (place, book) = state(tester).pointing!;
    final at = state(tester).play.order.indexOf(book);
    await swap(tester, place, at);
  }
}
