---

description: Finish the current feature and merge it into dev
allowed-tools: Read, Glob, Grep, Bash, Task, Skill
--------------------------------------------------

You are an AI assistant tasked with finishing a feature branch. You MUST follow these steps in exact order.

### Step 1: Determine the Feature Branch

Check the current branch.

Feature branches MUST follow:

`feat/<feature-name>`

If the current branch is a feature branch, use it.

If the current branch is NOT a feature branch:

**PAUSE:** Report the current branch and ask the user which `feat/*` branch they want to finish.

Do NOT guess the feature branch.

### Step 2: Pre-Merge Sanity Checks

Perform the following checks before modifying repository history.

#### Working Tree

Check the git status.

There MUST be no pending changes, including:

* Modified files
* Staged but uncommitted files
* Untracked files

If any pending changes exist:

**PAUSE:** Report them and ask the user how they want to proceed.

Do NOT automatically commit, stash, discard, or ignore changes.

#### Repository State

1. Verify that `dev` exists.
2. Verify that the feature branch exists.
3. Check whether a remote is configured.
4. If a remote exists, fetch the latest branch information without modifying local branches.
5. Check whether local `dev` is behind its remote counterpart.
6. Check whether the feature branch is behind its remote counterpart.

If either local branch is behind its remote branch:

**PAUSE:** Report the exact state and ask the user how they want to proceed.

Do NOT pull or rebase automatically.

### Step 3: Build and Test

Run the project's normal build and test commands.

Prefer commands already configured by the repository.

Examples:

* C#:

  * `dotnet build`
  * `dotnet test`
* TypeScript/JavaScript:

  * Use the configured package-manager build and test scripts.

If the build fails or tests fail:

**PAUSE:** Report the failures and ask the user whether they want to resolve them before finishing the feature.

Do NOT merge the feature while known build or test failures remain unless the user explicitly instructs you to proceed.

### Step 4: Merge the Feature

Only continue once all required sanity checks are satisfied.

1. Remember the feature branch:
   `feat/<feature-name>`
2. Switch to `dev`.
3. Merge the feature branch into `dev` using a merge commit.

The merge MUST create an explicit merge commit even when a fast-forward merge would be possible.

Use behavior equivalent to:

`git merge --no-ff feat/<feature-name>`

If the merge produces conflicts:

**PAUSE:** STOP immediately and report the conflicting files.

Do NOT resolve merge conflicts automatically unless explicitly instructed.

### Step 5: Push

If no remote is configured, skip pushing and report that no remote exists.

If a remote exists:

1. Push `dev`.
2. Push the feature branch:
   `feat/<feature-name>`

Ensure both remote branches contain their latest local state.

Do NOT force-push.

### Step 6: Verify

Verify the final repository state.

Report:

* Feature branch
* Feature commit before merge
* `dev` merge commit
* Build result
* Test result
* Whether `dev` was pushed
* Whether the feature branch was pushed
* Remote used

### CRITICAL RULES

* ALWAYS merge the feature into `dev`.
* NEVER merge the feature into `main`.
* NEVER modify `main`.
* ALWAYS create an explicit merge commit using non-fast-forward merge behavior.
* NEVER finish a feature with pending working-tree changes.
* NEVER automatically commit, stash, discard, or ignore pending changes.
* NEVER guess which feature branch should be finished.
* NEVER automatically pull, rebase, or overwrite remote changes.
* NEVER automatically resolve merge conflicts.
* NEVER force-push.
* Push BOTH `dev` and the feature branch when a remote is configured.
