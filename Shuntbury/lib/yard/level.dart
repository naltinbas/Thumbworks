import 'rules.dart';

/// One ask: a yard to shunt home.
class Level {
  const Level({
    required this.name,
    required this.start,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The wagons as they stand at the start, the gap as 0.
  final List<int> start;

  /// The fewest shunts home from the start, from the walk; null when it
  /// can never get there.
  final int? fewest;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => fewest != null;

  /// Whether the yard as it stands lands the ask: home.
  bool meets(List<int> yard) => yard.toString() == Rules.home.toString();

  /// The task, told in words for the ledger.
  String get task => 'shunt the wagons home from ${Rules.told(start)}${fewest == null ? '' : ', the fewest being ${_word(fewest!)}'}';

  static String _word(int n) => n < _words.length ? _words[n] : '$n';
  static const _words = [
    'nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
    'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen',
    'nineteen', 'twenty', 'twenty-one', 'twenty-two', 'twenty-three', 'twenty-four', 'twenty-five',
    'twenty-six', 'twenty-seven', 'twenty-eight', 'twenty-nine', 'thirty', 'thirty-one',
  ];
}
