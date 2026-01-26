#!/bin/bash

################################################################################
# PreCompact Hook Script
#
# Purpose:
#   Captures a comprehensive snapshot of the current session state BEFORE
#   context compaction occurs. This enables:
#   - Recovery point creation for critical decision-making
#   - Context analysis and metrics collection
#   - Backup generation for safety
#   - Compression recommendations
#
# When triggered:
#   - User context approaches threshold (e.g., 40KB)
#   - User explicitly requests compaction
#   - System detects context growth warning
#
# Output files created:
#   - .claude/snapshots/pre-compact-*.json   (metadata snapshot)
#   - .claude/backups/context-*.md.bak       (context backup)
#   - .claude/hooks.log                       (execution log)
#
# Usage:
#   ./pre-compact.sh                      # Execute hook (called automatically)
#   ./pre-compact.sh --verbose            # With detailed logging
#   ./pre-compact.sh --dry-run            # Preview without writing
#
# Integration:
#   Add to ~/.claude-plugin/hooks.json under PreCompact hook:
#   "command": "${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact.sh"
#
################################################################################

set -e

################################################################################
# CONFIGURATION
################################################################################

# Paths and directories
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
PROJECT_ROOT="${PROJECT_ROOT:-.}"
CONTEXT_DIR=".claude/context"
SNAPSHOTS_DIR=".claude/snapshots"
BACKUPS_DIR=".claude/backups"
HOOKS_LOG=".claude/hooks.log"

# Feature flags
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Threshold values (in KB) for compression recommendations
COMPRESS_THRESHOLD_KB=40
AGGRESSIVE_THRESHOLD_KB=60

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
        mkdir -p "$dir" || error "Failed to create directory: $dir"
        verbose "Created directory: $dir"
    fi
}

# Calculate file size in bytes and KB
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Count lines in a file
count_lines() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wc -l < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# Extract metadata from context file
extract_metadata() {
    local context_file="$1"

    if [[ ! -f "$context_file" ]]; then
        verbose "Context file not found: $context_file"
        return
    fi

    # Extract session info from markdown frontmatter
    if grep -q "^## Session" "$context_file"; then
        grep "^## Session" "$context_file" | sed 's/## Session: //' | head -1
    else
        echo "unknown"
    fi
}

# Get git information if in a git repository
get_git_info() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        verbose "Not a git repository"
        return
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

    echo "{\"branch\": \"$branch\", \"commit\": \"$commit\"}"
}

# Escape JSON string
json_escape() {
    local string="$1"
    # Simple escaping for JSON (handle quotes and newlines)
    echo "$string" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n'
}

################################################################################
# MAIN LOGIC
################################################################################

# Create necessary directories
setup_directories() {
    verbose "Setting up directories..."
    ensure_dir "$SNAPSHOTS_DIR"
    ensure_dir "$BACKUPS_DIR"
    ensure_dir "$(dirname "$HOOKS_LOG")"
}

# Analyze current context state
analyze_context() {
    verbose "Analyzing context..."

    # Check if context file exists
    if [[ ! -f ".claude/context.md" ]]; then
        verbose "No context.md file found"
        echo "0" "0" "0" "unknown"
        return
    fi

    # Get context metrics
    local size_bytes=$(get_file_size ".claude/context.md")
    local size_kb=$((size_bytes / 1024))
    local lines=$(count_lines ".claude/context.md")
    local session=$(extract_metadata ".claude/context.md")

    echo "$size_bytes" "$size_kb" "$lines" "$session"
}

# Get session ID (from .claude/session_id or generate)
get_session_id() {
    if [[ -f ".claude/session_id" ]]; then
        cat ".claude/session_id"
    else
        echo $(date +%s | md5sum | cut -c1-6)
    fi
}

# Create snapshot JSON file
create_snapshot() {
    local timestamp="$1"
    local timestamp_short="$2"
    local session_id="$3"
    local size_bytes="$4"
    local size_kb="$5"
    local lines="$6"

    local snapshot_file="${SNAPSHOTS_DIR}/pre-compact-${timestamp_short}-${session_id}.json"

    # Get optional git information
    local git_info="{}"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git_info=$(get_git_info)
    fi

    # Determine compression recommendation
    local compress_needed="false"
    local aggressive_compress="false"

    if [[ $size_kb -gt $COMPRESS_THRESHOLD_KB ]]; then
        compress_needed="true"
    fi

    if [[ $size_kb -gt $AGGRESSIVE_THRESHOLD_KB ]]; then
        aggressive_compress="true"
    fi

    # Create JSON snapshot
    cat > "$snapshot_file" <<EOF
{
  "metadata": {
    "timestamp": "$timestamp",
    "session_id": "$session_id",
    "action": "pre_compact_snapshot"
  },
  "context": {
    "size_bytes": $size_bytes,
    "size_kb": $size_kb,
    "lines": $lines
  },
  "git": $git_info,
  "recommendations": {
    "compress": $compress_needed,
    "aggressive_compress": $aggressive_compress
  }
}
EOF

    echo "$snapshot_file"
}

# Create backup of current context
create_backup() {
    local timestamp_short="$1"
    local backup_file="${BACKUPS_DIR}/context-${timestamp_short}.md.bak"

    if [[ -f ".claude/context.md" ]]; then
        cp ".claude/context.md" "$backup_file"
        verbose "Backup created: $backup_file"
        echo "$backup_file"
    fi
}

# Execute main hook logic
execute_hook() {
    # Generate timestamps
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local timestamp_short=$(date -u +"%Y%m%d-%H%M%S")

    verbose "Timestamp: $timestamp"
    verbose "Timestamp short: $timestamp_short"

    # Get session information
    local session_id=$(get_session_id)
    verbose "Session ID: $session_id"

    # Analyze context
    read -r size_bytes size_kb lines session_info < <(analyze_context)
    verbose "Context size: ${size_kb}KB ($lines lines)"

    # Create directories
    setup_directories

    # Create snapshot
    if [[ "$DRY_RUN" != "true" ]]; then
        local snapshot_file=$(create_snapshot "$timestamp" "$timestamp_short" "$session_id" "$size_bytes" "$size_kb" "$lines")
        verbose "Snapshot created: $snapshot_file"

        # Create backup
        if [[ -f ".claude/context.md" ]]; then
            local backup_file=$(create_backup "$timestamp_short")
            verbose "Backup created: $backup_file"
        fi

        # Log to hooks.log
        log_to_file "PreCompact Hook: Context size=${size_kb}KB, lines=$lines, session=$session_id"
    fi

    # Display summary
    echo "✅ PreCompact Hook Complete"
    echo "   Context Size: ${size_kb}KB"
    echo "   Lines: $lines"
    echo "   Session ID: $session_id"

    if [[ $size_kb -gt $AGGRESSIVE_THRESHOLD_KB ]]; then
        echo "   ⚠️ AGGRESSIVE compression recommended (>${AGGRESSIVE_THRESHOLD_KB}KB)"
    elif [[ $size_kb -gt $COMPRESS_THRESHOLD_KB ]]; then
        echo "   ⚠️ Compression recommended (>${COMPRESS_THRESHOLD_KB}KB)"
    else
        echo "   ✓ Context size is healthy (<${COMPRESS_THRESHOLD_KB}KB)"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "   [DRY RUN] No files actually written"
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
