import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hazardwell/game/odds.dart';
import 'package:hazardwell/game/play.dart';
import 'package:hazardwell/game/rules.dart';
import 'package:hazardwell/ui/app.dart';
import 'package:hazardwell/ui/table_screen.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// This one does what nothing else can: it works the table of odds out on the
// phone. A million positions settled to a fixed point is a second of
// arithmetic on a laptop, and how long it is on a real device — and whether
// the app is still answering while it happens — is a thing only a real device
// can say.
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

Future<void> _press(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pump();
  await _tapAt(tester, tester.getCenter(find.text(label)));
}

TableScreenState _state(WidgetTester tester) =>
    tester.state<TableScreenState>(find.byType(TableScreen));

var _opened = 0;

Future<void> _open(WidgetTester tester, {Odds? odds, bool atTable = false,
    Play? from}) async {
  await tester.pumpWidget(HazardwellApp(
    key: ValueKey(_opened++),
    odds: odds,
    opensAtTable: atTable,
    opensWith: from,
    showOdds: true,
  ));
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

  testWidgets('works the odds out on the phone', (tester) async {
    // No table handed in: the app starts one being worked out on an isolate
    // of its own, and the way in stays up and answering while it happens.
    await _open(tester);
    expect(find.text('Hazardwell'), findsOneWidget);
    await _shoot(tester, '01-way-in');

    final clock = Stopwatch()..start();
    for (var i = 0; i < 400; i++) {
      if (find.textContaining('settled in').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('settled in'), findsOneWidget,
        reason: 'the odds never arrived from the isolate');
    debugPrint('the odds took ${clock.elapsedMilliseconds}ms on this device');
    await _shoot(tester, '02-ready');
  });

  testWidgets('plays a hand with a real finger', (tester) async {
    final odds = Odds.reckon();
    await _open(
      tester,
      odds: odds,
      atTable: true,
      from: const Play(yours: 43, theirs: 51, turn: 0, toMove: Who.you),
    );

    await _press(tester, 'Two dice');
    expect(_state(tester).play.last, isNotNull,
        reason: 'the platform never delivered the tap');
    await _shoot(tester, '03-a-throw');

    // Played out by the table's own advice, both sides, to the end.
    for (var turn = 0; turn < 500; turn++) {
      if (_state(tester).play.isOver) break;
      if (_state(tester).theirs) {
        await tester.pump(const Duration(milliseconds: 900));
        continue;
      }
      final play = _state(tester).play;
      await _press(
        tester,
        switch (odds.bestAt(play.mine, play.others, play.turn)) {
          Move.bank => 'Bank ${play.turn}',
          Move.one => 'One die',
          Move.two => 'Two dice',
        },
      );
    }

    expect(_state(tester).play.isOver, isTrue);
    expect(_state(tester).review.mistakes, 0,
        reason: 'the table disagreed with itself on a real phone');
    await _shoot(tester, '04-the-end');
  });
}
