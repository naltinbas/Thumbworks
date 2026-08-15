import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cubewick/hex/levels.dart';
import 'package:cubewick/hex/rules.dart';
import 'package:cubewick/ui/app.dart';
import 'package:cubewick/ui/hex_screen.dart';
import 'package:cubewick/ui/hexview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a hexagon, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CubewickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

HexScreenState state(WidgetTester tester) =>
    tester.state<HexScreenState>(find.byType(HexScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a triangle through the painter's metrics.
Future<void> tapTri(WidgetTester tester, Tri t) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(t));
  await tester.pumpAndSettle();
}

/// Lays a lozenge by two taps.
Future<void> lay(WidgetTester tester, Lozenge l) async {
  await tapTri(tester, l.$1);
  await tapTri(tester, l.$2);
}

/// Lays lozenges one after another.
Future<void> layAll(WidgetTester tester, List<Lozenge> lozenges) async {
  for (final l in lozenges) {
    await lay(tester, l);
  }
}

/// Lays by the pointer until the hexagon is tiled.
Future<void> layByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (what, l) = state(tester).pointing!;
    if (what == 'lift') {
      await tapTri(tester, l.$1);
    } else {
      await lay(tester, l);
    }
  }
}

/// Lays lozenges anyhow, first free pair each time, until none fits.
Future<void> layAnyhow(WidgetTester tester) async {
  var guard = 0;
  while (state(tester).play.canLay && guard++ < 40) {
    final play = state(tester).play;
    Lozenge? next;
    for (final up in play.hexagon.ups) {
      if (play.covered(up)) continue;
      for (final d in Hexagon.mates(up)) {
        if (play.hexagon.holds(d) && !play.covered(d)) {
          next = (up, d);
          break;
        }
      }
      if (next != null) break;
    }
    await lay(tester, next!);
  }
}
