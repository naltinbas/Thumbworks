import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'best.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. The board is square and wants all the width there is;
  // sideways there is nothing to put beside it.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Read before the first frame, so no screen is ever built without it.
  final best = Best(await SharedPreferences.getInstance());

  runApp(SkeinmoorApp(best: best));
}
