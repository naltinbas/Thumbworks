import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slicebury/slice/cakes.dart';
import 'package:slicebury/ui/app.dart';
import 'package:slicebury/ui/slice_screen.dart';
import 'package:slicebury/ui/sliceview.dart';

/// Opens the app on a cake, or on the bury when [which] is
/// null.
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
  await tester.pumpWidget(const SliceburyApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Cakes.at(which).name));
    await tester.pumpAndSettle();
  }
}

SliceScreenState state(WidgetTester tester) =>
    tester.state<SliceScreenState>(find.byType(SliceScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The bury board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a rim spot through the painter's metrics.
Future<void> tapSpot(WidgetTester tester, int spot) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.spotAt(spot));
  await tester.pumpAndSettle();
}

/// Sets candles by the pointer until the cake lands.
Future<void> cutByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 16) {
    await press(tester, 'Show me');
    final spot = state(tester).pointing!;
    await tapSpot(tester, spot);
  }
}
