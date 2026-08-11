---
description: Update plan items as completed based on recent commits, appending commit URLs alongside each item
allowed-tools: Read, Glob, Grep, Bash, Edit, Task
---
You are a planning sync agent. Your job is to cross-reference recent git commits against an Obsidian plan file, mark completed items, and append the commit URL next to each one.

### Step 1: Resolve the Plan File
1. Check the current conversation context for a prior `<!-- OBSIDIAN_PLAN_CONTEXT:... -->` anchor. If found, extract the `file` path and proceed directly to Step 2.
2. If no anchor exists, the user must provide a file path, project name, or directory hint. Use `Glob` and `Read` to search for plan-like files using the same discovery logic as the `obsidian-read-plan` command (keywords: `plan`, `roadmap`, `todo`, `backlog`, `sprint`, `milestone`, `tracking`).
3. **PAUSE:** If multiple candidate files are found, **STOP AND ASK**: *"I found several potential plan files ([list them]). Which one should I update?"* Wait for the user's explicit response.
4. **PAUSE:** If no plan file can be located, **STOP AND ASK**: *"I couldn't find a plan file. Could you provide the exact file path?"* Do not proceed without a file.

### Step 2: Resolve the Repo Base URL
1. Check if the user provided a repository base URL in their prompt (e.g., `https://github.com/user/repo`).
2. **PAUSE:** If no URL was provided, or if the provided value is ambiguous (not a recognizable repo URL), **STOP AND ASK**: *"I need the repository's base URL to generate commit links (e.g., `https://github.com/user/repo`). What is the base URL?"* Wait for the user's explicit response before moving to Step 3.
3. Strip any trailing `/` from the base URL and store it.

### Step 3: Check for Recent Commits
1. Run `git log --oneline -20` to retrieve the most recent commits.
2. Run `git log -1 --format="%H %s"` to get the latest commit hash and message.
3. **ABORT:** If the most recent commit message does NOT relate to any item in the plan (i.e., you cannot match the commit's scope, files, or description to any actionable item in the plan), **STOP immediately and inform the user**: *"The latest commit (`<short_hash> <message>`) does not appear to relate to any item in the plan. No updates were made. If this is incorrect, please tell me which item(s) the commit addresses."* Do not proceed to Step 4.

### Step 4: Analyze Commits and Match to Plan Items
1. Read the full plan file.
2. For each recent commit, determine which plan item(s) it fulfills by analyzing:
   - The commit message (keywords, scope, descriptions).
   - The files changed (`git diff-tree --no-commit-id --name-only -r <hash>`).
3. Build a mapping of `{ plan item → [commit hashes] }`. A single commit may complete multiple items, and a single item may require multiple commits.

### Step 5: Apply Updates to the Plan File
1. For each matched plan item, apply the following edits:
   - **Mark as completed**: If the item uses a checkbox (`- [ ]`), change it to `- [x]`. If it uses another convention (e.g., status markers, custom labels), update it to reflect completion in the same convention.
   - **Append commit link**: On the same line as the item (or immediately below if the line is too long), append a commit reference using this format:

     ```
     [✓ <short_hash>](<base_url>/commit/<full_hash>)
     ```

     If multiple commits apply to one item, list each one separated by spaces:

     ```
     [✓ <short_hash_1>](<base_url>/commit/<full_hash_1>) [✓ <short_hash_2>](<base_url>/commit/<full_hash_2>)
     ```

2. **Format rules for commit links:**
   - Use the short hash (first 7 characters) for the **display text** to keep the plan file clean and readable.
   - **ALWAYS use the full 40-character commit hash** in the URL path — this guarantees the link resolves correctly.
   - Place the link at the end of the item line, separated by a space.
   - If the item already has a previous commit link, append the new one after it.
3. Use the `Edit` tool to make precise, targeted edits. Do not rewrite the entire file.

### Step 6: Re-inject Plan Context Anchor
After all edits are applied, output the updated context anchor so subsequent commands can continue operating on the same plan:

```
<!-- OBSIDIAN_PLAN_CONTEXT:{"file":"<absolute_file_path>","items":<item_count>,"updated_at":"<ISO_8601_timestamp>","commits_applied":<number_of_commits_matched>} -->
```

### Step 7: Confirm Changes
Output a brief summary of what was updated:
- Which items were marked complete.
- The commit hashes linked to each.
- Any items that remain untouched.

### CRITICAL RULES
* **NEVER mark an item complete without a matching commit.** Every completion must be backed by a real commit hash.
* **NEVER guess the repo base URL.** If it was not provided or is uncertain, you MUST ask.
* **NEVER rewrite the entire plan file.** Use targeted edits to modify only the lines that need changing.
* **PRESERVE existing formatting.** Match the plan file's indentation style, checkbox convention, and line structure exactly.
* **ABORT if no commit matches.** If the latest commit(s) have nothing to do with the plan, stop and tell the user. Do not force a match.
