---
name: godot-architecture
description: Use when making system design decisions in Godot 4.x — ownership, signal topology, performance trade-offs, scene boundaries, or large-scale feature architecture. Not for routine scripting tasks (use godot-core).
---

# Godot Architecture — Systems Design

## 1. Thinking Framework

Before writing any system, answer these three questions for **every piece of state**:
- **Who owns the data?** (`StatsComponent` owns health, NOT `CombatSystem`)
- **Who is allowed to change it?** (Only the owner via a public method like `apply_damage()`)
- **Who needs to know it changed?** (Anyone listening to the `health_changed` signal)

If you can't answer all three, you have a coupling problem.

**The Layer Cake** — signals travel UP, never down:
```
┌──────────────────────────────┐
│  PRESENTATION (UI / VFX)     │  ← Listens to signals, never owns data
├──────────────────────────────┤
│  LOGIC (State Machines)      │  ← Orchestrates transitions, queries data
├──────────────────────────────┤
│  DATA (Resources / .tres)    │  ← Single source of truth, serializable
├──────────────────────────────┤
│  INFRASTRUCTURE (Autoloads)  │  ← Signal Bus, SaveManager, AudioBus
└──────────────────────────────┘
```

**Signal Bus tiers:**
- **Global Bus (Autoload)**: lifecycle-only events (`match_started`, `player_died`). Keep < 15 events.
- **Scoped Feature Bus**: one per feature folder (e.g., `CombatBus`). Scales better than a single global bus.
- **Direct Signals**: parent→child within a single scene only. Never cross scene boundaries with direct signals.

---

## 2. Decision Matrix

| Scenario | Strategy | Key References | Trade-off |
|----------|----------|---------------|-----------|
| Rapid prototype | Event-Driven Mono | Foundations → Autoloads | Fast start, spaghetti risk |
| Complex RPG | Component-Driven | Composition → States → RPG Stats | Heavy setup, infinite scaling |
| Massive open world | Resource-Streaming | Open World → Save/Load → Performance | Complex I/O, float jitter past 10K units |
| Server-auth multiplayer | Deterministic | Server Arch → Multiplayer | High latency cost, anti-cheat secure |
| Mobile/Web port | Adaptive-Responsive | UI Containers → Adapt Desktop→Mobile | UI complexity, broad reach |
| Application/tool | App-Composition | App Composition → Theming | Different paradigm from games |
| Complex RPG with combat | Component-Driven | Composition → States → Combat → Inventory | Heavy setup, infinite scaling |

**Node vs lighter types** — don't default to `Node` for everything:

| Type | Use When | Cost |
|------|----------|------|
| `Node` | Needs `_process`, spatial transform, or scene tree lifetime | Heaviest — SceneTree overhead |
| `Resource` | Designer-editable data, serializable to `.tres` | Medium — Inspector support |
| `RefCounted` | Transient logic packets (DamageRequest, PathQuery) | Light — auto-freed when no refs remain |
| `Object` | Custom data structures, manual memory management | Lightest — must call `.free()` |

Use `RefCounted` for logic packets. Reserve `Node` for entities that must exist spatially or need per-frame updates.

---

## 3. NEVER Rules

1. **NEVER use `get_tree().root.get_node("...")`** — absolute paths break when ANY ancestor is renamed or reparented. Use `%UniqueNames`, `@export NodePath`, or signal-based discovery.
2. **NEVER mutate external state from a component** — if `HealthComponent` calls `$HUD.update_bar()`, deleting the HUD crashes the game. Components emit signals; listeners decide how to respond.
3. **NEVER use `Area2D` for 1000+ overlapping objects** — O(n²) broadphase cost. Use `ShapeCast2D`, `PhysicsDirectSpaceState2D.intersect_shape()`, or Server APIs for bullet-hell patterns.
4. **NEVER use `_process` for 1000+ entities** — per-node SceneTree overhead kills perf. Use a single `Manager._process` iterating an array of data structs, or Server APIs directly.
5. **NEVER create circular signal connections** — A connects to B, B connects to A → infinite loop on first emit. Use a Signal Bus mediator to break cycles.

---

## 4. Performance Budgets

| Metric | Mobile Target | Desktop Target | Notes |
|--------|--------------|----------------|-------|
| Draw calls | < 100 (2D), < 200 (3D) | < 500 | `MultiMeshInstance` for foliage/debris |
| Triangle count | < 100K visible | < 1M visible | LOD mandatory above 500K |
| Texture VRAM | < 512MB | < 2GB | ETC2 (mobile), BPTC (desktop) |
| Script time | < 4ms/frame | < 8ms/frame | Move hot loops to Server APIs |
| Physics bodies | < 200 active | < 1000 active | Use `PhysicsServer` direct API for mass sim |
| Particles | < 2000 total | < 10000 total | GPU particles; set `visibility_aabb` manually |
| Scene load time | < 500ms | < 2s | Use `load_threaded_request()` |

**Diagnosis-first approach** — never optimize blindly:
- **High script time** → profile with built-in Profiler; check for hundreds of `_process` calls
- **High draw calls** → `MultiMeshInstance` for repeated geometry
- **Physics stutter** → simplify collision shapes to primitives; verify `_physics_process` not `_process` is used for movement
- **Frame spikes** → usually GC pass, synchronous `load()`, or `NavigationServer` rebaking

---

## 5. Godot 4.x Gotchas

1. **`@export` Resources are shared**: all instances share the same object. Use `resource.duplicate()` in `_ready()` or "Local to Scene" checkbox.
2. **Signal syntax silently fails**: Godot 3 `connect("name", target, "method")` compiles but does nothing. Use `signal_name.connect(callable)`.
3. **`Tween` is not a Node**: bound to creating node's lifetime. Use `get_tree().create_tween()` for persistent tweens.
4. **Physics layer vs mask**: `collision_layer` = "what I am"; `collision_mask` = "what I detect". Same value on both → self-collision or misses.
5. **`@onready` timing**: runs during `_ready()`, after `_init()`. Never mix tree-access code in `_init()`.
6. **Server query stalls**: calling `RenderingServer`/`PhysicsServer` getter functions in `_process` forces a synchronous pipeline flush — these servers are async.
7. **`move_and_slide()` API change**: velocity is now a property, not a parameter. Set `velocity` before calling.
8. **Infinite world float jitter**: past ~10K world units, float precision causes visible jitter. Use origin-shifting or large-world coordinates plugin.

---

## 6. Expert Code Patterns

### State Machine Transition Guard

```gdscript
func can_transition_to(new_state: StringName) -> bool:
    match name:
        &"Dead": return false          # terminal — no exit
        &"Stunned": return new_state == &"Idle"   # can only recover to Idle
        _: return true
```

### Component Registry (Entity Root)

```gdscript
class_name Entity extends CharacterBody2D

var _components: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child.has_method("get_component_name"):
            _components[child.get_component_name()] = child

func get_component(name: StringName) -> Node:
    return _components.get(name)
```

### Dead-Instance Safe Signal Handler

```gdscript
func _on_damage_dealt(target: Node, amount: int) -> void:
    if not is_instance_valid(target): return
    if target.is_queued_for_deletion(): return
    target.get_component(&"health").apply_damage(amount)
```

### Async Level Loader

```gdscript
func _load_level_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)
    while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().process_frame
    var scene: PackedScene = ResourceLoader.load_threaded_get(path)
    add_child(scene.instantiate())
```

### Thread-Safe Chunk Attach

```gdscript
func _load_chunk_threaded(chunk_pos: Vector2i) -> void:
    # Generate OFF the active tree (thread-safe)
    var chunk := _generate_chunk(chunk_pos)
    # Attach on main thread only
    _world_root.add_child.call_deferred(chunk)
```

⚠️ **Threading rule**: the scene tree is NOT thread-safe. Server APIs (RenderingServer, PhysicsServer) ARE thread-safe when enabled in Project Settings. Always `call_deferred()` when attaching to the live tree from a worker thread.
