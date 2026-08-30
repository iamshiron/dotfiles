---

description: Validate the project and create a new release
allowed-tools: Read, Glob, Grep, Bash, Task, Skill
--------------------------------------------------

You are an AI assistant tasked with validating a project and creating a new git release. You MUST follow these steps in exact order. Do not skip ahead.

### Step 1: Determine the Release Version

1. Inspect the repository for an explicitly defined release version, including:

   * Existing version files or project metadata.
   * Existing git tags.
   * Any version explicitly provided by the user in the current conversation.
2. The release version MUST use the format:
   `v<Major>.<Minor>.<Patch>`
3. You may only continue if you know the intended version with 100% certainty.

**PAUSE:** If the intended release version cannot be determined with 100% certainty, STOP and ask the user:

*"What version should I release? Please provide it in the format `vMajor.Minor.Patch`."*

Wait for the user's explicit response before continuing.

### Step 2: Pre-Release Sanity Checks

Perform all checks without modifying the repository.

#### Git

1. Check the current git status.
2. Verify that the working tree is clean.
3. Verify that the following branches exist:

   * `dev`
   * `main`
4. Verify that a remote repository is configured.
5. Fetch the latest remote state and tags without modifying local branches.
6. Verify that the release tag does not already exist locally or remotely:

   * `v<Major>.<Minor>.<Patch>`
7. Verify that the release branch does not already exist locally or remotely:

   * `rel/v<Major>.<Minor>.<Patch>`

#### Ignored / Generated Files

Inspect the repository and `.gitignore` files for generated, sensitive, or dependency files that should normally not be committed.

Pay particular attention to:

* `node_modules/`
* `bin/`
* `obj/`
* `.env`
* IDE-generated files
* build artifacts
* temporary files
* generated package outputs

`.env.example` is safe and MUST NOT be reported as a sensitive `.env` file.

Report any suspicious tracked files or missing ignore rules.

#### License

Search the repository root and relevant project metadata for licensing information.

Look for common files such as:

* `LICENSE`
* `LICENSE.md`
* `LICENSE.txt`
* `COPYING`

Also inspect project/package metadata where appropriate.

You MUST report:

* Every license you found.
* Where each license was found.
* If no license can be identified, explicitly state that no license was found.

Do NOT assume a license based only on repository visibility or conventions.

#### Build

Determine the project type and run the appropriate build process.

Examples:

* C#: `dotnet build`
* TypeScript/JavaScript: use the project's configured package manager and build script

Prefer the build commands already defined by the repository.

#### Tests

Run the project's complete test suite using the repository's configured test commands.

Examples:

* C#: `dotnet test`
* TypeScript/JavaScript: use the configured test script

Do not ignore failing tests.

### Step 3: Report Findings

After completing the sanity checks, report the results to the user.

The report MUST include:

* Release version
* Git status
* Build result
* Test result
* Ignore-file findings
* License findings
* Whether the release tag already exists
* Whether the release branch already exists
* Any other issue that could make the release unsafe

Explicitly report build errors and test failures.

If no license was found, explicitly say so.

Do NOT create branches, merge branches, create tags, or push anything yet.

### Step 4: User Confirmation

**PAUSE:** Always STOP after reporting the findings and ask the user:

*"Do you want me to proceed with releasing `v<Major>.<Minor>.<Patch>`?"*

Wait for explicit user confirmation.

Do not interpret silence, unrelated responses, or ambiguous responses as approval.

### Step 5: Prepare the Release

Only continue after explicit approval.

1. Ensure the working tree is still clean.
2. Switch to `dev`.
3. Pull the latest `dev` from the configured remote using fast-forward-only behavior.
4. Switch to `main`.
5. Pull the latest `main` from the configured remote using fast-forward-only behavior.
6. Merge `dev` into `main`.

If the merge results in conflicts:

**PAUSE:** STOP immediately and report the conflicts to the user. Do not attempt to resolve them automatically unless explicitly instructed.

7. Create the release branch from the resulting `main`:
   `rel/v<Major>.<Minor>.<Patch>`
8. Create the release tag:
   `v<Major>.<Minor>.<Patch>`

The tag MUST point to the release commit on `main`.

### Step 6: Push the Release

Push all release-related references to the configured remote:

1. Push `main`.
2. Push `dev`.
3. Push:
   `rel/v<Major>.<Minor>.<Patch>`
4. Push:
   `v<Major>.<Minor>.<Patch>`

Do not force-push.

### Step 7: Verify the Release

Verify that all of the following exist on the remote and point to the expected commits:

* `main`
* `dev`
* `rel/v<Major>.<Minor>.<Patch>`
* `v<Major>.<Minor>.<Patch>`

Then output a concise final release summary containing:

* Released version
* Release commit hash
* Release branch
* Tag
* Remote
* Build result
* Test result
* License

### CRITICAL RULES

* NEVER guess the release version.
* NEVER continue if the version is not known with 100% certainty.
* NEVER perform release mutations before the user explicitly confirms the sanity-check report.
* NEVER continue after build failures or test failures without explicitly reporting them to the user first.
* NEVER hide or omit licensing information.
* NEVER claim that a license exists if none could be identified.
* NEVER force-push.
* NEVER automatically resolve merge conflicts.
* NEVER overwrite an existing release tag or release branch.
* NEVER create a release tag with a format other than `vMajor.Minor.Patch`.
* The release branch MUST use `rel/vMajor.Minor.Patch`.
