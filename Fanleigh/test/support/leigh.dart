import 'package:fanleigh/fold/folds.dart';
import 'package:fanleigh/ui/app.dart';
import 'package:fanleigh/ui/fold_screen.dart';
import 'package:fanleigh/ui/foldview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a fold, or on the leigh when [which] is null.
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
  await tester.pumpWidget(const FanleighApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Folds.at(which).name));
    await tester.pumpAndSettle();
  }
}

FoldScreenState state(WidgetTester tester) =>
    tester.state<FoldScreenState>(find.byType(FoldScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The paddock board, as laid out.
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

/// Lays a hurdle between two posts.
Future<void> layHurdle(WidgetTester tester, (int, int) hurdle) async {
  await tapPost(tester, hurdle.$1);
  await tapPost(tester, hurdle.$2);
}

/// Lays a whole fencing.
Future<void> layAll(
    WidgetTester tester, List<(int, int)> hurdles) async {
  for (final hurdle in hurdles) {
    await layHurdle(tester, hurdle);
  }
}
