import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'best_score.dart';
import 'game/lexicon.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A square grid under a thumb, with the score above it and the words found
  // below. Sideways there is nowhere for any of that to go.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Both before the first frame. The word list takes a moment to index and
  // every board is built against it, so a round that built it on the tap that
  // started it would stall on that tap; and a title screen built without the
  // best score would show the number a moment late.
  runApp(LatchwordApp(
    lexicon: Lexicon.standard(),
    best: await BestScore.open(),
  ));
}
