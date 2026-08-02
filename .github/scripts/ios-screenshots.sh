#!/usr/bin/env bash
#
# Plays a round on a booted simulator and keeps the pictures. Same two kinds
# as the Android run: the named ones the test asks the framework for, and
# sampled ones off the simulator screen that are allowed to fail.
#
# Takes the udid of the simulator to drive. It is the only one booted, so the
# sampler can say `booted` and mean it.
set -euo pipefail

udid="$1"
bundle=dev.latchword.latchword
shots=build/screenshots

mkdir -p "$shots/device"

sample_the_screen() {
  # The app has a container on the simulator from the moment it is installed,
  # which is the last thing to happen before it is launched.
  while ! xcrun simctl get_app_container "$udid" "$bundle" >/dev/null 2>&1; do
    sleep 5
  done
  for i in $(seq 0 39); do
    xcrun simctl io booted screenshot --type=png \
      "$shots/device/$(printf '%02d' "$i").png" || true
    sleep 2
  done
}

sample_the_screen &
sampler=$!
trap 'kill "$sampler" 2>/dev/null || true' EXIT

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  --device-id "$udid" \
  --debug

kill "$sampler" 2>/dev/null || true

# The drive can pass while handing back nothing, so say so here rather than
# let the job go green with an empty artifact.
for name in 01-title 02-tracing 03-counted 04-summary; do
  if [ ! -s "$shots/$name.png" ]; then
    echo "the drive finished without leaving $name.png" >&2
    exit 1
  fi
done
ls -l "$shots"
