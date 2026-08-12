import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchcote/round/cotes.dart';
import 'package:matchcote/ui/app.dart';
import 'package:matchcote/ui/cote_screen.dart';
import 'package:matchcote/ui/coteview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a cote, or on the coteland when [which] is
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
  await tester.pumpWidget(const MatchcoteApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Cotes.at(which).name));
    await tester.pumpAndSettle();
  }
}

CoteScreenState state(WidgetTester tester) =>
    tester.state<CoteScreenState>(find.byType(CoteScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The cote board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a player through the painter's metrics.
Future<void> tapPlayer(WidgetTester tester, int player) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.playerAt(player));
  await tester.pumpAndSettle();
}

/// Pairs two players.
Future<void> pairUp(WidgetTester tester, (int, int) pair) async {
  await tapPlayer(tester, pair.$1);
  await tapPlayer(tester, pair.$2);
}

/// Pairs a whole fixture, round after round.
Future<void> pairAll(
    WidgetTester tester, List<List<(int, int)>> rounds) async {
  for (final round in rounds) {
    for (final pair in round) {
      await pairUp(tester, pair);
    }
  }
}
