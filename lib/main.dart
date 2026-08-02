import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'best_run.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The playfield is fourteen metres wide and the game is played upwards, so
  // the scale comes off the width of the screen and everything left over
  // becomes sky. Sideways there is nothing to climb into.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Read the best score before the first frame, so the title screen is never
  // built without it and the number does not appear a moment late.
  runApp(SlingwellApp(best: await BestRun.open()));
}
