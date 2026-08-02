import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only. The field is nine across and thirteen down, and a lane that
  // long laid sideways is a lane nobody can see the far end of.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const EmberlaneApp());
}
