---
name: project-init
description: Initialize new project with Claude Code setup and templates. Auto-activates on keywords like "new project", "start project", "create project", "init project".
argument-hint: "[project-name]"
---

# Project Init

$ARGUMENTS

Initialize a new project with Claude Code configuration, backlog system, and development workflows.

---

## Prerequisites Check

**IMPORTANT: This skill must run from an empty or new project directory.**

```bash
# Check if current directory has files
ls -la
```

If directory has existing project files, warn user and exit.

---

## Step 1: Install Global Rules

**CRITICAL: Run /install-rule first to set up global rules.**

```bash
# This installs to ~/.claude/rules/:
# - interaction.md
# - versioning.md
# - backlog-rules.md
# - workflow.md
```

Execute `/install-rule` command before proceeding.

Wait for completion, then continue.

---

## Step 2: Gather Project Information

Use AskUserQuestion to collect:

**Question 1: Project Name**
```
Question: "What is your project name?"
Header: "Project Name"
Options: (text input via "Other")
```

**Question 2: One-line Description**
```
Question: "Describe your project in one sentence"
Header: "Description"
Options: (text input via "Other")
```

**Question 3: Tech Stack (Optional)**
```
Question: "What's your tech stack?"
Header: "Tech Stack"
Options:
- "TypeScript/Node.js"
- "Python"
- "Go"
- "Rust"
- "Other (specify)"
```

**Question 4: Development Philosophy**
```
Question: "What's your development approach?"
Header: "Philosophy"
Options:
- "MVP first (fast iteration)"
- "Quality first (thorough planning)"
- "Experimental (try new things)"
- "Other (specify)"
```

Store responses as:
- PROJECT_NAME
- ONE_LINE_DESCRIPTION
- TECH_STACK
- DEV_PHILOSOPHY

---

## Step 3: Copy Template Files

Get the skill's template directory path.

**Template structure in skill:**
```
skills/project-init/templates/
├── CLAUDE.md.template
├── README.md.template
├── .gitignore
├── .claude/
│   └── rules/
│       └── project-rules.md.template
└── docs/
    ├── README.md.template
    ├── architecture/
    │   └── .gitkeep
    ├── ideas/
    │   └── _template.md
    └── backlogs/
        ├── README.md.template
        ├── todo/
        │   └── phase0-001-define-project.md.template
        ├── doing/
        └── done/
```

**Copy all files:**
```bash
# Copy from skill templates/ to current directory
cp -r <skill-path>/templates/. ./
```

---

## Step 4: Replace Variables

For each `.template` file, replace variables and remove `.template` extension:

### Variables to replace:
- `{PROJECT_NAME}` → $PROJECT_NAME
- `{ONE_LINE_DESCRIPTION}` → $ONE_LINE_DESCRIPTION
- `{TECH_STACK}` → $TECH_STACK
- `{DEV_PHILOSOPHY}` → $DEV_PHILOSOPHY
- `{CORE_VALUES}` → "To be defined"
- `{ANTI_GOALS}` → "To be defined"
- `{LAST_UPDATE_DATE}` → Current date (YYYY-MM-DD)

### Process:

```bash
# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# For each .template file
find . -name "*.template" | while read file; do
    # Replace variables
    sed "s/{PROJECT_NAME}/$PROJECT_NAME/g" "$file" | \
    sed "s/{ONE_LINE_DESCRIPTION}/$ONE_LINE_DESCRIPTION/g" | \
    sed "s/{TECH_STACK}/$TECH_STACK/g" | \
    sed "s/{DEV_PHILOSOPHY}/$DEV_PHILOSOPHY/g" | \
    sed "s/{CORE_VALUES}/To be defined/g" | \
    sed "s/{ANTI_GOALS}/To be defined/g" | \
    sed "s/{LAST_UPDATE_DATE}/$CURRENT_DATE/g" > "${file%.template}"

    # Remove .template file
    rm "$file"
done
```

---

## Step 5: Initialize Git (Optional)

**Ask user:**
```
Question: "Initialize Git repository?"
Header: "Git Init"
Options:
- "Yes (recommended)"
- "No"
```

If Yes:
```bash
git init
git add .
git commit -m "Initial commit from project-init

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Step 6: Report Completion

Display success message:

```markdown
## ✅ Project Initialized: {PROJECT_NAME}

> {ONE_LINE_DESCRIPTION}

### 📁 Structure Created

```
.
├── CLAUDE.md                    # Project configuration
├── README.md                    # Project readme
├── .gitignore                   # Git ignore rules
│
├── .claude/
│   └── rules/
│       └── project-rules.md     # Project-specific coding rules (customize this!)
│
└── docs/
    ├── README.md                # Documentation index
    ├── architecture/            # Architecture docs (add as needed)
    ├── ideas/                   # Idea notes
    │   └── _template.md
    └── backlogs/
        ├── README.md            # Backlog dashboard
        ├── todo/                # Tasks to do
        │   └── phase0-001-define-project.md
        ├── doing/               # Current work (1 only!)
        └── done/                # Completed tasks
```

### 🌍 Global Rules Installed

These rules are now available in all your projects:
- `~/.claude/rules/interaction.md` - UX guidelines
- `~/.claude/rules/versioning.md` - Semantic versioning
- `~/.claude/rules/backlog-rules.md` - Backlog system
- `~/.claude/rules/workflow.md` - Git workflows

### 📝 Next Steps

1. **Define your project** - Start with:
   ```bash
   cat docs/backlogs/todo/phase0-001-define-project.md
   ```

2. **Customize project rules** - Edit:
   ```bash
   .claude/rules/project-rules.md
   ```

3. **Start working** - Use:
   ```bash
   /start-work
   ```

4. **When done** - Use:
   ```bash
   /wrap
   ```

---

Happy coding! 🚀
```

---

## Error Handling

**If /install-rule fails:**
- Display error message
- Explain that global rules are required
- Exit gracefully

**If directory not empty:**
- Warn user
- Ask if they want to continue anyway
- If No: exit
- If Yes: proceed (files may be overwritten)

**If template copy fails:**
- Check skill installation
- Display helpful error message
- Suggest reinstalling claude-automate plugin

---

## Notes

- This skill assumes claude-automate plugin is installed
- Templates are in `skills/project-init/templates/`
- All `.template` files will be processed
- Non-template files are copied as-is (.gitignore, .gitkeep, etc.)
- Global rules are shared across all projects
- Project-specific rules go in `.claude/rules/project-rules.md`
