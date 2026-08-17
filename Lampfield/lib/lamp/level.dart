import 'rules.dart';

/// One ask: what the lamps are to say.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// 'code': the message is in the code; 'four': in the code with four
  /// lamps lit; 'dark': every lamp dark; 'lit': every lamp lit;
  /// 'fool': in the code and a lost lamp the reader gets wrong, which
  /// never happens.
  final String kind;

  /// How many messages land it, from the sweep.
  final int ways;

  /// The fewest lamps to change from the opening; null when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the message lands the ask.
  bool meets(List<int> message) {
    if (!Rules.valid(message)) return false;
    switch (kind) {
      case 'code':
        return Rules.inCode(message);
      case 'four':
        return Rules.inCode(message) && Rules.lit(message) == 4;
      case 'dark':
        return Rules.lit(message) == 0;
      case 'lit':
        return Rules.lit(message) == Rules.lamps;
      default:
        if (!Rules.inCode(message)) return false;
        for (var gone = 1; gone <= Rules.lamps; gone++) {
          if (!Rules.holds(message, gone)) return true;
        }
        return false;
    }
  }

  /// The task, told in words.
  String get task => switch (kind) {
        'code' => 'light the lamps so the sum comes to nothing over nine',
        'four' => 'light four lamps so the sum comes to nothing over nine',
        'dark' => 'leave every lamp dark',
        'lit' => 'light every lamp',
        _ => 'send a message in the code that the reader gets wrong when a '
            'lamp goes out',
      };
}
