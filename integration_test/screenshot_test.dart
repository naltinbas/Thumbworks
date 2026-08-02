import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slingwell/best_run.dart';
import 'package:slingwell/sim/replay.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/app.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/game_screen.dart';
import 'package:slingwell/ui/game_view.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in test/.
//
// A screenshot of an arcade game at rest says nothing, so every shot here is
// taken out of a run that is being played: the craft mid-arc between two
// wells, a trail behind it and a score climbing on the clock.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// The run the pictures are taken out of: a good player's first thirteen
/// releases on seed 5.
///
/// Played out, this is at step [_referenceStep] with twelve wells behind it,
/// seventy-nine metres up and in the air between the twelfth well and the
/// thirteenth. That is the moment worth photographing, and it was chosen by
/// running the simulation and looking at what the numbers were doing.
///
/// It is here as the answer rather than as the driver. A device cannot be
/// asked to release on step 1628: the world advances by however long the last
/// frame really took, and a frame on an emulator is worth anything from two
/// steps to thirty. Playing these step numbers against a real clock loses the
/// run by the third well, which was measured before this was written. So the
/// device plays the same run by the rule that produced it, which corrects
/// itself at every well, and this is what the result is checked against.
const _reference = Replay(
  seed: 5,
  taps: <int>[
    29, 85, 271, 334, 540, 597, 819, 874, 1079, 1138, 1350, 1416, 1628,
  ],
);

/// The step the reference run is compared at, a fifth of a second into the
/// flight off the twelfth well.
const _referenceStep = 1652;

/// How long after letting go the picture is taken, in steps.
///
/// Far enough for the craft to be clear of the well and the trail to show the
/// whip as well as the arc; short enough that a stalled frame cannot carry it
/// past the next well and photograph a different hop. A quarter of a second
/// of stall is all the loop will ever make up at once, and a hop takes about
/// three quarters.
const _intoTheFlight = 24;

/// A best worth beating, so the pictures show what the numbers look like for
/// a player who has been at it a while, and so a twelve well run takes the
/// record on camera.
const _saved = <String, Object>{'best.score': 8, 'best.seed': 4711};

/// Releases when the craft is pointed at where the next well will be by the
/// time it arrives, which is what a player who has learnt the game does.
///
/// The test carries its own player rather than the game carrying one. It is a
/// pure function of the world in hand, so it is unbothered by a frame that
/// took thirty milliseconds instead of eight: whatever the last release did,
/// the next one is aimed from where the craft actually is.
bool _aimed(World world) {
  if (!world.isHeld) return false;
  final here = world.wells[world.heldBy!];
  Well? target;
  for (final well in world.wells) {
    if (well.at.y > here.at.y + 0.5) {
      target = well;
      break;
    }
  }
  if (target == null) return false;
  final flat = (target.at - world.craft).length;
  final flight = flat / World.launchSpeed;
  final lead = Vec(
    target.at.x,
    target.at.y + 0.5 * World.gravity * flight * flight,
  );
  final want = (lead - world.craft).normalised;
  final going = world.velocity.normalised;
  return want.x * going.x + want.y * going.y > 0.995;
}

GameLoop _loopOf(WidgetTester tester) =>
    tester.widget<GameView>(find.byType(GameView)).loop;

/// How long each pump asks for.
///
/// The number is a floor rather than a frame time: this binding waits it out
/// on the real clock and then draws, and the game advances by however long
/// that really took. Asking for a step's worth keeps the loop from spinning on
/// a fast device, and keeps the test looking at the world often enough to
/// release on time on a slow one.
const _frame = Duration(milliseconds: 8);

/// Opens the game on a known world.
///
/// The app picks a fresh seed every run, which is the right thing for a
/// player and no good for a photograph: a picture of a world nobody can name
/// is a picture nobody can check. Everything else is the app as it ships.
Future<void> _open(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(_saved));
  await tester.pumpWidget(
    MaterialApp(
      title: 'Slingwell',
      debugShowCheckedModeBanner: false,
      theme: SlingwellApp.theme,
      home: GameScreen(
        best: await BestRun.open(),
        seeds: () => _reference.seed,
      ),
    ),
  );
  await tester.pump(_frame);
}

/// Pumps [frames] frames.
///
/// Never pumpAndSettle. The view holds a ticker and asks for another frame
/// forever, the way a game does, so settling waits for the game to stop being
/// one and then times out.
Future<void> _pumpFrames(WidgetTester tester, int frames) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(_frame);
  }
}

/// Plays until [until] is happy or the run ends, and hands back where it got
/// to.
///
/// Every tap goes in as a real touch in the middle of the glass, because that
/// is the whole point of running on a device: the game is driven the way a
/// thumb drives it, through the gesture detector, the phase the screen is in
/// and the loop's own pending tap. Finding something to tap by widget type
/// would land on whichever widget answered to that type first.
///
/// [badly] plays the way a new player does, letting go the instant a well
/// catches, which is how a run ends.
Future<World> _play(
  WidgetTester tester, {
  bool Function(World world)? until,
  bool badly = false,
}) async {
  final thumb = tester.getCenter(find.byType(GameView));
  for (var frame = 0; frame < 6000; frame++) {
    final world = _loopOf(tester).world;
    if (world.isOver || (until != null && until(world))) return world;
    if (badly ? world.isHeld : _aimed(world)) await tester.tapAt(thumb);
    await tester.pump(_frame);
  }
  return _loopOf(tester).world;
}

/// Turns the Flutter surface into an image view, which is the only way
/// Android hands back anything but a black rectangle.
///
/// A no-op on iOS, undone when the test ends, and it may be made only once in
/// a test, so every later shot in the same test reuses it. It makes each frame
/// more expensive, so it is left as late as it can be: after the climb, and
/// before the first picture.
Future<void> _prepareToShoot() => binding.convertFlutterSurfaceToImage();

/// Takes the picture.
Future<void> _shoot(WidgetTester tester, String name) async {
  // A couple of frames clears the ring the binding paints where the test last
  // touched the screen, which fades two painted frames after the finger lifts.
  await _pumpFrames(tester, 4);
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens on a title over a craft already swinging', (tester) async {
    await _open(tester);

    expect(find.text('Slingwell'), findsOneWidget);
    expect(find.text('Tap to fly'), findsOneWidget);

    // The prompt breathes on a real clock and the craft is going round behind
    // it, so this waits for both to be somewhere worth photographing rather
    // than shooting the first frame after layout.
    await _pumpFrames(tester, 100);
    expect(_loopOf(tester).world.steps, greaterThan(0),
        reason: 'the run under the title is not moving');

    await _prepareToShoot();
    await _shoot(tester, '01-title');
  });

  testWidgets('plays the recorded run and photographs it mid-flight', (
    tester,
  ) async {
    await _open(tester);

    // The title screen is one tap deep and the run under it is already going,
    // so this is the player starting rather than the test skipping a screen.
    await tester.tapAt(tester.getCenter(find.byType(GameView)));
    await tester.pump(_frame);

    final want = _reference.play(maxSteps: _referenceStep);
    final wells = want.score;

    // The moment: off the twelfth well, far enough into the flight for the
    // trail to show the whip round it as well as the arc away.
    int? left;
    final world = await _play(tester, until: (world) {
      if (world.score < wells || world.isHeld) {
        left = null;
        return false;
      }
      left ??= world.steps;
      return world.steps - left! >= _intoTheFlight;
    });

    expect(world.isOver, isFalse,
        reason: 'the run ended before it got to the moment');
    expect(world.isHeld, isFalse,
        reason: 'the shot wants the craft in the air');
    expect(_loopOf(tester).trail.length, greaterThan(40),
        reason: 'a craft with no trail behind it is not worth a picture');
    // The live run is the reference run played on a real clock, so it lands
    // at the recorded moment or a little past it, never short: the test only
    // looks at the world once a frame, and a frame that stalls can carry the
    // craft through the next well before it looks again.
    //
    // One-sided on purpose. Playing this drive against two thousand modelled
    // clocks, with frames from eight to fifty milliseconds and a quarter
    // second stall every hundredth, arrives at twelve to fourteen wells and
    // 79 to 93 metres; the reference is the floor of that, and these bounds
    // are its ceiling with room. Tighter than this and the job goes red on a
    // busy runner for a picture that was perfectly good.
    expect(world.score, inInclusiveRange(wells, wells + 4),
        reason: 'the run is not the one that was recorded');
    expect(
      world.cameraY,
      inInclusiveRange(want.cameraY - 1, want.cameraY + 30),
      reason: 'the run drifted away from the one that was recorded',
    );

    await _prepareToShoot();
    await _shoot(tester, '02-flight');

    // Then the end of the run, which is the last thing worth a picture.
    final over = await _play(tester, badly: true);
    expect(over.isOver, isTrue, reason: 'the run would not end');

    // Long enough for the card to finish arriving over the wreck.
    await _pumpFrames(tester, 80);
    expect(find.text('Go again'), findsOneWidget);
    expect(find.text('New best'), findsOneWidget,
        reason: 'twelve wells should have taken a best of eight');
    await _shoot(tester, '03-over');
  });
}
