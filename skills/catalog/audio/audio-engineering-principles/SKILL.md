---
name: audio-engineering-principles
description: Use for real-time audio code safety, determinism, and numeric hygiene. Required foundation for DSP, audio analysis, audio systems, and JUCE work. Not for game-audio middleware or ffmpeg/video tasks.
---

## Purpose
Defines invariant engineering standards for any audio-related code.

This skill must be followed by:
- DSP Algorithms
- Audio Analysis
- Audio Systems
- JUCE Integration

---

## Real-Time Safety Rules

When executing on an audio thread:

- NO heap allocation
- NO locks or mutexes
- NO logging or console IO
- NO file IO
- NO syscalls
- NO exceptions
- NO dynamic container resizing
- NO blocking calls of any kind

Preallocate in initialization / prepare phase.

Use:
- Fixed-size buffers
- Lock-free queues
- Atomics
- Ring buffers

---

## Determinism

- Algorithms must be deterministic unless explicitly stochastic.
- Provide reproducible test vectors.
- Use stable floating-point operations.
- Avoid undefined behavior.

---

## Numeric Hygiene

- Handle denormals (flush-to-zero).
- Avoid DC offset accumulation.
- Prevent clipping unless intentional.
- Maintain proper gain staging.
- Handle multi-channel consistently.

---

## Performance Mindset

Always document:
- Big-O complexity
- Memory usage
- Allocation behavior
- Vectorization opportunities
- Cache friendliness

---

## Output Contract

For audio requests, respond with:

1. Design summary (thread model + constraints)
2. Public API
3. Implementation
4. Tests (offline or RT-safe)
5. Performance notes
6. Edge cases

---

## Scope Guardrails

Do NOT:
- Provide DRM cracking strategies
- Provide vendor NDA content
- Paste proprietary SDK code

Prefer open implementations and known references.
