import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fold.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every fence in them was raised hurdle by hurdle, so nothing in
/// the pictures is a green the game could not reach.
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
    testWidgets('the greens on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'greens-${phone.key}');
    });

    testWidgets('the empty pen mid-fence on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 1);
      for (var hurdle = 0; hurdle < 3; hurdle++) {
        final play = state(tester).play;
        await tapCross(tester, play.nextOf(play.finished!)!);
      }
      await shoot(tester, 'fencing-${phone.key}');
    });

    testWidgets('nine swallowed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await fenceIt(tester);
      expect(state(tester).play.swallows, 9);
      await shoot(tester, 'penned-${phone.key}');
    });
  }

  testWidgets('the two countings spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await fenceIt(tester);
    await press(tester, 'Again');
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('a hurdle pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'pointed');
  });

  testWidgets('the third acre called', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var miss = 0; miss < 3; miss++) {
      for (final spot in const [(0, 0), (1, 0), (0, 1)]) {
        await tapCross(tester, spot);
      }
      await tapCross(tester, (0, 0));
      if (miss < 2) {
        for (var back = 0; back < 4; back++) {
          await press(tester, 'Back');
        }
      }
    }
    expect(state(tester).gaveUp, isTrue);
    await shoot(tester, 'thirdacre');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'greens-iphone-14.png',
      'fencing-iphone-14.png',
      'penned-iphone-14.png',
      'why.png',
      'pointed.png',
      'thirdacre.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
