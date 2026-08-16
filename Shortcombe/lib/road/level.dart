import 'rules.dart';

/// One ask: a crowd to dial and the shortcut to open or shut.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.minutes,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'shutMinutes': the shortcut shut and every driver taking [minutes];
  /// 'openMinutes': the shortcut open and every driver taking [minutes];
  /// 'helps': the shortcut open on a crowd it speeds up; 'noOdds': a
  /// crowd the shortcut makes no odds to; 'bigHelped': the shortcut open
  /// on a crowd past thirty hundred that it speeds up.
  final String kind;

  final int? minutes;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the crowd and the shortcut land the ask.
  bool meets(int crowd, bool open) {
    if (crowd < Rules.least || crowd > Rules.most || crowd % Rules.step != 0) return false;
    switch (kind) {
      case 'shutMinutes':
        return !open && Rules.journey(crowd, false) == minutes;
      case 'openMinutes':
        return open && Rules.journey(crowd, true) == minutes;
      case 'helps':
        return open && Rules.verdictOf(crowd) == 'helps';
      case 'noOdds':
        return Rules.verdictOf(crowd) == 'no odds';
      default:
        return open && crowd > 30 && Rules.verdictOf(crowd) == 'helps';
    }
  }

  /// The setting the pointer works towards, the sweep's first, shut
  /// before open, or null.
  (int, bool)? get aim {
    for (var crowd = Rules.least; crowd <= Rules.most; crowd += Rules.step) {
      for (final open in [false, true]) {
        if (meets(crowd, open)) return (crowd, open);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'shutMinutes':
        return 'dial the crowd so that, with the shortcut shut, every driver takes $minutes minutes';
      case 'openMinutes':
        return 'dial the crowd so that, with the shortcut open, every driver takes $minutes minutes';
      case 'helps':
        return 'open the shortcut on a crowd it speeds up';
      case 'noOdds':
        return 'dial the crowd the shortcut makes no odds to, open or shut';
      default:
        return 'open the shortcut on a crowd past thirty hundred that it speeds up';
    }
  }
}
