import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'best.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. The fold is drawn square in the middle with the words
  // under it, and sideways there is nowhere for them to go.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Read before the first frame, so no screen is ever built without it.
  final best = Best(await SharedPreferences.getInstance());

  runApp(FoldburyApp(best: best));
}
