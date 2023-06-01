#!/usr/bin/env bash
#
# Helper functions for console (stdout/stderr) logging.
#

COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_RED="\033[0;31m"
COLOR_RESET="\033[0m"

# Helper function, not to use directly.
# Emits the current timestamp to stdout to be used as header in logging traces.
# If `date` command fails, it will print the error output instead and will
# exit with status code 1.
timestamp() {
	local err tms
	tms="$(date +%Y%m%d-%H:%M:%S 2>&1)" || {
		err=$?
		printf >&2 "%s\n" "Failed to run date command: $tms"
		exit $err
	}
	printf %s "$tms"
}

# Info logger: emits arguments to stdout with date-time and "INFO" as header.
# Example:
#  20230531-02:41:52 INFO : test for tracing with log_info
log_info() {
	local tms
	tms="$(timestamp)" || exit $?
	printf "${COLOR_GREEN}%s INFO : ${COLOR_RESET}%s\n" "$tms" "$*"
}

# Warning logger: emits arguments to stderr with date-time and "WARN" as header.
# Example:
#  20230531-02:41:52 WARN : test for tracing with log_warn
log_warn() {
	local tms
	tms="$(timestamp)" || exit $?
	printf >&2 "${COLOR_YELLOW}%s WARN : ${COLOR_RESET}%s\n" "$tms" "$*"
}

# Error logger: emits arguments to stderr with date-time and "ERROR" as header.
#  20230531-02:41:52 ERROR: test for tracing with log_error
log_error() {
	local tms
	tms="$(timestamp)" || exit $?
	printf >&2 "${COLOR_RED}%s ERROR: ${COLOR_RESET}%s\n" "$tms" "$*"
}
