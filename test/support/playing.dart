import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emberlane/sim/field.dart';
import 'package:emberlane/sim/run.dart';
import 'package:emberlane/ui/field_painter.dart';
import 'package:emberlane/ui/run_screen.dart';

/// The bits every test that touches the field needs.

RunScreenState screenState(WidgetTester tester) =>
    tester.state<RunScreenState>(find.byType(RunScreen));

Run run(WidgetTester tester) => screenState(tester).run;

Finder fieldPaint() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is FieldPainter,
    );

/// Where the field thinks a cell is.
///
/// Read off the painter rather than worked out again, so a tap lands on the
/// cell the game is actually drawing. A test with its own copy of the geometry
/// keeps passing while the field drifts under the thumb.
Metrics metricsOf(WidgetTester tester) =>
    (tester.widget<CustomPaint>(fieldPaint().first).painter as FieldPainter)
        .metrics;

Offset spotOf(WidgetTester tester, Cell cell) =>
    tester.getTopLeft(fieldPaint().first) + metricsOf(tester).rectOf(cell).center;

Future<void> tapCell(WidgetTester tester, Cell cell) async {
  await tester.tapAt(spotOf(tester, cell));
  await tester.pump();
}

/// Lets the clock run for a while, a frame at a time.
Future<void> letItRun(WidgetTester tester, Duration how) async {
  const frame = Duration(milliseconds: 16);
  for (var gone = Duration.zero; gone < how; gone += frame) {
    await tester.pump(frame);
  }
}
