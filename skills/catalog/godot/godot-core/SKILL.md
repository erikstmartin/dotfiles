---
name: godot-core
description: Use when writing GDScript, creating scenes, adding nodes, or doing day-to-day Godot 4.x development. Covers project structure, script patterns, signals, resources, and MCP tools.
---

# Godot Core — GDScript & Day-to-Day Development

## 1. Project Setup

Standard folder layout — organize by **feature**, not by class type:

```
project/
├── project.godot
├── features/
│   ├── player/          # scene + script + resources + tests together
│   ├── combat/
│   └── ui/
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── shaders/
└── resources/           # shared .tres files
```

**MCP Tools** — use these to act instead of explaining manually:

| Tool | When |
|------|------|
| `mcp__godot__launch_editor` | Open project in editor |
| `mcp__godot__run_project` | Run the game |
| `mcp__godot__get_debug_output` | Read console errors |
| `mcp__godot__stop_project` | Stop running game |
| `mcp__godot__create_scene` | Create a new .tscn |
| `mcp__godot__add_node` | Add node to scene |
| `mcp__godot__load_sprite` | Load texture into Sprite2D |
| `mcp__godot__save_scene` | Persist scene changes |
| `mcp__godot__get_uid` | Get file UID (4.4+) |
| `mcp__godot__list_projects` | Find projects in directory |

**Common task — create a 2D character:**
1. `mcp__godot__create_scene` with `CharacterBody2D` root
2. `mcp__godot__add_node` → `Sprite2D` child
3. `mcp__godot__add_node` → `CollisionShape2D` child
4. Write and attach script to root node
5. Implement movement in `_physics_process`

---

## 2. Script Structure

Every script follows this layout order — never deviate:

```gdscript
class_name PlayerCharacter   # NEVER skip — required for type hints elsewhere
extends CharacterBody2D

# 1. Signals (typed parameters always)
signal health_changed(new_health: int)
signal died

# 2. Enums / Constants
enum State { IDLE, RUN, JUMP, DEAD }
const MAX_SPEED: float = 600.0

# 3. @export variables
@export var speed: float = 200.0
@export_group("Combat")
@export var attack_damage: int = 10
@export var weapon: WeaponData  # custom Resource type

# 4. @onready references (cache everything — never $ in _process)
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = %HealthBar  # scene-unique name

# 5. Public variables
var current_state: State = State.IDLE

# 6. Private variables (_prefix by convention)
var _health: int
var _can_attack: bool = true

func _ready() -> void:
    _health = 100

func _physics_process(delta: float) -> void:
    var dir := Input.get_vector("left", "right", "up", "down")
    velocity = dir * speed
    move_and_slide()

func take_damage(amount: int) -> void:
    _health = max(_health - amount, 0)
    health_changed.emit(_health)
    if _health <= 0:
        died.emit()

func _apply_knockback(direction: Vector2) -> void:
    velocity += direction * 300.0
```

**Type system — static type everything:**

```gdscript
var speed: float = 300.0          # explicit
var direction := Vector2.ZERO     # inferred (:= when type is obvious)
var enemies: Array[Enemy] = []    # typed arrays

func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)
```

⚠️ Untyped code is significantly slower — the GDScript compiler only optimises typed paths.

---

## 3. Key Patterns

### Signal Connection

```gdscript
func _ready() -> void:
    health_component.died.connect(_on_died)
    health_component.health_changed.connect(_on_health_changed)
    # One-shot: auto-disconnects after first fire
    get_tree().create_timer(3.0).timeout.connect(_on_timer, CONNECT_ONE_SHOT)

func _exit_tree() -> void:
    # Always disconnect manually-connected signals
    if health_component.died.is_connected(_on_died):
        health_component.died.disconnect(_on_died)
```

⚠️ **Pitfall**: `connect("signal_name", target, "method")` is Godot 3 syntax — it compiles silently in Godot 4 but does nothing. Always use `signal_name.connect(callable)`.

### Resource-Based Data

Use `Resource` subclasses for all designer-editable data. Never embed data tables in scripts.

```gdscript
# weapon_data.gd
class_name WeaponData
extends Resource

@export var damage: int
@export var attack_speed: float
@export var icon: Texture2D
@export var sound_attack: AudioStream
```

```gdscript
# character.gd — consuming the resource
@export var base_stats: CharacterStats
var stats: CharacterStats

func _ready() -> void:
    # MANDATORY: duplicate() to prevent shared-resource bug
    stats = base_stats.duplicate() as CharacterStats
    stats.stat_changed.connect(_on_stat_changed)
```

⚠️ **Pitfall**: Multiple scene instances share the same `Resource` object by default. Call `duplicate()` in `_ready()` or enable "Local to Scene" in the Inspector. This is the #1 Godot 4 newcomer bug.

### StringName for Hot Paths

```gdscript
anim.play(&"run")              # O(1) pointer compare vs O(n) string compare
stats[&"health"] = 100
if group == &"enemies": pass
```

Use `&"name"` (StringName literal) anywhere the value is a key, animation name, or repeated identifier in `_process`.

### Async Resource Loading

```gdscript
func _load_level_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)
    while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().process_frame
    var scene: PackedScene = ResourceLoader.load_threaded_get(path)
    add_child(scene.instantiate())
```

Use `preload()` at script top for small assets known at edit-time. Use `ResourceLoader.load_threaded_request()` for levels and large assets.

---

## 4. NEVER Rules

1. **NEVER use dynamic typing in hot paths** — `var x = 5` is slower; `var x: int = 5` enables compiler optimisation.
2. **NEVER call `get_node()` or `$` inside `_process()`** — cache all node refs in `@onready`.
3. **NEVER `await` inside `_physics_process()`** — yields cause physics frames to be skipped; move async ops to a signal-triggered method.
4. **NEVER use `String` keys in hot-path dictionaries** — use `StringName` (`&"key"`) for O(1) pointer comparison.
5. **NEVER access dict keys directly with `dict["key"]`** — use `dict.get("key", default)` to avoid crashes on missing keys.
6. **NEVER skip `class_name`** — without it you can't use the script as a type hint elsewhere in the project.
7. **NEVER use `load()` inside `_process` or a loop** — synchronous disk read blocks the main thread; use `preload()` or `load_threaded_request()`.
8. **NEVER store `Callable` refs to freed objects** — disconnect signals in `_exit_tree()` or use `CONNECT_ONE_SHOT`.
9. **NEVER use `@export Resource` without `duplicate()` in `_ready()`** — shared Resource across instances is the #1 Godot 4 newcomer bug.
10. **NEVER use Godot 3 signal syntax** — `connect("name", target, "method")` compiles but does nothing in Godot 4.

---

## 5. Gotchas

- **`move_and_slide()` API change**: velocity is now a property. Set `velocity = dir * speed` before calling `move_and_slide()` — do not pass it as an argument.
- **`@onready` timing**: runs during `_ready()`, after `_init()`. Never mix constructor-time setup with `@onready`; use `_init()` for pre-tree setup.
- **`Tween` is not a Node**: created via `create_tween()`, bound to the creating node's lifetime. Use `get_tree().create_tween()` for tweens that must outlive the node.
- **Physics layers vs masks**: `collision_layer` = "what I am"; `collision_mask` = "what I detect". Setting both to the same value causes self-collision or missed detections.
