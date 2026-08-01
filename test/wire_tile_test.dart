import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/ui/wire_tile.dart';

/// One tile on its own, at a size a thumb would get on a phone.
Widget _tile(Cell cell, {bool lit = false}) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: WireTile(cell: cell, lit: lit),
        ),
      ),
    );

/// A halo is the only thing on a tile drawn far wider than the glyph, so its
/// radius is what separates a lamp that is on from one that is off.
bool Function(Symbol, List<dynamic>) _circleWiderThan(double radius) =>
    (method, arguments) =>
        method == #drawCircle && (arguments[1] as double) > radius;

bool Function(Symbol, List<dynamic>) _turnedBy(double atLeast) =>
    (method, arguments) =>
        method == #rotate && (arguments.first as double).abs() >= atLeast;

void main() {
  testWidgets('draws one stroke for every end its wire reaches',
      (tester) async {
    await tester.pumpWidget(
      _tile(Cell(kind: CellKind.wire, ends: Ends.north | Ends.east)),
    );

    expect(find.byType(WireTile), paintsExactlyCountTimes(#drawLine, 2));
  });

  testWidgets('lays a glow behind a wire the current has reached',
      (tester) async {
    await tester.pumpWidget(
      _tile(Cell(kind: CellKind.wire, ends: Ends.north | Ends.east), lit: true),
    );

    // Each end is stroked twice once it is live: the glow, then the wire.
    expect(find.byType(WireTile), paintsExactlyCountTimes(#drawLine, 4));
  });

  testWidgets('draws nothing on a cell with no wire in it', (tester) async {
    await tester.pumpWidget(_tile(Cell(kind: CellKind.empty, ends: Ends.none)));

    expect(find.byType(WireTile), paintsExactlyCountTimes(#drawLine, 0));
    expect(find.byType(WireTile), paintsExactlyCountTimes(#drawCircle, 0));
  });

  testWidgets('draws the wire part way round while the turn animates',
      (tester) async {
    final cell = Cell(kind: CellKind.wire, ends: Ends.north | Ends.east);
    await tester.pumpWidget(_tile(cell));
    expect(find.byType(WireTile), isNot(paints..something(_turnedBy(0.01))));

    await tester.pumpWidget(_tile(cell.turned));
    await tester.pump(const Duration(milliseconds: 40));

    // Part way through, the wire is drawn short of where the board has
    // already put it.
    expect(find.byType(WireTile), paints..something(_turnedBy(0.05)));

    await tester.pumpAndSettle();
    expect(find.byType(WireTile), isNot(paints..something(_turnedBy(0.01))));
  });

  testWidgets('leaves a cell still when a different board arrives',
      (tester) async {
    await tester.pumpWidget(_tile(Cell(kind: CellKind.wire, ends: Ends.east)));

    // A new level, not a move: three quarters further on than the last cell.
    await tester.pumpWidget(
      _tile(Cell(kind: CellKind.wire, ends: Ends.north, turns: 3)),
    );
    await tester.pump(const Duration(milliseconds: 40));

    expect(find.byType(WireTile), isNot(paints..something(_turnedBy(0.01))));
  });

  testWidgets('gives a lamp a halo only once it is lit', (tester) async {
    final lamp = Cell(kind: CellKind.lamp, ends: Ends.north);
    await tester.pumpWidget(_tile(lamp));
    expect(find.byType(WireTile), isNot(paints..something(_circleWiderThan(20))));

    await tester.pumpWidget(_tile(lamp, lit: true));
    await tester.pumpAndSettle();

    expect(find.byType(WireTile), paints..something(_circleWiderThan(20)));
  });

  testWidgets('draws the source as a shape no wire cell has', (tester) async {
    await tester.pumpWidget(_tile(Cell(kind: CellKind.source, ends: Ends.east)));
    expect(
      find.byType(WireTile),
      paints..something((method, arguments) => method == #drawPath),
    );

    await tester.pumpWidget(_tile(Cell(kind: CellKind.wire, ends: Ends.east)));
    expect(
      find.byType(WireTile),
      isNot(paints..something((method, arguments) => method == #drawPath)),
    );
  });
}
