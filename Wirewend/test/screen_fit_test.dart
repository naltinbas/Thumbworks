import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/game/progress.dart';
import 'package:wirewend/main.dart';
import 'package:wirewend/ui/board_view.dart';

/// The screens the game has to fit, in logical pixels: the smallest phone
/// either platform still runs on, the common shapes in between, and a tablet
/// because nothing stops one installing a phone game.
///
/// Written as physical pixels at three times the logical size, which is what
/// the view actually takes.
const _screens = <String, Size>{
  'iPhone SE, 320 by 568': Size(960, 1704),
  'a small Android, 360 by 640': Size(1080, 1920),
  'iPhone 8, 375 by 667': Size(1125, 2001),
  'a tall phone, 360 by 800': Size(1080, 2400),
  'iPhone 14, 390 by 844': Size(1170, 2532),
  'Pixel 7, 412 by 915': Size(1236, 2745),
  'an iPad, 768 by 1024': Size(2304, 3072),
};

/// One ordinary setting, one large, and the largest a phone offers. The game
/// screen holds text below the top of this range on purpose, so the last two
/// are expected to look alike.
const _textScales = [1.0, 1.6, 2.0];

/// The board that needs the most room: level 30 is past the point where the
/// grid stops growing, so it is the worst case every later level shares.
const _biggestLevel = 30;

Board boardOnScreen(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).board;

/// Starts the game on a screen of this shape with text at this scale, and
/// walks in to the board the way a player would.
Future<void> openBoard(
  WidgetTester tester, {
  required Size screen,
  required double textScale,
  required int level,
}) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 3;
  SharedPreferences.setMockInitialValues({'reached': level});
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Wirewend(progress: await Progress.open()),
    ),
  );
  await tester.pumpAndSettle();
  // The menu scrolls, so on a short screen the button may be below the fold.
  await tester.ensureVisible(find.byType(FilledButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the whole board on every screen at every text size',
      (tester) async {
    addTearDown(tester.view.reset);

    for (final textScale in _textScales) {
      for (final screen in _screens.entries) {
        final where = '${screen.key} at text scale $textScale';
        await openBoard(
          tester,
          screen: screen.value,
          textScale: textScale,
          level: _biggestLevel,
        );

        expect(find.text('Level $_biggestLevel'), findsOneWidget,
            reason: where);
        expect(tester.takeException(), isNull,
            reason: 'nothing overflowed on $where');
        expect(find.byType(Scrollable), findsNothing,
            reason: 'a puzzle you have to scroll to see is not one board');

        final board = boardOnScreen(tester);
        final tile = tester.getSize(find.byKey(const ValueKey<int>(0)));
        expect(tile.width, tile.height, reason: 'tiles are square on $where');
        final last = board.rows * board.cols - 1;
        expect(tester.getSize(find.byKey(ValueKey<int>(last))), tile,
            reason: 'every tile is the same size on $where');
        // Below this a thumb starts hitting the cell next door. It is the
        // whole reason the level sizes stop growing.
        expect(tile.width, greaterThanOrEqualTo(40), reason: where);

        // A fresh tree per shape: the app put up in place of the old one
        // would otherwise keep the navigator it already had.
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('shows the whole reward on every screen at every text size',
      (tester) async {
    addTearDown(tester.view.reset);

    for (final textScale in _textScales) {
      for (final screen in _screens.entries) {
        final where = '${screen.key} at text scale $textScale';
        // Level one, because this is about the banner rather than the board
        // and the first level is the quickest to finish.
        await openBoard(
          tester,
          screen: screen.value,
          textScale: textScale,
          level: 1,
        );

        final start = boardOnScreen(tester);
        for (var index = 0; index < start.rows * start.cols; index++) {
          final row = index ~/ start.cols;
          final col = index % start.cols;
          for (var left = (4 - start.at(row, col).turns % 4) % 4;
              left > 0;
              left--) {
            if (boardOnScreen(tester).isSolved) break;
            await tester.tap(find.byKey(ValueKey<int>(index)));
            await tester.pump();
          }
        }
        await tester.pumpAndSettle();

        expect(find.text('Level 1 solved'), findsOneWidget, reason: where);
        expect(find.text('Next level'), findsOneWidget,
            reason: 'the way on is reachable on $where');
        expect(tester.takeException(), isNull,
            reason: 'nothing overflowed on $where');

        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
