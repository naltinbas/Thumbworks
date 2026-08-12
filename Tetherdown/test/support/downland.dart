import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetherdown/down/downs.dart';
import 'package:tetherdown/ui/app.dart';
import 'package:tetherdown/ui/down_screen.dart';
import 'package:tetherdown/ui/downview.dart';

/// Opens the app on a down, or on the downland when [which] is null.
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
  await tester.pumpWidget(const TetherdownApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Downs.at(which).name));
    await tester.pumpAndSettle();
  }
}

DownScreenState state(WidgetTester tester) =>
    tester.state<DownScreenState>(find.byType(DownScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The down board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a post through the same metrics the painter draws by.
Future<void> tapPost(WidgetTester tester, int post) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.postAt(post));
  await tester.pumpAndSettle();
}

/// Ties a rope between two posts.
Future<void> tieRope(WidgetTester tester, (int, int) rope) async {
  await tapPost(tester, rope.$1);
  await tapPost(tester, rope.$2);
}

/// Ties every rope of a tethering.
Future<void> tieAll(
    WidgetTester tester, List<(int, int)> ropes) async {
  for (final rope in ropes) {
    await tieRope(tester, rope);
  }
}
