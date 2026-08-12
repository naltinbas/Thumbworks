import 'package:beamsworth/beam/worths.dart';
import 'package:beamsworth/ui/app.dart';
import 'package:beamsworth/ui/beam_screen.dart';
import 'package:beamsworth/ui/beamview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a worth, or on the yard when [which] is null.
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
  await tester.pumpWidget(const BeamsworthApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Worths.at(which).name));
    await tester.pumpAndSettle();
  }
}

BeamScreenState state(WidgetTester tester) =>
    tester.state<BeamScreenState>(find.byType(BeamScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The yard board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a rack weight through the painter's metrics.
Future<void> tapWeight(WidgetTester tester, int weight) async {
  final room = board(tester);
  final metrics = Metrics(room.size);
  await tester.tapAt(room.topLeft + metrics.weightAt(weight));
  await tester.pumpAndSettle();
}

/// Chooses a whole handful.
Future<void> chooseAll(WidgetTester tester, List<int> weights) async {
  for (final weight in weights) {
    await tapWeight(tester, weight);
  }
}
