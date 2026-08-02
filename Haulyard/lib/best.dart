import 'package:shared_preferences/shared_preferences.dart';

/// The fewest shoves anybody has finished each yard in.
///
/// Keyed on the yard's name rather than its place in the list, so putting a
/// new yard in the middle does not hand somebody else's record to one they
/// have never played.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String yard) => 'best.$yard';

  static const _prefix = 'best.';

  /// The fewest shoves this yard has been finished in, or null.
  int? shovesFor(String yard) => _prefs.getInt(_key(yard));

  bool has(String yard) => shovesFor(yard) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a finish, and says whether it beat what was there.
  Future<bool> record(String yard, int shoves) async {
    final before = shovesFor(yard);
    if (before != null && before <= shoves) return false;
    await _prefs.setInt(_key(yard), shoves);
    return true;
  }
}
