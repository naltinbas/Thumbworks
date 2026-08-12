import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gapstile/gap/stiles.dart';
import 'package:gapstile/ui/app.dart';
import 'package:gapstile/ui/gap_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a stile, or on the fence when [which] is null.
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
  await tester.pumpWidget(const GapstileApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Stiles.at(which).name));
    await tester.pumpAndSettle();
  }
}

GapScreenState state(WidgetTester tester) =>
    tester.state<GapScreenState>(find.byType(GapScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The dial buttons: stride's pair sits above the round's.
Finder _button(WidgetTester tester, String sign, {required bool stride}) {
  final all = find.text(sign);
  return stride ? all.first : all.last;
}

Future<void> _turn(WidgetTester tester, String sign,
    {required bool stride}) async {
  await tester.tap(_button(tester, sign, stride: stride));
  await tester.pumpAndSettle();
}

/// One tap on the round's or the stride's up or down.
Future<void> turnRound(WidgetTester tester, int by) =>
    _turn(tester, by > 0 ? '+' : '−', stride: false);

Future<void> turnStride(WidgetTester tester, int by) =>
    _turn(tester, by > 0 ? '+' : '−', stride: true);

/// Turns the dial to a stride over a round, round first so the
/// stride has room.
Future<void> dialTo(WidgetTester tester, int stride, int round) async {
  var guard = 0;
  while (state(tester).play.round != round && guard++ < 24) {
    await _turn(tester, state(tester).play.round < round ? '+' : '−',
        stride: false);
  }
  while (state(tester).play.stride != stride && guard++ < 24) {
    await _turn(tester, state(tester).play.stride < stride ? '+' : '−',
        stride: true);
  }
}
