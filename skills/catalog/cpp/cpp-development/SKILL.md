---
name: cpp-development
description: Use when writing, reviewing, or refactoring C++ code — covers workflow, essential patterns, and pre-commit checklist for modern C++17/20.
---

# C++ Development

## Workflow

1. **Analyze** — Review build system, compiler flags (`-Wall -Wextra -Wpedantic`), and C++ standard version
2. **Design with concepts** — Define type-safe interfaces using C++20 concepts before implementation
3. **Implement zero-cost** — Apply RAII, `constexpr`, smart pointers, and zero-overhead abstractions
4. **Verify** — Run AddressSanitizer (`-fsanitize=address`) and UBSan (`-fsanitize=undefined`); run static analysis
5. **Optimize** — Profile first (`perf`, `valgrind --tool=callgrind`); measure before and after any change

## Essential Patterns

### Rule of Zero
Let the compiler generate all special members. Compose from types that already manage their own resources.

```cpp
// GOOD: Rule of Zero — compiler generates correct copy/move/destructor
struct Employee {
    std::string name;
    std::string department;
    int id{0};
    // No destructor, no copy/move needed
};
```

### Rule of Five
If you manage a raw resource directly, define (or `=delete`) all five special members.

```cpp
// Rule of Five: owning a raw resource via unique_ptr handles it cleanly
class Buffer {
public:
    explicit Buffer(std::size_t n)
        : data_{std::make_unique<char[]>(n)}, size_{n} {}

    ~Buffer() = default;
    Buffer(Buffer&&) noexcept = default;
    Buffer& operator=(Buffer&&) noexcept = default;

    Buffer(const Buffer& o)
        : data_{std::make_unique<char[]>(o.size_)}, size_{o.size_} {
        std::copy_n(o.data_.get(), size_, data_.get());
    }
    Buffer& operator=(const Buffer& o) {
        if (this != &o) {
            auto nd = std::make_unique<char[]>(o.size_);
            std::copy_n(o.data_.get(), o.size_, nd.get());
            data_ = std::move(nd);
            size_ = o.size_;
        }
        return *this;
    }

private:
    std::unique_ptr<char[]> data_;
    std::size_t size_;
};
```

### Parameter Passing

```cpp
void print(int x);                      // cheap (≤ pointer size): by value
void analyze(const std::string& data);  // expensive, read-only: const&
void consume(std::string s);            // sink (will move/store): by value
```

### Smart Pointers

```cpp
auto widget = std::make_unique<Widget>("cfg");  // default: unique ownership
auto cache  = std::make_shared<Cache>(1024);    // shared ownership only when needed
void render(const Widget* w);                   // raw ptr = non-owning observer only
```

### RAII + const Correctness (combined example)

```cpp
class Sensor {
public:
    explicit Sensor(std::string id) : id_{std::move(id)} {}

    const std::string& id() const { return id_; }   // const member fn
    double reading()        const { return val_; }

    void record(double v) { val_ = v; }              // non-const only when needed

private:
    const std::string id_;   // never changes after construction
    double val_{0.0};
};

// RAII mutex lock — always named, never plain lock()/unlock()
void update(Sensor& s, double v) {
    std::lock_guard<std::mutex> lock{mtx_};  // released at scope exit
    s.record(v);
}
```

### Concepts for Template Constraints (C++20)

```cpp
#include <concepts>

template<std::integral T>
T gcd(T a, T b) {
    while (b) a = std::exchange(b, a % b);
    return a;
}

// Custom concept
template<typename T>
concept Serializable = requires(const T& t) {
    { t.serialize() } -> std::convertible_to<std::string>;
};

template<Serializable T>
void save(const T& obj, std::string_view path);
```

### enum class, Not Plain enum

```cpp
enum class Color   { red, green, blue };    // scoped, no name pollution
enum class LogLevel { debug, info, warning, error };

// BAD: enum { RED, GREEN }; — leaks names, clashes with macros
```

## Pre-Commit Checklist

- [ ] No raw `new`/`delete` — use smart pointers or RAII wrappers
- [ ] Every variable is `const`/`constexpr` by default; mutate only when needed
- [ ] `enum class` instead of plain `enum`
- [ ] `nullptr` instead of `0` or `NULL`
- [ ] Single-argument constructors are `explicit`
- [ ] Templates constrained with concepts (C++20) or `static_assert`
- [ ] Headers have `#pragma once` or `#ifndef` include guards and are self-contained
- [ ] Mutexes locked via RAII (`lock_guard`/`scoped_lock`), never `lock()`/`unlock()`
- [ ] Exceptions are custom types; thrown by value, caught by `const&`
- [ ] No magic numbers — use named `constexpr` constants

## Common Pitfalls

1. **Calling virtual functions in constructors/destructors** — the derived override is not active yet; behavior is undefined or wrong silently.

2. **`memset`/`memcpy` on non-trivial types** — bypasses constructors/destructors; use assignment or `std::copy` instead.

3. **Unnamed `lock_guard`**: `std::lock_guard<std::mutex>(m);` — this is a temporary that destructs immediately, leaving the mutex unlocked. Always name it: `std::lock_guard<std::mutex> lk{m};`.

4. **`volatile` for thread synchronization** — `volatile` prevents compiler reordering but provides no CPU memory-order guarantees. Use `std::atomic<T>` or proper mutexes.

5. **Catching exceptions by value** — catches a sliced copy. Always `catch (const MyException& e)`, never `catch (MyException e)`.
