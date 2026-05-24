# Coding Conventions
Always abide to these coding conventions.

## C# / .NET

### Naming

| Element | Convention | Do | Don't |
|---|---|---|---|
| Class | `PascalCase` | `RingBuffer`, `AuthService` | `ringBuffer`, `Auth_Service` |
| Abstract class | `PascalCase`, `Abstract` prefix or descriptive | `AbstractNode` | `BaseNode` (unless that's the name) |
| Interface | `IPascalCase` | `IPort`, `IAuthService` | `Port`, `IPORT` |
| Sealed class | `PascalCase`, `sealed` | `sealed class RingBuffer` | `class RingBuffer` (if not designed for inheritance) |
| Struct | `PascalCase`, prefer `readonly` | `readonly struct UUID` | `struct Uuid` |
| Record struct | `readonly record struct` | `readonly record struct Edge(...)` | `record struct Edge(...)` |
| Record class | `record class` | `record class NodeInstance(...)` | `record NodeInstance(...)` |
| Sealed record (DTOs) | `sealed record` | `sealed record AuthResponse(...)` | `record AuthResponse(...)` |
| Enum + members | `PascalCase` | `LogLevel`, `LogLevel.Warning` | `LOG_LEVEL`, `warning` |
| Type parameter | `TPascalCase` | `T`, `TValue`, `TEntity` | `TValue`, `TYPE` |
| Exception | `Exception` suffix | `PipelineCycleException` | `PipelineError` |
| Public property | `PascalCase` | `Capacity`, `CreatedAt` | `capacity`, `_capacity` |
| Private field | `_camelCase` | `_buffer`, `_dbContext` | `buffer`, `m_buffer` |
| Constant | `PascalCase` | `TickFrequency` | `TICK_FREQUENCY` |
| Parameter / local | `camelCase` | `options`, `result` | `Options`, `_result` |
| Async method | `Async` suffix | `ExecuteAsync()` | `ExecuteAsync` on sync, `Execute()` on async |
| Boolean method | `Try`/`Is`/`Has`/`Should` prefix | `TryRead()`, `HasValue()` | `ReadBool()` |
| DbSet | `PascalCase` plural | `Users`, `Characters` | `UserList`, `userSet` |
| Delegate | Prefer `Func`/`Action` | `Func<int, bool>` | `delegate bool Filter(int i);` |
| Generic constraint | `where T :` | `where T : notnull` | omitting constraints |

### Constraints

**Avoid boxing at all cost in hot paths.** Before allowing boxing, analyze where it occurs and how frequently:

- **Startup / one-time:** Fine — boxing is acceptable.
- **Loop / hot-path / general runtime:** Avoid it. Use generics, `Span<T>`, `stackalloc`, or other zero-alloc alternatives.

### Language Features (.NET 10 / C# 12+)

**File-scoped namespaces** — always, never block-scoped:
```csharp
// Do
namespace Shiron.Lib.Collections;

// Don't
namespace Shiron.Lib.Collections { ... }
```

**Primary constructors** — use by default to capture parameters into fields/properties. Quick field initialization is fine, but keep all constructor logic minimal — only what's needed to set up fields.

```csharp
// Do
public class Throttler(long intervalMS) { ... }
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options) { ... }
public class Renderer(string format) {
    private readonly string _normalized = format.ToUpperInvariant(); // fine
}

// Don't — avoid heavy logic in constructors
public class Scheduler {
    public Scheduler() {
        _thread = new Thread(Run);
        _thread.Start();
        InitializeSubsystems();
        LoadConfiguration();
    }
}
```

**Guard clauses** over nested conditionals. Return early to keep the happy path flat:

```csharp
// Do
public void Process(Order? order) {
    if (order is null) throw new ArgumentNullException(nameof(order));
    if (order.Items.Count == 0) return;
    if (!order.IsPaid) {
        NotifyUnpaid(order);
        return;
    }
    Ship(order);
}

// Don't
public void Process(Order? order) {
    if (order is not null) {
        if (order.Items.Count > 0) {
            if (order.IsPaid) {
                Ship(order);
            } else {
                NotifyUnpaid(order);
            }
        }
    }
}
```

**Pattern matching** — use switch expressions extensively:
```csharp
return status switch {
    true when success => State.Done,
    true => State.Failed,
    false => State.Skipped
};
```

**`with` expressions** for record copies:
```csharp
var updated = payload with { Header = payload.Header with { Id = newId } };
```

**`required` keyword** for mandatory entity properties:
```csharp
public required string DiscordId { get; set; }
```

**Collection expressions** for initialization:
```csharp
public ICollection<Item> Items { get; set; } = [];
```

**`in` modifier** to pass structs by readonly reference:
```csharp
public void Log<T>(in LogPayload<T> payload) where T : notnull { ... }
```

**`out` parameters** for contextual returns:
```csharp
public void Info(string message, out ContextualLogger logger) { ... }
```

**Sealed classes** — concrete types not designed for inheritance:
```csharp
public sealed class RingBuffer : IRingBuffer { ... }
```

**`InternalsVisibleTo`** — expose internals to test projects:
```csharp
[assembly: InternalsVisibleTo("MyLib.Tests")]
```

---

## Project Structure

### Solution

- Always use `.slnx` format (XML-based), never `.sln`.

### Layout Patterns

**Library project:**
```
src/<Module>/          # Source
tests/<Module>/        # Tests
samples/<Module>/      # Samples (optional)
benchmarks/<Module>/   # Benchmarks (optional)
```

**Backend API project:**
```
backend/src/<Domain>.API/     # Web API host
backend/src/<Domain>.DB/      # Database layer
backend/src/<Domain>.CLI/      # Optional CLI
backend/tests/<Domain>.Tests/ # Tests
```

**Extension library:**
```
src/<Module>.Ext.<Feature>/   # e.g., Pipeline.Ext.DI
```

### Namespaces

Pattern: `<Root>.<Domain>.<Layer>[.<SubFolder>]` — mirrors folder hierarchy exactly.

| Folder | Namespace |
|---|---|
| `<Domain>.API/` | `<Root>.<Domain>.API` |
| `<Domain>.API/Endpoints/` | `<Root>.<Domain>.API.Endpoints` |
| `<Domain>.API/Services/` | `<Root>.<Domain>.API.Services` |
| `<Domain>.API/Services/Impl/` | `<Root>.<Domain>.API.Services.Impl` |
| `<Domain>.DB/Schema/` | `<Root>.<Domain>.DB.Schema` |
| `<Module>.Ext.<Feature>/` | `<Root>.<Module>.Ext.<Feature>` |

Subfolder names are `PascalCase`.

### File Naming

| Artifact | Convention | Do | Don't |
|---|---|---|---|
| C# file | Matches type name exactly | `RingBuffer.cs` → `class RingBuffer` | `ring_buffer.cs` |
| One type per file | File name = type name | `IPort.cs` → `interface IPort` | multiple types in one file |
| DTO file | `<Domain>DTOs.cs` (grouped) | `AuthDTOs.cs` | `AuthResponse.cs` (for a single small DTO) |
| Endpoint file | `<Name>Endpoints.cs` | `AuthEndpoints.cs` | `Auth.cs` |
| Service interface | `I<Name>Service.cs` or `I<Name>.cs` | `IStorageService.cs` | `StorageServiceInterface.cs` |
| Service impl | `<Name>Service.cs` or `<Name>.cs` | `MinioStorageService.cs` | `MinioStorageServiceImpl.cs` |
| DbContext | `<Domain>DbContext.cs` | `AppDbContext.cs` | `DbContext.cs` |
| Options | `<Name>Options.cs` | `StorageOptions.cs` | `StorageConfig.cs` |
| Test file | `<ClassName>Tests.cs` | `RingBufferTests.cs` | `RingBufferTest.cs` |
| CLI command | `<Name>Command.cs` | `RecordCommand.cs` | `Record.cs` |

### .csproj Conventions

**All projects:**
```xml
<TargetFramework>net10.0</TargetFramework>
<Nullable>enable</Nullable>
<ImplicitUsings>enable</ImplicitUsings>
```

**Library:** `Microsoft.NET.Sdk`
**Web API:** `Microsoft.NET.Sdk.Web` + `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`
**Test:** `IsPackable=false`, `IsTestProject=true`, `TreatWarningsAsErrors=true`
**Sample/Benchmark/CLI:** `<OutputType>Exe</OutputType>`

Package references never include `Version` — managed centrally in `Directory.Packages.props`.

Project references use relative paths.

---

## Backend / Web API

### Minimal APIs

No controllers. Endpoints are `public static` classes with extension methods.

```csharp
// Do
namespace My.API.Endpoints;

public static class AuthEndpoints {
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app) {
        var group = app.MapGroup("/api/auth").WithTags("Authentication");

        group.MapGet("/discord", (IAuthService authService) => {
            // handler
        });
    }
}

// Don't — no controllers
[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase { ... }
```

### Program.cs Order

1. Environment loading
2. `WebApplication.CreateBuilder(args)`
3. `AddDbContext`
4. `Configure<TOptions>`
5. Service registration (`AddScoped<IService, Service>()`)
6. Auth setup
7. `AddOpenApi`
8. JSON options
9. CORS
10. `builder.Build()`
11. OpenAPI UI (dev only)
12. Middleware (`UseCors`, `UseAuthentication`, `UseAuthorization`)
13. Endpoint mapping
14. DB migration on startup
15. `app.Run()`

### Data Layer (EF Core)

- **Database:** PostgreSQL via Npgsql
- **ORM:** EF Core 10.0, code-first, migrations
- **IDs:** `Guid.CreateVersion7()`
- **Fluent API:** inline in `OnModelCreating` — no separate `IEntityTypeConfiguration<T>`

```csharp
// Do — base entity
public abstract class BaseEntity {
    public Guid Id { get; set; } = Guid.CreateVersion7();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

// Do — primary constructor DbContext
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options) { ... }

// Do — required properties, collection expressions
public required string Name { get; set; }
public ICollection<Item> Items { get; set; } = [];
```

### Service Pattern

- Interfaces in `Services/`, implementations in `Services/Impl/`
- Register via DI: `builder.Services.AddScoped<IService, Service>()`
- Hosted services: `AddHostedService<T>()`

### DTOs

`sealed record` types, grouped by domain in one file:

```csharp
// Do
public sealed record AuthResponse(string AccessToken, string RefreshToken, int ExpiresIn, UserDto User);
public sealed record UserDto(Guid Id, string Username, string? AvatarUrl);

// Don't
public class AuthResponse { ... }
public record AuthResponse(...) { ... }  // not sealed
```

### Plugin System

```csharp
public abstract class Plugin(string group, string name, string version) {
    public abstract void Initialize();
    public abstract void Dispose();
}
```

### API Docs

OpenAPI + Scalar UI (dev only):
```csharp
app.MapScalarApiReference(options => {
    options.Title = "My API";
    options.Theme = ScalarTheme.Purple;
});
```

---

## Frontend (TypeScript / React)

### Constraints

- **ALWAYS use `pnpm`** (and `pnpx` / `pnpm dlx`) for all JS/TS operations — never `npm` or `yarn` unless explicitly instructed.
- **NEVER write JavaScript.** Always write fully typed TypeScript with strict types. If you hit a circular or unresolvable type situation where `any` seems necessary, **stop and ask the user** before using it.

### TS Config (base)

```json
{
    "strict": true,
    "noImplicitOverride": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "noFallthroughCasesInSwitch": true,
    "isolatedModules": true,
    "composite": true
}
```

### App Structure

```
apps/<domain>-web/
├── src/
│   ├── api/          # Generated API client (Orval)
│   ├── components/   # React components
│   ├── hooks/        # Custom hooks
│   ├── lib/          # Utilities
│   ├── routes/       # TanStack Router files
│   ├── styles/       # CSS
│   ├── types/        # TypeScript types
│   └── main.tsx
├── biome.json
├── components.json   # shadcn/ui
├── orval.config.ts
├── vite.config.ts
└── tsconfig.json
```

### Tech Stack

React 19, Vite, TypeScript 5.7+, TanStack Router + Query, Orval + native fetch, Tailwind CSS v4, shadcn/ui + Radix UI, Biome, pnpm, Nx.

### Package Scope

`@<scope>/<name>`, referenced via `"workspace:*"` for internal packages.

App folders: `kebab-case`. Source subfolders: `lowercase`.

---

## Testing

### Framework

xUnit + `[Fact]`. FluentAssertions for backend. `coverlet` for coverage. Testcontainers for integration.

### Structure

```
tests/<Module>/
├── <Module>.Tests.csproj
├── <Class>Tests.cs
└── Data/              # Test data (optional)
```

### Naming

| Element | Convention | Do | Don't |
|---|---|---|---|
| Test class | `<ClassName>Tests` | `RingBufferTests` | `RingBufferTest`, `Tests` |
| Test method | `Method_Scenario_Expected` | `ParseCollection_Valid_ReturnsItems` | `TestParse` |

One test class per source class.

### Helpers

Private nested classes for mocks/fixtures inside the test class:
```csharp
public class RingBufferTests {
    private class TestValidator<T> : IValidator<T> { ... }
}
```

### Assertions

```csharp
// Backend — FluentAssertions
result.Should().HaveCount(3);
result[0].Name.Should().Be("expected");

// Library — xUnit asserts
Assert.Equal(expected, actual);
Assert.True(condition, "message");
Assert.Throws<ArgumentException>(action);
```

### Test data

Place in `Data/` subfolder, mark as copy-to-output:
```xml
<None Update="Data\**\*">
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
</None>
```

---

## Performance (.NET Library)

| Pattern | Use When | Example |
|---|---|---|
| `AggressiveInlining` | Hot paths | `[MethodImpl(MethodImplOptions.AggressiveInlining)]` |
| `ArrayPool<T>` | Temp arrays | `ArrayPool<double>.Shared.Rent(count)` + `Return` in `finally` |
| `Span<T>` / `stackalloc` | Small buffers | `Span<byte> buf = stackalloc byte[16];` |
| Volatile snapshot arrays | Lock-free reads | `volatile T[] _snapshot` + `lock` for writes, iterate snapshot for reads |
| `ISpanFormattable` | Allocation-free formatting | Implement `TryFormat` on structs |
| `string.Create` | Allocation-free string building | `string.Create(length, state, static (span, s) => ...)` |
| `ConcurrentDictionary`/`ConcurrentBag` | Thread-safe collections | Instead of `lock` + `Dictionary` |
| `AsyncLocal<T>` | Flow-aware context | Across async boundaries |
| `ValueTask<bool>` | Sync+async hybrid | Avoid `Task` allocation on sync completions |

---

## Benchmarks

- **BenchmarkDotNet**, console apps
- One project per module in `benchmarks/<Module>/`
- `benchmarks/All/` aggregates all by referencing them
- Results in `BENCHMARKS.md`

---

## Documentation

- XML doc comments (`///`) on **all public APIs**
- `<inheritdoc/>` on interface implementations
- Single-line summaries OK: `/// <summary>Short description.</summary>`
- DocFX for API docs
- OpenAPI + Scalar for REST API docs
- `README.md` for project overview, `BENCHMARKS.md` for perf results

```csharp
// Do
/// <summary>
/// Provides throttling with a configurable interval.
/// </summary>
/// <param name="intervalMS">Minimum interval in milliseconds.</param>
/// <returns>True if the action is allowed.</returns>
public bool TryExecute(int intervalMS) { ... }

/// <inheritdoc/>
public int Count => _count;

// Don't — no docs on public APIs
public bool TryExecute(int intervalMS) { ... }
```

---

## Package Management

### Adding Packages

Always run the package manager to pull in packages — never hardcode versions manually. This ensures the latest version is resolved.

```bash
# .NET
dotnet add package <PackageName>

# Frontend
pnpm add <package-name>
```

**NEVER** delete or modify lock files (`pnpm-lock.yaml`, `packages.lock.json`) without asking the user first.

### NuGet

**Central Package Management** in `Directory.Packages.props`. All versions declared centrally. `.csproj` files never include `Version`.

```xml
// Do — Directory.Packages.props
<PackageVersion Include="xunit" Version="2.9.3" />

// Do — .csproj
<PackageReference Include="xunit"/>

// Don't
<PackageReference Include="xunit" Version="2.9.3"/>
```

Never use `packages.config`.

### pnpm (Frontend)

Workspace in `pnpm-workspace.yaml`. Internal packages via `"workspace:*"`.

---

## Infrastructure

### Docker Compose

In `docker/`. Services typically include PostgreSQL, object storage (MinIO), admin UI.

Bucket policies: public read for assets, private for user data.

### Environment Variables

Pattern: `<DOMAIN>_<CONCERN>_<SETTING>`

```
MUTILS_MINIO_ENDPOINT
MUTILS_JWT_SECRET
POSTGRES_DB
```

`.env` (gitignored) + `.env.example` as template. Loaded via `DotNetEnv`.

---

## Git

### Branches

| Pattern | Example | Purpose |
|---|---|---|
| `main` | `main` | Stable |
| `feature_<scope>_<detail>` | `feature_pipeline_di` | Features |
| `<scope>_types` | `pipeline_types` | Exploration |

### Workflow

Always build and test before pushing. Run locally:

```bash
dotnet build --configuration Release
dotnet test --configuration Release --verbosity minimal
```

### Gitignore

`bin/`, `obj/`, `.vscode/`, `.idea/`, `BenchmarkDotNet.Artifacts/`, log files, profile data.

### Attributes

`* text=auto eol=lf` — LF everywhere. C# files: `diff=csharp`.

---

## Build & CI

### SDK

Defined in `global.json` with `rollForward` and `allowPrerelease`.

### Commands

```bash
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release --verbosity minimal
```

### CI (GitHub Actions)

- **Build+Test:** `restore` → `build Release` → `test Release`. Cross-platform on main branch.
- **Quality gate:** `build /p:TreatWarningsAsErrors=true`. No tests.

### Root Scripts

`lint`, `format`, `build`, `dev`, `migrate`, `clean` — all via `nx run-many`.

---

## Tooling

| Tool | Config File | Scope |
|---|---|---|
| .NET | `.slnx` | Solution |
| Nx | `nx.json` | Monorepo |
| pnpm | `pnpm-workspace.yaml` | Frontend packages |
| NuGet CPM | `Directory.Packages.props` | Package versions |
| Editor | `.editorconfig` | C# + general formatting |
| Biome | `biome.json` | JS/TS lint + format |
| TypeScript | `tsconfig.base.json` | TS config |
| Docker | `docker/docker-compose.yml` | Local infra |
| DocFX | `docs/docfx.json` | API docs |
| mise | `mise.toml` | Tool versions |

Nx plugins: `@nx/js/typescript`, `@nx/dotnet`, `@nx/vite`.
