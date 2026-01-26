#!/bin/bash

################################################################################
# SessionStart Hook Script
#
# Purpose:
#   Restores context from previous sessions when a new session begins.
#   Enables seamless continuation of work across sessions by:
#   - Finding the most recent session context file
#   - Loading previous state and decisions
#   - Injecting recovery information into system prompt
#   - Generating a new session ID for tracking
#
# When triggered:
#   - Plugin initializes at session start
#   - Before any user prompts are sent
#   - Automatically by Claude Code hook system
#
# Output:
#   - .claude/session_id                (new session identifier)
#   - .claude/recovery_prompt.txt       (to be injected into system prompt)
#   - .claude/hooks.log                 (execution record)
#   - JSON response to hook system
#
# Usage:
#   ./session-start.sh                  # Execute hook (called automatically)
#   ./session-start.sh --verbose        # With detailed logging
#   ./session-start.sh --dry-run        # Preview without creating files
#
# Integration:
#   Add to ~/.claude-plugin/hooks.json under SessionStart hook:
#   "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
#   "inject_result": "system_prompt"
#
################################################################################

set -e

################################################################################
# CONFIGURATION
################################################################################

# Paths and directories
PROJECT_ROOT="${PROJECT_ROOT:-.}"
CONTEXT_DIR=".claude/context"
SESSION_ID_FILE=".claude/session_id"
RECOVERY_FILE=".claude/recovery_prompt.txt"
HOOKS_LOG=".claude/hooks.log"

# Feature flags
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Context preview size (characters)
CONTEXT_PREVIEW_SIZE=2000

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
            verbose "Cannot create directory: $dir (may not have permission)"
        }
    fi
}

# Generate new session ID (6-character hex)
generate_session_id() {
    # Use date + random for unique ID
    echo $(date +%s | md5sum | cut -c1-6)
}

# Find the most recent context file
find_latest_context() {
    # Search for context files in YYYY-MM-DD format under CONTEXT_DIR/YYYY-MM/
    if [[ ! -d "$CONTEXT_DIR" ]]; then
        verbose "No context directory found"
        return
    fi

    # Find most recent .md file in context directory
    find "$CONTEXT_DIR" -name "*.md" -type f 2>/dev/null | sort -r | head -1
}

# Extract preview from context file
extract_context_preview() {
    local context_file="$1"

    if [[ ! -f "$context_file" ]]; then
        return
    fi

    # Get last CONTEXT_PREVIEW_SIZE characters, truncate to reasonable length
    tail -c "$CONTEXT_PREVIEW_SIZE" "$context_file" 2>/dev/null | head -50
}

# Create JSON for hook system
create_hook_response() {
    local session_id="$1"
    local previous_session="$2"
    local recovery_file="$3"

    # Build JSON response
    cat <<EOF
{
  "session_started": true,
  "session_id": "$session_id",
  "previous_session": "$previous_session",
  "recovery_prompt_file": "$recovery_file",
  "inject_into_system_prompt": true,
  "recovery_content_preview": "Context recovered from previous session"
}
EOF
}

################################################################################
# MAIN LOGIC
################################################################################

# Setup directories
setup_directories() {
    verbose "Setting up directories..."
    ensure_dir "$CONTEXT_DIR"
    ensure_dir "$(dirname "$SESSION_ID_FILE")"
    ensure_dir "$(dirname "$HOOKS_LOG")"
}

# Create new session ID
create_session_id() {
    local session_id=$(generate_session_id)

    if [[ "$DRY_RUN" != "true" ]]; then
        echo "$session_id" > "$SESSION_ID_FILE"
        verbose "Session ID file created: $SESSION_ID_FILE"
    fi

    # Also save as current session ID for quick reference
    if [[ "$DRY_RUN" != "true" ]]; then
        echo "$session_id" > ".claude/current_session_id" 2>/dev/null || true
    fi

    echo "$session_id"
}

# Restore previous session context
restore_previous_context() {
    local latest_context=$(find_latest_context)

    if [[ -z "$latest_context" ]]; then
        verbose "No previous session found"
        echo ""
        return
    fi

    if [[ ! -f "$latest_context" ]]; then
        verbose "Previous session file not readable: $latest_context"
        echo ""
        return
    fi

    verbose "Found previous session: $latest_context"
    echo "$latest_context"
}

# Generate recovery prompt for system injection
generate_recovery_prompt() {
    local previous_session="$1"
    local previous_content="$2"
    local session_id="$3"

    cat <<'PROMPT_EOF'
## 🔄 Session Continuation - Automatic Context Recovery

### Previous Session Information

PROMPT_EOF

    if [[ -n "$previous_session" ]]; then
        echo ""
        echo "**Previous Session File**: $(basename "$previous_session")"
        echo ""
        echo '```markdown'
        echo "$previous_content"
        echo '```'
    fi

    cat <<'PROMPT_EOF'

---

### Instructions for This Session

1. **You are continuing from a previous session**
2. All prior context, decisions, and work are preserved above
3. Maintain consistency with decisions made in previous sessions
4. If uncertain about previous state, ask the user for clarification
5. Use this context to avoid repeating work or decisions

### Current Session ID
PROMPT_EOF
    echo "- Session ID: $session_id"
}

# Execute main hook logic
execute_hook() {
    verbose "SessionStart Hook: Beginning execution"

    # Setup directories
    setup_directories

    # Generate new session ID
    local new_session_id=$(create_session_id)
    verbose "New session ID: $new_session_id"

    # Find and load previous session
    local previous_session=$(restore_previous_context)

    if [[ -z "$previous_session" ]]; then
        verbose "Starting fresh (no previous session)"

        if [[ "$DRY_RUN" != "true" ]]; then
            # Log fresh start
            log_to_file "SessionStart: New session (no previous context) - ID=$new_session_id"
        fi

        # Return response indicating new session
        echo "{\"new_session\": true, \"session_id\": \"$new_session_id\"}"
        return 0
    fi

    # Read previous session content
    local previous_content=$(extract_context_preview "$previous_session")

    # Generate recovery prompt
    local recovery_prompt=$(generate_recovery_prompt "$previous_session" "$previous_content" "$new_session_id")

    # Write recovery prompt to file (for injection into system prompt)
    if [[ "$DRY_RUN" != "true" ]]; then
        echo "$recovery_prompt" > "$RECOVERY_FILE"
        verbose "Recovery prompt file created: $RECOVERY_FILE"

        # Log the restoration
        log_to_file "SessionStart: Context restored from $previous_session - New session ID=$new_session_id"
    fi

    # Display summary
    echo "✅ SessionStart Hook Complete"
    echo "   New Session ID: $new_session_id"
    echo "   Previous Session: $(basename "$previous_session")"
    echo "   Recovery prompt ready for system prompt injection"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "   [DRY RUN] No files actually written"
    fi

    # Return JSON response for hook system to inject into system prompt
    create_hook_response "$new_session_id" "$(basename "$previous_session")" "$RECOVERY_FILE"
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
