import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultline/sim/ground.dart';
import 'package:vaultline/sim/journey.dart';
import 'package:vaultline/sim/library.dart';
import 'package:vaultline/sim/runner.dart';
import 'package:vaultline/ui/over_card.dart';
import 'package:vaultline/ui/run_screen.dart';
import 'package:vaultline/ui/title_screen.dart';

import '../support/playing.dart';

void main() {
  group('the title', () {
    testWidgets('makes the promise and starts a run', (tester) async {
      await open(tester, running: false);

      expect(find.text('Vaultline'), findsOneWidget);
      expect(find.text('Every stretch has been got through'), findsOneWidget);
      expect(find.textContaining('${Library.count} of them'), findsOneWidget);
      expect(find.text('no run yet'), findsOneWidget);
      expect(find.byType(RunScreen), findsNothing);

      await tester.tap(find.text('Run'));
      await tester.pump();

      expect(find.byType(RunScreen), findsOneWidget);
      expect(find.byType(TitleScreen), findsNothing);
    });

    testWidgets('shows the furthest run so far', (tester) async {
      await open(tester, running: false, saved: {'best.tiles': 412});
      expect(find.text('furthest 412'), findsOneWidget);
    });

    testWidgets('plays itself behind the words', (tester) async {
      await open(tester, running: false);
      final was = shownAt(tester);
      await letItRun(tester, const Duration(seconds: 2));
      expect(shownAt(tester), greaterThan(was + 5),
          reason: 'the runner behind the title should be running');
    });
  });

  group('running', () {
    testWidgets('goes forwards on its own', (tester) async {
      await open(tester);
      final was = journey(tester).run.x;

      await letItRun(tester, const Duration(seconds: 1));

      expect(journey(tester).run.x, greaterThan(was + 5));
      expect(journey(tester).isOver, isFalse,
          reason: 'the first stretch is flat');
    });

    testWidgets('the whole screen is the button', (tester) async {
      await open(tester);
      await letItRun(tester, const Duration(milliseconds: 200));

      // A touch anywhere, including where the score is drawn.
      final gesture = await tester.startGesture(const Offset(300, 700));
      await tester.pump();
      expect(screenState(tester).holding, isTrue);

      await letItRun(tester, const Duration(milliseconds: 200));
      expect(journey(tester).run.y, greaterThan(0.3),
          reason: 'holding should have left the ground');

      await gesture.up();
      await tester.pump();
      expect(screenState(tester).holding, isFalse);
    });

    testWidgets('counts the tiles gone by', (tester) async {
      await open(tester);
      await letItRun(tester, const Duration(seconds: 2));
      expect(find.text('${journey(tester).score}'), findsOneWidget);
      expect(journey(tester).score, greaterThan(10));
    });
  });

  group('dying', () {
    testWidgets('says what happened and writes the run down', (tester) async {
      // A pit a few tiles ahead and nobody touching the button.
      final doomed = Journey.begin(seed: 1);
      await open(tester, at: _intoAPit(), saved: {'best.tiles': 3});

      await letItRun(tester, const Duration(seconds: 3));

      expect(journey(tester).isOver, isTrue);
      expect(find.byType(OverCard), findsOneWidget);
      expect(find.text('Down the gap'), findsOneWidget);
      expect(find.text('Again'), findsOneWidget);
      expect(doomed.run.ending, Ending.none, reason: 'the fresh one is fine');
    });

    testWidgets('and says when it was the furthest yet', (tester) async {
      await open(tester, at: _intoAPit());
      await letItRun(tester, const Duration(seconds: 3));
      await settle(tester);

      expect(find.text('the furthest yet'), findsOneWidget);
    });

    testWidgets('Again starts a different run', (tester) async {
      await open(tester, at: _intoAPit());
      await letItRun(tester, const Duration(seconds: 3));
      await settle(tester);

      await tester.tap(find.text('Again'));
      await tester.pump();

      expect(find.byType(OverCard), findsNothing);
      expect(journey(tester).isOver, isFalse);
      expect(journey(tester).run.x, lessThan(2));
    });
  });

  group('leaving it', () {
    testWidgets('holds the run where it was', (tester) async {
      await open(tester);
      await letItRun(tester, const Duration(seconds: 1));
      final was = journey(tester).run.steps;

      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await letItRun(tester, const Duration(seconds: 2));

      expect(find.text('Held'), findsOneWidget);
      expect(journey(tester).run.steps, was,
          reason: 'it ran on with nobody watching');

      for (final state in const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await letItRun(tester, const Duration(milliseconds: 300));
      expect(journey(tester).run.steps, was, reason: 'still held');

      await tester.tapAt(const Offset(200, 600));
      await tester.pump();
      await letItRun(tester, const Duration(milliseconds: 400));
      expect(journey(tester).run.steps, greaterThan(was));
    });
  });

  group('fitting a phone', () {
    for (final entry in const {
      'iphone-se': Size(320, 568),
      'iphone-14': Size(390, 844),
      'pixel-7': Size(412, 915),
    }.entries) {
      testWidgets('the world fits and reads on ${entry.key}', (tester) async {
        await open(tester, screen: entry.value * 3);

        final metrics = metricsOf(tester);
        expect(metrics.tile, greaterThan(24),
            reason: 'a tile big enough to see what is coming');
        expect(metrics.floor, lessThan(metrics.space.height),
            reason: 'the ground has to be on the screen');
        // Four tiles of air above the floor, which is as high as a full hold
        // carries.
        expect(metrics.screenY(4), greaterThan(0));
      });
    }
  });
}

/// A journey with a pit close enough to fall into without touching anything.
Journey _intoAPit() => Journey.on(
      Ground.of('${'.' * 8}${'_' * 6}${'.' * 40}'),
    );
