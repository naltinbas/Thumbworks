import 'frac.dart';
import 'rules.dart';

/// One ask: what the timetable is to be.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'fair': the average wait the fair 9 1/2; 'half': the average wait
  /// 14 1/2; 'quarter': the average wait a quarter hour or more; 'worst':
  /// the average wait as long as it can be; 'under': the average wait
  /// under the fair, which no timetable gives.
  final String kind;

  /// How many timetables land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The longest average wait any timetable gives: 27 11/20, two buses
  /// a minute apart and the third fifty-eight on.
  static Frac get worst => Frac.of(551, 20);

  /// Whether the timetable [gaps] lands the ask.
  bool meets(List<int> gaps) {
    if (!Rules.valid(gaps)) return false;
    final w = Rules.waitByGaps(gaps);
    switch (kind) {
      case 'fair':
        return w == Rules.fairWait;
      case 'half':
        return w == Frac.of(29, 2);
      case 'quarter':
        return w.compareTo(Frac.of(15)) >= 0;
      case 'worst':
        return w == worst;
      default:
        return w.compareTo(Rules.fairWait) < 0;
    }
  }

  /// The timetable the pointer works towards, the sweep's first that
  /// lands the ask, or null.
  List<int>? get aim {
    for (final g in Rules.timetables) {
      if (meets(g)) return g;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'fair':
        return 'set the gaps so that the average wait is the fair 9 1/2 minutes';
      case 'half':
        return 'set the gaps so that the average wait is 14 1/2 minutes';
      case 'quarter':
        return 'set the gaps so that the average wait is a quarter hour or more';
      case 'worst':
        return 'set the gaps so that the average wait is as long as it can be';
      default:
        return 'set the gaps so that the average wait is under the fair 9 1/2 minutes';
    }
  }
}
