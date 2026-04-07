---
name: audio-dsp
description: Use when implementing real-time DSP algorithms, audio thread architecture, or offline spectral analysis in C++/Rust. Covers filters, STFT pipelines, lock-free concurrency, and RT safety. Not for JUCE plugin lifecycle wiring or ffmpeg.
---

Requires: audio-engineering-principles

## Workflow

### 1. Design: Thread Model + Constraints

Before writing any code, classify each component:

| Component | Thread | Allocation allowed? |
|-----------|--------|---------------------|
| DSP (filter, STFT) | Audio | No — preallocate in init |
| Parameter smoothing | Audio | No |
| SPSC push (events out) | Audio | No — fixed buffer |
| Analysis, logging | Worker | Yes |
| Result publishing | Worker | Yes |

**RT constraints checklist (audio thread must pass ALL):**
- [ ] No `new`/`malloc`/`std::vector::push_back`
- [ ] No mutex, no `std::lock_guard`
- [ ] No file IO, no `printf`/`std::cout`
- [ ] No syscalls, no exceptions
- [ ] No dynamic container resize
- [ ] All state pre-allocated in `prepare()`/`prepareToPlay()`

### 2. Implement DSP

**Biquad filter (Direct Form II Transposed) — RT-safe:**

```cpp
struct Biquad {
    float b0, b1, b2, a1, a2;
    float z1 = 0, z2 = 0;

    float process(float in) {
        float out = b0 * in + z1;
        z1 = b1 * in - a1 * out + z2;
        z2 = b2 * in - a2 * out;
        return out;
    }

    void setLowpass(float freq, float q, float sr) {
        float w0 = 2.0f * M_PI * freq / sr;
        float alpha = sinf(w0) / (2.0f * q);
        float cosw0 = cosf(w0);
        float a0 = 1.0f + alpha;
        b0 = ((1.0f - cosw0) / 2.0f) / a0;
        b1 = (1.0f - cosw0) / a0;
        b2 = b0;
        a1 = (-2.0f * cosw0) / a0;
        a2 = (1.0f - alpha) / a0;
    }
};
```

⚠️ **Pitfall:** Call `setLowpass()` only on the non-RT thread or in `prepare()`. Calling it mid-block without smoothing causes audible zipper noise.

**STFT pipeline (offline/hybrid — allocation OK):**

```cpp
void analyzeSpectrum(const float* input, size_t numSamples, float sampleRate) {
    constexpr size_t fftSize = 2048;  // default; Hann window
    constexpr size_t hopSize = 512;
    std::vector<float> window(fftSize);
    hannWindow(window.data(), fftSize);

    for (size_t pos = 0; pos + fftSize <= numSamples; pos += hopSize) {
        std::vector<float> windowed(input + pos, input + pos + fftSize);
        applyWindow(windowed.data(), window.data(), fftSize);
        auto magnitudes = computeFFT(windowed.data(), fftSize);
        float centroid = spectralCentroid(magnitudes.data(), fftSize, sampleRate);
        // store or process centroid per frame
    }
}
```

**STFT defaults (use unless specified):**
- Window: Hann
- FFT size: 2048
- Hop: 512 (use 256 for higher time resolution)
- Output: magnitude spectrum

**Parameter smoothing (required for any modulated RT param):**

```cpp
struct SmoothedParam {
    float current, target, coeff;
    void prepare(float sr, float smoothMs) {
        coeff = expf(-1.0f / (sr * smoothMs * 0.001f));
    }
    float next() {
        current = current * coeff + target * (1.0f - coeff);
        return current;
    }
};
```

### 3. Wire Concurrency

Use SPSC queue to pass data from audio thread → worker thread. Never share mutable state without atomics.

```cpp
template<typename T, size_t Size>
struct SPSCQueue {
    std::array<T, Size> buffer;
    std::atomic<size_t> head{0}, tail{0};

    bool push(const T& item) {
        size_t h = head.load(std::memory_order_relaxed);
        size_t next = (h + 1) % Size;
        if (next == tail.load(std::memory_order_acquire)) return false; // full
        buffer[h] = item;
        head.store(next, std::memory_order_release);
        return true;
    }

    bool pop(T& item) {
        size_t t = tail.load(std::memory_order_relaxed);
        if (t == head.load(std::memory_order_acquire)) return false; // empty
        item = buffer[t];
        tail.store((t + 1) % Size, std::memory_order_release);
        return true;
    }
};
```

**Pattern:** Audio thread `push`es events/samples; worker thread `pop`s and processes. Publish results via atomic pointer swap or immutable snapshots — never reverse the direction through a lock.

⚠️ **Pitfall:** `push` returning `false` (queue full) must be silently dropped on the audio thread — never block or retry.

### 4. Test

- **Offline buffer test:** Feed known input (sine, impulse, silence), assert output matches expected within tolerance.
- **Impulse response test:** Send a unit impulse through the filter, verify frequency-domain magnitude matches `setLowpass` design.
- **Stability tests:** Run 10⁶ samples of white noise; verify no NaN/Inf, no unbounded growth.
- **Edge cases:** 0 Hz, Nyquist (sr/2), silence (all-zeros block), single-sample buffer.
- **SPSC test:** Fill queue to capacity, verify `push` returns false; drain fully, verify `pop` returns false.

```cpp
// Impulse response test example
void testLowpassImpulse() {
    Biquad f;
    f.setLowpass(1000.0f, 0.707f, 48000.0f);
    std::vector<float> ir(512, 0.0f);
    ir[0] = 1.0f;
    for (auto& s : ir) s = f.process(s);
    // Verify: DC gain ≈ 1.0, gain at Nyquist ≈ 0
    assert(std::abs(ir[0]) < 2.0f); // not clipping
}
```

### 5. Optimize

- Reuse FFT buffers across hops; avoid `std::vector` construction in the inner loop.
- Vectorize filter processing using SIMD or compiler auto-vec (`-O2 -ffast-math`).
- For multi-channel: process channels interleaved or use channel loop inside sample loop (cache-friendly).
- Document Big-O and allocation behavior in public API comments.

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Denormals | CPU spikes on silence | Add `juce::ScopedNoDenormals` or FTZ/DAZ flags; add DC offset (`1e-25f`) to filter state |
| DC offset accumulation | Low-frequency drift | Apply 1-pole highpass after filter chain; `y = x - x_prev + 0.995f * y_prev` |
| Allocation on audio thread | Dropouts under load | Profile with `-fsanitize=thread`; audit every `new`/container use in callback |
| Coefficient change without smoothing | Zipper noise on parameter change | Use `SmoothedParam` above for all user-visible knobs |
| SPSC overflow dropped silently | Missing events | Size queue for worst-case burst; monitor drop rate in worker |
| STFT phase discontinuity | Spectral smearing | Apply window before FFT; use 75% overlap for reconstruction |
