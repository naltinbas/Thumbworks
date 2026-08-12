import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noughtsmill/mill/grinds.dart';
import 'package:noughtsmill/ui/app.dart';
import 'package:noughtsmill/ui/mill_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a grind, or on the mill when [which] is null.
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
  await tester.pumpWidget(const NoughtsmillApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Grinds.at(which).name));
    await tester.pumpAndSettle();
  }
}

MillScreenState state(WidgetTester tester) =>
    tester.state<MillScreenState>(find.byType(MillScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Winds the mill to a target with the four winders.
Future<void> windTo(WidgetTester tester, int target) async {
  var guard = 0;
  while (state(tester).play.wound != target && guard++ < 60) {
    final far = target - state(tester).play.wound;
    if (far >= 10) {
      await press(tester, '+10');
    } else if (far > 0) {
      await press(tester, '+1');
    } else if (far <= -10) {
      await press(tester, '-10');
    } else {
      await press(tester, '-1');
    }
  }
}
