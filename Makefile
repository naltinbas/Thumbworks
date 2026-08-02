.PHONY: deps test analyze shots book apk ios clean

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

# Rebuilds lib/game/deals.dart: searches the first five hundred deals, keeps
# the ones the solver wins, and writes them down. Four minutes, and the reason
# the game can promise that every deal it deals can be won.
book:
	dart run tool/build_book.dart 500

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
