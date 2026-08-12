import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rackenford/rack/pantries.dart';
import 'package:rackenford/ui/app.dart';
import 'package:rackenford/ui/rack_screen.dart';
import 'package:rackenford/ui/rackview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a pantry, or on the larder when [which] is
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
  await tester.pumpWidget(const RackenfordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Pantries.at(which).name));
    await tester.pumpAndSettle();
  }
}

RackScreenState state(WidgetTester tester) =>
    tester.state<RackScreenState>(find.byType(RackScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The pantry board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a jar through the painter's metrics.
Future<void> tapJar(WidgetTester tester, int jar) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.jarAt(jar));
  await tester.pumpAndSettle();
}

/// Lifts a jar until it stands on [rack].
Future<void> liftTo(WidgetTester tester, int jar, int rack) async {
  var guard = 0;
  while (state(tester).play.racking[jar] != rack && guard++ < 5) {
    await tapJar(tester, jar);
  }
}

/// Racks by the pointer until the pantry lands.
Future<void> rackByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 50) {
    await press(tester, 'Show me');
    final jar = state(tester).pointing!;
    await tapJar(tester, jar);
  }
}
