import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starholme/round/tours.dart';
import 'package:starholme/ui/app.dart';
import 'package:starholme/ui/round_screen.dart';
import 'package:starholme/ui/roundview.dart';

/// Opens the app on a tour, or on the holme when [which] is
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
  await tester.pumpWidget(const StarholmeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Tours.at(which).name));
    await tester.pumpAndSettle();
  }
}

RoundScreenState state(WidgetTester tester) =>
    tester.state<RoundScreenState>(find.byType(RoundScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The holme board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a post through the painter's metrics.
Future<void> tapPost(WidgetTester tester, int post) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.postAt(post));
  await tester.pumpAndSettle();
}

/// Walks a whole round and closes it.
Future<void> walkRound(WidgetTester tester, List<int> walk) async {
  for (final post in walk) {
    await tapPost(tester, post);
  }
  await tapPost(tester, walk.first);
}

/// Walks by the pointer until the tour closes.
Future<void> roundByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 16) {
    await press(tester, 'Show me');
    final post = state(tester).pointing!;
    await tapPost(tester, post);
  }
}
