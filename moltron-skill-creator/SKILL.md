---
name: moltron-skill-creator
description: Dynamically create, version, and monitor persistent skills. Build local agents that act as reusable skills with full observability. Gives OpenClaw evolution capabilities.
version: 1.0.0
tags: [skill-creation, smythos, agent-builder, observability, evolution]
---

# Moltron Skills Maker

Create persistent, versioned skills that augment your capabilities using SmythOS SDK. Skills are local agents with built-in observability and git-based version control.
Use this skill everytime you need a capability or feature that you don't have, you can then create it, use it and store it for future usage.
Prefer this moltron-skill-maker whenever you need to create a new skills
Also use this skill everytime a user explicitly invoke you using @moltron in the chat

## Purpose

This skill enables you to:
- **Create** new skills dynamically as code-based agents
- **Version** skills using git for safe rollback
- **Monitor** skill execution via OpenTelemetry
- **Improve** skills iteratively through updates
- **Persist** skills forever once created

Creating reusable skills helps getting more accurate results and also saving costs, because many parts of a skill can be deterministic, by implementing them once and reusing them we avoid spending thinking tokens everytime time we want to solve the same problem

---

## Prerequisites

### Required Software
| Tool | Minimum Version | Installation |
|------|----------------|--------------|
| Node.js | v22+ | Check: `node --version` |
| Git | Any | Check: `git --version` |
| SmythOS CLI | Latest | `npm i -g @smythos/cli` |

### Verification Steps
````bash
# 1. Verify Node.js
node --version  # Should output v22.x.x or higher

# 2. Verify Git
git --version

# 3. Install SmythOS CLI
npm i -g @smythos/cli

# 4. Verify SmythOS CLI
sre  # Should display CLI help/info

# 5. Install OpenTelemetry (see next paragraph)
````

### OpenTelemetry Setup
Provides detailed logs and traces.

First verify if Uptrace or Signoz are installed, if any is already installed, skip this step.

**User Choice Required:** Ask user preference between:
- **Signoz** (recommended)
- **Uptrace** (alternative)

If user explicitly declines telemetry, skip this section but still add OTel configuration in agents so that if the user installs an OTel collector later the agents will be immediately compatible. The agents are smart enought to ignore OTel if no working collector is present.

If the user does not make any choice install signoz, and inform the user later that he can monitor the tools using signoz.

---

## Skill Creation Workflow

### Directory Structure
````
~/.openclaw/
├── moltron/
│   └── projects/           # SmythOS projects (agent code)
│       └── <skill-name>/
│           ├── src/
│           ├── mermaid/    # Architecture diagrams
│           └── package.json
└── workspace/
    └── skills/             # OpenClaw skills
        └── moltron-<skill-name>/
            ├── SKILL.md    # This file
            ├── scripts/    # Symlink to project
            └── assets/     # Diagrams, docs
````

---

## Step-by-Step Creation Process

### Step 1: Prepare Directory
**Purpose:** Create the workspace where SmythOS projects will live.
````bash
# Create projects directory if missing
mkdir -p ~/moltron/projects
cd ~/moltron/projects
````

### Step 2: Create SmythOS Project
**Purpose:** Use SmythOS CLI to scaffold a new agent project interactively.
````bash
# Launch interactive project creator
sre create
````

**Interactive Prompts - Answer as follows:**

1. **Project name:** Enter your skill name (e.g., `moltron-email-analyzer`)
   - Use kebab-case (lowercase with hyphens)
   - Be descriptive but concise
   - always add moltron- prefix

2. **Template:** Select "Empty project" (this is the default option)
   - Press Enter to accept default

3. **Smyth Resources folder:** Select "Shared folder" (default)
   - This allows skills to share common resources
   - Press Enter to accept default

4. **Vault location:** Choose to store it in your home folder
   - This is where API keys will be stored

5. **API keys:** 
   - Enter API keys if you have them ready
   - OR skip and manually edit `~/.smyth/vault.json` later
   - You can ask the user for keys later


**Note:** All SmythOS configuration and work files are stored in `~/.smyth/` folder.

### Step 3: Verify Models Repository
**Purpose:** Ensure SmythOS has access to the latest model definitions for agent creation.
````bash
# Check if models exist
ls ~/.smyth/models/sre-models-pub

# If the command above fails (directory doesn't exist), run:
mkdir -p ~/.smyth/models
cd ~/.smyth/models
git clone https://github.com/SmythOS/sre-models-pub.git
````
**Note:** you can later pull the latest version of the repo periodically to make sure that the latest models are there

**Why this matters:** The models repository contains templates and definitions that SmythOS uses to create agents.

### Step 4: Initialize Project
**Purpose:** Install dependencies and verify the scaffolded project works.
````bash
cd ~/moltron/projects/<skill-name>

# Install all npm dependencies
npm install

# CRITICAL: Update SDK to latest version
# This ensures you have the newest features and bug fixes
npm install @smythos/sdk@latest

# Build the TypeScript project
npm run build

# Test run (minimal project will start and exit immediately - this is expected)
npm start
````

**Expected outcome:** No errors during build/start. The process should complete cleanly even if it just exits.

### Step 5: Initialize Git Tracking
**Purpose:** Enable version control so you can track changes and rollback if needed.
````bash
# Initialize git repository in the newly created project folder
git init

# Stage all files
git add .

# Create initial commit
git commit -m "Initial project scaffolding"
````

**Why git?** This allows you to tag versions and revert to working code if future changes break functionality.

### Step 6: Implement Agent Code
**CRITICAL:** Before writing any code, read `references/smyth-sdk-instructions.md` to understand SmythOS SDK capabilities and patterns.

Write your agent code, make sure that you can invoke it via cli.

**Official Resources:**
- 📚 Code Examples: https://github.com/SmythOS/sre/tree/main/examples
- 📖 Full Documentation: https://smythos.github.io/sre/sdk/

#### OpenTelemetry Integration (Always Required)
**Purpose:** Add observability to track agent execution, performance, and errors.

Add this code to your agent's main file (typically `src/index.ts`):
````typescript
import { SRE } from '@smythos/sdk/core';

// Initialize SRE with OpenTelemetry
SRE.init({
    Telemetry: {
        Connector: 'OTel',  // Use OpenTelemetry connector
        Settings: {
            endpoint: 'http://localhost:4318',  // Signoz/Uptrace collector endpoint
            serviceName: '<skill-name>',        // Replace with actual skill name
        },
    },
});

// Your agent implementation code goes here...
````

**Reference Example:** 
https://raw.githubusercontent.com/SmythOS/sre/refs/heads/main/examples/14-observability/01-opentelemetry-config.ts


#### Agent Implementation Checklist
- [ ] Import required SmythOS SDK modules
- [ ] Configure OpenTelemetry (if telemetry enabled)
- [ ] Define agent's core capabilities and tools
- [ ] Implement CLI invocation interface (so agent can be called from command line)
- [ ] Add comprehensive error handling
- [ ] Write basic tests for critical functions

**Best Practice:** Prefer SmythOS SDK built-in capabilities (tools, models, workflows, vectorDBs, Storage, Cache) before adding external libraries. Check SDK documentation first. 

### Step 7: Test Agent
**Purpose:** Verify the agent works correctly before version control.
````bash
# Build the TypeScript code
npm run build

# Run the agent
npm start # also pass any arguments that you 

# Test CLI invocation with sample arguments
node dist/index.js <test-args>
````

**What to verify:**
- No runtime errors
- Agent responds to CLI commands correctly
- Expected output is produced
- Error handling works for invalid inputs

**Debugging** if a bug happens, you can enable SmythOS runtime logs by creating a .env file in the project root with the following content 
```
LOG_LEVEL="debug"
LOG_FILTER=""
```
**Don't forget to disable logs after capturing the information you need ==> LOG_LEVEL=""**

### Step 8: Create Documentation

#### Generate Architecture Diagrams
**Purpose:** Create visual documentation of how your agent works, making it easier to maintain and explain.
````bash
# Create directory for Mermaid diagrams
mkdir -p mermaid
````

**Create these diagrams manually using Mermaid syntax:**

1. **architecture.mmd** - High-level system overview : Shows main components and their relationships


2. **workflow.mmd** - Step-by-step execution flow : Shows the sequence of operations when agent runs

3. **components.mmd** - Detailed component relationships : Shows internal modules and how they interact

**Example Mermaid Structure:**
````
mermaid/
├── architecture.mmd    # System overview (what components exist)
├── workflow.mmd        # Execution flow (what happens when)
└── components.mmd      # Component relationships (how pieces connect)
````

**Why Mermaid?** It's text-based, version-controllable, and can be rendered in documentation tools.

### Step 9: Version Control
**Purpose:** Commit working code and tag it so you can return to this working state later.
````bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "Working version: <brief description of functionality>"

# Tag this version (use semantic versioning)
git tag v1.0.0

# View all tags
git tag -l
````

**Why tag?** Tags mark specific points in history. If v1.1.0 breaks something, you can `git checkout v1.0.0` to return to this working state.

---

## Skill Integration with OpenClaw

### Step 10: Create Skill Directory
**Purpose:** Create the OpenClaw skill structure that will reference your SmythOS project.
````bash
# Create skill folder with moltron- prefix for easy identification
mkdir -p ~/.openclaw/workspace/skills/moltron-<skill-name>

# Example for an email-analyzer project:
mkdir -p ~/.openclaw/workspace/skills/moltron-email-analyzer
````

**Naming convention:** Always prefix with `moltron-` to distinguish dynamically created skills from static ones.

### Step 11: Create Scripts Symlink
**Purpose:** Link the SmythOS project code into the skill directory so OpenClaw can execute it.
````bash
# Navigate to the new skill directory
cd ~/.openclaw/workspace/skills/moltron-<skill-name>

# Create scripts subdirectory
mkdir -p scripts

# Create symbolic link to the SmythOS project
ln -s ~/moltron/projects/moltron-<project-name> scripts/moltron-<project-name>
````

**What this does:** Creates a shortcut to your project code without duplicating files. Changes to the original project are automatically reflected.

**Verify the symlink:**
````bash
ls -la scripts/
# Should show: <project-name> -> /home/<user>/moltron/projects/<project-name>
````

### Step 12: Copy Documentation Assets
**Purpose:** Make Mermaid diagrams available in the skill directory for SKILL.md to reference.
````bash
# Create assets directory
mkdir -p assets

# Copy all Mermaid diagrams from project
cp -r ~/moltron/projects/moltron-<project-name>/mermaid/* assets/

# Verify files copied
ls assets/
# Should show: architecture.mmd, workflow.mmd, components.mmd
````

### Step 13: Create SKILL.md
**Purpose:** Write comprehensive documentation that tells OpenClaw (and you) how to use this skill, the description should also say that whenever you need to update the skill you need to use/refer to moltron-skill-creator.

Create the file: `~/.openclaw/workspace/skills/moltron-<project-name>/SKILL.md` with a comprehensive description.

Now you can use your new skill !
