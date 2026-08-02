import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chimefall/music.dart';
import 'package:chimefall/play/session.dart';
import 'package:chimefall/tune/tune.dart';
import 'package:chimefall/tune/tunes.dart';
import 'package:chimefall/ui/app.dart';
import 'package:chimefall/ui/play_screen.dart';
import 'package:chimefall/ui/stage_painter.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// This one does something the others cannot: it plays the sound. There is no
// audio device on the machine this was built on, so whether a tune actually
// starts on a real Android is a thing only a real Android can say — and this
// is the only place there is one.
late final IntegrationTestWidgetsFlutterBinding binding;

/// Whether the Flutter surface has already been turned into an image view.
///
/// Android hands back a black rectangle for a screenshot until it has been,
/// and the call asserts if it is made twice — once per run, not once per test.
var _surfaceConverted = false;

Future<void> _asDevice(PointerEvent event) => TestAsyncUtils.guard<void>(
      () async => binding.handlePointerEventForSource(
        event,
        source: TestBindingEventSource.device,
      ),
    );

Future<void> _tapAt(WidgetTester tester, Offset at) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(at);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

PlayScreenState _state(WidgetTester tester) =>
    tester.state<PlayScreenState>(find.byType(PlayScreen));

Finder _stage() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is StagePainter,
    );

Metrics _metrics(WidgetTester tester) =>
    (tester.widget<CustomPaint>(_stage().first).painter! as StagePainter)
        .metrics;

Future<void> _letItPlay(WidgetTester tester, Duration how) async {
  const frame = Duration(milliseconds: 16);
  for (var gone = Duration.zero; gone < how; gone += frame) {
    await tester.pump(frame);
  }
}

Future<void> _open(
  WidgetTester tester, {
  Tune? tune,
  bool silent = false,
}) async {
  await tester.pumpWidget(ChimefallApp(opensWith: tune, silent: silent));
  await tester.pump();

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

  testWidgets('opens on the tunes', (tester) async {
    await _open(tester);

    expect(find.text('Chimefall'), findsOneWidget);
    expect(find.text('The music and the notes are one list'), findsOneWidget);
    for (final tune in Tunes.all) {
      expect(find.text(tune.name), findsOneWidget);
    }
    await _shoot(tester, '01-tunes');
  });

  testWidgets('really plays the sound on a real device', (tester) async {
    // The one thing that cannot be checked anywhere but here. It does not
    // prove a speaker made a noise — nothing short of a microphone would —
    // but it does prove the platform took the file, started it, and reported
    // a position that moved, which is every step between the asset and the
    // speaker.
    final music = Music();
    addTearDown(music.throwAway);

    final heard = <Duration>[];
    final listening = music.positions.listen(heard.add);
    addTearDown(listening.cancel);

    await music.play(Tunes.first);
    for (var i = 0; i < 60 && heard.length < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
    }
    await music.stop();

    expect(heard, isNotEmpty,
        reason: 'the player never reported a position: the tune did not start');
    expect(heard.last, greaterThan(Duration.zero),
        reason: 'the tune started and then did not move');
  });

  testWidgets('photographs notes falling, and one landing', (tester) async {
    // Silent, so the pictures are taken at moments this test chooses rather
    // than whenever the device's audio clock happened to be.
    await _open(tester, tune: Tunes.third, silent: true);
    await _letItPlay(tester, const Duration(milliseconds: 6400));
    await _shoot(tester, '02-falling');

    // Wound to a note and tapped on the line.
    await _open(tester, tune: Tunes.second, silent: true);
    final note = Tunes.second.inOrder[14];
    final due = note.secondsAt(Tunes.second.beatsPerMinute);
    for (var i = 0; i < 4000; i++) {
      if (_state(tester).session.at >= due) break;
      await tester.pump(const Duration(milliseconds: 8));
    }

    final metrics = _metrics(tester);
    await _tapAt(
      tester,
      tester.getTopLeft(_stage().first) +
          Offset(metrics.middleOf(note.lane), metrics.line),
    );

    expect(_state(tester).session.hits.last.judgement, Judgement.perfect);
    await _shoot(tester, '03-perfect');
  });
}
