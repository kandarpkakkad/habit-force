#!/usr/bin/env bash
# Builds the debug APKs in Docker and runs the Kotlin unit tests. The APKs land
# in build/docker/. This is the only check that the Kotlin half compiles.
#
#   tool/build_in_docker.sh
#   HABIT_FORCE_TIMEOUT=90m tool/build_in_docker.sh
#
# The first run downloads Gradle, the Android dependencies and the NDK into
# named volumes, which is why the default limit is an hour; later runs reuse
# them and take minutes. After the limit the build is killed, the container
# removed, and the script exits 124.
set -euo pipefail

cd "$(dirname "$0")/.."
file=docker-compose.test.yml
limit="${HABIT_FORCE_TIMEOUT:-60m}"

cleanup() {
  docker compose -f "$file" down --remove-orphans > /dev/null 2>&1 || true
  docker ps -aq --filter "label=com.docker.compose.project=habit-force-test" \
    | xargs -r docker rm -f > /dev/null 2>&1 || true
}
trap cleanup EXIT

status=0
timeout --kill-after=30s "$limit" docker compose -f "$file" run --rm build || status=$?
[ "$status" = 124 ] && echo "tool/build_in_docker.sh: stopped after $limit" >&2
exit "$status"
