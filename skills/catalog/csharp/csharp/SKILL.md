---
name: csharp
description: Use for .NET 8+ C# apps: ASP.NET Core APIs, Blazor, EF Core, minimal APIs, async patterns, CQRS with MediatR, and Dapper.
---

# C# / .NET 8+

## When to Use This Skill

- Building ASP.NET Core APIs (Minimal or Controller-based)
- Implementing EF Core or Dapper data access
- Creating Blazor web applications (Server / WASM)
- Optimising .NET performance with `Span<T>`, `Memory<T>`, AOT
- Implementing CQRS with MediatR
- Setting up authentication / authorisation
- Redis or in-memory caching strategies

## Core Workflow

1. **Analyse solution** — Review `.csproj` files, NuGet packages, architecture
2. **Design models** — Domain models, DTOs, validation (FluentValidation)
3. **Implement** — Endpoints, repositories, services with DI
4. **Optimise** — Async patterns, caching, performance tuning
5. **Test** — xUnit + Moq unit tests, `WebApplicationFactory` integration tests, 80%+ coverage

---

## Project Structure (Clean Architecture)

```
src/
  MyApp.Api/          # Presentation: controllers/minimal API, middleware, DI wiring
  MyApp.Application/  # Use cases: commands, queries, handlers (MediatR)
  MyApp.Domain/       # Entities, value objects, domain events, interfaces
  MyApp.Infrastructure/ # EF Core, Dapper, Redis, external services
tests/
  MyApp.UnitTests/
  MyApp.IntegrationTests/
```

---

## Dependency Injection

```csharp
// Keyed services (.NET 8+)
builder.Services.AddKeyedSingleton<IPaymentProcessor, StripeProcessor>("stripe");
builder.Services.AddKeyedSingleton<IPaymentProcessor, PayPalProcessor>("paypal");

// Options pattern
builder.Services.Configure<DatabaseOptions>(
    builder.Configuration.GetSection("Database"));

// IOptionsSnapshot (per-request, supports reload)
// IOptionsMonitor (singleton, change callback)
public class UserService(IOptionsSnapshot<DatabaseOptions> options)
{
    private readonly DatabaseOptions _db = options.Value;
}
```

---

## Async / Await Patterns

```csharp
// Prefer ValueTask for hot paths that often complete synchronously
public ValueTask<User?> GetCachedUserAsync(int id, CancellationToken ct = default)
{
    return _cache.TryGetValue(id, out var user)
        ? ValueTask.FromResult<User?>(user)
        : new ValueTask<User?>(FetchFromDbAsync(id, ct));
}

// ConfigureAwait(false) in library / infrastructure code
public async Task<IReadOnlyList<Product>> GetProductsAsync(CancellationToken ct)
{
    await using var conn = await _dataSource.OpenConnectionAsync(ct).ConfigureAwait(false);
    return await conn.QueryAsync<Product>("SELECT * FROM products").ConfigureAwait(false);
}

// Parallel bounded work
public async Task ProcessOrdersAsync(IEnumerable<int> orderIds, CancellationToken ct)
{
    var options = new ParallelOptions { MaxDegreeOfParallelism = 4, CancellationToken = ct };
    await Parallel.ForEachAsync(orderIds, options, async (id, token) =>
    {
        await ProcessSingleOrderAsync(id, token);
    });
}

// Fan-out
var (users, products) = await (
    _userRepo.GetAllAsync(ct),
    _productRepo.GetAllAsync(ct)
).WhenAll();
```

---

## Result Pattern

Avoid exceptions for expected failures. Return explicit success/failure.

```csharp
// Domain/Result.cs
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    private Result(T value) { IsSuccess = true; Value = value; }
    private Result(string error) { IsSuccess = false; Error = error; }

    public static Result<T> Success(T value) => new(value);
    public static Result<T> Failure(string error) => new(error);
}

// Usage in a handler
public async Task<Result<OrderDto>> Handle(CreateOrderCommand cmd, CancellationToken ct)
{
    var customer = await _customerRepo.GetAsync(cmd.CustomerId, ct);
    if (customer is null)
        return Result<OrderDto>.Failure("Customer not found");

    if (!customer.IsEligible)
        return Result<OrderDto>.Failure("Customer account suspended");

    var order = Order.Create(customer, cmd.Items);
    await _orderRepo.AddAsync(order, ct);
    return Result<OrderDto>.Success(order.ToDto());
}

// In the endpoint
var result = await _mediator.Send(cmd, ct);
return result.IsSuccess
    ? Results.Created($"/orders/{result.Value!.Id}", result.Value)
    : Results.BadRequest(result.Error);
```

---

## Entity Framework Core

```csharp
// Separate entity configuration
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.HasKey(o => o.Id);
        builder.Property(o => o.Status)
            .HasConversion<string>()
            .HasMaxLength(20);
        builder.OwnsOne(o => o.ShippingAddress);
        builder.HasMany(o => o.Items)
            .WithOne()
            .HasForeignKey(i => i.OrderId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

// Load all configurations from assembly
protected override void OnModelCreating(ModelBuilder mb)
    => mb.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

// Read-only queries — always use AsNoTracking
public async Task<IReadOnlyList<ProductDto>> GetProductsAsync(CancellationToken ct)
    => await _context.Products
        .AsNoTracking()
        .Where(p => p.IsActive)
        .Select(p => new ProductDto(p.Id, p.Name, p.Price))
        .ToListAsync(ct);

// Bulk operations (.NET 7+ EF Core)
await _context.Products
    .Where(p => p.CategoryId == categoryId)
    .ExecuteUpdateAsync(s => s.SetProperty(p => p.IsActive, false), ct);
```

---

## Dapper

Use for complex read queries and reporting when EF Core query translation is poor.

```csharp
public async Task<IEnumerable<OrderSummary>> GetRecentAsync(
    int customerId, int limit, CancellationToken ct)
{
    await using var conn = await dataSource.OpenConnectionAsync(ct);
    return await conn.QueryAsync<OrderSummary>(
        "SELECT id, status, total, created_at FROM orders " +
        "WHERE customer_id = @CustomerId ORDER BY created_at DESC LIMIT @Limit",
        new { CustomerId = customerId, Limit = limit });
}
```

---

## Caching — Multi-Level

```csharp
// L1: IMemoryCache (in-process), L2: IDistributedCache via Redis

public async Task<User?> GetAsync(int id, CancellationToken ct)
{
    if (l1.TryGetValue(Key(id), out User? user)) return user;

    var bytes = await l2.GetAsync(Key(id), ct);
    if (bytes is not null)
    {
        user = JsonSerializer.Deserialize<User>(bytes)!;
        l1.Set(Key(id), user, TimeSpan.FromMinutes(1));
        return user;
    }

    user = await inner.GetAsync(id, ct);
    if (user is not null)
    {
        l1.Set(Key(id), user, TimeSpan.FromMinutes(1));
        await l2.SetAsync(Key(id), JsonSerializer.SerializeToUtf8Bytes(user),
            new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = opts.Value.L2Ttl }, ct);
    }
    return user;
}

public async Task InvalidateAsync(int id, CancellationToken ct)
{
    l1.Remove(Key(id));
    await l2.RemoveAsync(Key(id), ct);
}
```

---

## Testing

### Unit tests (xUnit + Moq)

```csharp
public class CreateOrderHandlerTests
{
    private readonly Mock<ICustomerRepository> _customerRepo = new();
    private readonly Mock<IOrderRepository> _orderRepo = new();
    private readonly CreateOrderHandler _handler;

    public CreateOrderHandlerTests()
        => _handler = new(_customerRepo.Object, _orderRepo.Object);

    [Fact]
    public async Task Handle_CustomerNotFound_ReturnsFailure()
    {
        _customerRepo.Setup(r => r.GetAsync(It.IsAny<int>(), default))
            .ReturnsAsync((Customer?)null);

        var result = await _handler.Handle(new CreateOrderCommand(99, []), default);

        Assert.False(result.IsSuccess);
        Assert.Equal("Customer not found", result.Error);
        _orderRepo.Verify(r => r.AddAsync(It.IsAny<Order>(), default), Times.Never);
    }
}
```

### Integration tests (WebApplicationFactory)

```csharp
public class OrdersApiTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client = factory.WithWebHostBuilder(builder =>
    {
        builder.ConfigureServices(services =>
        {
            // Replace EF Core with in-memory provider
            var descriptor = services.Single(d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            services.Remove(descriptor);
            services.AddDbContext<AppDbContext>(o => o.UseInMemoryDatabase("TestDb"));
        });
    }).CreateClient();

    [Fact]
    public async Task POST_CreateOrder_Returns201()
    {
        var response = await _client.PostAsJsonAsync("/orders", new
        {
            customerId = 1,
            items = new[] { new { productId = 10, qty = 2 } }
        });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }
}
```

---

## Constraints

### MUST DO
- Enable nullable reference types in all projects
- Use file-scoped namespaces and primary constructors (C# 12)
- Apply `async`/`await` for all I/O operations; pass `CancellationToken` through the call stack
- Use dependency injection for all services
- Include XML documentation for public APIs
- Implement the Result pattern for expected failures (not exceptions)
- Use strongly-typed configuration with `IOptions<T>` / `IOptionsSnapshot<T>`
- Use `AsNoTracking()` on all read-only EF Core queries
- Use `duplicate()` pattern (or separate read models) to avoid exposing EF entities in API responses

### MUST NOT DO
- Use blocking calls (`.Result`, `.Wait()`) in async code
- Disable nullable warnings without justification
- Skip `CancellationToken` support in async methods
- Expose EF Core entities directly in API responses
- Use string-based configuration keys
- Skip input validation
- Ignore code analysis warnings
- Use `HttpClient` directly — always use `IHttpClientFactory`
- Catch and swallow exceptions without logging

---

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| `async void` methods (fire-and-forget with no error handling) | Return `Task`; use `IHostedService` for background work |
| N+1 queries with EF Core | Use `Include()`/`ThenInclude()` or projection queries |
| `DateTime.Now` in tests | Inject `TimeProvider` (abstract; .NET 8) |
| `Task.Run` wrapping sync code to fake async | Remove `Task.Run`; expose as synchronous or fix the underlying I/O |
| Shared `HttpClient` instances causing socket exhaustion | Register via `AddHttpClient<T>()` |
| `new()` inside constructors for services | Inject via DI; enables testing and lifetime management |
| Missing `ConfigureAwait(false)` in library code | Prevents deadlocks in synchronisation-context-heavy hosts |

---
