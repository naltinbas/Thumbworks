import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weirbank/best.dart';
import 'package:weirbank/ui/app.dart';
import 'package:weirbank/ui/waterworks.dart';
import 'package:weirbank/ui/works_screen.dart';

/// The bits every test that sets a works needs.

/// A phone to lay the works out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last works'.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // In a boundary, so a screenshot can be taken of whatever a test leaves on
  // it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: WeirbankApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WorksScreenState state(WidgetTester tester) =>
    tester.state<WorksScreenState>(find.byType(WorksScreen));

/// Where a pipe is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int pipe) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WorksScreenState.worksKey),
  );
  final metrics = Metrics(state(tester).play.works, box.size);
  return box.localToGlobal(metrics.middleOfPipe(pipe));
}

/// Taps a pipe, which sends one more down it.
Future<void> turn(WidgetTester tester, int pipe) async {
  await tester.tapAt(whereIs(tester, pipe));
  await tester.pump();
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Sets every pipe to what the answer has in it, one tap at a time.
Future<void> setItAll(WidgetTester tester) async {
  final most = state(tester).most;
  for (var pipe = 0; pipe < most.down.length; pipe++) {
    for (var one = 0; one < most.down[pipe]; one++) {
      await turn(tester, pipe);
    }
  }
}
