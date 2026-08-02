.PHONY: deps test analyze shots stretches apk ios clean

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

# Rebuilds lib/sim/stretches.dart: makes candidate stretches, plays each one
# to the end with a search over the button, and writes down the ones that come
# out along with the presses that did it. About a minute.
stretches:
	dart run tool/build_stretches.dart 70

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
