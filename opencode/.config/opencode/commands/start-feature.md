---

description: Start a new feature branch
allowed-tools: Read, Glob, Grep, Bash, Task, Skill
--------------------------------------------------

You are an AI assistant tasked with starting a new feature branch. You MUST follow these steps in exact order and MUST NOT make assumptions about ambiguous repository state or user intent.

### Step 1: Determine the Feature Name

Determine the intended feature from the user's request.

Feature branches MUST follow this format:

`feat/<feature-name>`

Where `<feature-name>`:

* MUST use `kebab-case`.
* MUST be concise and descriptive.
* MUST contain only lowercase words separated by hyphens.

Examples:

* `feat/user-authentication`
* `feat/project-search`
* `feat/release-management`

If the feature name is clearly implied by the user's request, use it.

If the user is brainstorming, provides several loosely connected ideas, or the feature name is otherwise unclear:

**PAUSE:** Give exactly 5 DIFFERENT feature name suggestions that satisfy their requirements.

Show the complete branch name for each suggestion.

Do NOT create anything until the user chooses or provides a feature name.

### Step 2: Determine Where to Create the Feature

A feature may be created either:

* In the current working directory.
* In a new git worktree.

Infer this only when the user's request is explicit.

Examples:

* "Start a feature here" → current directory.
* "Create a worktree for this feature" → worktree.

If you are NOT certain which mode the user wants:

**PAUSE:** Ask whether they want to create the feature in the current directory or in a worktree.

If the user chooses a worktree but has not specified where it should be created:

**PAUSE:** Ask the user for the desired worktree path.

Do NOT invent a worktree location.

### Step 3: Inspect Repository State

Before creating anything:

1. Check the current git branch.
2. Check the working tree status.
3. Check whether `dev` exists.
4. Check whether `main` exists.
5. Check whether a remote is configured.
6. If a remote exists, fetch the latest branch information without modifying local branches.
7. Compare:

   * Local `dev`
   * Remote `dev`, if available
   * Local `main`
   * Remote `main`, if available

The feature MUST ultimately branch from `dev`.

### Step 4: Validate `dev`

Do NOT modify repository state until all issues below have been resolved.

#### Current Branch Is Not `dev`

If the current branch is not `dev`:

**PAUSE:** Tell the user which branch they are currently on and ask how they want to proceed.

Do NOT automatically switch branches.

#### Uncommitted Changes

If there are uncommitted changes that would be affected by switching branches or creating the feature:

**PAUSE:** Report the changes and ask the user how they want to handle them.

Do NOT automatically commit, stash, discard, or move changes.

#### `dev` Is Behind `main`

If `dev` is behind `main`:

**PAUSE:** Tell the user that `dev` is behind `main` and ask whether they want to merge `main` into `dev` first.

Do NOT merge automatically.

#### `dev` Has Pending Changes Not on `main`

If `dev` contains uncommitted changes:

**PAUSE:** Report the pending changes and ask whether the user wants to commit them first.

Do NOT automatically commit them.

If `dev` contains commits that are not on `main`, report this state when relevant, but do not treat committed `dev` work as an error by itself.

#### Local `dev` Is Behind Remote `dev`

If a configured remote has a newer `dev` branch than the local repository:

**PAUSE:** Tell the user that local `dev` is behind the remote and ask whether they want to update it first.

Do NOT pull automatically.

#### Other Ambiguous States

If the repository state makes it unclear whether `dev` is the correct and current base:

**PAUSE:** Explain the exact state and ask the user how they want to proceed.

Make NO assumptions.

### Step 5: Create the Feature

Only continue once:

* The feature name is confirmed.
* The creation mode is confirmed.
* `dev` is the confirmed base branch.
* All relevant repository-state issues have been resolved.

#### Current Directory

If creating the feature in the current directory:

1. Ensure the current branch is `dev`.
2. Create and switch to:

   `feat/<feature-name>`

The branch MUST be created directly from the current `dev` commit.

#### Worktree

If creating the feature in a worktree:

1. Leave the existing working directory unchanged unless explicitly required by the user.
2. Create:

   `feat/<feature-name>`

   directly from `dev`.
3. Create the new worktree at the user-confirmed path using that branch.

Do NOT create the feature from `main`, the current branch, `HEAD`, or any other branch when that would differ from `dev`.

### Step 6: Remote Branch

If no git remote is configured, skip this step and report that no remote is available.

If a remote is configured:

* If the user already explicitly requested that the new feature branch be pushed, push it and configure its upstream without asking again.
* Otherwise:

**PAUSE:** Ask the user whether they want to push `feat/<feature-name>` to the remote now.

If approved, push the branch and configure its upstream tracking branch.

Do NOT push unrelated branches.

### Step 7: Report Status

After completing the requested operations, report:

* Feature branch name
* Base branch and commit
* Whether it was created in the current directory or a worktree
* Worktree path, if applicable
* Current branch in the affected working directory
* Remote
* Whether the feature branch was pushed
* Upstream branch, if configured

### CRITICAL RULES

* ALWAYS branch from `dev`.
* NEVER branch from `main` directly.
* NEVER guess whether the user wants the current directory or a worktree.
* NEVER invent a worktree path.
* NEVER guess an unclear feature name.
* Feature names MUST use `kebab-case`.
* Feature branches MUST use `feat/<feature-name>`.
* NEVER automatically switch away from a non-`dev` branch when the user's intent is unclear.
* NEVER automatically commit, stash, discard, or otherwise modify pending changes.
* NEVER automatically merge `main` into `dev`.
* NEVER automatically update a stale local `dev`.
* NEVER push unless the user explicitly requested it or explicitly confirms when asked.
* NEVER ask a question again when the user's earlier request has already clearly answered it.
