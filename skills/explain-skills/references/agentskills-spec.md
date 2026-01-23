# Agent Skills Open Standard

> Based on https://agentskills.io - The open format for AI agent capabilities

## What are Agent Skills?

Agent Skills are a lightweight, open format for extending AI agent capabilities with specialized knowledge and workflows. They enable agents to access domain-specific expertise on demand without loading everything into context at startup.

Originally developed by Anthropic, now maintained as an open standard for the broader ecosystem.

---

## Directory Structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: instructions + metadata
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
└── assets/           # Optional: templates, resources
```

---

## SKILL.md Format

Every skill requires a `SKILL.md` file with **YAML frontmatter** followed by **Markdown instructions**.

### Minimum Required Structure

```markdown
---
name: skill-name
description: A description of what this skill does and when to use it.
---

# Skill Instructions

Your markdown instructions here...
```

### Complete Example

```markdown
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.
license: Apache-2.0
compatibility: Requires pdfplumber, PyPDF2. Internet access required for OCR.
metadata:
  author: example-org
  version: "1.0"
  category: document-processing
allowed-tools: Bash(python:*) Read
---

# PDF Processing

## When to use this skill
Use this skill when the user needs to work with PDF files...

## How to extract text
1. Use pdfplumber for text extraction...
```

---

## Frontmatter Fields Reference

| Field | Required | Description | Constraints |
|-------|----------|-------------|-------------|
| `name` | **Yes** | Skill identifier | Max 64 chars. Lowercase, numbers, hyphens only. Must match directory name. Cannot start/end with hyphen or contain consecutive hyphens. |
| `description` | **Yes** | What the skill does and when to use it | Max 1024 chars. Non-empty. Should include specific keywords for agent identification. |
| `license` | No | License identifier or reference | License name (e.g., "MIT", "Apache-2.0") or path to license file |
| `compatibility` | No | Environment requirements | Max 500 chars. List required packages, system tools, network access, etc. |
| `metadata` | No | Arbitrary key-value data | String keys to string values. Use unique key names. |
| `allowed-tools` | No | Pre-approved tools | Space-delimited list. Experimental support. |

### Field Validation Rules

#### `name` Field

**Valid examples:**
```yaml
name: pdf-processing
name: data-analysis
name: code-review
name: api-client-v2
```

**Invalid examples:**
```yaml
name: PDF-Processing          # ❌ uppercase not allowed
name: -pdf                    # ❌ cannot start with hyphen
name: pdf--processing         # ❌ consecutive hyphens
name: pdf_processing          # ❌ underscores not allowed
```

#### `description` Field

**Good example:**
```yaml
description: Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.
```

**Poor example:**
```yaml
description: Helps with PDFs.  # ❌ Too vague, lacks keywords
```

**Tips:**
- Include specific keywords agents can match
- Describe WHEN to use the skill
- Mention specific use cases
- Keep under 1024 characters

---

## Progressive Disclosure Strategy

Skills use a three-stage approach to manage context efficiently:

### 1. Discovery (Startup)
Agents load only `name` and `description` of each skill (~50-100 tokens per skill).

```xml
<available_skills>
  <skill>
    <name>pdf-processing</name>
    <description>Extracts text and tables from PDF files...</description>
  </skill>
</available_skills>
```

### 2. Activation (On Match)
When a task matches the description, the agent reads the full `SKILL.md` body.

Recommended: Keep main instructions under 5000 tokens (≈500 lines).

### 3. Execution (As Needed)
Agent loads referenced files or executes bundled scripts only when required.

**Best practice:** Move detailed content to `references/`, `scripts/`, or `assets/` to keep main file focused.

---

## Optional Directories

### `scripts/` - Executable Code

Executable code agents can run during skill execution.

**Guidelines:**
- Should be self-contained or document dependencies clearly
- Include helpful error messages
- Handle edge cases gracefully
- Supported languages: Python, Bash, JavaScript (agent-dependent)

**Example structure:**
```
scripts/
├── extract.py          # Main extraction script
├── merge.py            # PDF merging utility
└── requirements.txt    # Python dependencies
```

### `references/` - Additional Documentation

Documentation files loaded on demand to avoid cluttering main instructions.

**Common patterns:**
```
references/
├── REFERENCE.md        # Detailed technical reference
├── API.md              # API documentation
├── FORMS.md            # Form templates
└── domain-specific/
    ├── finance.md
    └── legal.md
```

**Best practice:** Keep files focused; smaller files mean less context usage.

### `assets/` - Static Resources

Templates, images, data files, and other static resources.

**Example structure:**
```
assets/
├── templates/
│   ├── report-template.md
│   └── config-template.json
├── diagrams/
│   └── workflow.png
└── data/
    └── lookup-table.csv
```

---

## File References

Use relative paths from skill root in your instructions:

```markdown
See [the detailed API reference](references/API.md) for complete documentation.

For form templates, check [FORMS.md](references/FORMS.md).

Run the extraction script:
```bash
python scripts/extract.py input.pdf
```
```

**Best practices:**
- Keep references one level deep from `SKILL.md`
- Avoid deeply nested reference chains
- Load only what's needed for the current task

---

## Body Content Guidelines

The Markdown body after frontmatter has no format restrictions, but consider:

### Recommended Sections

```markdown
## Overview
Brief introduction to what the skill does.

## When to Use
Clear criteria for when this skill is appropriate.

## How to Use
Step-by-step instructions.

## Examples
Concrete examples with inputs and outputs.

## Common Issues
Edge cases and troubleshooting.

## See Also
References to related skills or documentation.
```

### Keep It Focused

- Main `SKILL.md`: Core instructions (<500 lines recommended)
- Extended documentation: Move to `references/`
- Examples and templates: Move to `assets/`
- Implementation code: Move to `scripts/`

---

## Integration Approaches

### Filesystem-Based Agents

Agents operating within computer environments (bash/unix).

**Skill activation:**
```bash
cat /path/to/my-skill/SKILL.md
```

**Resource access:**
```bash
python /path/to/my-skill/scripts/extract.py
```

### Tool-Based Agents

Agents without dedicated computer environment.

**Custom tools needed:**
- `load_skill(name)` - Load skill instructions
- `run_skill_script(skill, script, args)` - Execute bundled code
- `get_skill_resource(skill, path)` - Fetch assets

---

## Validation

Use the `skills-ref` reference library to validate skills:

```bash
# Install
pip install skills-ref

# Validate a skill
skills-ref validate ./my-skill

# Generate prompt XML
skills-ref to-prompt ./my-skill
```

**Validates:**
- Frontmatter YAML syntax
- Field constraints (name format, description length)
- Directory structure
- File references

---

## Security Considerations

Script execution introduces security risks:

### Recommended Safeguards

1. **Sandboxing**: Run scripts in isolated environments (containers, VMs)
2. **Allowlisting**: Only execute scripts from trusted skill sources
3. **Confirmation**: Ask users before running potentially dangerous operations
4. **Logging**: Record all script executions for auditing
5. **Code Review**: Review third-party skills before installation

---

## Best Practices Summary

✅ **DO:**
- Keep main `SKILL.md` under 500 lines
- Write detailed, keyword-rich descriptions
- Use progressive disclosure (metadata → instructions → resources)
- Include concrete examples
- Document dependencies in `compatibility`
- Version your skills (use `metadata.version`)

❌ **DON'T:**
- Load unnecessary context in main instructions
- Use vague descriptions
- Nest file references too deeply
- Skip validation before deployment
- Execute untrusted scripts without sandboxing

---

## Resources

- **Specification**: https://agentskills.io/specification
- **GitHub**: https://github.com/agentskills/agentskills
- **Example Skills**: https://github.com/anthropics/skills
- **Reference Library**: https://github.com/agentskills/agentskills/tree/main/skills-ref
- **Best Practices**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
