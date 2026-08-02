import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. The board is square and the two choices on the title read
  // as a list, so landscape gives the board less room and the list nowhere
  // sensible to be.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ThornguardApp());
}
