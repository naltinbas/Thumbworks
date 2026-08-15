import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patchmere/quilt/levels.dart';
import 'package:patchmere/quilt/rules.dart';
import 'package:patchmere/ui/app.dart';
import 'package:patchmere/ui/quilt_screen.dart';
import 'package:patchmere/ui/quiltview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a level, or on the sham when [which] is null.
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
  await tester.pumpWidget(const PatchmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

QuiltScreenState state(WidgetTester tester) =>
    tester.state<QuiltScreenState>(find.byType(QuiltScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cell through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int cell) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(cell));
  await tester.pumpAndSettle();
}

/// Sews a patch by two taps; the house answers.
Future<void> sew(WidgetTester tester, Patch patch) async {
  await tapCell(tester, patch.$1);
  await tapCell(tester, patch.$2);
}

/// Sews patches one after another.
Future<void> sewAll(WidgetTester tester, List<Patch> patches) async {
  for (final patch in patches) {
    await sew(tester, patch);
  }
}

/// Sews by the pointer until the quilt is out.
Future<void> sewByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 12) {
    await press(tester, 'Show me');
    final patch = state(tester).pointing!;
    await sew(tester, patch);
  }
}

/// Sews the first patch that fits, over and over, until the quilt
/// is out.
Future<void> sewAnyhow(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 12) {
    final play = state(tester).play;
    await sew(tester, play.quilt.moves(play.sewn).first);
  }
}
