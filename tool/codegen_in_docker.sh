#!/usr/bin/env bash
# Regenerates drift's code (lib/**/*.g.dart) in Docker and copies back only the
# generated files and pubspec.lock. Run it after changing
# lib/platform/storage/tables.dart or a query that drift generates.
#
#   tool/codegen_in_docker.sh
#   HABIT_FORCE_TIMEOUT=30m tool/codegen_in_docker.sh
#
# Time-limited like tool/test_in_docker.sh: killed and cleaned up after the
# limit, exit 124.
set -euo pipefail

cd "$(dirname "$0")/.."
file=docker-compose.test.yml
limit="${HABIT_FORCE_TIMEOUT:-20m}"

cleanup() {
  docker compose -f "$file" down --remove-orphans > /dev/null 2>&1 || true
  docker ps -aq --filter "label=com.docker.compose.project=habit-force-test" \
    | xargs -r docker rm -f > /dev/null 2>&1 || true
}
trap cleanup EXIT

status=0
timeout --kill-after=30s "$limit" docker compose -f "$file" run --rm codegen || status=$?
[ "$status" = 124 ] && echo "tool/codegen_in_docker.sh: stopped after $limit" >&2
exit "$status"
