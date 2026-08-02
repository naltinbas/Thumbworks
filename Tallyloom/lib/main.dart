import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'progress.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. The grid is square and the clue strips hang off two of its
  // sides, so landscape gives the puzzle less room and the tools nowhere
  // sensible to be.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Read before the first frame, so no screen is ever built without knowing
  // where the player is up to and nothing has to be redrawn when it arrives.
  final progress = Progress(await SharedPreferences.getInstance());

  runApp(TallyloomApp(progress: progress));
}
