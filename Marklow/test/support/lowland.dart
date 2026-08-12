import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marklow/mark/lows.dart';
import 'package:marklow/ui/app.dart';
import 'package:marklow/ui/low_screen.dart';
import 'package:marklow/ui/lowview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a low, or on the lowland when [which] is null.
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
  await tester.pumpWidget(const MarklowApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Lows.at(which).name));
    await tester.pumpAndSettle();
  }
}

LowScreenState state(WidgetTester tester) =>
    tester.state<LowScreenState>(find.byType(LowScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The low board, as laid out.
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

/// Marks a post to a wanted number.
Future<void> markTo(WidgetTester tester, int post, int mark) async {
  var guard = 0;
  final most = state(tester).play.low.lines.length + 2;
  while (state(tester).play.numbering[post] != mark &&
      guard++ < most) {
    await tapPost(tester, post);
  }
}

/// Marks the whole low to a target numbering.
Future<void> markAll(WidgetTester tester, List<int> target) async {
  for (var post = 0; post < target.length; post++) {
    await markTo(tester, post, target[post]);
  }
}
