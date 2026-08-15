import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stilemere/field/levels.dart';
import 'package:stilemere/field/rules.dart';
import 'package:stilemere/ui/app.dart';
import 'package:stilemere/ui/field_screen.dart';
import 'package:stilemere/ui/fieldview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a field, or on the sham when [which] is null.
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
  await tester.pumpWidget(const StilemereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

FieldScreenState state(WidgetTester tester) =>
    tester.state<FieldScreenState>(find.byType(FieldScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a junction through the painter's metrics.
Future<void> tapJunction(WidgetTester tester, Junction j) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(j));
  await tester.pumpAndSettle();
}

/// Steps along junctions one after another.
Future<void> stepAll(WidgetTester tester, List<Junction> junctions) async {
  for (final j in junctions) {
    await tapJunction(tester, j);
  }
}

/// Walks by the pointer until the field lands.
Future<void> walkByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    final (what, j) = state(tester).pointing!;
    if (what == 'back') {
      await press(tester, 'Back');
    } else {
      await tapJunction(tester, j);
    }
  }
}
