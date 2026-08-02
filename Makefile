.PHONY: deps test analyze shots audio apk ios clean

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

# Rebuilds the sound in assets/ from the note lists in lib/tune/. The tests
# check that what is in assets/ is what this makes, so run it after changing a
# tune or the synthesiser.
audio:
	dart run tool/build_audio.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
