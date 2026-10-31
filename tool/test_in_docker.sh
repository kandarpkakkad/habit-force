#!/usr/bin/env bash
# `flutter analyze` and `flutter test` in Docker — no Flutter needed here.
#
#   tool/test_in_docker.sh
#   HABIT_FORCE_TIMEOUT=30m tool/test_in_docker.sh
#
# Time-limited: a hung container must not run for ever. After the limit the
# run is killed, the container removed, and the script exits 124.
#
# The container is removed when the run ends, pass, fail or timeout, and so is
# the network compose made for it; only the cache volumes are kept. The exit
# status is the suite's. docker-compose.test.yml says why it works this way.
set -euo pipefail

cd "$(dirname "$0")/.."
file=docker-compose.test.yml
limit="${HABIT_FORCE_TIMEOUT:-20m}"

cleanup() {
  docker compose -f "$file" down --remove-orphans > /dev/null 2>&1 || true
  # A run container killed by the timeout can outlive `down`; remove it by label.
  docker ps -aq --filter "label=com.docker.compose.project=habit-force-test" \
    | xargs -r docker rm -f > /dev/null 2>&1 || true
}
trap cleanup EXIT

status=0
timeout --kill-after=30s "$limit" docker compose -f "$file" run --rm test || status=$?
[ "$status" = 124 ] && echo "tool/test_in_docker.sh: stopped after $limit" >&2
exit "$status"
