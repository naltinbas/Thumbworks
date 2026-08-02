import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/best_score.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/game/round.dart';
import 'package:latchword/ui/app.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/game_screen.dart';
import 'package:latchword/ui/grid_geometry.dart';
import 'package:latchword/ui/play_area.dart';
import 'package:latchword/ui/summary_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/tracing.dart';

/// The screens the game has to fit, in physical pixels at three times the
/// logical size, which is what the view is handed.
const _screens = <String, Size>{
  'iPhone SE, 320 by 568': Size(960, 1704),
  'a small Android, 360 by 640': Size(1080, 1920),
  'iPhone 14, 390 by 844': Size(1170, 2532),
  'Pixel 7, 412 by 915': Size(1236, 2745),
  'an iPad, 768 by 1024': Size(2304, 3072),
};

/// One ordinary setting, one large, the largest a phone offers, and past it:
/// iOS accessibility sizes go well beyond what Android's slider reaches.
const _textScales = [1.0, 1.6, 2.0, 3.0];

final _lexicon = Lexicon.of(['stare', 'least', 'stone']);

Board _board() => Board(
      size: 5,
      letters: 'starelmonewsdgeatirblnhoc'.split(''),
      lexicon: _lexicon,
    );

void main() {
  testWidgets('fits every screen at every text size', (tester) async {
    addTearDown(tester.view.reset);

    for (final textScale in _textScales) {
      for (final screen in _screens.entries) {
        final where = '${screen.key} at text scale $textScale';
        tester.view
          ..physicalSize = screen.value
          ..devicePixelRatio = 3;

        await tester.pumpWidget(MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: MaterialApp(home: PlayArea(board: _board())),
        ));

        expect(find.text('Trace a word'), findsOneWidget, reason: where);
        expect(
          tester.takeException(),
          isNull,
          reason: 'something overflowed on $where',
        );

        final box = tester.getRect(find.byType(BoardView));
        final grid = GridGeometry.fit(box.size, 5);
        final panel = grid.panel.shift(box.topLeft);
        final screenSize = screen.value / 3;
        expect(panel.left, greaterThanOrEqualTo(-0.01), reason: where);
        expect(panel.top, greaterThanOrEqualTo(-0.01), reason: where);
        expect(
          panel.right,
          lessThanOrEqualTo(screenSize.width + 0.01),
          reason: where,
        );
        expect(
          panel.bottom,
          lessThanOrEqualTo(screenSize.height + 0.01),
          reason: where,
        );
        expect(
          grid.side,
          greaterThanOrEqualTo(44),
          reason: 'a square has to be big enough for a thumb on $where',
        );
        expect(box.width, box.height, reason: 'the grid is square on $where');

        // A tree of its own for each shape, or the next one inherits this
        // one's state.
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('fits a whole round on every screen at every text size',
      (tester) async {
    // The board is only one of the three screens. The end of a round is the
    // one that carries the most words, and a word chip is the widest thing
    // the game draws.
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    const length = Duration(seconds: 30);
    final shipped = Lexicon.standard();

    for (final textScale in _textScales) {
      for (final screen in _screens.entries) {
        final where = '${screen.key} at text scale $textScale';
        tester.view
          ..physicalSize = screen.value
          ..devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;

        SharedPreferences.setMockInitialValues(<String, Object>{});
        await tester.pumpWidget(MaterialApp(
          theme: LatchwordApp.theme,
          home: GameScreen(
            lexicon: shipped,
            best: BestScore(await SharedPreferences.getInstance()),
            seeds: () => 1234,
            length: length,
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: 'the title overflowed on $where');

        await tester.tap(find.text('Play'));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: 'the round overflowed on $where');

        // The longest word on the board, because a long word is what makes a
        // chip too wide to fit.
        final board = tester.widget<PlayArea>(find.byType(PlayArea)).board;
        await traceWord(tester, board, Round.ranked(board.everyWord).first);
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull,
            reason: 'a word found overflowed on $where');

        await tester.pump(length + const Duration(seconds: 1));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(SummaryCard), findsOneWidget, reason: where);
        expect(tester.takeException(), isNull,
            reason: 'the end of the round overflowed on $where');

        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
