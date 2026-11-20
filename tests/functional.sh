#!/usr/bin/env bash
#
# Functional tests for wtr. These run the real program against the live
# Rijkswaterstaat API, so they need network access.
#
# Usage: tests/functional.sh [path/to/wtr]
#

set -u

WTR="${1:-./wtr}"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
export WTR_CACHE="$WORKDIR/wtr_cache.db"

PASSED=0
FAILED=0
CURRENT=""
CURRENT_OK=1

# Data row with headers:     "  2026-11-20T20:10:00.000+01:00  314.0"
# Data row without headers:  "2026-11-20T20:10:00.000+01:00  314.0"
ROW_RE='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}[+-][0-9]{2}:[0-9]{2}  -?[0-9]+(\.[0-9]+)?'

# Run wtr with the given arguments; capture stdout, stderr and exit code.
run() {
    "$WTR" "$@" >"$WORKDIR/out" 2>"$WORKDIR/err"
    EXIT=$?
    OUT="$(cat "$WORKDIR/out")"
    ERR="$(cat "$WORKDIR/err")"
}

begin() {
    CURRENT="$1"
    CURRENT_OK=1
}

fail() {
    if [ "$CURRENT_OK" -eq 1 ]; then
        echo "FAIL  $CURRENT"
    fi
    CURRENT_OK=0
    echo "      - $1"
}

end() {
    if [ "$CURRENT_OK" -eq 1 ]; then
        echo "PASS  $CURRENT"
        PASSED=$((PASSED + 1))
    else
        echo "      stdout (first 10 lines):"
        echo "$OUT" | head -10 | sed 's/^/        | /'
        echo "      stderr (first 10 lines):"
        echo "$ERR" | head -10 | sed 's/^/        | /'
        FAILED=$((FAILED + 1))
    fi
}

expect_exit() {
    [ "$EXIT" -eq "$1" ] || fail "expected exit code $1, got $EXIT"
}

expect_out() {
    grep -qF -- "$1" <<<"$OUT" || fail "stdout does not contain: $1"
}

expect_no_out() {
    ! grep -qF -- "$1" <<<"$OUT" || fail "stdout unexpectedly contains: $1"
}

expect_err() {
    grep -qF -- "$1" <<<"$ERR" || fail "stderr does not contain: $1"
}

# expect_rows <min> <max> <regex>: number of data rows matching regex
expect_rows() {
    local count
    count=$(grep -cE -- "$3" <<<"$OUT")
    if [ "$count" -lt "$1" ] || [ "$count" -gt "$2" ]; then
        fail "expected $1..$2 data rows, got $count"
    fi
}

#
# Help and argument handling (no network needed)
#

begin "--help shows usage and version"
run --help
expect_exit 0
expect_out "usage: wtr"
expect_out "Rijkswaterstaat Waterinfo API client v"
expect_no_out "vv"
end

begin "unknown command is rejected"
run foo
expect_exit 2
expect_err "invalid choice"
end

begin "observe without -l is rejected"
run observe
expect_exit 2
expect_err "observe requires a location"
end

begin "--rows 0 is rejected"
run observe -l culemborg -r 0
expect_exit 2
expect_err "--rows must be 1 or more"
end

begin "--rows with a non-number is rejected"
run observe -l culemborg -r abc
expect_exit 2
expect_err "invalid int value"
end

begin "argument errors do not create the cache"
[ ! -e "$WTR_CACHE" ] || fail "cache file exists before any real command ran"
end

#
# Cache creation and listing
#

begin "first run creates the cache (list -c measures)"
run list -c measures
expect_exit 0
expect_out "Caching metadata..."
expect_out "Compartment_Code (Description): Measure (Description) - Note"
expect_out "OW (Oppervlaktewater): WATHTE (Waterhoogte)"
[ -s "$WTR_CACHE" ] || fail "cache file $WTR_CACHE was not created"
end

begin "list defaults to locations and reuses the cache"
run list
expect_exit 0
expect_no_out "Caching metadata..."
expect_out "Location (Name): Compartment_Code (Description) - Measure (Description)"
expect_out "culemborg (Culemborg): OW (Oppervlaktewater) - WATHTE (Waterhoogte)"
end

begin "list -c locations"
run list -c locations
expect_exit 0
expect_out "Location (Name): Compartment_Code (Description) - Measure (Description)"
expect_out "culemborg (Culemborg): OW (Oppervlaktewater) - WATHTE (Waterhoogte)"
end

begin "list -c with an unknown category"
run list -c foo
expect_exit 0
expect_out "Unknown category"
end

begin "update refreshes the cache"
run update
expect_exit 0
expect_out "Updating metadata..."
run list -c locations
expect_out "culemborg (Culemborg)"
end

#
# Observations
#

begin "observe -l culemborg (default measure WATHTE, 18 rows)"
run observe -l culemborg
expect_exit 0
expect_out "# Location: culemborg (Culemborg)"
expect_out "# Measure: WATHTE (Waterhoogte)"
expect_out "# Timestamp                      Value"
expect_rows 1 18 "^  $ROW_RE\$"
end

begin "observe -m WATHTE -r 5"
run observe -l culemborg -m WATHTE -r 5
expect_exit 0
expect_out "# Measure: WATHTE (Waterhoogte)"
expect_rows 1 5 "^  $ROW_RE\$"
end

begin "observe -r 1"
run observe -l culemborg -r 1
expect_exit 0
expect_rows 1 1 "^  $ROW_RE\$"
end

begin "observe --no-headers"
run observe -l culemborg -r 3 --no-headers
expect_exit 0
expect_no_out "#"
expect_rows 1 3 "^$ROW_RE\$"
end

begin "observe -m T (data may be unavailable)"
run observe -l culemborg -m T -r 3
expect_exit 0
if grep -qF "No data available" <<<"$OUT"; then
    echo "      note: no live data for measure T at culemborg"
else
    expect_out "# Measure: T ("
    expect_rows 1 3 "^  $ROW_RE\$"
fi
end

begin "observe with an unknown location"
run observe -l nowhere
expect_exit 1
expect_err "unknown location 'nowhere'"
end

begin "observe with a quote in the location"
run observe -l "x'y"
expect_exit 1
expect_err "unknown location 'x'y'"
end

begin "observe with an unknown measure"
run observe -l culemborg -m NOPE
expect_exit 1
expect_err "unknown measure 'NOPE'"
end

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
