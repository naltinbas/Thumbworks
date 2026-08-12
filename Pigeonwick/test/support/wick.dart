import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeonwick/post/rounds.dart';
import 'package:pigeonwick/ui/app.dart';
import 'package:pigeonwick/ui/post_screen.dart';
import 'package:pigeonwick/ui/postview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a round, or on the wick when [which] is null.
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
  await tester.pumpWidget(const PigeonwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Rounds.at(which).name));
    await tester.pumpAndSettle();
  }
}

PostScreenState state(WidgetTester tester) =>
    tester.state<PostScreenState>(find.byType(PostScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The round board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a bagged letter through the painter's metrics.
Future<void> tapLetter(WidgetTester tester, int letter) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.seatAt(letter));
  await tester.pumpAndSettle();
}

/// Taps a hole through the painter's metrics.
Future<void> tapHole(WidgetTester tester, int hole) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.holeAt(hole));
  await tester.pumpAndSettle();
}

/// Posts a letter to a hole.
Future<void> post(WidgetTester tester, int letter, int hole) async {
  await tapLetter(tester, letter);
  await tapHole(tester, hole);
}

/// Posts a whole round.
Future<void> postAll(WidgetTester tester, List<int> posting) async {
  for (var letter = 0; letter < posting.length; letter++) {
    await post(tester, letter, posting[letter]);
  }
}
