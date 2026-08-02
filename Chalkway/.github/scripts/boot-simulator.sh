#!/usr/bin/env bash
#
# Boots one iPhone simulator and reports which one, so the steps after this
# drive it by udid instead of trusting whatever `booted` happens to mean.
#
# Which iPhone it is does not matter to the game, only that it is a phone, so
# this takes whatever the runner's Xcode already has rather than naming a
# model that a newer image might have dropped.
set -euo pipefail

udid=$(xcrun simctl list devices available --json | python3 -c '
import json, sys

runtimes = json.load(sys.stdin)["devices"]
chosen = ""
for runtime in sorted(runtimes):
    if "iOS" not in runtime:
        continue
    for device in runtimes[runtime]:
        if device.get("isAvailable") and device["name"].startswith("iPhone"):
            chosen = device["udid"]
print(chosen)
')

if [ -z "$udid" ]; then
  echo "this runner has no iPhone simulator to play on" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

xcrun simctl boot "$udid" || true
# -b waits for the boot to finish, and boots the device if it has not started.
xcrun simctl bootstatus "$udid" -b
xcrun simctl list devices booted

echo "udid=$udid" >>"$GITHUB_OUTPUT"
