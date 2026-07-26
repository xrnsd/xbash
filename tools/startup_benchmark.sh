#!/opt/homebrew/bin/bash
# Benchmark the login-shell path that macOS Terminal uses for xbash.

set -u

runs=7
target_ms=500
refresh_cache=false

usage()
{
    cat <<'EOF'
Usage: tools/startup_benchmark.sh [--runs N] [--target-ms N] [--refresh-cache]

Measures a login, interactive Bash shell and verifies that xbash and Conda are
ready at the prompt.  The target defaults to 500ms.

  --runs N          Number of timed runs (default: 7)
  --target-ms N     Maximum allowed average startup time (default: 500)
  --refresh-cache   Rebuild the Conda startup cache before measuring
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --runs)
            runs="${2:-}"
            shift 2
            ;;
        --target-ms)
            target_ms="${2:-}"
            shift 2
            ;;
        --refresh-cache)
            refresh_cache=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

[[ "$runs" =~ ^[1-9][0-9]*$ ]] || {
    printf '%s\n' '--runs must be a positive integer' >&2
    exit 2
}
[[ "$target_ms" =~ ^[1-9][0-9]*$ ]] || {
    printf '%s\n' '--target-ms must be a positive integer' >&2
    exit 2
}

bash_bin=${BASH:-bash}

if [[ "$refresh_cache" == true ]]; then
    XBASH_CONDA_CACHE_REFRESH=true "$bash_bin" -ilc true </dev/null >/dev/null 2>&1 || {
        printf '%s\n' 'Failed to refresh the Conda startup cache.' >&2
        exit 1
    }
fi

"$bash_bin" -ilc '
    type -t ftMain | grep -qx function &&
    alias xdf >/dev/null &&
    type -t conda | grep -qx function &&
    [[ "$CONDA_PREFIX" = "/opt/homebrew/Caskroom/miniconda/base" ]] &&
    [[ "$CONDA_SHLVL" = 1 ]]
' </dev/null >/dev/null 2>&1 || {
    printf '%s\n' 'Readiness check failed: xbash or the base Conda environment is unavailable.' >&2
    exit 1
}

samples=()
for ((run=1; run<=runs; run++)); do
    start_time=$EPOCHREALTIME
    "$bash_bin" -ilc true </dev/null >/dev/null 2>&1
    end_time=$EPOCHREALTIME
    samples+=("$(awk -v start="$start_time" -v end="$end_time" 'BEGIN { printf "%.0f", (end - start) * 1000 }')")
done

summary=$(printf '%s\n' "${samples[@]}" | awk '
    { total += $1; if (NR == 1 || $1 < min) min = $1; if ($1 > max) max = $1 }
    END { printf "avg=%.0f min=%d max=%d", total / NR, min, max }
')
average_ms=${summary#avg=}
average_ms=${average_ms%% *}

printf 'xbash login startup: %s ms (%s)\n' "${samples[*]}" "$summary"
printf 'Readiness check: passed (ftMain, xdf, Conda base)\n'

if (( average_ms <= target_ms )); then
    printf 'Target: passed (average %sms <= %sms)\n' "$average_ms" "$target_ms"
    exit 0
fi

printf 'Target: not met (average %sms > %sms)\n' "$average_ms" "$target_ms" >&2
exit 1
