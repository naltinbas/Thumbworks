.PHONY: deps test analyze shots odds apk ios clean

deps:
	flutter pub get

test:
	flutter test

analyze:
	flutter analyze

# Renders the game at real phone sizes into build/showcase, and redraws the
# logo and the app icon.
shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

# Works out the whole table of odds and prints what it cost and what it found:
# how many passes it took to settle, what the first player is worth, and the
# turn total worth banking on at every score.
odds:
	dart run tool/reckon.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
