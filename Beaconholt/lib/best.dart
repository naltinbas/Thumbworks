import 'package:shared_preferences/shared_preferences.dart';

/// The fewest beacons each country has been watched with.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a country they have
/// never lit.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'watched.';

  static String _key(String country) => '$_prefix$country';

  int? beaconsFor(String country) => _prefs.getInt(_key(country));

  bool has(String country) => beaconsFor(country) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a country, and says whether it beat what was there.
  Future<bool> record(String country, int beacons) async {
    final before = beaconsFor(country);
    if (before != null && before <= beacons) return false;
    await _prefs.setInt(_key(country), beacons);
    return true;
  }
}
