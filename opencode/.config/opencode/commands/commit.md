---
description: Analyze the changes and create a commit
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, Skill
---
You are an AI assistant tasked with preparing and executing a git commit. You MUST follow these steps in exact order. Do not skip ahead.

### Step 1: Pre-Commit Sanity Check
1. Check the current git status and diff to identify untracked or modified files.
2. Scan the list for potentially sensitive or generated files that usually shouldn't be committed. Specifically look for:
   - `node_modules/`
   - `bin/` and `obj/`
   - `.env` (NOTE: `.env.example` is safe and should be ignored by this warning).
3. **PAUSE:** If any of these unwanted files are detected, STOP and ask the user: *"I found potentially unwanted files ([list them]). Do you want to proceed anyways, or should I add them to .gitignore?"* Wait for the user's explicitly approved response before moving to Step 2.

### Step 2: Draft the Commit Message
1. Analyze all the approved changes that have been made.
2. DRAFT a commit message following the strict schema and rules below. Keep it in memory.

**Schema:**
`<type>[optional scope]: <description>`
` `
`[optional body]`

**Rules & Overrides:**
* **Type**: Use standard conventional commit types (e.g., feat, fix, chore, docs, refactor, test, build).
* **Description (Override)**: The first word of the description (immediately following the colon and space) MUST be capitalized and in the past tense.
* **Body Restriction**: ONLY include a body if the changes are highly complex and the single header line is strictly insufficient to explain the reasoning or scope. If the header is enough, omit the body entirely.
* **Style**: Keep the message concise. Avoid overly verbose descriptions or unnecessary details. Always write in proper English.

**Examples:**
* feat(client): Added routing
* fix: Fixed docker builds
* refactor(api): Extracted authentication logic

### Step 3: Format the Code
Before staging, ensure the codebase is formatted based on the project type:
* If it is a TypeScript/JavaScript project, run: `pnpm format`
* If it is a C# project, run: `dotnet format`
Wait for the formatting script to finish executing.

### Step 4: Stage and Commit
1. Stage all the files (including the newly formatted changes).
2. Commit the changes using the exact message you drafted in Step 2.
3. Verify that the commit was successful and output the final commit log.

### CRITICAL RULE
**NEVER PUSH the commit to the remote repository.**
