---
description: Analyze the codebase and generate unit tests for a specified scope
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, Skill
---
You are an AI assistant tasked with generating comprehensive unit tests for a user-specified scope (e.g., specific classes, files, or folders). You MUST follow these steps in exact order. Do not skip ahead.

### Step 1: Environment & Framework Discovery
1. Identify the programming language of the target files (focusing primarily on C# or TypeScript/React).
2. Determine the existing testing framework and paradigms used in the project by scanning:
   - Configuration files (e.g., `package.json`, `.csproj`, `jest.config.js`, `vitest.config.ts`).
   - Existing test files (look for imports like `xunit`, `Moq`, `jest`, `vitest`, or `@testing-library/react`).
3. **PAUSE:** If you cannot confidently determine the testing framework or if there are conflicting testing libraries, STOP and ask the user: *"I couldn't definitively identify the testing framework (found [list findings]). Which framework should I use for these tests?"* Wait for the user's explicitly approved response before moving to Step 2.

### Step 2: Contract Analysis
1. Use the allowed tools to read and analyze the source code within the requested scope.
2. Identify the "contract" of the code:
   - Public methods, functions, and exposed properties.
   - Required inputs, optional parameters, and specific data types.
   - Expected return values, state changes, and potential thrown exceptions.
3. Map out the different scenarios that need testing, ensuring coverage for the "happy path," edge cases, and failure states.

### Step 3: Test Generation
1. Draft the tests based on the framework identified in Step 1 and the contracts analyzed in Step 2.
2. **Strict Naming Convention:** You MUST name every single test function or method using the following pattern: `MethodName_StateUnderContext_ExpectedBehavior` (often simplified as `Method_Scenario_Expected`). 
   - *Example (C#):* `public void CalculateTotal_EmptyCart_ReturnsZero()`
   - *Example (TS/JS):* `it('CalculateTotal_EmptyCart_ReturnsZero', () => { ... })`
3. Ensure each test contains clear Arrange, Act, and Assert (AAA) phases. Use mocking appropriately where external dependencies are present.

### Step 4: Write and Format
1. Write the generated tests to the appropriate test files. If creating new files, follow the project's existing naming convention (e.g., `[FileName].test.ts`, `[FileName]Tests.cs`).
2. If applicable, run the project's formatting script (e.g., `pnpm format` or `dotnet format`) to ensure the newly generated test files adhere to the codebase's style guidelines.

### CRITICAL RULE
**DO NOT modify the original source code files.** Your actions must be strictly limited to creating or updating test files. If you find a bug in the source code during analysis, document it in a comment within the test file or inform the user, but do not alter the implementation.
