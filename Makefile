.PHONY: deps test analyze shots audit apk ios clean

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

# Lays out a hundred boards of each plot and says what that cost: how many
# were thrown away for each one kept, how long a board takes, and which rule
# each kept board actually needed.
audit:
	dart run tool/audit.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
