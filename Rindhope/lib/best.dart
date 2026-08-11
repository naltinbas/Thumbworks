import 'package:shared_preferences/shared_preferences.dart';

/// The fewest bites each block has been won in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a block nobody has
/// bitten. Lost blocks write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'eaten.';

  static String _key(String block) => '$_prefix$block';

  int? bitesFor(String block) => _prefs.getInt(_key(block));

  bool has(String block) => bitesFor(block) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a won block down, and says whether it beat what was there.
  Future<bool> record(String block, int bites) async {
    final before = bitesFor(block);
    if (before != null && before <= bites) return false;
    await _prefs.setInt(_key(block), bites);
    return true;
  }
}
