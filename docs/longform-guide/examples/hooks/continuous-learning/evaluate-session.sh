#!/bin/bash

################################################################################
# Continuous Learning: Session Evaluation Script
#
# Purpose:
#   Analyzes a completed session to extract and record learning insights.
#   Creates structured TIL (Today I Learned) documents from session activities.
#   This script:
#   - Extracts git commits and changes
#   - Identifies problems solved and solutions applied
#   - Captures patterns discovered during work
#   - Generates actionable insights and next steps
#   - Stores learning in organized TIL files for future reference
#
# When used:
#   - At session end via Stop hook
#   - Manually after important work sessions
#   - As part of /wrap command for documentation
#
# Output files created:
#   - .claude/til/YYYY-MM-DD.md          (daily TIL document)
#   - .claude/til/session-metadata.json  (learning metrics)
#   - .claude/hooks.log                  (execution record)
#
# Usage:
#   ./evaluate-session.sh                # Analyze current session
#   ./evaluate-session.sh --verbose      # With detailed output
#   ./evaluate-session.sh --dry-run      # Preview without writing
#   ./evaluate-session.sh --session-id ID  # Analyze specific session
#
# Integration:
#   Call from session-stop.sh or /wrap command:
#   "${HOOK_SCRIPTS}/evaluate-session.sh" \
#     --project "$PROJECT_ROOT" \
#     --til-dir "$TIL_DIR" \
#     --session-id "$SESSION_ID"
#
################################################################################

set -e

################################################################################
# CONFIGURATION
################################################################################

# Paths and directories
PROJECT_ROOT="${PROJECT_ROOT:-.}"
TIL_DIR="${TIL_DIR:-.claude/til}"
HOOKS_LOG="${HOOKS_LOG:-.claude/hooks.log}"

# Feature flags
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Parameters
SESSION_ID="${SESSION_ID:-}"
TIMESTAMP="${TIMESTAMP:-}"

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

# Get today's date in YYYY-MM-DD format
get_today() {
    date +%Y-%m-%d
}

################################################################################
# GIT ANALYSIS
################################################################################

# Extract recent git commits
get_recent_commits() {
    local limit="${1:-10}"

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        verbose "Not a git repository"
        echo "Not in a git repository"
        return 1
    fi

    verbose "Extracting commits (limit: $limit)..."
    git log --oneline -n "$limit" 2>/dev/null || echo "No commits found"
}

# Get changed files summary
get_changed_files() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return 1
    fi

    verbose "Extracting file changes..."
    # Changed files in current session vs HEAD~1
    git diff --stat HEAD~1 HEAD 2>/dev/null || echo "No changes to previous commit"
}

# Get staged files (uncommitted changes)
get_staged_files() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return 1
    fi

    verbose "Extracting staged files..."
    git diff --cached --stat 2>/dev/null || echo "No staged changes"
}

# Analyze commit messages for insights
extract_commit_insights() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return
    fi

    verbose "Analyzing commit messages..."

    local commits=$(git log --oneline -n 10 2>/dev/null)
    local insights=""

    # Look for common keywords in commits
    if echo "$commits" | grep -qi "fix\|bug\|patch"; then
        insights="${insights}• Bug fixes and patches were applied"$'\n'
    fi

    if echo "$commits" | grep -qi "feat\|add\|implement"; then
        insights="${insights}• New features were implemented"$'\n'
    fi

    if echo "$commits" | grep -qi "refactor\|improve\|optimize"; then
        insights="${insights}• Code was refactored or optimized"$'\n'
    fi

    if echo "$commits" | grep -qi "test\|spec"; then
        insights="${insights}• Tests were added or updated"$'\n'
    fi

    if echo "$commits" | grep -qi "doc\|comment"; then
        insights="${insights}• Documentation was improved"$'\n'
    fi

    echo "$insights"
}

################################################################################
# PROBLEM/SOLUTION EXTRACTION
################################################################################

# Look for problem solving patterns in recent changes
extract_problems_solved() {
    verbose "Looking for solved problems..."

    local problems=""

    # Check git logs for problem-related keywords
    if git log --oneline -n 20 2>/dev/null | grep -qi "error\|fix\|bug"; then
        problems="${problems}• Fixed one or more bugs or errors"$'\n'
    fi

    if git log --oneline -n 20 2>/dev/null | grep -qi "debug\|issue"; then
        problems="${problems}• Debugged and resolved issues"$'\n'
    fi

    if git log --oneline -n 20 2>/dev/null | grep -qi "fail\|broken"; then
        problems="${problems}• Fixed broken functionality"$'\n'
    fi

    echo "$problems"
}

# Suggest next steps based on current state
suggest_next_steps() {
    verbose "Generating next steps..."

    local suggestions=""

    # Check for uncommitted changes
    if git status --porcelain 2>/dev/null | grep -q "^??"; then
        suggestions="${suggestions}• Review and commit new files"$'\n'
    fi

    if git status --porcelain 2>/dev/null | grep -q "^ M"; then
        suggestions="${suggestions}• Commit modified files"$'\n'
    fi

    # Generic next steps
    suggestions="${suggestions}• Test changes with comprehensive test suite"$'\n'
    suggestions="${suggestions}• Review code for potential improvements"$'\n'
    suggestions="${suggestions}• Update relevant documentation"$'\n'

    echo "$suggestions"
}

################################################################################
# TIL GENERATION
################################################################################

# Create TIL header
create_til_header() {
    local today="$1"
    local session_id="$2"
    local timestamp="$3"

    cat <<EOF
# TIL: $today

**Session ID**: $session_id
**Time**: $timestamp

---

EOF
}

# Create commits section
create_commits_section() {
    local commits="$1"

    cat <<EOF
## Session Work Summary

### Commits
\`\`\`
$commits
\`\`\`

EOF
}

# Create insights section
create_insights_section() {
    local insights="$1"
    local problems="$2"

    if [[ -z "$insights" ]] && [[ -z "$problems" ]]; then
        return
    fi

    cat <<EOF
## Session Insights

### Accomplishments
$insights

### Problems Solved
$problems

EOF
}

# Create patterns section
create_patterns_section() {
    cat <<EOF
## Patterns & Techniques Discovered

- [Document specific patterns you discovered]
- [Note any interesting approaches used]
- [Record useful code patterns]

EOF
}

# Create technical notes section
create_technical_notes_section() {
    cat <<EOF
## Technical Notes

### Key Implementation Details
- [Implementation details from this session]

### Dependencies & Requirements
- [Important libraries or tools used]

### Edge Cases Found
- [Any edge cases or gotchas discovered]

EOF
}

# Create next session section
create_next_session_section() {
    local suggestions="$1"

    cat <<EOF
## Next Session TODOs

### High Priority
$suggestions

### Medium Priority
- [ ] Write additional tests
- [ ] Optimize performance
- [ ] Improve error handling

### Documentation
- [ ] Update README if needed
- [ ] Add inline code comments
- [ ] Update API documentation

EOF
}

# Combine all sections into complete TIL
generate_til_content() {
    local today="$1"
    local session_id="$2"
    local timestamp="$3"
    local commits="$4"
    local insights="$5"
    local problems="$6"
    local suggestions="$7"

    echo "$(create_til_header "$today" "$session_id" "$timestamp")"
    echo "$(create_commits_section "$commits")"
    echo "$(create_insights_section "$insights" "$problems")"
    echo "$(create_patterns_section)"
    echo "$(create_technical_notes_section)"
    echo "$(create_next_session_section "$suggestions")"

    cat <<EOF
---

## Session Reflection

### What went well?
[Reflect on successful aspects of this session]

### What was challenging?
[Note any challenges encountered]

### Key learnings?
[Record important learnings]

### Advice to future self?
[Tips for tackling similar work in the future]

---

**Status**: Ready for next session
**Archive Date**: (to be filled when session is finalized)

EOF
}

################################################################################
# FILE OPERATIONS
################################################################################

# Write TIL file (create or append)
write_til_file() {
    local til_file="$1"
    local content="$2"

    if [[ -f "$til_file" ]]; then
        verbose "Appending to existing TIL: $til_file"
        # Append with separator
        echo "" >> "$til_file"
        echo "---" >> "$til_file"
        echo "" >> "$til_file"
        echo "$content" >> "$til_file"
    else
        verbose "Creating new TIL: $til_file"
        echo "$content" > "$til_file"
    fi
}

# Create session metadata file
create_metadata_file() {
    local til_dir="$1"
    local today="$2"
    local session_id="$3"
    local timestamp="$4"

    local metadata_file="${til_dir}/.session-metadata-${today}.json"

    cat > "$metadata_file" <<EOF
{
  "date": "$today",
  "session_id": "$session_id",
  "timestamp": "$timestamp",
  "type": "continuous_learning_evaluation",
  "til_generated": true
}
EOF

    echo "$metadata_file"
}

################################################################################
# MAIN EXECUTION
################################################################################

# Execute session evaluation
execute_evaluation() {
    verbose "Continuous Learning: Session Evaluation Starting"

    # Setup
    ensure_dir "$TIL_DIR"
    ensure_dir "$(dirname "$HOOKS_LOG")"

    # Get session metadata
    local today=$(get_today)
    local session_id="${SESSION_ID:-$(date +%s | md5sum | cut -c1-6)}"
    local timestamp="${TIMESTAMP:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}"

    verbose "Evaluation metadata:"
    verbose "  Date: $today"
    verbose "  Session ID: $session_id"
    verbose "  Timestamp: $timestamp"

    # Extract information from git
    local commits=$(get_recent_commits 10)
    local insights=$(extract_commit_insights)
    local problems=$(extract_problems_solved)
    local suggestions=$(suggest_next_steps)

    verbose "Information extracted:"
    verbose "  Commits: $(echo "$commits" | wc -l) entries"
    verbose "  Insights: $(echo "$insights" | wc -l) found"
    verbose "  Problems: $(echo "$problems" | wc -l) found"

    # Generate TIL content
    local til_content=$(generate_til_content "$today" "$session_id" "$timestamp" "$commits" "$insights" "$problems" "$suggestions")

    # Write files
    if [[ "$DRY_RUN" != "true" ]]; then
        local til_file="${TIL_DIR}/${today}.md"
        write_til_file "$til_file" "$til_content"
        verbose "TIL written to: $til_file"

        # Create metadata
        local metadata_file=$(create_metadata_file "$TIL_DIR" "$today" "$session_id" "$timestamp")
        verbose "Metadata written to: $metadata_file"

        # Log execution
        log_to_file "Continuous Learning: Session evaluation completed - Session ID=$session_id, TIL=$til_file"
    fi

    # Display summary
    display_evaluation_summary "$today" "$session_id" "$til_content"
}

# Display evaluation summary
display_evaluation_summary() {
    local today="$1"
    local session_id="$2"
    local content="$3"

    echo "✅ Session Evaluation Complete"
    echo "   Date: $today"
    echo "   Session ID: $session_id"
    echo "   TIL file: .claude/til/${today}.md"
    echo ""
    echo "Generated TIL Preview:"
    echo "─────────────────────────────────────────"
    echo "$content" | head -30
    echo "─────────────────────────────────────────"
    echo ""
    echo "📚 Your learning has been captured and saved."
    echo "   Review the full TIL file to complete the reflection section."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "   [DRY RUN] File not actually written"
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
        --til-dir)
            TIL_DIR="$2"
            shift 2
            ;;
        --session-id)
            SESSION_ID="$2"
            shift 2
            ;;
        --timestamp)
            TIMESTAMP="$2"
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

# Execute the evaluation
execute_evaluation

exit 0
