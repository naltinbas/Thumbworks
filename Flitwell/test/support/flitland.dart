import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flitwell/flit/levels.dart';
import 'package:flitwell/ui/app.dart';
import 'package:flitwell/ui/flit_screen.dart';
import 'package:flitwell/ui/flitview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the lane when [which] is null.
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
  await tester.pumpWidget(const FlitwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few asks only until it scrolls.
      await tester.scrollUntilVisible(tile, 80,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

FlitScreenState state(WidgetTester tester) =>
    tester.state<FlitScreenState>(find.byType(FlitScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a tenant is drawn, which is where a thumb goes.
Offset tenantAt(WidgetTester tester, int tenant) {
  final where = board(tester);
  return where.topLeft + Metrics(state(tester).play, where.size).perch(tenant);
}

/// The sky over a cottage, for a tap that should land on nobody.
Offset skyOver(WidgetTester tester, int cottage) {
  final where = board(tester);
  final m = Metrics(state(tester).play, where.size);
  return where.topLeft + m.cottage(cottage) - Offset(0, m.tall * 0.55);
}

/// Taps a tenant, which picks them up or swaps them with whoever waits.
Future<void> tapTenant(WidgetTester tester, int tenant) async {
  await tester.tapAt(tenantAt(tester, tenant));
  await tester.pumpAndSettle();
}

/// Swaps two tenants, which is two taps.
Future<void> swap(WidgetTester tester, int one, int two) async {
  await tapTenant(tester, one);
  await tapTenant(tester, two);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  await swap(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] swaps at most.
Future<void> landByPointer(WidgetTester tester, {int most = 6}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
