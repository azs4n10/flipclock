"""Generate a soft pastel chime WAV used as the timer/pomodoro alert."""
import math
import struct
import wave

SAMPLE_RATE = 44100
OUT = "assets/sounds/chime.wav"

# Two gentle notes: C6, then E6, each with a soft attack and long decay.
NOTES = [(1046.50, 0.0, 0.45), (1318.51, 0.18, 0.7)]  # (freq_hz, start_s, dur_s)
TOTAL = 1.0


def envelope(t, dur):
    attack = 0.02
    if t < attack:
        return t / attack
    return math.exp(-3.2 * (t - attack) / dur)


samples = []
n = int(SAMPLE_RATE * TOTAL)
for i in range(n):
    t = i / SAMPLE_RATE
    v = 0.0
    for freq, start, dur in NOTES:
        lt = t - start
        if 0 <= lt <= dur:
            # fundamental + soft 2nd harmonic for a bell-like tone
            tone = math.sin(2 * math.pi * freq * lt)
            tone += 0.25 * math.sin(2 * math.pi * 2 * freq * lt)
            v += envelope(lt, dur) * tone
    samples.append(v)

peak = max(1e-6, max(abs(s) for s in samples))
scale = 0.82 / peak

with wave.open(OUT, "w") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SAMPLE_RATE)
    frames = bytearray()
    for s in samples:
        frames += struct.pack("<h", int(max(-1.0, min(1.0, s * scale)) * 32767))
    w.writeframes(bytes(frames))

print("wrote", OUT, n, "samples")
