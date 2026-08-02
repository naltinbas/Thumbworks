import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. Eight columns of overlapping cards want height above all
  // else, and laid sideways a column of seven has nowhere to go.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FanwrightApp());
}
