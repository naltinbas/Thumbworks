import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreham/score/rings.dart';
import 'package:scoreham/score/rules.dart';

import 'support/fonts.dart';
import 'support/score.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every walk in them was started by a tap, so nothing in the
/// pictures is a tally the game could not reach.
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
    testWidgets('the rings on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rings-${phone.key}');
    });

    testWidgets('a grounded walk on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      final bad = List.generate(9, (at) => at).firstWhere(
          (at) => !Rules.staysAhead(Rings.at(3).marks, at));
      await tapMark(tester, bad);
      await shoot(tester, 'grounded-${phone.key}');
    });

    testWidgets('a ring settled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await findIt(tester);
      await shoot(tester, 'settled-${phone.key}');
    });
  }

  testWidgets('the ebb pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'pointed');
  });

  testWidgets('the ledger spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the tied vote ground out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var start = 0; start < 6; start++) {
      await tapMark(tester, start);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'tiedvote');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rings-iphone-14.png',
      'grounded-iphone-14.png',
      'settled-iphone-14.png',
      'pointed.png',
      'why.png',
      'tiedvote.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
