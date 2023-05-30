#!/usr/bin/env bash
#
# Helper functions for console (stdout/stderr) logging.
#

function get_datetime_str() {
    date +"%D %T %Z"
}

# Emits argument in $1 to stdout with date-time and "INFO" as header.
function log() {
    printf "[%s] INFO : %s\n" "$(get_datetime_str)" "$1"
}

# Emits argument in $1 to stdout+stderr with date-time and "ERROR" as header.
function log_err() {
    printf "[%s] ERROR: %s\n" "$(get_datetime_str)" "$1" 1>&2
}
