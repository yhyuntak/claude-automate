#!/bin/bash

################################################################################
# Session End Hook Script
#
# Purpose:
#   Executes when user ends a session to:
#   - Capture final session state and metrics
#   - Evaluate whether compression is needed
#   - Generate recommendations for next session
#   - Display reminder to run /wrap for finalization
#   - Log session metrics for analysis
#
# When triggered:
#   - User triggers session stop/exit
#   - Before plugin shuts down
#   - Automatically by Claude Code hook system
#
# Output files created:
#   - .claude/session-end-logs/*.json    (session end metadata)
#   - .claude/hooks.log                  (execution log)
#   - Display message to user
#
# Usage:
#   ./session-end.sh                     # Execute hook (called automatically)
#   ./session-end.sh --verbose           # With detailed logging
#   ./session-end.sh --dry-run           # Preview without writing
#
# Integration:
#   Add to ~/.claude-plugin/hooks.json under Stop hook:
#   "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-end.sh"
#
################################################################################

set -e

################################################################################
# CONFIGURATION
################################################################################

# Paths and directories
PROJECT_ROOT="${PROJECT_ROOT:-.}"
SESSION_END_LOGS=".claude/session-end-logs"
HOOKS_LOG=".claude/hooks.log"

# Thresholds for compression recommendations (in KB)
COMPRESS_THRESHOLD_KB=40
AGGRESSIVE_THRESHOLD_KB=60

# Feature flags
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"

################################################################################
# UTILITY FUNCTIONS
################################################################################

# Print message (only in verbose mode)
verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[VERBOSE] $1" >&2
    fi
}

# Print error and exit
error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Log to hooks.log file
log_to_file() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$HOOKS_LOG"
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" 2>/dev/null || {
            verbose "Cannot create directory: $dir"
        }
    fi
}

# Get file size in bytes
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Get session ID
get_session_id() {
    if [[ -f ".claude/session_id" ]]; then
        cat ".claude/session_id"
    else
        echo "unknown"
    fi
}

# Calculate session duration if start time is available
calculate_duration() {
    local start_file=".claude/session_start_time"

    if [[ ! -f "$start_file" ]]; then
        echo "0" "0"
        return
    fi

    local start_time=$(cat "$start_file")
    local end_time=$(date +%s)
    local duration_secs=$((end_time - start_time))
    local duration_mins=$((duration_secs / 60))

    echo "$duration_secs" "$duration_mins"
}

# Escape JSON string value
json_escape() {
    local string="$1"
    # Escape special characters for JSON
    echo "$string" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n'
}

################################################################################
# MAIN LOGIC
################################################################################

# Collect session metrics
collect_metrics() {
    verbose "Collecting session metrics..."

    # Session information
    local session_id=$(get_session_id)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local timestamp_short=$(date -u +"%Y%m%d-%H%M%S")

    # Context metrics
    local context_size=0
    local context_kb=0
    if [[ -f ".claude/context.md" ]]; then
        context_size=$(get_file_size ".claude/context.md")
        context_kb=$((context_size / 1024))
    fi

    # Duration metrics
    read -r duration_secs duration_mins < <(calculate_duration)

    # Compression recommendations
    local needs_compression="false"
    local needs_aggressive_compression="false"

    if [[ $context_kb -gt $COMPRESS_THRESHOLD_KB ]]; then
        needs_compression="true"
    fi

    if [[ $context_kb -gt $AGGRESSIVE_THRESHOLD_KB ]]; then
        needs_aggressive_compression="true"
    fi

    echo "$session_id" "$timestamp" "$timestamp_short" "$context_size" "$context_kb" "$duration_secs" "$duration_mins" "$needs_compression" "$needs_aggressive_compression"
}

# Create session end log file
create_session_end_log() {
    local session_id="$1"
    local timestamp="$2"
    local timestamp_short="$3"
    local context_size="$4"
    local context_kb="$5"
    local duration_secs="$6"
    local duration_mins="$7"
    local needs_compression="$8"
    local needs_aggressive="$9"

    local log_file="${SESSION_END_LOGS}/session-${timestamp_short}-${session_id}.json"

    # Create JSON log file
    cat > "$log_file" <<EOF
{
  "metadata": {
    "timestamp": "$timestamp",
    "session_id": "$session_id",
    "action": "session_stop"
  },
  "session_duration": {
    "seconds": $duration_secs,
    "minutes": $duration_mins
  },
  "context_state": {
    "size_bytes": $context_size,
    "size_kb": $context_kb
  },
  "recommendations": {
    "needs_compression": $needs_compression,
    "needs_aggressive_compression": $needs_aggressive,
    "wrap_recommended": true
  }
}
EOF

    echo "$log_file"
}

# Create user-facing message
create_user_message() {
    local context_kb="$1"
    local needs_compression="$2"
    local duration_mins="$3"

    # Determine urgency level
    local urgency=""
    local recommendation=""

    if [[ "$needs_compression" == "true" ]]; then
        if [[ $context_kb -gt $AGGRESSIVE_THRESHOLD_KB ]]; then
            urgency="URGENT"
            recommendation="Context is large. Compression is strongly recommended."
        else
            urgency="RECOMMENDED"
            recommendation="Context size is approaching limit. Consider compacting."
        fi
    else
        urgency="OK"
        recommendation="Your context is healthy for now."
    fi

    cat <<'EOF'
<system-reminder>

[SESSION END SUMMARY]

Your development session has ended. Here's a quick summary:

EOF

    if [[ $duration_mins -gt 0 ]]; then
        echo "Session Duration: ${duration_mins} minutes"
    fi

    echo "Context Size: ${context_kb}KB"
    echo "Compression: $urgency - $recommendation"

    cat <<'EOF'

Next Steps:

1. Consider running /wrap to:
   • Check code patterns
   • Analyze usage patterns
   • Sync documentation
   • Finalize session context

2. After /wrap, your session will be saved to:
   .claude/context/YYYY-MM/YYYY-MM-DD-{id}.md

3. Type '/wrap' now, or exit to end the session.

</system-reminder>
EOF
}

# Display session summary
display_summary() {
    local context_kb="$1"
    local duration_mins="$2"
    local needs_compression="$3"

    echo "✅ SessionEnd Hook Complete"
    echo "   Context Size: ${context_kb}KB"

    if [[ $duration_mins -gt 0 ]]; then
        echo "   Session Duration: ${duration_mins} minutes"
    fi

    if [[ "$needs_compression" == "true" ]]; then
        echo "   ⚠️ Compression recommended"
    else
        echo "   ✓ Context healthy"
    fi

    echo "   /wrap reminder sent to user"
}

# Execute main hook logic
execute_hook() {
    verbose "SessionEnd Hook: Beginning execution"

    # Setup directories
    ensure_dir "$SESSION_END_LOGS"
    ensure_dir "$(dirname "$HOOKS_LOG")"

    # Collect all metrics
    read -r session_id timestamp timestamp_short context_size context_kb duration_secs duration_mins needs_compression needs_aggressive < <(collect_metrics)

    verbose "Collected metrics:"
    verbose "  Session ID: $session_id"
    verbose "  Context: ${context_kb}KB"
    verbose "  Duration: ${duration_mins}m"
    verbose "  Needs compression: $needs_compression"

    # Create session end log file
    if [[ "$DRY_RUN" != "true" ]]; then
        local log_file=$(create_session_end_log "$session_id" "$timestamp" "$timestamp_short" "$context_size" "$context_kb" "$duration_secs" "$duration_mins" "$needs_compression" "$needs_aggressive")
        verbose "Session end log created: $log_file"

        # Log to hooks.log
        log_to_file "SessionEnd Hook: Session ID=$session_id, Duration=${duration_mins}min, Context=${context_kb}KB, Compression=$needs_compression"
    fi

    # Display summary
    display_summary "$context_kb" "$duration_mins" "$needs_compression"

    # Create user message
    local user_message=$(create_user_message "$context_kb" "$needs_compression" "$duration_mins")

    # Escape for JSON output
    local escaped_message=$(echo "$user_message" | jq -Rs '.')

    # Return JSON response for hook system
    # This will be displayed to the user and allow continuation if they want to run /wrap
    cat <<EOF
{
  "continue": true,
  "message": $escaped_message,
  "metadata": {
    "session_id": "$session_id",
    "context_kb": $context_kb,
    "needs_compression": $needs_compression
  }
}
EOF

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] No files actually written" >&2
    fi
}

################################################################################
# CLI DISPATCHER
################################################################################

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --project)
            PROJECT_ROOT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Change to project root if specified
if [[ -n "$PROJECT_ROOT" ]] && [[ "$PROJECT_ROOT" != "." ]]; then
    cd "$PROJECT_ROOT" || error "Failed to change to project directory: $PROJECT_ROOT"
    verbose "Changed to project root: $PROJECT_ROOT"
fi

# Execute the hook
execute_hook

exit 0
