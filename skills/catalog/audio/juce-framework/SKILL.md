---
name: juce-framework
description: Use for JUCE audio apps/plugins: AudioProcessor lifecycle, VST3/AU targets, parameter systems, and thread separation. Requires audio-engineering-principles. Not for game-audio middleware or non-JUCE frameworks.
---

Requires: audio-engineering-principles
May use: dsp-algorithms, audio-systems

## Purpose
Builds production-quality JUCE-based software: standalone apps, plugin targets (VST3/AU), shared DSP cores, parameter systems, UI wiring, and host/device interoperability.

This skill covers both:
- Full JUCE applications / plugins end-to-end
- Framework-specific glue needed to embed portable DSP and analysis modules into JUCE lifecycles

---

## Core Areas

- AudioProcessor lifecycle
- prepareToPlay()
- processBlock()
- releaseResources()
- AudioProcessorValueTreeState
- Parameter smoothing
- Message thread vs audio thread separation
- JUCE DSP module usage when appropriate

---

## Rules

- Use juce::ScopedNoDenormals
- Preallocate in prepareToPlay
- Smooth parameters
- Avoid heap in processBlock
- UI must never block audio thread

---

## AudioProcessor Skeleton Example

```cpp
class MyProcessor : public juce::AudioProcessor {
    void prepareToPlay(double sampleRate, int samplesPerBlock) override {
        // Preallocate here — NO allocation in processBlock
        filter.setLowpass(1000.0f, 0.707f, (float)sampleRate);
    }

    void processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer&) override {
        juce::ScopedNoDenormals noDenormals;
        for (int ch = 0; ch < buffer.getNumChannels(); ++ch) {
            auto* data = buffer.getWritePointer(ch);
            for (int i = 0; i < buffer.getNumSamples(); ++i)
                data[i] = filter.process(data[i]);
        }
    }
};
```

## Plugin Considerations

- Automation compatibility
- Sample rate changes
- Block size changes
- Host tempo sync
- Parameter thread safety
