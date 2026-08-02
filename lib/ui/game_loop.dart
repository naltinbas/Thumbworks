import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../sim/replay.dart';
import '../sim/world.dart';
import 'trail.dart';

/// Turns however long a frame took into whole simulation steps.
///
/// A frame is never exactly a step long. Sixty hertz is two steps and a bit,
/// a hundred and twenty hertz is one step and a bit either way, and a phone
/// under load hands over whatever it managed. The way to survive that is to
/// keep the leftover time and spend it on the next frame, never to stretch
/// the step to fit the frame: a step that changes length is a simulation that
/// gives different answers on different phones, and every test here assumes
/// it does not.
///
/// The arithmetic is in whole microseconds times the step rate, so the
/// leftover is exact. Carrying it as a double works for a while and then
/// quietly loses or gains a step an hour into a session, which is the kind of
/// bug nobody ever finds.
class FixedStepClock {
  /// Steps in a second, from the simulation rather than written out again.
  static final int stepsPerSecond = (1 / World.stepSeconds).round();

  /// The most world time one frame is allowed to make up.
  ///
  /// A gap longer than this means the app was in the background, or the
  /// phone stalled. Playing the whole gap would teleport the craft across the
  /// screen and usually end the run for something the player never saw, so
  /// the rest is dropped: better to lose world time than to lose the run.
  static const maxCatchUp = Duration(milliseconds: 250);

  int _carry = 0;

  /// How many steps [elapsed] of real time is worth, keeping the remainder.
  int stepsFor(Duration elapsed) {
    assert(
      (1 / World.stepSeconds - stepsPerSecond).abs() < 1e-9,
      'the step is no longer a whole number of steps a second',
    );
    var micros = elapsed.inMicroseconds;
    // A clock that goes backwards is not worth a crash: a Ticker that was
    // muted and started again can hand back a smaller stamp than last time.
    if (micros < 0) micros = 0;
    if (micros > maxCatchUp.inMicroseconds) micros = maxCatchUp.inMicroseconds;

    _carry += micros * stepsPerSecond;
    final steps = _carry ~/ Duration.microsecondsPerSecond;
    _carry -= steps * Duration.microsecondsPerSecond;
    return steps;
  }

  /// Throw away the part-step in hand, for when the run is starting over and
  /// the time before it should not leak into it.
  void reset() => _carry = 0;
}

/// Something that happened at a point in the world and is worth a moment of
/// light: it is how a player reads what the game just did.
enum FlashKind { released, caught, crashed }

@immutable
class Flash {
  const Flash({required this.at, required this.age, required this.kind});

  /// How long a flash is drawn for, in seconds.
  static const life = 0.36;

  final Vec at;

  /// Seconds since it happened.
  final double age;

  final FlashKind kind;

  /// Nought when it happens, one when it is done.
  double get progress => (age / life).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      other is Flash &&
      identical(other.at, at) &&
      other.age == age &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(identityHashCode(at), age, kind);
}

/// A well being played: the simulation, a clock to drive it with, and the
/// handful of things the view remembers that the simulation does not.
///
/// Everything the screen needs comes off here, and nothing here knows what a
/// screen looks like. It is a [ChangeNotifier] and it only notifies when
/// something actually moved, so a finished run that nobody is touching costs
/// a frame check and no repaint.
class GameLoop extends ChangeNotifier {
  GameLoop({int seed = 1}) : _seed = seed {
    _reset(seed);
  }

  /// How long the camera takes to close most of the gap to the height it is
  /// following. Small enough to keep up with a climb, big enough that a catch
  /// does not snap the whole screen.
  static const _followSeconds = 0.16;

  /// Below this the camera is treated as arrived. Without it the last
  /// hundredth of a millimetre takes forever and every frame counts as a
  /// change, so the screen repaints for the rest of the session.
  static const _followSettled = 0.0005;

  static final double _followStep =
      1 - math.exp(-World.stepSeconds / _followSeconds);

  /// How long the world takes to settle back down the glass when a lift comes
  /// off. Slower than the camera's own follow, because this is not the view
  /// keeping up with the craft: it is the game handing the screen over to the
  /// player, and it should read as a move rather than a jump.
  static const _liftSeconds = 0.28;

  /// Below this the lift is treated as gone.
  ///
  /// Bigger than the camera's own threshold because a lift is ten metres
  /// rather than a fraction of one, and an exponential ease that far out
  /// spends seconds creeping through the last hundredth. Two centimetres is
  /// under half a pixel on any screen the game runs on.
  static const _liftSettled = 0.02;

  static final double _liftStep =
      1 - math.exp(-World.stepSeconds / _liftSeconds);

  final FixedStepClock _clock = FixedStepClock();
  final Trail trail = Trail();

  int _seed;
  late World _world;
  late double _focusY;
  double _lift = 0;
  double _liftTarget = 0;
  bool _tapPending = false;
  final List<int> _taps = <int>[];
  final List<_Mark> _marks = <_Mark>[];
  List<Flash> _flashes = const <Flash>[];

  /// Steps since the view started, which keeps running after the run has
  /// ended so a crash has time to play out.
  int _viewSteps = 0;

  World get world => _world;

  /// The height in metres the camera is looking at, chasing the high point of
  /// the run rather than the craft itself. The high point only ever goes up,
  /// so the view never drops back down the screen mid-run, and a craft that
  /// is falling is a craft the player can see falling behind.
  ///
  /// Less whatever the screen has asked to be lifted by: looking lower puts
  /// the world higher on the glass.
  double get focusY => _focusY - _lift;

  /// Raise the world up the glass by [metres], easing there.
  ///
  /// The title screen owns the bottom of the screen, and a craft swinging
  /// behind the words is a craft nobody can see. The run itself is played with
  /// this at nought.
  set lift(double metres) => _liftTarget = metres;

  /// The same, arrived at rather than eased to, for a screen that is opening
  /// rather than changing.
  void settleLift(double metres) {
    _lift = metres;
    _liftTarget = metres;
  }

  List<Flash> get flashes => _flashes;

  /// The run so far as something that can be played back exactly.
  Replay get replay => Replay(seed: _seed, taps: List.unmodifiable(_taps));

  /// The player's thumb. One tap anywhere on the glass gets here, and it is
  /// spent on the next step whatever the craft is doing: holding a tap back
  /// until the next well would be the game playing itself.
  void tap() {
    if (_world.isOver) return;
    _tapPending = true;
  }

  /// Start again, on [seed] or on the one already in hand.
  void restart({int? seed}) {
    _reset(seed ?? _seed);
    notifyListeners();
  }

  void _reset(int seed) {
    _seed = seed;
    _world = World.newRun(seed: seed);
    _focusY = _world.cameraY;
    _tapPending = false;
    _viewSteps = 0;
    _taps.clear();
    _marks.clear();
    _flashes = const <Flash>[];
    _clock.reset();
    trail
      ..clear()
      ..add(_world.craft);
  }

  /// Advance by [elapsed] of real time, which is however long the last frame
  /// took. Runs as many fixed steps as that covers and keeps the rest.
  void advance(Duration elapsed) {
    final steps = _clock.stepsFor(elapsed);
    if (steps == 0) return;

    final before = _world;
    final wasFocus = focusY;
    final wasTrail = trail.revision;
    final wasFlashes = _flashes;

    for (var i = 0; i < steps; i++) {
      _step();
    }
    _ageFlashes();

    if (!identical(before, _world) ||
        focusY != wasFocus ||
        trail.revision != wasTrail ||
        !listEquals(wasFlashes, _flashes)) {
      notifyListeners();
    }
  }

  void _step() {
    _viewSteps++;

    final tapped = _tapPending;
    _tapPending = false;
    final before = _world;
    if (tapped && before.isHeld) _taps.add(before.steps);

    _world = before.step(tapped: tapped);

    if (before.isHeld && !_world.isHeld) {
      _marks.add(_Mark(before.craft, _viewSteps, FlashKind.released));
    } else if (!before.isHeld && _world.isHeld) {
      _marks.add(_Mark(_world.craft, _viewSteps, FlashKind.caught));
    }
    if (before.ending == Ending.none && _world.ending == Ending.crashed) {
      _marks.add(_Mark(_world.craft, _viewSteps, FlashKind.crashed));
    }

    if (_world.isOver) {
      trail.fade();
    } else {
      trail.add(_world.craft);
    }

    final target = _world.cameraY;
    final gap = target - _focusY;
    _focusY = gap.abs() < _followSettled ? target : _focusY + gap * _followStep;

    final lifting = _liftTarget - _lift;
    _lift = lifting.abs() < _liftSettled
        ? _liftTarget
        : _lift + lifting * _liftStep;
  }

  void _ageFlashes() {
    if (_marks.isEmpty) {
      if (_flashes.isNotEmpty) _flashes = const <Flash>[];
      return;
    }
    _marks.removeWhere(
      (mark) => (_viewSteps - mark.step) * World.stepSeconds > Flash.life,
    );
    _flashes = List.unmodifiable(
      _marks.map(
        (mark) => Flash(
          at: mark.at,
          age: (_viewSteps - mark.step) * World.stepSeconds,
          kind: mark.kind,
        ),
      ),
    );
  }
}

/// Where and when something worth a flash happened.
class _Mark {
  const _Mark(this.at, this.step, this.kind);

  final Vec at;
  final int step;
  final FlashKind kind;
}
