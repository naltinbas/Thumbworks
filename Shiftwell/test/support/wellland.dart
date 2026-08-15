import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftwell/rota/rotas.dart';
import 'package:shiftwell/rota/rules.dart';
import 'package:shiftwell/ui/app.dart';
import 'package:shiftwell/ui/rota_screen.dart';
import 'package:shiftwell/ui/rotaview.dart';

/// Opens the app on a rota, or on the sham when [which] is null.
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
  await tester.pumpWidget(const ShiftwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Rotas.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

RotaScreenState state(WidgetTester tester) =>
    tester.state<RotaScreenState>(find.byType(RotaScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a shift through the painter's metrics.
Future<void> tapShift(WidgetTester tester, Shift shift) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(shift));
  await tester.pumpAndSettle();
}

/// Turns a shift round to a hand: taps until it reads so.
Future<void> setHand(WidgetTester tester, Shift shift, int hand) async {
  var guard = 0;
  while (state(tester).play.filled[shift] != hand && guard++ < 6) {
    await tapShift(tester, shift);
  }
}

/// Fills by the pointer until the rota finishes.
Future<void> fillByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (shift, hand) = state(tester).pointing!;
    await setHand(tester, shift, hand);
  }
}
