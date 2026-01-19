#!/bin/bash

# /wrap Session Start Hook
# Loads context.md and displays session continuity information

CONTEXT_FILE=".claude/context.md"

if [ -f "$CONTEXT_FILE" ]; then
    echo "📋 Context Loaded from previous session"
    echo ""
    echo "---"
    cat "$CONTEXT_FILE"
    echo "---"
    echo ""
    echo "💡 Run /wrap at the end of this session to update context"
else
    echo "📋 No previous context found"
    echo "💡 Run /wrap at the end of this session to create context.md"
fi
