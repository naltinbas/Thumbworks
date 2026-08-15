import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetleigh/string/shares.dart';
import 'package:sweetleigh/ui/app.dart';
import 'package:sweetleigh/ui/string_screen.dart';
import 'package:sweetleigh/ui/stringview.dart';

/// Opens the app on a share, or on the sham when [which] is null.
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
  await tester.pumpWidget(const SweetleighApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Shares.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

StringScreenState state(WidgetTester tester) =>
    tester.state<StringScreenState>(find.byType(StringScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a gap through the painter's metrics.
Future<void> tapGap(WidgetTester tester, int gap) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.gapAt(gap));
  await tester.pumpAndSettle();
}

/// Cuts gaps one after another.
Future<void> cutAll(WidgetTester tester, List<int> gaps) async {
  for (final gap in gaps) {
    await tapGap(tester, gap);
  }
}

/// Cuts by the pointer until the share lands.
Future<void> cutByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, gap) = state(tester).pointing!;
    await tapGap(tester, gap);
  }
}
