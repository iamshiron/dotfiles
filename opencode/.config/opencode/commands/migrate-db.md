---
description: Analyze model changes, generate a name, and create an EFCore migration
allowed-tools: Read, Glob, Grep, Bash, Write, Task, Skill
---
You are an AI assistant tasked with preparing and generating an Entity Framework Core (EFCore) database migration. You MUST follow these steps in exact order. Do not skip ahead.

### Step 1: Identify the Target Environment
1. Scan the repository to locate the C# project containing the EFCore `DbContext`.
2. Identify the startup project (the entry point, typically an API or Web project) if it differs from the data layer project.
3. **PAUSE:** If multiple `DbContext` classes or multiple candidate projects are found, STOP and ask the user: *"I found multiple DbContexts/projects ([list them]). Which DbContext and target project should I use for this migration?"* Wait for the user's explicit response before moving to Step 2.

### Step 2: Analyze Changes Since Last Migration
1. Check the git status and diff specifically for changes in entity models, entity configurations, or the `DbContext` file itself.
2. Determine the core intent of these changes (e.g., adding a new table, modifying a column type, creating a relationship, or adding an index).

### Step 3: Draft the Migration Name
1. Based on the analysis in Step 2, generate a simple, highly descriptive migration name. Keep it in memory.

**Rules for Migration Names:**
* **Format**: MUST be strictly PascalCase.
* **Clarity**: Keep it concise but specific enough to immediately understand the schema change. Avoid generic names like `UpdateDatabase`.
* **Action-Oriented**: Start with a verb indicating the change.

**Examples:**
* `AddedUserProfileTable`
* `ModifiedOrderTotalColumn`
* `AddedIndexToUserEmail`

### Step 4: Execute the Migration Command
1. Run the `dotnet ef migrations add` command using the exact name drafted in Step 3.
2. Ensure you specify the correct `--project` and `--startup-project` flags based on the paths identified in Step 1.
   * Example: `dotnet ef migrations add <MigrationName> --project <Path/To/DataProject.csproj> --startup-project <Path/To/ApiProject.csproj>`
3. Verify that the build succeeded and the migration files were generated successfully. Output the final CLI log.

### CRITICAL RULE
**NEVER APPLY the migration to the database.** Do not run `dotnet ef database update` under any circumstances. Your sole responsibility is to generate the migration files.
