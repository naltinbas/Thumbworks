import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/ui/board_view.dart';
import 'package:wirewend/ui/palette.dart';
import 'package:wirewend/ui/wire_tile.dart';

/// Holds a board and plays moves the way a screen would, so the tests can ask
/// what a tap did rather than what it called.
class _Playable extends StatefulWidget {
  const _Playable({required this.start});

  final Board start;

  @override
  State<_Playable> createState() => _PlayableState();
}

class _PlayableState extends State<_Playable> {
  late Board _board = widget.start;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          backgroundColor: Palette.backdrop,
          body: BoardView(
            board: _board,
            onTapCell: (row, col) =>
                setState(() => _board = _board.turn(row, col)),
          ),
        ),
      );
}

/// Every cell is wire of some sort, so every tile is worth tapping.
Board _fullGrid() => Board(
      rows: 3,
      cols: 3,
      cells: [
        for (var i = 0; i < 9; i++)
          Cell(
            kind: switch (i) {
              0 => CellKind.source,
              8 => CellKind.lamp,
              _ => CellKind.wire,
            },
            ends: Ends.north | Ends.east,
          ),
      ],
    );

/// A source facing its lamp, and the lamp one quarter away from facing back.
Board _oneTapFromSolved() => Board(
      rows: 1,
      cols: 2,
      cells: [
        Cell(kind: CellKind.source, ends: Ends.east),
        Cell(kind: CellKind.lamp, ends: Ends.south),
      ],
    );

Board _boardOnScreen(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).board;

/// Any shape put down in this colour, whatever call drew it: a border with a
/// radius lands as a rounded rect or a pair of them depending on its width.
///
/// Compared as packed bytes because a Paint keeps its colour as floats, so a
/// colour that went through one gives back something a shade off what went in.
bool Function(Symbol, List<dynamic>) _anythingDrawnIn(Color colour) =>
    (method, arguments) {
      final paint = arguments.isEmpty ? null : arguments.last;
      return paint is Paint && paint.color.toARGB32() == colour.toARGB32();
    };

void main() {
  testWidgets('gives every cell of the board a tile', (tester) async {
    await tester.pumpWidget(_Playable(start: _fullGrid()));

    expect(find.byType(WireTile), findsNWidgets(9));
  });

  testWidgets('fits a portrait phone without scrolling', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _Playable(start: Board(rows: 7, cols: 5, cells: [
        for (var i = 0; i < 35; i++)
          Cell(kind: i == 0 ? CellKind.source : CellKind.wire, ends: Ends.east),
      ])),
    );

    final panel = tester.getSize(find.byType(AnimatedContainer));
    expect(panel.width, lessThanOrEqualTo(360));
    expect(panel.height, lessThanOrEqualTo(640));
    expect(find.byType(Scrollable), findsNothing);

    final tile = tester.getSize(find.byKey(const ValueKey<int>(0)));
    expect(tile.width, tile.height, reason: 'tiles are square');
    expect(tile.width, greaterThanOrEqualTo(48),
        reason: 'a tile has to be big enough for a thumb');
    expect(tester.getSize(find.byKey(const ValueKey<int>(34))), tile,
        reason: 'every tile is the same size');
  });

  testWidgets('turns exactly the one cell that was tapped', (tester) async {
    await tester.pumpWidget(_Playable(start: _fullGrid()));
    final before = _boardOnScreen(tester);

    await tester.tap(find.byKey(const ValueKey<int>(4)));
    await tester.pumpAndSettle();

    final after = _boardOnScreen(tester);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final wasTapped = row * 3 + col == 4;
        expect(
          after.at(row, col).ends,
          wasTapped ? before.at(row, col).ends.turned : before.at(row, col).ends,
          reason: 'cell $row,$col',
        );
      }
    }
  });

  testWidgets('ignores a tap that lands on a cell with no wire',
      (tester) async {
    await tester.pumpWidget(
      _Playable(start: Board(rows: 1, cols: 2, cells: [
        Cell(kind: CellKind.source, ends: Ends.east),
        Cell(kind: CellKind.empty, ends: Ends.none),
      ])),
    );

    await tester.tap(find.byKey(const ValueKey<int>(1)));
    await tester.pumpAndSettle();

    expect(_boardOnScreen(tester).at(0, 1).turns, 0);
  });

  testWidgets('lights a lamp the move connects to the source', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_Playable(start: _oneTapFromSolved()));

    expect(find.bySemanticsLabel('unlit lamp'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<int>(1)));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('lit lamp'), findsOneWidget);
    expect(find.bySemanticsLabel('unlit lamp'), findsNothing);
    semantics.dispose();
  });

  testWidgets('marks the board itself once every lamp is lit', (tester) async {
    await tester.pumpWidget(_Playable(start: _oneTapFromSolved()));
    expect(
      find.byType(BoardView),
      isNot(paints..something(_anythingDrawnIn(Palette.solvedEdge))),
    );

    await tester.tap(find.byKey(const ValueKey<int>(1)));
    await tester.pumpAndSettle();

    expect(_boardOnScreen(tester).isSolved, isTrue);
    expect(
      find.byType(BoardView),
      paints..something(_anythingDrawnIn(Palette.solvedEdge)),
    );
  });
}
