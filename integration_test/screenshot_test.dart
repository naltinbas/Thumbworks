import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultline/best.dart';
import 'package:vaultline/sim/journey.dart';
import 'package:vaultline/sim/library.dart';
import 'package:vaultline/ui/app.dart';
import 'package:vaultline/ui/run_screen.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// A runner photographed standing on flat ground is a square on a line. The
// picture that matters is the one with the runner in the air over a gap, which
// means the run has to be somewhere in particular before the shutter goes.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// Whether the Flutter surface has already been turned into an image view.
///
/// Android hands back a black rectangle for a screenshot until it has been,
/// and the call asserts if it is made twice — once per run, not once per
/// test, which is a distinction that only shows up on a device and so only
/// ever shows up in CI.
var _surfaceConverted = false;

/// A run played by the stored proofs, wound forward to a chosen moment.
///
/// The same trick the tests use and the same thing running behind the title:
/// each stretch was proved on its own, and a stretch laid at tile t has its
/// proof's step s at the run's step s + 16t.
Journey _playedTo(bool Function(Journey) until, {int seed = 3}) {
  var journey = Journey.begin(seed: seed);
  final held = <int>{};
  var known = 0;
  var guard = 0;
  while (!journey.isOver && guard++ < 20000) {
    for (; known < journey.laid.length; known++) {
      held.addAll(journey.laid[known].holdsInRun);
    }
    journey = journey.step(holding: held.contains(journey.run.steps));
    if (until(journey)) break;
  }
  return journey;
}

Future<void> _letItRun(WidgetTester tester, Duration how) async {
  const frame = Duration(milliseconds: 16);
  for (var gone = Duration.zero; gone < how; gone += frame) {
    await tester.pump(frame);
  }
}

Future<void> _open(
  WidgetTester tester, {
  Journey? at,
  bool running = true,
}) async {
  SharedPreferences.setMockInitialValues(const {'best.tiles': 418});
  final best = Best(await SharedPreferences.getInstance());

  await tester.pumpWidget(
    VaultlineApp(best: best, opensRunning: running, opening: at),
  );
  await tester.pump();

  // Android hands back a black rectangle for a screenshot until the Flutter
  // surface is an image view. It is a no-op elsewhere and may be done only
  // once in a test.
  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => binding.shouldPropagateDevicePointerEvents = true);

  testWidgets('opens on a title that makes the promise', (tester) async {
    await _open(tester, running: false);

    expect(find.text('Vaultline'), findsOneWidget);
    expect(find.text('Every stretch has been got through'), findsOneWidget);
    expect(find.textContaining('${Library.count} of them'), findsOneWidget);

    // The title plays itself, so a moment of it before the picture.
    await _letItRun(tester, const Duration(milliseconds: 900));
    await _shoot(tester, '01-title');
  });

  testWidgets('photographs a run, and the runner in the air', (tester) async {
    await _open(tester, at: _playedTo((run) => run.run.x > 120));
    expect(find.byType(RunScreen), findsOneWidget);
    await _shoot(tester, '02-running');

    // Wound on to the moment the runner leaves the ground, which is the one
    // frame in this game worth photographing.
    await _open(
      tester,
      at: _playedTo((run) => run.run.x > 40 && !run.run.onGround),
    );
    await _shoot(tester, '03-jumping');
  });

  testWidgets('photographs the end of a run', (tester) async {
    // Not posed: the run is played by the proofs and then abandoned — the
    // button is never touched again, and the next gap does the rest.
    await _open(tester, at: _playedTo((run) => run.run.x > 60));

    for (var i = 0; i < 400; i++) {
      await _letItRun(tester, const Duration(milliseconds: 100));
      if (find.textContaining('Again').evaluate().isNotEmpty) break;
    }

    expect(find.text('Again'), findsOneWidget);
    await _shoot(tester, '04-over');
  });
}
