# Benchmarking Workflow: Skills Impact Measurement

## Overview

Benchmarking is the systematic process of **comparing skill impact** by running identical tasks in two parallel work environments. This guide teaches you how to measure whether a skill actually improves your development efficiency, token usage, or output quality.

---

## 개요 (Korean)

벤치마킹은 **스킬의 실제 효과를 측정**하기 위한 체계적인 프로세스입니다. 동일한 작업을 두 개의 병렬 워크트리(Worktree A - 스킬 사용, Worktree B - 스킬 미사용)에서 실행하여 결과를 비교합니다.

---

## Why Benchmarking Matters

### The Problem: Intuitive Assumptions

Without benchmarking, we often rely on **gut feeling** about skill effectiveness:

- "This skill probably saves time" → Unverified assumption
- "The output quality seems better" → Subjective judgment
- "Token usage is probably lower" → No concrete evidence

### The Solution: Data-Driven Verification

Benchmarking provides **measurable evidence**:

- Actual time savings in seconds/minutes
- Token reduction with exact percentages
- Output quality metrics with objective criteria
- Cost differential analysis

### Real-World Example

A skill that claims to reduce token usage by 30%:

**Without Benchmarking:**
- You assume it works
- You use it everywhere
- You never know if it actually helps

**With Benchmarking:**
- Run identical task 5 times WITH skill
- Run identical task 5 times WITHOUT skill
- Calculate: avg tokens WITH / avg tokens WITHOUT
- Make data-backed decision

---

## Benchmarking Architecture

### Worktree-Based Comparison

The core benchmarking approach uses **Git worktrees** to isolate two parallel environments:

```
Project Repository (main branch)
│
├─── Worktree A: WITH Skill
│    └─ Enhanced configuration
│    └─ Skill enabled
│    └─ Identical task execution
│
├─── Worktree B: WITHOUT Skill
│    └─ Base configuration
│    └─ Skill disabled
│    └─ Identical task execution
│
└─── Results Comparison
     ├─ Token usage diff
     ├─ Time elapsed diff
     ├─ Output quality diff
     └─ Cost analysis
```

---

## Complete Benchmarking Workflow Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                    BENCHMARKING WORKFLOW                           │
│                                                                    │
│  PREPARATION PHASE                                                │
│  ────────────────────────────────────────────────────────────────  │
│                                                                    │
│  [1] Define Benchmark Task                                        │
│      └─ Select identical, repeatable task                         │
│      └─ Document expected duration (est. 5-15 min)                │
│      └─ Define success criteria (output quality)                  │
│                                                                    │
│  [2] Create Worktree A (WITH Skill)                               │
│      ├─ git worktree add ../project-benchmark-with -b bench-with  │
│      ├─ cd ../project-benchmark-with                              │
│      └─ Enable skill in system prompt / rules                     │
│                                                                    │
│  [3] Create Worktree B (WITHOUT Skill)                            │
│      ├─ git worktree add ../project-benchmark-without -b bench-no │
│      ├─ cd ../project-benchmark-without                           │
│      └─ Disable skill / use base configuration                    │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  EXECUTION PHASE (Run 3-5 iterations per worktree)                │
│  ────────────────────────────────────────────────────────────────  │
│                                                                    │
│  WORKTREE A (WITH SKILL)        │  WORKTREE B (WITHOUT SKILL)     │
│  ───────────────────────────────────────────────────────────────  │
│                                                                    │
│  Iteration 1                     │  Iteration 1                   │
│  ├─ Clear cache/context          │  ├─ Clear cache/context       │
│  ├─ Start task timer             │  ├─ Start task timer          │
│  ├─ Execute identical task       │  ├─ Execute identical task    │
│  ├─ Capture logs and output      │  ├─ Capture logs and output   │
│  ├─ Record token usage           │  ├─ Record token usage        │
│  └─ Save results: run-1-with.txt │  └─ Save results: run-1-no.txt│
│                                   │                               │
│  Iteration 2                     │  Iteration 2                   │
│  ├─ [repeat with fresh state]    │  ├─ [repeat with fresh state] │
│  └─ Save results: run-2-with.txt │  └─ Save results: run-2-no.txt│
│                                   │                               │
│  Iteration 3                     │  Iteration 3                   │
│  ├─ [repeat with fresh state]    │  ├─ [repeat with fresh state] │
│  └─ Save results: run-3-with.txt │  └─ Save results: run-3-no.txt│
│                                   │                               │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ANALYSIS PHASE                                                   │
│  ────────────────────────────────────────────────────────────────  │
│                                                                    │
│  [4] Collect Results                                              │
│      ├─ Extract all run-*.txt files                               │
│      ├─ Parse token counts from logs                              │
│      ├─ Extract elapsed time                                      │
│      └─ Quality assessment: output comparison                     │
│                                                                    │
│  [5] Calculate Metrics                                            │
│      ├─ Avg tokens WITH skill = Σ(tokens_with) / N                │
│      ├─ Avg tokens WITHOUT skill = Σ(tokens_without) / N          │
│      ├─ Token reduction % = (1 - avg_with/avg_without) × 100      │
│      ├─ Avg time WITH = Σ(time_with) / N                          │
│      ├─ Avg time WITHOUT = Σ(time_without) / N                    │
│      ├─ Time saved = avg_without - avg_with                       │
│      └─ Cost differential (if applicable)                         │
│                                                                    │
│  [6] Quality Assessment                                           │
│      ├─ Compare output structure                                  │
│      ├─ Check completeness (WITH vs WITHOUT)                      │
│      ├─ Evaluate clarity and usability                            │
│      ├─ Document improvements or regressions                      │
│      └─ Generate side-by-side diff                                │
│                                                                    │
│  [7] Generate Report                                              │
│      └─ benchmark-report.md with full analysis                    │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  DECISION PHASE                                                   │
│  ────────────────────────────────────────────────────────────────  │
│                                                                    │
│  [8] Evaluate Results                                             │
│      ├─ Token savings ≥ 20% AND quality ≥ baseline?               │
│      │  ├─ YES: Skill provides value ✓                            │
│      │  └─ NO: Requires optimization or reconsideration           │
│      │                                                             │
│      ├─ Time savings ≥ 15% AND output quality maintained?         │
│      │  ├─ YES: Skill improves efficiency ✓                       │
│      │  └─ NO: Skill may not be worth the complexity              │
│      │                                                             │
│      └─ Overall ROI positive?                                     │
│         ├─ YES: Recommend skill adoption                          │
│         └─ NO: Requires refinement (return to development)        │
│                                                                    │
│  [9] Record Findings                                              │
│      ├─ Save benchmark report to version control                  │
│      ├─ Link findings to Continuous Learning section              │
│      ├─ Update skill documentation with metrics                   │
│      └─ Share results with team                                   │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  CLEANUP PHASE                                                    │
│  ────────────────────────────────────────────────────────────────  │
│                                                                    │
│  [10] Clean Up Worktrees                                          │
│       ├─ cd back to main project directory                        │
│       ├─ git worktree remove ../project-benchmark-with            │
│       ├─ git worktree remove ../project-benchmark-without         │
│       └─ git branch -D bench-with bench-without                   │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Implementation

### Step 1: Define Your Benchmark Task

Choose a task that:
- **Is repeatable**: Can run it 3-5 times identically
- **Is realistic**: Reflects actual usage patterns
- **Has clear success criteria**: Known expected output
- **Runs in 5-15 minutes**: Long enough to be meaningful, short enough to repeat
- **Isolates one variable**: Tests ONE skill/feature, nothing else

#### Example Tasks

**Good benchmarks:**
- "Write a README.md for this function" (1 skill focus)
- "Generate test cases for this module" (clear input/output)
- "Create API documentation from code" (measurable output)

**Poor benchmarks:**
- "Refactor this entire project" (too long, multiple variables)
- "Write everything from scratch" (no baseline)
- "Test everything we've built" (vague success criteria)

#### Task Definition Template

```markdown
# Benchmark Task: [Task Name]

## Objective
[What are we measuring?]

## Input
[Provide exact input/code/requirements]

## Expected Output
[Clear description of what success looks like]

## Success Criteria
- [ ] Output completeness
- [ ] Code quality/standards met
- [ ] No regressions compared to baseline

## Estimated Duration
- With skill: [estimate] min
- Without skill: [estimate] min

## Notes
[Any special considerations]
```

---

### Step 2: Create Worktree A (WITH Skill)

```bash
# From your main project directory
cd /Users/yoohyuntak/workspace/claude-automate

# Create worktree for WITH-skill version
git worktree add ../claude-automate-benchmark-with -b bench-with

# Switch to worktree A
cd ../claude-automate-benchmark-with

# Enable the skill (modify your system prompt or rules)
# Example: Add skill instructions to .claude/CLAUDE.md or create skill enable config

# Verify you're in worktree A
pwd
# Output: /Users/yoohyuntak/workspace/claude-automate-benchmark-with

git status
# Should show: on branch bench-with
```

#### Enabling Skills in Worktree A

**Option 1: System Prompt Injection**
```markdown
# In .claude/CLAUDE.md for Worktree A
## BENCHMARK CONFIGURATION: WITH SKILL

### Active Skills
- [Your skill name] ENABLED

### Instructions
When executing benchmark tasks:
- Use [skill name] for [specific scenario]
- Follow [skill guidelines]
- Optimize for [metric: token efficiency/speed/quality]
```

**Option 2: Rules-Based Activation**
```markdown
# Create .claude/rules/benchmark-with.md
## Benchmark WITH Skill

When processing tasks:
1. Apply [skill name] logic
2. Record all token usage
3. Capture execution time
4. Document output quality
```

---

### Step 3: Create Worktree B (WITHOUT Skill)

```bash
# From main project directory
cd /Users/yoohyuntak/workspace/claude-automate

# Create worktree for WITHOUT-skill version
git worktree add ../claude-automate-benchmark-without -b bench-without

# Switch to worktree B
cd ../claude-automate-benchmark-without

# Disable the skill / use base configuration
# Remove skill instructions from .claude/CLAUDE.md

# Verify you're in worktree B
pwd
# Output: /Users/yoohyuntak/workspace/claude-automate-benchmark-without

git status
# Should show: on branch bench-without
```

#### Disabling Skills in Worktree B

```markdown
# In .claude/CLAUDE.md for Worktree B
## BENCHMARK CONFIGURATION: WITHOUT SKILL

### Active Skills
- [Your skill name] DISABLED

### Instructions
When executing benchmark tasks:
- Do NOT use [skill name]
- Proceed with standard approach
- Record all metrics identically
```

---

### Step 4-5: Execute Iterations

#### Iteration Structure

Run **3-5 iterations** per worktree to account for variance:

**Why multiple iterations?**
- API latency varies between calls
- Context might affect results
- Averaging reduces random noise
- 3-5 is the sweet spot (diminishing returns beyond 5)

#### Execution Template (Per Iteration)

```bash
# In Worktree A or B

# Clear any caches
rm -rf .cache/* 2>/dev/null || true

# Record start time
START_TIME=$(date +%s%N)

# Execute the exact benchmark task
# [YOUR EXACT TASK HERE - must be identical each iteration]
# Example: Claude Code prompt for task, capture response

# Record end time
END_TIME=$(date +%s%N)

# Calculate elapsed time in milliseconds
ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

# Save results
cat > benchmark-run-${ITERATION_NUM}.txt <<EOF
BENCHMARK RESULT
================
Iteration: ${ITERATION_NUM}
Worktree: [WITH/WITHOUT]
Timestamp: $(date)
Elapsed Time (ms): ${ELAPSED_MS}

Token Usage: [parse from Claude response]
Input Tokens: [captured from response]
Output Tokens: [captured from response]
Total Tokens: [input + output]

Output Quality Assessment:
- Completeness: [score 1-10]
- Accuracy: [score 1-10]
- Format: [comment]

Raw Output:
[full response content]
EOF
```

#### Capturing Token Usage

Most important: **Log the token counts** from Claude API responses.

**From Claude Code console:**
```
{
  "usage": {
    "input_tokens": 1234,
    "output_tokens": 567,
    "cache_creation_input_tokens": 0,
    "cache_read_input_tokens": 0
  }
}
```

**Create a log parser script:**
```bash
#!/bin/bash
# extract-tokens.sh

LOG_FILE=$1

grep -oP '"input_tokens":\s*\K[0-9]+' "$LOG_FILE" | head -1
grep -oP '"output_tokens":\s*\K[0-9]+' "$LOG_FILE" | head -1

# Calculate total
INPUT=$(grep -oP '"input_tokens":\s*\K[0-9]+' "$LOG_FILE" | head -1)
OUTPUT=$(grep -oP '"output_tokens":\s*\K[0-9]+' "$LOG_FILE" | head -1)
echo "TOTAL_TOKENS=$((INPUT + OUTPUT))"
```

---

### Step 6: Quality Assessment

Quality metrics should be **objective, repeatable, and clear**.

#### Quality Assessment Framework

```markdown
# Quality Assessment Template

## Completeness
- WITH skill output covers [X%] of requirements
- WITHOUT skill output covers [Y%] of requirements
- Difference: [X - Y]%

## Accuracy
- WITH skill: [correct/incorrect/partial] on key metrics
- WITHOUT skill: [correct/incorrect/partial] on key metrics
- Examples:
  - Metric A: WITH [result], WITHOUT [result]
  - Metric B: WITH [result], WITHOUT [result]

## Usability
- WITH skill output: [easy/moderate/difficult] to use as-is
- WITHOUT skill output: [easy/moderate/difficult] to use as-is
- Required edits: WITH [0/1/2] edits, WITHOUT [0/1/2] edits

## Structure & Format
- WITH skill follows format: [yes/partially/no]
- WITHOUT skill follows format: [yes/partially/no]

## Verdict
- Better quality: [WITH / WITHOUT / EQUIVALENT]
- Confidence: [High / Medium / Low]
```

#### Real-World Quality Comparison

**Example: Documentation Generation**

Worktree A (WITH skill) output:
```markdown
# Module: UserAuth

## Overview
Handles user authentication with JWT tokens.

## API Reference
...complete reference...
```

Worktree B (WITHOUT skill) output:
```markdown
# UserAuth Module

Authentication module.

## Methods
...incomplete list...
```

**Assessment:**
- Completeness: WITH 95%, WITHOUT 60% (Δ +35%)
- Format compliance: WITH yes, WITHOUT partially
- Quality verdict: WITH skill significantly better ✓

---

### Step 7: Generate Report

Create a comprehensive benchmark report aggregating all results.

#### Benchmark Report Template

```markdown
# Benchmark Report: [Skill Name]

## Executive Summary

**Task:** [Brief description]
**Iterations:** 3 (Jan 25, 2026)
**Finding:** [Skill provides/does not provide significant value]

### Key Metrics
- Token reduction: [X%] (SIGNIFICANT / MODERATE / MINIMAL)
- Time improvement: [X%] (SIGNIFICANT / MODERATE / MINIMAL)
- Quality change: [IMPROVED / MAINTAINED / DEGRADED]
- Recommendation: [ADOPT / REFINE / REJECT]

---

## Detailed Results

### Token Usage Analysis

| Metric | WITH Skill | WITHOUT Skill | Difference | % Change |
|--------|-----------|---------------|-----------|----------|
| Avg Input Tokens | 1200 | 1500 | -300 | -20% |
| Avg Output Tokens | 800 | 1100 | -300 | -27% |
| Avg Total Tokens | 2000 | 2600 | -600 | -23% |

**Interpretation:**
- Skill reduces token usage by ~23% on average
- This translates to X cost savings per task
- Over 100 tasks: $Y annual savings

### Time Efficiency Analysis

| Metric | WITH Skill | WITHOUT Skill | Difference |
|--------|-----------|---------------|-----------|
| Iteration 1 | 6.2 min | 7.1 min | -0.9 min |
| Iteration 2 | 5.9 min | 7.3 min | -1.4 min |
| Iteration 3 | 6.1 min | 7.0 min | -0.9 min |
| **Average** | **6.07 min** | **7.13 min** | **-1.06 min (-15%)** |

**Interpretation:**
- Skill reduces execution time by ~15%
- Time saved per task: 1 minute
- Over 5 tasks daily: 5 minutes saved per day

### Quality Assessment

| Aspect | WITH Skill | WITHOUT Skill | Winner |
|--------|-----------|---------------|--------|
| Completeness | 95% | 70% | WITH ✓ |
| Accuracy | 100% | 90% | WITH ✓ |
| Format Compliance | Yes | Partial | WITH ✓ |
| Usability (edits needed) | 0 | 2 | WITH ✓ |

**Detailed Comparison:**

**WITH Skill Output:**
- All sections present
- Correct structure
- Ready to use immediately
- No corrections needed

**WITHOUT Skill Output:**
- Missing API reference section
- Inconsistent formatting
- Requires 2 edits before use
- Partially complete

---

## Iteration Details

### Iteration 1

**Worktree A (WITH Skill):**
- Elapsed: 6.2 min
- Tokens: 2010 (IN: 1205, OUT: 805)
- Quality: Excellent
- Notes: Completed on first try

**Worktree B (WITHOUT Skill):**
- Elapsed: 7.1 min
- Tokens: 2580 (IN: 1480, OUT: 1100)
- Quality: Good with modifications
- Notes: Required formatting fixes

### [Iteration 2, 3...]

---

## Cost Impact Analysis

**Current pricing (as of 2026-01-25):**
- Haiku input: $0.80/M tokens
- Sonnet input: $3/M tokens
- Haiku output: $4/M tokens
- Sonnet output: $12/M tokens

**Calculation (assuming Sonnet):**
- Cost WITH skill: (1200 * $3 + 800 * $12) / 1M = $12.00
- Cost WITHOUT skill: (1500 * $3 + 1100 * $12) / 1M = $17.20
- **Savings per task: $5.20 (30%)**
- **Savings per month (20 tasks): $104**
- **Savings per year: $1,248**

---

## Recommendations

### Based on Metrics

✓ **Token reduction: 23%** - MEETS THRESHOLD (>20%)
✓ **Time improvement: 15%** - MEETS THRESHOLD (>10%)
✓ **Quality: IMPROVED** - MAINTAINS BASELINE
✓ **Cost ROI: POSITIVE** - $1,248 annual savings

### Decision: ADOPT THIS SKILL

**Rationale:**
- Significant token savings (23%)
- Meaningful time improvement (15%)
- Superior output quality (95% vs 70% completeness)
- Positive cost impact ($1,248/year)

### Implementation Plan
1. Add skill to main project CLAUDE.md
2. Train team on skill usage
3. Measure adoption rate
4. Re-benchmark in 3 months

### Next Steps
- [ ] Integrate skill into production workflow
- [ ] Document skill in project wiki
- [ ] Schedule follow-up benchmark (Q2 2026)
- [ ] Monitor real-world usage metrics

---

## Conclusion

[Skill Name] demonstrates **measurable and significant improvements** across token efficiency, execution time, and output quality. Implementation is recommended with confidence.

**Generated:** 2026-01-25
**Benchmark Version:** 1.0
```

---

### Step 8: Compare With Git Diff

Git diff is a powerful tool to see **exact differences** in benchmark results and output files.

#### Git Diff Strategy

```bash
# In your benchmarking directory

# Compare worktree A and B output files
git diff bench-with..bench-without -- benchmark-results/

# Shows:
# - Added/removed lines in output
# - Token count differences
# - Time spent differences

# Example output visualization:
diff --git a/run-1-with.txt b/run-1-without.txt
index 1234567..abcdefg 100644
--- a/run-1-with.txt
+++ b/run-1-without.txt
@@ -1,10 +1,12 @@
 BENCHMARK RESULT
 ================
-Elapsed Time (ms): 6200
+Elapsed Time (ms): 7100

-Total Tokens: 2010
-Input Tokens: 1205
-Output Tokens: 805
+Total Tokens: 2580
+Input Tokens: 1480
+Output Tokens: 1100
```

#### Creating a Diff-Based Comparison

```bash
#!/bin/bash
# compare-runs.sh - Generate structured diff report

WORKTREE_A="/Users/yoohyuntak/workspace/claude-automate-benchmark-with"
WORKTREE_B="/Users/yoohyuntak/workspace/claude-automate-benchmark-without"

echo "=== BENCHMARK COMPARISON ==="
echo ""

for i in 1 2 3; do
  echo "--- RUN $i ---"

  # Extract metrics from both runs
  TOKENS_A=$(grep "Total Tokens:" "$WORKTREE_A/benchmark-run-$i.txt" | awk '{print $NF}')
  TOKENS_B=$(grep "Total Tokens:" "$WORKTREE_B/benchmark-run-$i.txt" | awk '{print $NF}')

  TIME_A=$(grep "Elapsed Time:" "$WORKTREE_A/benchmark-run-$i.txt" | awk '{print $NF}')
  TIME_B=$(grep "Elapsed Time:" "$WORKTREE_B/benchmark-run-$i.txt" | awk '{print $NF}')

  # Calculate differences
  TOKEN_DIFF=$((TOKENS_B - TOKENS_A))
  TOKEN_PCT=$(echo "scale=1; (100 * $TOKEN_DIFF / $TOKENS_B)" | bc)

  TIME_DIFF=$(echo "$TIME_B - $TIME_A" | bc)

  echo "Tokens: WITH=$TOKENS_A, WITHOUT=$TOKENS_B, DIFF=$TOKEN_DIFF ($TOKEN_PCT%)"
  echo "Time: WITH=$TIME_A ms, WITHOUT=$TIME_B ms, DIFF=$TIME_DIFF ms"
  echo ""
done
```

---

## Connecting to Continuous Learning

Benchmarking results directly feed into your **Continuous Learning system**. This is where insights become actionable knowledge.

### Recording Benchmark Insights

After completing a benchmark, capture learnings in your TIL (Today I Learned) system:

```markdown
# TIL: Skill Impact Measurement

## Finding
[Skill name] provides 23% token reduction with no quality degradation.

## Evidence
- Benchmark report: docs/benchmarks/skill-name-2026-01.md
- 3 iterations averaged
- Statistical confidence: high

## Implementation
The skill has been added to the main workflow based on these metrics.

## Next Action
Monitor real-world usage for 3 months to validate benchmark results.

## Related
- Continuous Learning: Section 06 of Context & Memory Management
- Skill Documentation: skills/[skill-name]/SKILL.md
- Benchmark Report: docs/benchmarks/skill-name-2026-01.md
```

### Continuous Learning Integration Points

1. **After benchmarking completes**: Record key metrics in TIL
2. **When adopting skill**: Link benchmark evidence to adoption decision
3. **During monthly review**: Compare predicted vs. actual savings
4. **For quarterly planning**: Use benchmark data for ROI calculations

### Feedback Loop

```
Benchmark Results
    ↓
TIL Recording (Continuous Learning)
    ↓
Implementation Decision
    ↓
Real-World Monitoring
    ↓
Validation/Refinement
    ↓
Knowledge Base Update
```

---

## Practical Examples

### Example 1: Benchmarking a Documentation Skill

**Task Definition:**
```
Write comprehensive API documentation for a simple module.
Input: JavaScript file with 3 functions
Output: README with API reference, examples, and error documentation
```

**Results (3 iterations average):**
- WITH skill: 2015 tokens, 6.2 min, 95% complete
- WITHOUT skill: 2580 tokens, 7.1 min, 70% complete
- **Outcome: Adopt skill** (23% token savings, better quality)

### Example 2: Benchmarking a Code Generation Skill

**Task Definition:**
```
Generate test cases for a data validation function.
Input: Python function (25 lines)
Output: pytest test file with 15+ test cases
```

**Results (5 iterations average):**
- WITH skill: 1850 tokens, 5.1 min, 100% coverage
- WITHOUT skill: 2100 tokens, 5.8 min, 75% coverage
- **Outcome: Adopt skill** (12% token savings, 25% better coverage)

### Example 3: Benchmarking a Refactoring Skill

**Task Definition:**
```
Refactor a messy helper module using project conventions.
Input: 150-line module with poor structure
Output: Well-organized module following standards
```

**Results (3 iterations average):**
- WITH skill: 3200 tokens, 12.4 min, passes all tests
- WITHOUT skill: 2900 tokens, 11.1 min, passes all tests
- **Outcome: Conditional adoption** (skill uses MORE tokens but improves code quality)

---

## Common Pitfalls & How to Avoid Them

| Pitfall | Impact | Prevention |
|---------|--------|-----------|
| **Task not identical** | Results don't compare | Use exact copy-paste for each iteration |
| **Caching affects results** | Inflated or deflated metrics | Clear cache before each iteration |
| **Only 1-2 iterations** | High variance, unreliable | Use 3-5 iterations minimum |
| **Mixing multiple skills** | Can't isolate impact | Test ONE variable per benchmark |
| **Including setup time** | Skewed time metrics | Only measure task execution time |
| **Forgetting token logging** | Can't analyze cost | Capture API response with token counts |
| **Subjective quality assessment** | Inconsistent results | Use objective, scored criteria |
| **Comparing different models** | Apples-to-oranges | Run both worktrees with same model |

---

## Verification Checklist

Before declaring benchmark complete:

- [ ] **Task Definition**: Clear, repeatable, with success criteria
- [ ] **Worktree A**: Created with skill enabled, verified
- [ ] **Worktree B**: Created with skill disabled, verified
- [ ] **Iterations**: Ran 3-5 iterations per worktree
- [ ] **Token Logging**: Captured input/output tokens for all runs
- [ ] **Time Recording**: Measured elapsed time for all runs
- [ ] **Quality Assessment**: Completed for all iterations
- [ ] **Metrics Calculated**: Averages and percentages computed
- [ ] **Report Generated**: benchmark-report.md created and reviewed
- [ ] **Git Diff Analysis**: Compared runs to highlight differences
- [ ] **Findings Recorded**: Added to Continuous Learning system
- [ ] **Worktrees Cleaned**: Removed temporary branches
- [ ] **Documentation Updated**: Skill docs reflect benchmark results

---

## Advanced: Statistical Significance

For rigorous benchmarking, consider statistical analysis:

```python
# calculate-confidence.py
import statistics
import math

# Token data from 5 iterations WITH skill
tokens_with = [2010, 2005, 2020, 2015, 2010]

# Token data from 5 iterations WITHOUT skill
tokens_without = [2580, 2600, 2570, 2590, 2585]

# Calculate means and standard deviations
mean_with = statistics.mean(tokens_with)
mean_without = statistics.mean(tokens_without)

stdev_with = statistics.stdev(tokens_with)
stdev_without = statistics.stdev(tokens_without)

# Calculate percent difference
pct_diff = ((mean_without - mean_with) / mean_without) * 100

# Standard error
se = math.sqrt((stdev_with**2/5) + (stdev_without**2/5))

# Confidence interval (95%)
ci = 1.96 * se

print(f"Token Reduction: {pct_diff:.1f}% ± {ci:.0f} (95% CI)")
print(f"Confidence: {'HIGH' if ci < mean_without * 0.1 else 'MEDIUM' if ci < mean_without * 0.2 else 'LOW'}")
```

---

## Key Takeaways

1. **Benchmarking is systematic**: Follow the workflow, don't skip steps
2. **Multiple iterations matter**: 3-5 runs reduce variance significantly
3. **Isolate variables**: Test ONE skill per benchmark, not multiple
4. **Measure everything**: Token counts, time, and quality assessment
5. **Compare objectively**: Use criteria-based quality assessment, not feelings
6. **Record findings**: Add results to Continuous Learning for future reference
7. **Clean up**: Remove temporary worktrees and branches when done
8. **Make decisions**: Use data to decide whether to adopt/refine/reject skills

---

## Related Documentation

- **Context & Memory Management**: [Continuous Learning](./06-continuous-learning.md)
- **Token Optimization**: [Understanding Token Economy](../02-token-optimization/README.md)
- **Verification Loops**: [Main README](./README.md)
- **Practical Tools**: Git worktrees, bash scripting, JSON parsing

---

**Created:** 2026-01-25
**Status:** Published
**Language:** English + Korean
