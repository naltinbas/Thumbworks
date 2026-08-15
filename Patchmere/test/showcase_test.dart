import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every patch in them was sewn by taps or by the house's answer, so
/// nothing in the pictures is a quilt the game could not reach.
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

    testWidgets('the two by six sewn out on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await sewByPointer(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'twobysix-${phone.key}');
    });
  }

  testWidgets('the three by four sewn out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await sewByPointer(tester);
    expect(state(tester).play.won, isTrue);
    await shoot(tester, 'threebyfour');
  });

  testWidgets('the three by three sewn out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await sewByPointer(tester);
    expect(state(tester).play.won, isTrue);
    await shoot(tester, 'threebythree');
  });

  testWidgets('the four by five sewn out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await sewByPointer(tester);
    expect(state(tester).play.won, isTrue);
    await shoot(tester, 'fourbyfive');
  });

  testWidgets('a quilt mid-sewing, a cell picked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await sew(tester, (7, 12));
    final free = state(tester).play.quilt.moves(state(tester).play.sewn).last.$2;
    await tapCell(tester, free);
    expect(state(tester).play.held, free);
    await shoot(tester, 'midsewing');
  });

  testWidgets('show me ringing the middle patch', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the four by four admitted, every patch mirrored',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await sewAll(tester, [(0, 1), (2, 6), (8, 12)]);
    await sewAnyhow(tester);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'fourbyfour');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'twobysix-iphone-14.png',
      'threebyfour.png',
      'threebythree.png',
      'fourbyfive.png',
      'midsewing.png',
      'showme.png',
      'why.png',
      'fourbyfour.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
