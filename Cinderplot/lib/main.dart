import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'best.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. The squares are square and the board is taller than it is
  // wide; sideways it would be a strip of it with the rest off the screen.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Read before the first frame, so no screen is ever built without it.
  final best = Best(await SharedPreferences.getInstance());

  runApp(CinderplotApp(best: best));
}
