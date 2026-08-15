/// One load on the sham: how much to balance, which weights are barred,
/// and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.load,
    this.barred = const [],
    required this.ways,
    required this.placings,
    this.note,
  });

  final String name;
  final int load;

  /// Weights that stay off the scale.
  final List<int> barred;

  /// Placings that balance, by the sweep; nought for the hopeless.
  final int ways;

  /// Placings of the weights allowed, all told: three ways apiece.
  final int placings;

  /// One thing worth knowing about this load, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {2: 'two', 10: 'ten', 20: 'twenty', 31: 'thirty-one', 40: 'forty'};

  /// The task, told in words for the ledger.
  String get task => barred.isEmpty
      ? 'balance a load of ${_words[load] ?? '$load'} with the four weights on either pan'
      : 'balance a load of ${_words[load] ?? '$load'} with the ${barred.join(', ')} kept off';
}
