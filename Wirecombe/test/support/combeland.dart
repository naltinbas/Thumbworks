import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wirecombe/ui/app.dart';
import 'package:wirecombe/ui/combe_screen.dart';
import 'package:wirecombe/ui/combeview.dart';
import 'package:wirecombe/wire/combes.dart';

/// Opens the app on a combe, or on the combeland when [which] is
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
  await tester.pumpWidget(const WirecombeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Combes.at(which).name));
    await tester.pumpAndSettle();
  }
}

CombeScreenState state(WidgetTester tester) =>
    tester.state<CombeScreenState>(find.byType(CombeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The combe board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a cottage through the same metrics the painter draws by.
Future<void> tapCottage(WidgetTester tester, int cottage) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cottageAt(cottage));
  await tester.pumpAndSettle();
}

/// Wires a line between two cottages.
Future<void> wireLine(WidgetTester tester, (int, int) line) async {
  await tapCottage(tester, line.$1);
  await tapCottage(tester, line.$2);
}

/// Wires every line of a run.
Future<void> wireAll(
    WidgetTester tester, List<(int, int)> lines) async {
  for (final line in lines) {
    await wireLine(tester, line);
  }
}
