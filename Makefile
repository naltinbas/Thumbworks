.PHONY: deps test analyze shots balance apk ios clean

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

# Plays the opponent against itself and reports who wins. This is what settled
# the opening; a change to the rules, the evaluation or the search should be
# run past it before it is believed.
balance:
	dart run tool/balance.dart 3 40

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
