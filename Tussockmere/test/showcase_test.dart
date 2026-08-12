import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mere.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every marsh in them was stepped tussock by tussock, so nothing in
/// the pictures is a field the game could not reach.
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
    testWidgets('the fields on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fields-${phone.key}');
    });

    testWidgets('the four-field mid-step on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 1);
      for (var step = 0; step < 3; step++) {
        await tapTussock(
            tester, int.parse(state(tester).play.next!));
      }
      await shoot(tester, 'stepping-${phone.key}');
    });

    testWidgets('a marsh linked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await linkIt(tester);
      await shoot(tester, 'linked-${phone.key}');
    });
  }

  testWidgets('the pie on the table', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'pie');
  });

  testWidgets('the sweep spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the second chair fallen', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    var guard = 0;
    while (!state(tester).play.isOver) {
      if (guard++ > 16) fail('the chair never fell');
      await tapTussock(tester, state(tester).play.cells.indexOf(0));
    }
    expect(state(tester).play.isLost, isTrue);
    await shoot(tester, 'secondchair');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fields-iphone-14.png',
      'stepping-iphone-14.png',
      'linked-iphone-14.png',
      'pie.png',
      'why.png',
      'secondchair.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
