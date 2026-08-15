import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shamland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every husband in them was picked and seated by a tap, so nothing
/// in the pictures is a table the game could not reach.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);
    await useRealFonts();
  });

  Future<void> shoot(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(screen),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$shots/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> show(WidgetTester tester, Size size, {int? which}) =>
      open(tester, which: which, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the five couples parted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await partByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.moves, 5);
      await shoot(tester, 'fivecouples-${phone.key}');
    });
  }

  testWidgets('the three couples parted by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await seat(tester, 2, 0);
    await seat(tester, 0, 1);
    await seat(tester, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threecouples');
  });

  testWidgets('the four couples parted, the table turned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await seat(tester, 3, 0);
    await seat(tester, 0, 1);
    await seat(tester, 1, 2);
    await seat(tester, 2, 3);
    expect(state(tester).play.seated, [3, 0, 1, 2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourcouples');
  });

  testWidgets('the seated host, held in his chair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await shoot(tester, 'seatedhost');
  });

  testWidgets('a table mid-seating, one husband picked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await seat(tester, 2, 0);
    await seat(tester, 0, 1);
    await pickBench(tester, 4);
    expect(state(tester).play.picked, 4);
    expect(state(tester).play.quarrels, isEmpty);
    await shoot(tester, 'midseat');
  });

  testWidgets('show me ringing a chair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the two couples admitted, both seated and quarrelling',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await seat(tester, 0, 0);
    await seat(tester, 1, 1);
    for (var dither = 0; dither < 5; dither++) {
      await tapGap(tester, 0);
      await seat(tester, 0, 0);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.seated, [0, 1]);
    expect(state(tester).play.quarrels, [0, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'twocouples');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fivecouples-iphone-14.png',
      'threecouples.png',
      'fourcouples.png',
      'seatedhost.png',
      'midseat.png',
      'showme.png',
      'why.png',
      'twocouples.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
