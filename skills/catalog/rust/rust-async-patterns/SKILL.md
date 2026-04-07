---
name: rust-async-patterns
description: Use for async Rust with Tokio: tasks, channels, error handling, concurrency patterns, and debugging async issues.
---

# Rust Async Patterns

Production patterns for async Rust programming with Tokio runtime, including tasks, channels, streams, and error handling.

## When to Use This Skill

- Building async Rust applications
- Implementing concurrent network services
- Using Tokio for async I/O
- Handling async errors properly
- Debugging async code issues
- Optimizing async performance

## Core Concepts

### 1. Async Execution Model

```
Future (lazy) → poll() → Ready(value) | Pending
                ↑           ↓
              Waker ← Runtime schedules
```

### 2. Key Abstractions

| Concept    | Purpose                                  |
| ---------- | ---------------------------------------- |
| `Future`   | Lazy computation that may complete later |
| `async fn` | Function returning impl Future           |
| `await`    | Suspend until future completes           |
| `Task`     | Spawned future running concurrently      |
| `Runtime`  | Executor that polls futures              |

## Quick Start

```toml
# Cargo.toml
[dependencies]
tokio = { version = "1", features = ["full"] }
futures = "0.3"
async-trait = "0.1"
anyhow = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
```

```rust
use tokio::time::{sleep, Duration};
use anyhow::Result;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Async operations
    let result = fetch_data("https://api.example.com").await?;
    println!("Got: {}", result);

    Ok(())
}

async fn fetch_data(url: &str) -> Result<String> {
    // Simulated async operation
    sleep(Duration::from_millis(100)).await;
    Ok(format!("Data from {}", url))
}
```

## Patterns

### Pattern 1: Concurrent Task Execution

```rust
use tokio::task::JoinSet;
use anyhow::Result;

// Spawn multiple concurrent tasks
async fn fetch_all_concurrent(urls: Vec<String>) -> Result<Vec<String>> {
    let mut set = JoinSet::new();

    for url in urls {
        set.spawn(async move {
            fetch_data(&url).await
        });
    }

    let mut results = Vec::new();
    while let Some(res) = set.join_next().await {
        match res {
            Ok(Ok(data)) => results.push(data),
            Ok(Err(e)) => tracing::error!("Task failed: {}", e),
            Err(e) => tracing::error!("Join error: {}", e),
        }
    }

    Ok(results)
}

// With concurrency limit
use futures::stream::{self, StreamExt};

async fn fetch_with_limit(urls: Vec<String>, limit: usize) -> Vec<Result<String>> {
    stream::iter(urls)
        .map(|url| async move { fetch_data(&url).await })
        .buffer_unordered(limit) // Max concurrent tasks
        .collect()
        .await
}

// Select first to complete
use tokio::select;

async fn race_requests(url1: &str, url2: &str) -> Result<String> {
    select! {
        result = fetch_data(url1) => result,
        result = fetch_data(url2) => result,
    }
}
```

### Pattern 2: Channels for Communication

```rust
use tokio::sync::{mpsc, broadcast, oneshot, watch};

// Multi-producer, single-consumer
async fn mpsc_example() {
    let (tx, mut rx) = mpsc::channel::<String>(100);

    // Spawn producer
    let tx2 = tx.clone();
    tokio::spawn(async move {
        tx2.send("Hello".to_string()).await.unwrap();
    });

    // Consume
    while let Some(msg) = rx.recv().await {
        println!("Got: {}", msg);
    }
}

// Broadcast: multi-producer, multi-consumer
async fn broadcast_example() {
    let (tx, _) = broadcast::channel::<String>(100);

    let mut rx1 = tx.subscribe();
    let mut rx2 = tx.subscribe();

    tx.send("Event".to_string()).unwrap();

    // Both receivers get the message
    let _ = rx1.recv().await;
    let _ = rx2.recv().await;
}

// Oneshot: single value, single use
async fn oneshot_example() -> String {
    let (tx, rx) = oneshot::channel::<String>();

    tokio::spawn(async move {
        tx.send("Result".to_string()).unwrap();
    });

    rx.await.unwrap()
}

// Watch: single producer, multi-consumer, latest value
async fn watch_example() {
    let (tx, mut rx) = watch::channel("initial".to_string());

    tokio::spawn(async move {
        loop {
            // Wait for changes
            rx.changed().await.unwrap();
            println!("New value: {}", *rx.borrow());
        }
    });

    tx.send("updated".to_string()).unwrap();
}
```

### Pattern 3: Async Error Handling

```rust
use anyhow::{Context, Result, bail};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ServiceError {
    #[error("Network error: {0}")]
    Network(#[from] reqwest::Error),

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Timeout after {0:?}")]
    Timeout(std::time::Duration),
}

// Using anyhow for application errors
async fn process_request(id: &str) -> Result<Response> {
    let data = fetch_data(id)
        .await
        .context("Failed to fetch data")?;

    let parsed = parse_response(&data)
        .context("Failed to parse response")?;

    Ok(parsed)
}

// Using custom errors for library code
async fn get_user(id: &str) -> Result<User, ServiceError> {
    let result = db.query(id).await?;

    match result {
        Some(user) => Ok(user),
        None => Err(ServiceError::NotFound(id.to_string())),
    }
}

// Timeout wrapper
use tokio::time::timeout;

async fn with_timeout<T, F>(duration: Duration, future: F) -> Result<T, ServiceError>
where
    F: std::future::Future<Output = Result<T, ServiceError>>,
{
    timeout(duration, future)
        .await
        .map_err(|_| ServiceError::Timeout(duration))?
}
```

### Pattern 4: Graceful Shutdown

```rust
use tokio::signal;
use tokio::sync::broadcast;
use tokio_util::sync::CancellationToken;

async fn run_server() -> Result<()> {
    // Method 1: CancellationToken
    let token = CancellationToken::new();
    let token_clone = token.clone();

    // Spawn task that respects cancellation
    tokio::spawn(async move {
        loop {
            tokio::select! {
                _ = token_clone.cancelled() => {
                    tracing::info!("Task shutting down");
                    break;
                }
                _ = do_work() => {}
            }
        }
    });

    // Wait for shutdown signal
    signal::ctrl_c().await?;
    tracing::info!("Shutdown signal received");

    // Cancel all tasks
    token.cancel();

    // Give tasks time to cleanup
    tokio::time::sleep(Duration::from_secs(5)).await;

    Ok(())
}

// Method 2: Broadcast channel for shutdown
async fn run_with_broadcast() -> Result<()> {
    let (shutdown_tx, _) = broadcast::channel::<()>(1);

    let mut rx = shutdown_tx.subscribe();
    tokio::spawn(async move {
        tokio::select! {
            _ = rx.recv() => {
                tracing::info!("Received shutdown");
            }
            _ = async { loop { do_work().await } } => {}
        }
    });

    signal::ctrl_c().await?;
    let _ = shutdown_tx.send(());

    Ok(())
}
```

## Debugging Tips

```rust
// Enable tokio-console for runtime debugging
// Cargo.toml: tokio = { features = ["tracing"] }
// Run: RUSTFLAGS="--cfg tokio_unstable" cargo run
// Then: tokio-console

// Instrument async functions
use tracing::instrument;

#[instrument(skip(pool))]
async fn fetch_user(pool: &PgPool, id: &str) -> Result<User> {
    tracing::debug!("Fetching user");
    // ...
}

// Track task spawning
let span = tracing::info_span!("worker", id = %worker_id);
tokio::spawn(async move {
    // Enters span when polled
}.instrument(span));
