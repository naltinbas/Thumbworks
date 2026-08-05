import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the fonts the app really uses.
///
/// A test renders text with a placeholder face that draws every glyph as a
/// filled box, which is fine for measuring a layout and useless in a picture
/// — and the letters on these pieces are half of what tells them apart.
Future<void> useRealFonts() async {
  final fonts = Directory(
    '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
    '/bin/cache/artifacts/material_fonts',
  );
  for (final family in const ['Roboto', 'MaterialIcons']) {
    final loader = FontLoader(family);
    for (final file in fonts.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (!name.startsWith(family)) continue;
      if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}
