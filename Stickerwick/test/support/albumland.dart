import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stickerwick/album/levels.dart';
import 'package:stickerwick/ui/app.dart';
import 'package:stickerwick/ui/album_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const StickerwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

AlbumScreenState state(WidgetTester tester) =>
    tester.state<AlbumScreenState>(find.byType(AlbumScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns the stickers dial one step, [by] 1 or -1.
Future<void> turnStickers(WidgetTester tester, int by) async {
  await tester.tap(find.byKey(Key('stickers${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Winds the packets by [by]: -10, -1, 1 or 10.
Future<void> windPackets(WidgetTester tester, int by) async {
  await tester.tap(find.byKey(Key('packets${by > 0 ? '+' : ''}$by')));
  await tester.pumpAndSettle();
}

/// Sets the stickers and the packets from where they stand, stickers
/// first by ones, packets by tens then ones.
Future<void> setDials(WidgetTester tester, int stickers, int packets) async {
  while (state(tester).play.stickers != stickers && !state(tester).play.isOver) {
    await turnStickers(tester, (stickers - state(tester).play.stickers).sign);
  }
  while (state(tester).play.packets != packets && !state(tester).play.isOver) {
    final gap = packets - state(tester).play.packets;
    await windPackets(tester, gap.abs() >= 10 ? gap.sign * 10 : gap.sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  if (which == 0) {
    await turnStickers(tester, by);
  } else {
    await windPackets(tester, by);
  }
}

/// Follows the pointer until the album lands, [most] steps at most.
Future<void> collectByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
