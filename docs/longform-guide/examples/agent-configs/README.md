# Agent Configuration Examples

This directory contains comprehensive, production-ready examples of orchestrator agent configurations and workflows using the 5-phase pattern.

## Files in This Directory

### 1. orchestrator.yaml
**Configuration file demonstrating a complete orchestrator setup**

- **Size**: ~22KB
- **Type**: YAML configuration
- **Purpose**: Reference implementation of an orchestrator agent that coordinates multi-agent workflows

**Key Sections**:
- Core orchestrator configuration (model selection, timeouts)
- 6 specialized subagents with their optimal models and capabilities
- 5-phase workflow definitions with example prompts
- Delegation strategy and complexity assessment rules
- Error handling and escalation policies
- Monitoring and quality assurance setup

**When to Use**:
- As a starting template for your own orchestrator
- To understand agent delegation patterns
- To learn model selection heuristics
- To implement quality gates in workflows

**Key Configuration Features**:
```yaml
# Phase-based workflow
phases:
  phase1_research:    # Haiku - fast information gathering
  phase2_planning:    # Opus - strategic design
  phase3_implementation: # Sonnet - standard development
  phase4_review:      # Opus - critical review
  phase5_verification: # Sonnet - testing & validation

# Smart delegation
delegation:
  complexity_assessment: true
  model_selection_rules: true
  escalation_rules: true

# Quality gates at each phase
quality_gates:
  phase1_research: 0.80
  phase2_planning: 0.95
  phase3_implementation: 0.88
  phase4_review: 0.92
  phase5_verification: 0.90
```

---

### 2. sequential-phases-example.md
**Complete real-world workflow example with actual prompts and outputs**

- **Size**: ~42KB
- **Type**: Markdown guide with detailed walkthrough
- **Purpose**: Step-by-step example of implementing the 5-phase pattern for a real authentication system upgrade

**Structure**:
1. **Scenario Context** - Business requirements and constraints
2. **Phase 1: Research** - Complete prompt and expected output
3. **Phase 2: Planning** - Design process with architecture diagrams
4. **Phase 3: Implementation** - File creation and code structure
5. **Phase 4: Review** - Validation checklist
6. **Phase 5: Verification** - Testing and final approval

**Key Components**:
- Actual prompts you can copy and adapt
- Example outputs showing what each phase produces
- Quality gate validation at each step
- Cost breakdown and time estimates
- Risk assessment and mitigation strategies
- Database schema and migration scripts
- Security design patterns

**When to Use**:
- To see how the 5-phase pattern works in practice
- To understand quality gates and gate validation
- As a template for your own multi-phase workflows
- To learn prompt engineering for each phase type
- To understand model selection impact on cost (80% savings shown)

**Key Insights**:
```markdown
# Model Selection Impact
Phase 1 (Research):      $0.04  (Haiku)   - 73% cheaper than Opus
Phase 2 (Planning):      $0.28  (Opus)    - Complex reasoning required
Phase 3 (Implementation):$0.18  (Sonnet)  - Good quality/cost balance
Phase 4 (Review):        $0.24  (Opus)    - Critical quality needed
Phase 5 (Verification):  $0.16  (Sonnet)  - Testing expertise

Total: $0.90 (vs $4.50 if using Opus for all - 80% savings!)
```

---

## How to Use These Examples

### Approach 1: Learn by Example (Recommended for Beginners)

1. **Start here**: Read the scenario in `sequential-phases-example.md`
2. **Study Phase 1**: See how research prompts work and what output they produce
3. **Study Phase 2**: Understand planning and design prompts
4. **Understand Model Selection**: Note why different models are used for different phases
5. **Review Configuration**: Look at `orchestrator.yaml` to see how these phases are configured

### Approach 2: Implement Now (For Experienced Users)

1. **Copy orchestrator.yaml** to your project
2. **Customize** the subagents list with your agents
3. **Update** the phase prompts with your specific requirements
4. **Set** quality thresholds appropriate for your domain
5. **Configure** your cost limits and monitoring
6. **Run** your first workflow

### Approach 3: Adapt for Your Domain

1. **Study both files** together to understand the pattern
2. **Identify** your use case (feature, bug fix, refactoring, etc.)
3. **Create** custom prompts based on the examples
4. **Add/remove** phases as needed for your workflow
5. **Validate** outputs match your quality standards
6. **Iterate** and refine prompts based on results

---

## The 5-Phase Pattern Explained

### Phase 1: Research & Discovery
**Purpose**: Understand the current state and landscape

**Agent**: Haiku (low cost, fast)
- Explore codebase
- Identify patterns
- Find dependencies
- Assess current implementation

**Deliverable**: Research report with findings

---

### Phase 2: Planning & Design
**Purpose**: Create comprehensive strategy and architecture

**Agent**: Opus (high capability for complex reasoning)
- Design new architecture
- Plan migration strategy
- Identify risks
- Create implementation roadmap

**Deliverable**: Detailed plan with designs, estimates, and risk mitigation

---

### Phase 3: Implementation & Development
**Purpose**: Build the solution following the plan

**Agent**: Sonnet (balanced cost/capability)
- Write code
- Create database migrations
- Write tests
- Build features

**Deliverable**: Working implementation with tests and documentation stubs

---

### Phase 4: Review & Validation
**Purpose**: Ensure implementation matches plan and standards

**Agent**: Opus (expertise needed for critical review)
- Review code quality
- Validate against plan
- Check security
- Identify improvements

**Deliverable**: Review report with quality assessment and approval

---

### Phase 5: Verification & Final Validation
**Purpose**: Confirm deployment readiness

**Agent**: Sonnet (testing expertise)
- Execute tests
- Load testing
- Security verification
- Create deployment checklist

**Deliverable**: Test results, metrics, and deployment approval

---

## Key Features Demonstrated

### 1. Intelligent Model Selection

| Phase | Model | Why | Cost |
|-------|-------|-----|------|
| Research | Haiku | Simple information gathering | $0.04 |
| Planning | Opus | Complex strategic reasoning | $0.28 |
| Implementation | Sonnet | Standard development capability | $0.18 |
| Review | Opus | Critical quality assurance | $0.24 |
| Verification | Sonnet | Testing and validation | $0.16 |

**Result**: 80% cost savings vs using Opus for everything

### 2. Quality Gates at Each Phase

Each phase has defined quality thresholds:
- Research: 80% (lower threshold for simple search)
- Planning: 95% (high threshold for critical design)
- Implementation: 88% (code quality standard)
- Review: 92% (critical review standard)
- Verification: 90% (deployment readiness standard)

### 3. Escalation Rules

If a phase doesn't meet quality threshold:
- Simple tasks: Retry with same agent
- Medium tasks: Escalate to higher model
- Critical tasks: Halt and request manual review

### 4. Complexity Assessment

Automatic calculation of task complexity based on:
- Input length
- Required reasoning depth
- Number of subagents needed
- Impact of decisions

Complexity score determines model selection automatically.

### 5. Cost Tracking

Monitor spending across:
- Per-task budgets
- Per-phase budgets
- Overall workflow budget
- Alert on budget overruns

---

## Real-World Metrics from Example

### Authentication System Upgrade Project

**Timeline**:
- Research: 10 minutes
- Planning: 20 minutes
- Implementation: 35 hours (team parallel work)
- Review: 30 minutes
- Verification: 25 minutes
- **Total elapsed**: 36-40 hours (1 week with 4-person team)

**Cost**:
```
Phase 1 (Research):        $0.04
Phase 2 (Planning):        $0.28
Phase 3 (Implementation):  $0.18
Phase 4 (Review):          $0.24
Phase 5 (Verification):    $0.16
───────────────────────────────
Total:                     $0.90

(Would cost $4.50 with Opus for all phases)
(Savings: $3.60 or 80%)
```

**Quality Metrics**:
- Phase 1 Quality: 0.80
- Phase 2 Quality: 0.96
- Phase 3 Quality: 0.90
- Phase 4 Quality: 0.93
- Phase 5 Quality: 0.95
- **Overall Success Rate**: 100%

---

## Customization Guide

### Adapting for Your Use Case

#### Bug Fix Workflow
- **Phase 1**: Explore bug, find root cause (might use Oracle instead of Explore)
- **Phase 2**: Design fix and test strategy
- **Phase 3**: Implement fix and tests
- **Phase 4**: Review fix quality
- **Phase 5**: Verify fix in staging

#### Feature Implementation
- **Phase 1**: Understand current feature area
- **Phase 2**: Design new feature and integration points
- **Phase 3**: Implement feature with full tests
- **Phase 4**: Review feature completeness
- **Phase 5**: Verify feature works and scales

#### Refactoring Project
- **Phase 1**: Explore code patterns and dependencies
- **Phase 2**: Design refactoring approach
- **Phase 3**: Refactor code and update tests
- **Phase 4**: Review code quality improvements
- **Phase 5**: Verify no regressions in functionality

#### Documentation Project
- **Phase 1**: Explore what needs documentation
- **Phase 2**: Plan documentation structure
- **Phase 3**: Write documentation (use document-writer)
- **Phase 4**: Review for accuracy and clarity
- **Phase 5**: Verify links work and examples execute

---

## Tips for Best Results

### 1. Write Clear Phase Prompts
- Be specific about deliverables
- Include context from previous phases
- Define success criteria
- Specify output format

### 2. Set Appropriate Quality Thresholds
- Too low: Poor quality results
- Too high: Excessive costs and delays
- Start with recommended thresholds, adjust based on results

### 3. Monitor Quality Gates
- Check each phase output against gates
- Don't proceed if gates not met
- Adjust prompts if repeatedly failing gates

### 4. Track Metrics
- Record actual vs estimated costs
- Compare actual vs target quality
- Update complexity assessment over time

### 5. Iterate Prompts
- Keep what works
- Refine what doesn't
- Build library of effective prompts for your domain

---

## Common Patterns

### Pattern 1: Feature with External Integration
```yaml
Phase 1: Explore existing integration points
Phase 2: Design integration approach + fallback
Phase 3: Implement integration + error handling
Phase 4: Review security + API compatibility
Phase 5: Verify with integration provider's sandbox
```

### Pattern 2: Performance Optimization
```yaml
Phase 1: Profile and identify bottlenecks
Phase 2: Design optimization strategy
Phase 3: Implement optimizations + benchmarks
Phase 4: Review optimization validity
Phase 5: Load test to verify improvements
```

### Pattern 3: Security Hardening
```yaml
Phase 1: Identify security gaps
Phase 2: Design security improvements
Phase 3: Implement security patches
Phase 4: Security review + audit
Phase 5: Penetration testing verification
```

### Pattern 4: Multi-Service Refactoring
```yaml
Phase 1: Map service dependencies
Phase 2: Design refactoring + migration strategy
Phase 3: Refactor services (parallel agents)
Phase 4: Review inter-service compatibility
Phase 5: Integration testing all services
```

---

## Troubleshooting

### Phase Failing Quality Gate

**Problem**: Phase completes but quality score is below threshold

**Solutions**:
1. Review the agent's output carefully
2. Check if prompt was clear enough
3. Try escalating to higher model
4. Add more context from previous phases
5. Retry with refined prompt

### Cost Exceeding Budget

**Problem**: Workflow cost exceeded budget limit

**Solutions**:
1. Use lower model tier if quality permits
2. Break workflow into smaller phases
3. Combine some phases if possible
4. Pre-filter requirements to reduce scope
5. Use caching for repeated tasks

### Model Selection Confusion

**Problem**: Not sure which model to use for a phase

**Heuristic**:
- Simple = Haiku (cost-optimized)
- Standard = Sonnet (balanced, default)
- Complex = Opus (highest capability)
- Strategic/Critical = Opus (always)
- Timing sensitive = Haiku (fastest)

---

## Next Steps

### Learn More
- Read: [Subagent Architecture & Token Optimization](../../02-token-optimization/01-subagent-architecture.md)
- Read: [Agent Best Practices](../../06-agent-best-practices/README.md)

### Implement
- Copy `orchestrator.yaml` to your project
- Customize for your specific use case
- Run first workflow with monitoring
- Iterate and optimize

### Share
- Create examples for your domain
- Share prompts that work well
- Contribute improvements back

---

## Questions & Support

For questions about:
- **YAML syntax**: See orchestrator.yaml inline comments
- **Prompt engineering**: See sequential-phases-example.md Phase sections
- **Model selection**: See "Key Features Demonstrated" section
- **Customization**: See "Customization Guide" section
- **Patterns**: See "Common Patterns" section

---

## File Sizes & Complexity

| File | Size | Complexity | Time to Read | Time to Implement |
|------|------|-----------|--------------|------------------|
| orchestrator.yaml | 22 KB | Medium | 20 minutes | 30-60 minutes |
| sequential-phases-example.md | 42 KB | High | 60 minutes | 4+ hours |
| **Total** | 64 KB | High | 80 minutes | 4-6 hours |

**Recommendation**: Start with sequential-phases-example.md, then study orchestrator.yaml, then customize both for your use case.

---

<div align="center">

### These examples provide everything you need to master the 5-phase orchestrator pattern

**Ready to transform your workflow?** Start with the authentication system example and adapt it for your domain.

</div>
