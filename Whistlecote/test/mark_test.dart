import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whistlecote/ui/app.dart';
import 'package:whistlecote/ui/mark.dart';
import 'package:whistlecote/ui/palette.dart';

import 'support/fonts.dart';

/// Draws the logo and the app icons.
///
/// There is no image in this repository that was not produced here.
void main() {
  const out = 'assets';
  const frame = Key('mark');

  setUpAll(() async {
    Directory(out).createSync(recursive: true);
    await useRealFonts();
  });

  Future<void> drawTo(
    WidgetTester tester,
    String path,
    double side,
    Widget child,
  ) async {
    tester.view
      ..physicalSize = Size(side, side)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: frame,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: WhistlecoteApp.theme,
          home: SizedBox(width: side, height: side, child: child),
        ),
      ),
    );
    await tester.pump();

    await tester.runAsync(() async {
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(frame));
      final image = await boundary.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> draw(
    WidgetTester tester,
    String name,
    double side,
    Widget child,
  ) =>
      drawTo(tester, '$out/$name.png', side, child);

  /// The icon at whatever size a platform asks for. Drawn at that size rather
  /// than shrunk down from one big one, so nothing is ever resampled.
  Widget icon(double side) => ColoredBox(
        color: Palette.night,
        child: Padding(
          padding: EdgeInsets.all(side * 0.05),
          child: const Mark(),
        ),
      );

  test('the mark is the four calls whistled, real and checked', () {
    // The picture is the shepherd's marking of the four calls: one, two,
    // three and three notes, every tune spoken for and no whistle the
    // start of another.
    final play = Mark.fourCalls;
    expect(play.isDone, isTrue);
    expect(play.clashes, isEmpty);
    expect(play.share, 8);
  });

  testWidgets('the logo', (tester) async {
    await draw(
      tester,
      'logo',
      512,
      const ColoredBox(
        color: Palette.night,
        child: Padding(padding: EdgeInsets.all(26), child: Mark()),
      ),
    );
    expect(File('$out/logo.png').lengthSync(), greaterThan(1000));
  });

  testWidgets('the app icon', (tester) async {
    await draw(
      tester,
      'icon',
      1024,
      const ColoredBox(
        color: Palette.night,
        child: Padding(padding: EdgeInsets.all(52), child: Mark()),
      ),
    );
    expect(File('$out/icon.png').lengthSync(), greaterThan(1000));
  });

  testWidgets('the adaptive icon foreground, on nothing', (tester) async {
    // Android puts this on a layer of its own and crops it to whatever shape
    // the launcher likes, so it is drawn small and well inside the edge.
    await draw(
      tester,
      'icon-foreground',
      1024,
      const Padding(
        padding: EdgeInsets.all(250),
        child: Mark(onVerge: false),
      ),
    );
    expect(File('$out/icon-foreground.png').lengthSync(), greaterThan(1000));
  });

  testWidgets('the Android launcher icons', (tester) async {
    const res = 'android/app/src/main/res';
    // A launcher icon is 48dp, and the foreground of an adaptive one is
    // 108dp with the picture in the middle 72 of it.
    const densities = <String, double>{
      'mdpi': 1,
      'hdpi': 1.5,
      'xhdpi': 2,
      'xxhdpi': 3,
      'xxxhdpi': 4,
    };

    for (final density in densities.entries) {
      final side = 48 * density.value;
      await drawTo(
        tester,
        '$res/mipmap-${density.key}/ic_launcher.png',
        side,
        icon(side),
      );

      final wide = 108 * density.value;
      await drawTo(
        tester,
        '$res/drawable-${density.key}/ic_launcher_foreground.png',
        wide,
        Padding(
          padding: EdgeInsets.all(wide * 0.23),
          child: const Mark(onVerge: false),
        ),
      );
    }

    for (final density in densities.keys) {
      expect(File('$res/mipmap-$density/ic_launcher.png').existsSync(), isTrue);
      expect(
        File('$res/drawable-$density/ic_launcher_foreground.png').existsSync(),
        isTrue,
      );
    }
  });

  testWidgets('and the iOS ones, every size the app icon set asks for',
      (tester) async {
    const set = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final listed = jsonDecode(File('$set/Contents.json').readAsStringSync())
        as Map<String, dynamic>;

    for (final image in listed['images'] as List<dynamic>) {
      final what = image as Map<String, dynamic>;
      final name = what['filename'] as String?;
      if (name == null) continue;

      final points = double.parse((what['size'] as String).split('x').first);
      final scale = double.parse((what['scale'] as String).replaceAll('x', ''));
      final side = points * scale;

      await drawTo(tester, '$set/$name', side, icon(side));
      expect(File('$set/$name').existsSync(), isTrue, reason: name);
    }
  });
}
