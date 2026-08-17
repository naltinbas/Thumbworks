import 'rules.dart';

/// One ask: what the out-train is to look like when the yard is clear.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'order': the out-train is exactly [aim]; 'last': wagon 1 leaves
  /// last; 'odds': every odd wagon leaves before every even one;
  /// 'head': the first three out are 3, then 1, then 2, which one
  /// siding cannot do.
  final String kind;

  /// How many out-trains land it, from the sweep.
  final int ways;

  /// The cheapest out-train that lands it, from the sweep; null when
  /// none does.
  final List<int>? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the finished out-train lands the ask.
  bool meets(List<int> train) {
    if (train.length != Rules.wagons) return false;
    switch (kind) {
      case 'order':
        return train.join(',') == aim!.join(',');
      case 'last':
        return train.last == 1;
      case 'odds':
        var evens = 0;
        for (final wagon in train) {
          if (wagon.isEven) {
            evens++;
          } else if (evens > 0) {
            return false;
          }
        }
        return true;
      default:
        return train.length >= 3 &&
            train[0] == 3 &&
            train[1] == 1 &&
            train[2] == 2;
    }
  }

  /// Whether a train begun this way could still land the ask.
  bool couldStill(List<int> sent) {
    switch (kind) {
      case 'order':
        for (var i = 0; i < sent.length; i++) {
          if (sent[i] != aim![i]) return false;
        }
        return true;
      case 'last':
        return !sent.contains(1) || sent.length == Rules.wagons;
      case 'odds':
        var evens = 0;
        for (final wagon in sent) {
          if (wagon.isEven) {
            evens++;
          } else if (evens > 0) {
            return false;
          }
        }
        return true;
      default:
        const head = [3, 1, 2];
        for (var i = 0; i < sent.length && i < 3; i++) {
          if (sent[i] != head[i]) return false;
        }
        return true;
    }
  }

  /// The taps the cheapest out-train takes.
  int? get fewest => aim == null ? null : Rules.tapsFor(aim!);

  /// The task, told in words.
  String get task => switch (kind) {
        'order' => aim!.first == 1
            ? 'send the wagons out in the order they stand in'
            : 'send the wagons out backwards, 6 first and 1 last',
        'last' => 'send the wagons out with wagon 1 last',
        'odds' => 'send every odd wagon out before any even one',
        _ => 'send wagon 3 out first, then wagon 1, then wagon 2',
      };
}
