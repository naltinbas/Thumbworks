.PHONY: deps test analyze shots pars apk ios clean

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

# Searches every yard for the shortest way through it and prints what it
# found. This is where the par on a level comes from — and a test fails if a
# level's par is not what this says.
pars:
	dart run tool/pars.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
