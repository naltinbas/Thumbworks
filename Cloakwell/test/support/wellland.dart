import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloakwell/rail/levels.dart';
import 'package:cloakwell/rail/rules.dart';
import 'package:cloakwell/ui/app.dart';
import 'package:cloakwell/ui/rail_screen.dart';
import 'package:cloakwell/ui/railview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a rail, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CloakwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

RailScreenState state(WidgetTester tester) =>
    tester.state<RailScreenState>(find.byType(RailScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Swaps hooks [i] and [i + 1] through the painter's metrics.
Future<void> swapAt(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.gapAt(i));
  await tester.pumpAndSettle();
}

/// Swaps one after another.
Future<void> swapAll(WidgetTester tester, List<int> gaps) async {
  for (final g in gaps) {
    await swapAt(tester, g);
  }
}

/// Sorts by the pointer until the rail lands.
Future<void> sortByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, i) = state(tester).pointing!;
    await swapAt(tester, i);
  }
}

/// Sorts by the first descent, with no pointer.
Future<void> sortByDescents(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 12) {
    final d = Rules.firstDescent(state(tester).play.row);
    if (d == null) break;
    await swapAt(tester, d);
  }
}
