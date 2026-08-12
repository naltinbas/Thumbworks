import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackholt/stack/boxsets.dart';
import 'package:stackholt/ui/app.dart';
import 'package:stackholt/ui/stack_screen.dart';

/// Opens the app on a stack, or on the holt when [which] is null.
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
  await tester.pumpWidget(const StackholtApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(BoxSets.at(which).name));
    await tester.pumpAndSettle();
  }
}

StackScreenState state(WidgetTester tester) =>
    tester.state<StackScreenState>(find.byType(StackScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Spins or tips a box by its button.
Future<void> spin(WidgetTester tester, int box) =>
    press(tester, 'Spin ${box + 1}');

Future<void> tip(WidgetTester tester, int box) =>
    press(tester, 'Tip ${box + 1}');

/// Follows the pointer until the stack settles.
Future<void> settleByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 400) {
    final aim = state(tester).play.next!;
    final (box, wants) = aim;
    // Walk the box's turnings by tips and spins until it matches.
    var inner = 0;
    while (
        state(tester).play.walls[box] != wants && inner++ < 48) {
      // Try the four spins of this stand first, then tip.
      var spun = 0;
      while (state(tester).play.walls[box] != wants && spun < 3) {
        await spin(tester, box);
        spun++;
      }
      if (state(tester).play.walls[box] != wants) {
        await spin(tester, box);
        await tip(tester, box);
      }
    }
  }
}
