---
name: godot-audio
description: Use for Godot game-audio and middleware integration — AudioBus routing, Wwise/FMOD events, adaptive music, and procedural sound systems. Not for DSP, JUCE, ffmpeg, or offline audio pipelines.
---

# Godot Game Audio & Middleware

## AudioBus Architecture

Standard bus layout — configure in Godot: **Audio tab → Bus Layout**:

```
Master
├── Music        (adaptive layers route here)
├── SFX
│   ├── Footsteps
│   ├── Weapons
│   └── Environment
├── UI           (menu sounds, notifications)
├── Voice        (dialogue, barks)
└── Ambient      (background loops)
```

Each bus supports effects chains (reverb, compressor, EQ, limiter). Add reverb to a `CaveReverb` bus; use `Area3D` with `AudioBusOverride` to switch it in spatial zones.

---

## Wwise / FMOD Integration

### Wwise (via Wwise Godot Integration Plugin)

```gdscript
# Post a one-shot event
AkSoundEngine.post_event("Play_Footstep", self)

# Continuous parameter — drive from physics
AkSoundEngine.set_rtpc_value("Player_Speed", velocity.length(), self)

# Discrete switch — surface material from raycast
AkSoundEngine.set_switch("Surface_Material", surface_name, self)

# Global music state
AkSoundEngine.set_state("Combat_State", "Engaged")
# Wwise handles: beat-quantized transition, layer mixing, stingers
```

### FMOD (via fmod-gdextension)

```gdscript
# One-shot with parameters
var event = FMODRuntime.create_instance("event:/SFX/Footstep")
event.set_parameter_by_name("Surface", surface_id)
event.set_parameter_by_name("Speed", velocity.length())
event.start()
event.release()  # release immediately for one-shots

# Persistent event (music, ambient) — keep reference
var music = FMODRuntime.create_instance("event:/Music/Exploration")
music.start()
music.set_parameter_by_name("Intensity", danger_level)  # adjust live
```

### Middleware vs Godot Native

| Scenario | Godot Native | Wwise/FMOD |
|----------|-------------|------------|
| Simple SFX playback | ✅ | Overkill |
| Music with 2-3 states | ✅ | Optional |
| Complex adaptive music | Difficult | ✅ |
| 50+ surface/material combos | Tedious | ✅ |
| Beat-synced transitions | Manual work | ✅ Built-in |
| Prototype / game jam | ✅ | Too much setup |
| Production with audio designer | Limiting | ✅ |

---

## Adaptive Music

### Vertical Remixing (Layer Fading)

Multiple synced layers on the Music bus — fade in/out independently:

```gdscript
@onready var layers = {
    "bass":    $MusicBass,
    "drums":   $MusicDrums,
    "melody":  $MusicMelody,
    "tension": $MusicTension
}

func set_intensity(level: float) -> void:
    # level 0.0 = calm, 1.0 = full combat
    _fade_layer("bass",    1.0)
    _fade_layer("drums",   clampf(level, 0.0, 1.0))
    _fade_layer("melody",  clampf(level - 0.3, 0.0, 1.0))
    _fade_layer("tension", clampf(level - 0.6, 0.0, 1.0))

func _fade_layer(layer: String, target_volume: float, duration: float = 1.0) -> void:
    var player: AudioStreamPlayer = layers[layer]
    var target_db := linear_to_db(target_volume) if target_volume > 0.01 else -80.0
    var tween := create_tween()
    tween.tween_property(player, "volume_db", target_db, duration)
```

All layers must start simultaneously and stay in sync — start them all in the same `_ready()` call.

### Horizontal Re-sequencing (State Crossfade)

```gdscript
var music_states: Dictionary = {
    "explore": preload("res://audio/music/explore.ogg"),
    "combat":  preload("res://audio/music/combat.ogg"),
    "stealth": preload("res://audio/music/stealth.ogg"),
}

func transition_music(new_state: String, crossfade_time: float = 2.0) -> void:
    var tween := create_tween()
    tween.tween_property($MusicPlayer, "volume_db", -40.0, crossfade_time)
    await tween.finished
    $MusicPlayer.stream = music_states[new_state]
    $MusicPlayer.play()
    tween = create_tween()
    tween.tween_property($MusicPlayer, "volume_db", 0.0, crossfade_time)
```

---

## Footstep System

Surface-driven footstep playback with speed-scaled timing:

```gdscript
@export var step_interval: float = 0.4  # seconds at walk speed

var _step_timer: float = 0.0

func _physics_process(delta: float) -> void:
    if not is_on_floor() or velocity.length() < 0.1:
        _step_timer = 0.0
        return

    var speed_factor := clampf(velocity.length() / max_speed, 0.3, 1.0)
    _step_timer += delta

    if _step_timer >= step_interval / speed_factor:
        _step_timer = 0.0
        _play_footstep()

func _play_footstep() -> void:
    var surface := _detect_surface()

    # Godot native: random pick + pitch variation
    var pool: Array = footstep_sounds[surface]
    $FootstepPlayer.stream = pool[randi() % pool.size()]
    $FootstepPlayer.pitch_scale = randf_range(0.9, 1.1)
    $FootstepPlayer.play()

    # Wwise alternative (comment out native block above):
    # AkSoundEngine.set_switch("Surface", surface, self)
    # AkSoundEngine.post_event("Play_Footstep", self)

func _detect_surface() -> String:
    if $FloorRaycast.is_colliding():
        var collider := $FloorRaycast.get_collider()
        if collider.has_meta("surface_type"):
            return collider.get_meta("surface_type")
    return "default"
```

---

## UI Audio Manager

Autoload singleton for consistent UI sound routing:

```gdscript
extends Node

var _sounds: Dictionary = {
    &"click": preload("res://audio/ui/click.wav"),
    &"hover": preload("res://audio/ui/hover.wav"),
    &"open":  preload("res://audio/ui/open.wav"),
    &"error": preload("res://audio/ui/error.wav"),
}

func play(sound_name: StringName) -> void:
    var stream: AudioStream = _sounds.get(sound_name)
    if stream:
        $UIPlayer.stream = stream
        $UIPlayer.play()

# Usage from any UI element:
# UIAudio.play(&"click")
```

UI sounds should sit at −18 to −24 dB relative to SFX. Keep durations short (30–200ms for interactions). Players hear these thousands of times — non-fatigue is the primary design constraint.
