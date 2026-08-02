import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emberlane/sim/field.dart';
import 'package:emberlane/sim/kinds.dart';
import 'package:emberlane/sim/run.dart';
import 'package:emberlane/ui/app.dart';
import 'package:emberlane/ui/run_screen.dart';
import 'package:emberlane/ui/title_screen.dart';

import '../support/playing.dart';

/// A phone to lay the game out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  Run? at,
  bool playing = true,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(EmberlaneApp(opening: at, opensPlaying: playing));
  await tester.pump();
}

void main() {
  group('the title', () {
    testWidgets('says what the towers do, and starts a run', (tester) async {
      await open(tester, playing: false);

      expect(find.text('Emberlane'), findsOneWidget);
      for (final tower in Tower.values) {
        expect(find.textContaining(tower.name), findsWidgets);
      }
      expect(find.byType(RunScreen), findsNothing);

      await tester.ensureVisible(find.text('Play'));
      await tester.pump();
      await tester.tap(find.text('Play'));
      await tester.pump();

      expect(find.byType(RunScreen), findsOneWidget);
      expect(find.byType(TitleScreen), findsNothing);
    });
  });

  group('building', () {
    testWidgets('takes two taps: the shop, then the square', (tester) async {
      await open(tester);
      expect(run(tester).built, isEmpty);

      // The square on its own does nothing until a tower is chosen.
      await tapCell(tester, const Cell(3, 1));
      expect(run(tester).built, isEmpty);

      await tester.tap(find.text('Spark'));
      await tester.pump();
      await tapCell(tester, const Cell(3, 1));

      expect(run(tester).built, hasLength(1));
      expect(run(tester).built.first.on, const Cell(3, 1));
      expect(run(tester).embers, Run.startingEmbers - Tower.spark.cost);
    });

    testWidgets('will not build on the lane', (tester) async {
      await open(tester);
      await tester.tap(find.text('Spark'));
      await tester.pump();

      await tapCell(tester, Field.only.path[4]);
      expect(run(tester).built, isEmpty, reason: 'that square is the lane');
    });

    testWidgets('will not build what cannot be paid for', (tester) async {
      await open(tester);
      // A forge costs more than a run starts with.
      await tester.tap(find.text('Forge'));
      await tester.pump();
      await tapCell(tester, const Cell(3, 1));
      expect(run(tester).built, isEmpty);
    });
  });

  group('a tower already there', () {
    testWidgets('opens its panel, and can be upgraded and sold',
        (tester) async {
      await open(tester, at: Run.fresh(embers: 500));
      await tester.tap(find.text('Spark'));
      await tester.pump();
      await tapCell(tester, const Cell(3, 1));

      // Tapping it again asks about it rather than building another.
      await tapCell(tester, const Cell(3, 1));
      expect(find.textContaining('Upgrade'), findsOneWidget);
      expect(find.textContaining('Sell'), findsOneWidget);

      await tester.tap(find.textContaining('Upgrade'));
      await tester.pump();
      expect(run(tester).towerOn(const Cell(3, 1))!.level, 2);

      await tester.tap(find.textContaining('Sell'));
      await tester.pump();
      expect(run(tester).built, isEmpty);
    });
  });

  group('waves', () {
    testWidgets('do not start until they are sent', (tester) async {
      await open(tester);
      await letItRun(tester, const Duration(seconds: 3));
      expect(run(tester).walking, isEmpty);

      await tester.tap(find.textContaining('Send wave 1'));
      await tester.pump();
      await letItRun(tester, const Duration(seconds: 1));
      expect(run(tester).walking, isNotEmpty);
    });

    testWidgets('walk, and the clock keeps its own time', (tester) async {
      await open(tester);
      await tester.tap(find.textContaining('Send wave 1'));
      await tester.pump();
      await letItRun(tester, const Duration(seconds: 2));

      final walker = run(tester).walking.first;
      // Two seconds at a drifter's pace, give or take a frame either way.
      expect(walker.along, closeTo(Walker.drifter.pace * 2, 0.4));
    });

    testWidgets('cost the keep when they get through', (tester) async {
      await open(tester);
      await tester.tap(find.textContaining('Send wave 1'));
      await tester.pump();
      // Nothing built, so they walk the whole lane.
      await letItRun(tester, const Duration(seconds: 25));
      expect(run(tester).keep, lessThan(Run.startingKeep));
    });
  });

  group('leaving it', () {
    testWidgets('stops the run where it was', (tester) async {
      await open(tester);
      await tester.tap(find.textContaining('Send wave 1'));
      await tester.pump();
      await letItRun(tester, const Duration(seconds: 2));
      final was = run(tester).steps;

      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await letItRun(tester, const Duration(seconds: 5));

      expect(find.text('Paused'), findsOneWidget);
      expect(run(tester).steps, was, reason: 'it ran on without anybody there');

      // Back on screen, but still covered: the run waits to be picked up.
      for (final state in const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await letItRun(tester, const Duration(seconds: 2));
      expect(run(tester).steps, was, reason: 'the cover is still up');

      await tester.tap(find.text('Tap to carry on'));
      await tester.pump();
      await letItRun(tester, const Duration(seconds: 1));
      expect(run(tester).steps, greaterThan(was));
    });
  });

  group('the end', () {
    testWidgets('says the keep fell and offers another run', (tester) async {
      // One keep left and a wave already walking.
      await open(tester, at: Run.fresh(keep: 1));
      await tester.tap(find.textContaining('Send wave 1'));
      await tester.pump();
      await letItRun(tester, const Duration(seconds: 25));

      expect(find.text('The keep falls'), findsOneWidget);
      expect(find.text('Another run'), findsOneWidget);

      await tester.tap(find.text('Another run'));
      await tester.pump();
      expect(run(tester).keep, Run.startingKeep);
      expect(run(tester).steps, 0);
    });
  });

  group('fitting a phone', () {
    for (final entry in const {
      'iphone-se': Size(320, 568),
      'iphone-14': Size(390, 844),
      'pixel-7': Size(412, 915),
    }.entries) {
      testWidgets('the field fits and is playable on ${entry.key}',
          (tester) async {
        await open(tester, screen: entry.value * 3);

        final metrics = metricsOf(tester);
        expect(metrics.cell, greaterThan(20),
            reason: 'a cell a thumb can hit');

        await tester.tap(find.text('Spark'));
        await tester.pump();
        await tapCell(tester, const Cell(3, 1));
        expect(run(tester).built, hasLength(1));
      });
    }
  });
}
