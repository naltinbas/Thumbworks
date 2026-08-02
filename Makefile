.PHONY: deps test analyze shots dryrun apk ios clean

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

# Plays the whole game three ways with nobody at the controls and reports how
# far each got. This is what the waves and the tower numbers were tuned
# against; run it before believing any change to either.
dryrun:
	dart run tool/dryrun.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
