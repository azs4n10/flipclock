"""Generate calm, looping BGM tracks for the app.

These are gentle relaxation/focus sounds (noise colours, waves, an ambient
pad) that suit the soft "yumekawa" theme and its audience — deliberately not
harsh alarm tones. All are synthesized (no third-party samples), mono, and
crossfade-looped so they repeat seamlessly.
"""
import wave

import numpy as np

SR = 32000
LOOP = 12.0  # seconds
N = int(SR * LOOP)
T = np.arange(N) / SR


def crossfade(sig, fade_s=0.6):
    f = int(SR * fade_s)
    ramp = np.linspace(0.0, 1.0, f)
    head = sig[:f].copy()
    tail = sig[-f:].copy()
    out = sig[:-f].copy()
    out[:f] = tail * (1 - ramp) + head * ramp
    return out


def normalize(sig, peak):
    m = np.max(np.abs(sig)) + 1e-9
    return sig / m * peak


def pink(n):
    white = np.random.randn(n)
    spec = np.fft.rfft(white)
    freqs = np.arange(spec.size)
    freqs[0] = 1
    spec = spec / np.sqrt(freqs)
    return np.fft.irfft(spec, n)


def brown(n):
    y = np.cumsum(np.random.randn(n))
    y = y - np.linspace(y[0], y[-1], n)  # de-trend for loopability
    return y


def save(name, sig, peak=0.5):
    sig = crossfade(normalize(sig, peak))
    pcm = (np.clip(sig, -1, 1) * 32767).astype('<i2')
    with wave.open(f'assets/bgm/{name}.wav', 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print('wrote', name, round(len(sig) / SR, 2), 's')


# Pink noise — even, soft hiss often used for focus/sleep.
save('pink_noise', pink(N), peak=0.42)

# Brown noise — deeper, rounder, very calming.
save('brown_noise', brown(N), peak=0.55)

# Ocean — brown noise under a slow swell (waves), ~7s period.
swell = 0.35 + 0.65 * (0.5 - 0.5 * np.cos(2 * np.pi * T / (LOOP / 2)))
save('ocean', brown(N) * swell, peak=0.55)

# Rain — pink noise with a gentle high shelf for a soft patter.
rn = pink(N)
spec = np.fft.rfft(rn)
freqs = np.fft.rfftfreq(N, 1 / SR)
shelf = 1.0 + 0.8 * (freqs / (freqs + 2000.0))  # lift highs a touch
rain = np.fft.irfft(spec * shelf, N)
save('rain', rain, peak=0.4)

# Dream pad — soft major chord with slow tremolo (1/f-like gentle motion).
# Snap each partial to the loop grid so the tone loops without a click.
base = [261.63, 329.63, 392.00, 523.25]  # C E G C
pad = np.zeros(N)
for f0 in base:
    f = round(f0 * LOOP) / LOOP
    for det in (-0.6, 0.0, 0.6):  # mild detune for warmth
        fd = round((f0 + det) * LOOP) / LOOP
        pad += np.sin(2 * np.pi * fd * T)
trem = 0.75 + 0.25 * np.sin(2 * np.pi * (1.0 / LOOP) * T)  # 1 cycle/loop
save('dream_pad', pad * trem, peak=0.34)

print('done')
