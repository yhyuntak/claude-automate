# Project Init Skill

Initialize new projects with Claude Code configuration, backlog system, and development workflows.

## Usage

```bash
/project-init
```

Or with project name:
```bash
/project-init my-awesome-project
```

## What It Does

### 1. Installs Global Rules
Automatically runs `/install-rule` to set up:
- `~/.claude/rules/interaction.md` - UX guidelines
- `~/.claude/rules/versioning.md` - Semantic versioning
- `~/.claude/rules/backlog-rules.md` - Backlog management
- `~/.claude/rules/workflow.md` - Git workflows

### 2. Collects Project Info
Asks for:
- Project name
- One-line description
- Tech stack (optional)
- Development philosophy

### 3. Creates Project Structure
```
your-project/
├── CLAUDE.md                    # Claude configuration
├── README.md                    # Project documentation
├── .gitignore                   # Git ignore rules
│
├── .claude/
│   └── rules/
│       └── project-rules.md     # Project-specific rules
│
└── docs/
    ├── README.md
    ├── architecture/            # Architecture docs
    ├── ideas/                   # Idea notes
    └── backlogs/
        ├── README.md            # Backlog dashboard
        ├── todo/                # Tasks to start
        ├── doing/               # Current work (1 only!)
        └── done/                # Completed tasks
```

### 4. Replaces Variables
All `.template` files are processed:
- `{PROJECT_NAME}` → Your project name
- `{ONE_LINE_DESCRIPTION}` → Your description
- `{TECH_STACK}` → Your tech stack
- `{DEV_PHILOSOPHY}` → Your approach
- `{LAST_UPDATE_DATE}` → Current date

### 5. Initializes Git (Optional)
Offers to:
- Run `git init`
- Create initial commit

## Template Files

Templates are in `skills/project-init/templates/`:

### Variable Templates (.template files)
- `CLAUDE.md.template` → `CLAUDE.md`
- `README.md.template` → `README.md`
- `docs/README.md.template` → `docs/README.md`
- `docs/backlogs/README.md.template` → `docs/backlogs/README.md`
- `docs/backlogs/todo/phase0-001-define-project.md.template`
- `.claude/rules/project-rules.md.template` → `.claude/rules/project-rules.md`

### Static Files (copied as-is)
- `.gitignore`
- `.gitkeep` files
- `docs/ideas/_template.md`

## Requirements

- claude-automate plugin installed
- Empty or new directory (will warn if files exist)
- Global rules will be installed to `~/.claude/rules/`

## Next Steps After Init

1. Review `docs/backlogs/todo/phase0-001-define-project.md`
2. Customize `.claude/rules/project-rules.md`
3. Start working with `/start-work`
4. Complete session with `/wrap`

## Updating Templates

To update templates for new projects:

1. Edit files in `~/workspace/project-skeleton/`
2. Copy to `skills/project-init/templates/`
3. Rename `.md` → `.md.template` for files needing variable replacement
4. Update SKILL.md if logic changes

## Related

- `/install-rule` - Install global rules manually
- `/start-work` - Begin work session
- `/backlog` - View backlog status
- `/wrap` - Complete work session
