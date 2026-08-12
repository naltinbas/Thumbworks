import 'package:acreford/acre/fields.dart';
import 'package:acreford/ui/acre_screen.dart';
import 'package:acreford/ui/acreview.dart';
import 'package:acreford/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a field, or on the fieldland when [which]
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
  await tester.pumpWidget(const AcrefordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Fields.at(which).name));
    await tester.pumpAndSettle();
  }
}

AcreScreenState state(WidgetTester tester) =>
    tester.state<AcreScreenState>(find.byType(AcreScreen));

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

/// Taps a post through the painter's metrics.
Future<void> tapPost(WidgetTester tester, (int, int) post) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.postAt(post));
  await tester.pumpAndSettle();
}

/// Walks a whole fence and closes it back on the first post.
Future<void> fence(
    WidgetTester tester, List<(int, int)> walk) async {
  for (final post in walk) {
    await tapPost(tester, post);
  }
  await tapPost(tester, walk.first);
}

/// Fences by the pointer until the field lands.
Future<void> fenceByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (post, _) = state(tester).pointing!;
    await tapPost(tester, post);
  }
}
