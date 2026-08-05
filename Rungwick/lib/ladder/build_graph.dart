import 'graph.dart';
import 'words.dart';

/// Works the word graph out, for handing back from another isolate.
///
/// A top level function taking one plain value, because that is what can be
/// started on an isolate of its own. Two and a half thousand words is a
/// moment's work and the phone should not be holding still through it.
Ladder ladderFor(int letters) => Ladder.of(letters == 5 ? kFive : kFour);
