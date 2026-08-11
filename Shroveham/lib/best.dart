import 'package:shared_preferences/shared_preferences.dart';

/// The fewest flips each batch has been served on.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a batch nobody has
/// flipped.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'served.';

  static String _key(String batch) => '$_prefix$batch';

  int? flipsFor(String batch) => _prefs.getInt(_key(batch));

  bool has(String batch) => flipsFor(batch) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a serving down, and says whether it beat what was there.
  Future<bool> record(String batch, int flips) async {
    final before = flipsFor(batch);
    if (before != null && before <= flips) return false;
    await _prefs.setInt(_key(batch), flips);
    return true;
  }
}
