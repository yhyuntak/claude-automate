#!/bin/bash

################################################################################
# Strategic Compact Suggester Script
#
# Purpose:
#   Monitors tool execution count and suggests context compaction at optimal times.
#   Uses a counter-based threshold system to avoid context bloat without being
#   overly aggressive.
#
# How it works:
#   1. Increments a counter for each tool execution
#   2. When counter reaches threshold (default: 10), triggers compaction alert
#   3. After compaction, counter resets
#   4. Fully configurable thresholds for different session types
#
# Usage:
#   ./strategic-compact.sh main          # Primary function (hooked)
#   ./strategic-compact.sh reset         # Reset counter to 0
#   ./strategic-compact.sh status        # Show current counter state
#   ./strategic-compact.sh config        # Display configuration
#
# Configuration:
#   - Adjust THRESHOLD variable (lines ~30-35) for different session types
#   - Session type: 3-5 (marathon), 5-10 (long), 10-20 (standard), 20+ (short)
#
# Integration:
#   Add to ~/.claude-plugin/hooks.json under PreToolUse hook:
#   "command": "${HOME}/.claude-plugin/hooks/strategic-compact.sh main"
#
################################################################################

set -o pipefail

################################################################################
# CONFIGURATION SECTION
################################################################################

# Path where counter file is stored (survives across sessions)
COUNTER_FILE="${HOME}/.claude-plugin/.compact-counter"

# Compression alert threshold
# This is the number of tool executions before suggesting compaction
# Adjust based on your typical session length:
#   - Long sessions (2+ hours): THRESHOLD=5 or 10
#   - Standard sessions (30-60 min): THRESHOLD=10 or 15
#   - Short sessions (<30 min): THRESHOLD=20 or 30
THRESHOLD=10

# Optional: Enable logging for debugging
ENABLE_LOGGING=${ENABLE_LOGGING:-false}
LOG_FILE="${HOME}/.claude-plugin/.compact-log"

################################################################################
# UTILITY FUNCTIONS
################################################################################

# Log messages if logging is enabled
log_message() {
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $1" >> "$LOG_FILE"
    fi
}

# Initialize counter file if it doesn't exist
init_counter() {
    if [[ ! -f "$COUNTER_FILE" ]]; then
        mkdir -p "$(dirname "$COUNTER_FILE")"
        echo "0" > "$COUNTER_FILE"
        log_message "Counter initialized at $COUNTER_FILE"
    fi
}

# Read current counter value
read_counter() {
    init_counter
    if [[ -f "$COUNTER_FILE" ]]; then
        cat "$COUNTER_FILE" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Write counter value
write_counter() {
    local value="$1"
    echo "$value" > "$COUNTER_FILE" 2>/dev/null || {
        # Fallback if write fails
        mkdir -p "$(dirname "$COUNTER_FILE")"
        echo "$value" > "$COUNTER_FILE"
    }
}

# Increment counter and return new value
increment_counter() {
    init_counter
    local current=$(read_counter)
    local next=$((current + 1))
    write_counter "$next"
    echo "$next"
}

# Reset counter to 0
reset_counter() {
    write_counter "0"
}

# Check if compaction should be triggered
should_trigger_compaction() {
    local current=$(read_counter)

    # Trigger if counter is exactly divisible by THRESHOLD
    if [[ $((current % THRESHOLD)) -eq 0 ]] && [[ $current -gt 0 ]]; then
        return 0  # true - should compact
    fi

    return 1  # false - no compaction needed
}

################################################################################
# MAIN LOGIC
################################################################################

# Main function: increment counter and check if compaction needed
main() {
    init_counter

    # Increment counter for this tool execution
    local count=$(increment_counter)

    log_message "Tool execution #$count (threshold: $THRESHOLD)"

    # Check if we've hit the threshold
    if should_trigger_compaction; then
        # Calculate how many more executions until next alert
        local next_threshold=$((THRESHOLD + count))

        # Display alert message
        display_compaction_alert "$count" "$THRESHOLD" "$next_threshold"

        return 0
    fi

    # Silent mode - no alert on non-threshold executions
    return 0
}

# Display the compaction alert message
display_compaction_alert() {
    local count="$1"
    local threshold="$2"
    local next_alert="$3"

    cat << EOF
┌─────────────────────────────────────────────────────────────┐
│ 🔴 CONTEXT COMPACTION ALERT                                 │
├─────────────────────────────────────────────────────────────┤
│ Tool executions: $count                                      │
│ Threshold: $threshold                                        │
│                                                              │
│ Your context window is growing. Consider compacting to:     │
│ • Reduce token usage                                        │
│ • Improve response speed                                    │
│ • Lower operational costs                                   │
│                                                              │
│ After compacting, run:                                      │
│ $ strategic-compact reset                                   │
│                                                              │
│ Next alert after $threshold more executions                 │
└─────────────────────────────────────────────────────────────┘
EOF

    log_message "COMPACTION ALERT triggered at count=$count"
}

# Display current counter status with progress
status_command() {
    local current=$(read_counter)
    local next_alert=$((THRESHOLD - (current % THRESHOLD)))
    local progress_percent=$((current * 100 / THRESHOLD))

    # Clamp to 100%
    if [[ $progress_percent -gt 100 ]]; then
        progress_percent=100
    fi

    echo "═══════════════════════════════════════════════════════"
    echo "STRATEGIC COMPACTION STATUS"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Current executions:      $current"
    echo "Threshold:               $THRESHOLD"
    echo "Progress to alert:       $progress_percent%"
    echo "Executions until alert:  $next_alert"
    echo ""

    # Visual progress bar
    local bar_width=30
    local filled=$((progress_percent * bar_width / 100))
    echo -n "Progress: ["
    for ((i = 0; i < filled; i++)); do echo -n "█"; done
    for ((i = filled; i < bar_width; i++)); do echo -n "░"; done
    echo "] $progress_percent%"
    echo ""

    if [[ $next_alert -eq 0 ]]; then
        echo "⚠️  ALERT: Time to compact!"
    elif [[ $next_alert -lt 3 ]]; then
        echo "⚡ WARNING: Compaction recommended soon"
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════"
}

# Display configuration
config_command() {
    echo "═══════════════════════════════════════════════════════"
    echo "STRATEGIC COMPACTION CONFIGURATION"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Counter file:       $COUNTER_FILE"
    echo "Threshold:          $THRESHOLD"
    echo "Logging enabled:    $ENABLE_LOGGING"

    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        echo "Log file:           $LOG_FILE"
    fi

    echo ""
    echo "Session type recommendations:"
    echo "  • Marathon (4+ hours):      THRESHOLD=3 or 5"
    echo "  • Long (2+ hours):          THRESHOLD=5 or 10"
    echo "  • Standard (30-60 min):     THRESHOLD=10 or 15"
    echo "  • Short (<30 min):          THRESHOLD=20 or 30"
    echo ""
    echo "═══════════════════════════════════════════════════════"
}

################################################################################
# CLI DISPATCHER
################################################################################

# Handle command-line arguments
case "${1:-main}" in
    "main")
        # Primary hook function - called on each tool execution
        main
        exit $?
        ;;

    "reset")
        # Reset counter after compacting
        reset_counter
        log_message "Counter reset to 0"
        echo "✓ Counter reset to 0"
        exit 0
        ;;

    "status")
        # Display current status with progress
        status_command
        exit 0
        ;;

    "config")
        # Display configuration details
        config_command
        exit 0
        ;;

    "read")
        # Output counter value (for scripting)
        read_counter
        exit 0
        ;;

    "increment")
        # Manually increment and show new value
        new_value=$(increment_counter)
        echo "$new_value"
        exit 0
        ;;

    *)
        # Unknown command - show usage
        cat << EOF
Strategic Compaction Suggester

Usage:
  ./strategic-compact.sh main          Execute hook (called automatically)
  ./strategic-compact.sh reset         Reset counter to 0
  ./strategic-compact.sh status        Show current status with progress
  ./strategic-compact.sh config        Display configuration
  ./strategic-compact.sh read          Output counter value
  ./strategic-compact.sh increment     Increment counter by 1

Examples:
  # In hooks.json, use:
  "command": "\${HOME}/.claude-plugin/hooks/strategic-compact.sh main"

  # After compacting:
  \$ strategic-compact reset

  # Check progress:
  \$ strategic-compact status

Configuration:
  Edit THRESHOLD variable in this script to adjust sensitivity
  Current threshold: $THRESHOLD tool executions
EOF
        exit 1
        ;;
esac
