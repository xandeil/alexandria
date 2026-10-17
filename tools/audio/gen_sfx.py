"""Gera os efeitos sonoros e ambientes do jogo por sintese (numpy).

Uso (na raiz do projeto):  python3 tools/audio/gen_sfx.py
Saida: assets/sfx/*.wav (mono, 22050 Hz, 16 bits). Sons provisorios, mas com
"peso": impacto grave + estalo agudo e o segredo de quase todo som de golpe.
"""
from __future__ import annotations

import os
import wave

import numpy as np

SR = 22050
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "sfx")
rng = np.random.default_rng(7)


# --- blocos basicos ----------------------------------------------------------------
def t_axis(seconds: float) -> np.ndarray:
    return np.arange(int(SR * seconds)) / SR


def noise(seconds: float) -> np.ndarray:
    return rng.uniform(-1, 1, int(SR * seconds))


def env_exp(seconds: float, decay: float, attack: float = 0.002) -> np.ndarray:
    t = t_axis(seconds)
    env = np.exp(-t / decay)
    a = int(SR * attack)
    if a > 0:
        env[:a] *= np.linspace(0, 1, a)
    return env


def env_swell(seconds: float, peak: float = 0.5) -> np.ndarray:
    t = t_axis(seconds) / seconds
    return np.where(t < peak, t / peak, (1 - t) / (1 - peak)) ** 1.5


def lowpass(x: np.ndarray, cutoff) -> np.ndarray:
    """Passa-baixa de 1 polo. cutoff pode ser escalar ou array (varredura)."""
    cut = np.broadcast_to(np.asarray(cutoff, dtype=float), x.shape)
    alpha = 1 - np.exp(-2 * np.pi * cut / SR)
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += alpha[i] * (x[i] - acc)
        y[i] = acc
    return y


def highpass(x: np.ndarray, cutoff) -> np.ndarray:
    return x - lowpass(x, cutoff)


def bandpass(x: np.ndarray, low, high) -> np.ndarray:
    return lowpass(highpass(x, low), high)


def sine(freq, seconds: float, phase: float = 0.0) -> np.ndarray:
    f = np.broadcast_to(np.asarray(freq, dtype=float), (int(SR * seconds),))
    return np.sin(2 * np.pi * np.cumsum(f) / SR + phase)


def sweep(f0: float, f1: float, seconds: float, curve: float = 1.0) -> np.ndarray:
    t = t_axis(seconds) / seconds
    return f0 + (f1 - f0) * t ** curve


def metallic(seconds: float, base: float, decay: float) -> np.ndarray:
    ratios = [1.0, 2.76, 5.40, 8.93, 13.34]
    out = np.zeros(int(SR * seconds))
    for i, r in enumerate(ratios):
        out += sine(base * r, seconds) * env_exp(seconds, decay / (1 + i * 0.6)) / (1 + i)
    return out


def resonator(x: np.ndarray, freq: float, q: float = 6.0) -> np.ndarray:
    """Passa-faixa ressonante (biquad RBJ): bom para "formantes" de voz."""
    w0 = 2 * np.pi * freq / SR
    alpha = np.sin(w0) / (2 * q)
    b0, b2 = alpha, -alpha
    a0, a1, a2 = 1 + alpha, -2 * np.cos(w0), 1 - alpha
    b0, b2, a1, a2 = b0 / a0, b2 / a0, a1 / a0, a2 / a0
    y = np.zeros_like(x)
    x1 = x2 = y1 = y2 = 0.0
    for i in range(len(x)):
        out = b0 * x[i] + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1 = x1, x[i]
        y2, y1 = y1, out
        y[i] = out
    return y


def voice(f0, seconds: float, formants, breath: float = 0.15) -> np.ndarray:
    """Voz sintetica: trem de pulsos (glote) filtrado por formantes (vogal)."""
    f = np.broadcast_to(np.asarray(f0, dtype=float), (int(SR * seconds),))
    phase = np.cumsum(f) / SR
    pulses = 2 * (phase - np.floor(phase)) - 1  # dente de serra: rico em harmonicos
    source = pulses + noise(seconds) * breath
    return sum(resonator(source, fr, q) * g for fr, q, g in formants)


def mix(*parts: np.ndarray) -> np.ndarray:
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def pad(x: np.ndarray, before: float = 0.0, after: float = 0.0) -> np.ndarray:
    return np.concatenate([np.zeros(int(SR * before)), x, np.zeros(int(SR * after))])


def save(name: str, x: np.ndarray, gain: float = 0.8) -> None:
    peak = np.max(np.abs(x)) or 1.0
    x = np.tanh(x / peak * 1.2) / np.tanh(1.2) * gain
    fade = min(len(x) // 10, int(SR * 0.01))
    if fade:
        x[-fade:] *= np.linspace(1, 0, fade)
    data = (x * 32767).astype(np.int16)
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print(f"   {name}.wav  {len(x) / SR:.2f}s")


def save_loop(name: str, x: np.ndarray, gain: float = 0.5) -> None:
    """Loop sem emenda: mistura o fim no comeco (crossfade)."""
    xf = int(SR * 0.5)
    head, body, tail = x[:xf], x[xf:-xf], x[-xf:]
    ramp = np.linspace(0, 1, xf)
    looped = np.concatenate([tail * (1 - ramp) + head * ramp, body])
    peak = np.max(np.abs(looped)) or 1.0
    data = (looped / peak * gain * 32767).astype(np.int16)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print(f"   {name}.wav  {len(looped) / SR:.2f}s (loop)")


# --- efeitos -----------------------------------------------------------------------
def swing(seconds=0.2, lo=600, hi=3200):
    n = noise(seconds)
    cut = sweep(lo, hi, seconds, 0.6)
    return bandpass(n, cut * 0.4, cut) * env_swell(seconds, 0.35)


def impact(seconds=0.18, f0=150, f1=55, crack=0.6):
    body = sine(sweep(f0, f1, seconds, 0.5), seconds) * env_exp(seconds, seconds / 3)
    snap = highpass(noise(0.05), 1500) * env_exp(0.05, 0.012) * crack
    return mix(body, snap)


def main() -> None:
    print("Efeitos sonoros")
    save("swing", swing(0.18, 700, 3600), 0.55)
    save("swing_heavy", swing(0.32, 300, 2200), 0.65)
    save("hit", impact(0.16, 170, 60, 0.7), 0.8)
    save("hit_heavy", mix(impact(0.3, 120, 40, 0.9), impact(0.2, 300, 90, 0.4)), 0.9)
    save("clang", mix(metallic(0.45, 520, 0.09), highpass(noise(0.03), 2500) * env_exp(0.03, 0.008)), 0.6)
    save("armor_break", mix(metallic(0.8, 360, 0.15), pad(metallic(0.5, 610, 0.08), 0.12), pad(metallic(0.4, 450, 0.06), 0.26),
                            impact(0.25, 140, 50, 0.3)), 0.75)
    save("dash", bandpass(noise(0.24), sweep(300, 900, 0.24), sweep(1200, 4200, 0.24)) * env_swell(0.24, 0.25), 0.5)
    save("hurt", mix(impact(0.22, 110, 45, 0.5), lowpass(noise(0.15), 900) * env_exp(0.15, 0.04) * 0.6), 0.85)
    gulp = mix(sine(sweep(180, 120, 0.12), 0.12) * env_exp(0.12, 0.05), pad(sine(sweep(200, 130, 0.12), 0.12) * env_exp(0.12, 0.05), 0.16))
    chime = pad(mix(sine(1046, 0.5) * env_exp(0.5, 0.15), sine(1568, 0.5) * env_exp(0.5, 0.1) * 0.5), 0.3)
    save("heal", mix(gulp, chime * 0.5), 0.6)
    splash = highpass(noise(0.4), sweep(800, 3000, 0.4)) * env_exp(0.4, 0.09)
    shimmer = pad(mix(*(sine(f, 0.7) * env_exp(0.7, 0.25) * 0.3 for f in (1318, 1760, 2093, 2637))), 0.1)
    save("sanity", mix(splash, shimmer), 0.6)
    save("memory", mix(sine(880, 0.35) * env_exp(0.35, 0.1), pad(sine(1320, 0.3) * env_exp(0.3, 0.09), 0.05)), 0.4)
    boom = sine(sweep(70, 32, 1.6, 0.4), 1.6) * env_exp(1.6, 0.5)
    rumble = lowpass(noise(1.6), 200) * env_exp(1.6, 0.6)
    save("death", mix(boom, rumble * 0.8), 0.9)
    dissolve = bandpass(noise(0.6), sweep(2000, 200, 0.6), sweep(5000, 800, 0.6)) * env_exp(0.6, 0.25)
    save("enemy_death", mix(dissolve, impact(0.2, 120, 50, 0.2)), 0.6)
    bell = metallic(2.0, 196, 0.6)
    save("boss_phase", mix(bell * 0.6, sine(sweep(60, 40, 1.5), 1.5) * env_exp(1.5, 0.5), rumble[: int(SR * 1.5)] * 0.5), 0.85)
    save("ui_click", highpass(noise(0.03), 2000) * env_exp(0.03, 0.006), 0.35)
    save("ui_open", mix(sine(660, 0.12) * env_exp(0.12, 0.04), pad(sine(990, 0.1) * env_exp(0.1, 0.04), 0.05)), 0.35)
    chord = mix(*(sine(f, 1.4) * env_swell(1.4, 0.3) for f in (110, 164.8, 220, 277.2)))
    save("rest", chord, 0.5)
    save("fog", lowpass(noise(0.9), sweep(200, 1400, 0.9, 0.5)) * env_swell(0.9, 0.6), 0.55)
    save("door", mix(impact(0.4, 90, 40, 0.2), lowpass(noise(0.5), sweep(600, 150, 0.5)) * env_exp(0.5, 0.2) * 0.5), 0.6)
    save("telegraph", sine(2200, 0.18) * env_exp(0.18, 0.05) + sine(3300, 0.18) * env_exp(0.18, 0.03) * 0.4, 0.3)
    save("block", mix(metallic(0.3, 700, 0.06), impact(0.12, 220, 90, 0.4)), 0.6)
    save("step_heavy", impact(0.25, 90, 35, 0.15), 0.6)

    print("Ambientes")
    s = 12.0
    t = t_axis(s)
    drone = (np.sin(2 * np.pi * 55 * t) * 0.5 + np.sin(2 * np.pi * 82.5 * t) * 0.3) * (0.7 + 0.3 * np.sin(2 * np.pi * t / s))
    room = lowpass(noise(s), 400) * 0.6
    crackle = np.zeros_like(t)
    for _ in range(40):
        i = rng.integers(0, len(t) - 400)
        crackle[i:i + 300] += highpass(noise(300 / SR), 1800) * env_exp(300 / SR, 0.003) * rng.uniform(0.2, 0.6)
    save_loop("amb_theater", drone * 0.5 + room + crackle * 0.5, 0.35)
    wind = bandpass(noise(s), 150, 900 + 500 * np.sin(2 * np.pi * t / 6)) * (0.6 + 0.4 * np.sin(2 * np.pi * t / 4))
    save_loop("amb_city", wind + crackle * 0.8, 0.4)
    beat = np.zeros(int(SR * 3.2))
    for start in (0.0, 0.32, 1.6, 1.92):
        thump = impact(0.3, 70, 38, 0.0) * (1.0 if start in (0.0, 1.6) else 0.7)
        i = int(SR * start)
        beat[i:i + len(thump)] += thump
    tension = sine(110 + 2 * np.sin(2 * np.pi * 5 * t_axis(3.2)), 3.2) * 0.12
    save_loop("amb_boss", np.tile(beat + tension, 4), 0.55)

    # Aldir Cornélios (gerados por último para não mudar os sons acima: o rng é compartilhado)
    print("Aldir")
    boom = sine(sweep(95, 28, 0.7, 0.4), 0.7) * env_exp(0.7, 0.22)
    debris = lowpass(noise(0.9), sweep(1800, 250, 0.9)) * env_exp(0.9, 0.25)
    save("slam", mix(boom, debris * 0.7, highpass(noise(0.06), 1200) * env_exp(0.06, 0.015)), 0.95)
    rocks = np.zeros(int(SR * 0.9))
    for _ in range(14):
        start = int(rng.uniform(0, 0.6) * SR)
        hit = impact(0.12, rng.uniform(140, 320), rng.uniform(50, 90), 0.5) * rng.uniform(0.3, 0.8)
        rocks[start:start + len(hit)] += hit[: len(rocks) - start]
    save("crumble", mix(rocks, lowpass(noise(0.9), 500) * env_exp(0.9, 0.35) * 0.6), 0.75)
    whoosh = bandpass(noise(0.7), sweep(900, 120, 0.7), sweep(2600, 400, 0.7)) * env_swell(0.7, 0.2)
    save("fall", whoosh, 0.6)
    t = t_axis(1.2)
    growl = np.sign(np.sin(2 * np.pi * (85 + 10 * np.sin(2 * np.pi * 7 * t)) * t)) * 0.35
    growl = lowpass(growl + lowpass(noise(1.2), 900) * 0.5, sweep(1400, 500, 1.2)) * env_swell(1.2, 0.25)
    save("roar", mix(growl, sine(sweep(70, 45, 1.2), 1.2) * env_exp(1.2, 0.5) * 0.6), 0.85)
    roll = lowpass(noise(0.6), sweep(300, 900, 0.6, 0.5)) * env_swell(0.6, 0.15)
    save("shockwave", mix(roll, impact(0.2, 110, 40, 0.3)), 0.7)

    # Prologo (tambem no fim: o rng compartilhado nao muda nenhum som acima)
    print("Prologo")
    eh = [(620, 5.0, 1.0), (2300, 8.0, 0.55), (3100, 9.0, 0.25)]
    giggle = np.zeros(int(SR * 0.75))
    for i, start in enumerate((0.0, 0.13, 0.25, 0.37, 0.5)):
        dur = 0.09 if i < 4 else 0.14
        f0 = sweep(560 - i * 22, 470 - i * 22, dur) * (1 + 0.03 * np.sin(2 * np.pi * 24 * t_axis(dur)))
        syl = voice(f0, dur, eh, 0.25) * env_exp(dur, dur / 2.2, 0.008)
        h = highpass(noise(0.03), 1800) * env_exp(0.03, 0.01) * 0.35
        k = int(SR * start)
        part = mix(h, pad(syl, 0.012))
        giggle[k:k + len(part)] += part[: len(giggle) - k]
    save("laugh", giggle, 0.42)
    t = t_axis(1.5)
    f0 = 560 + 260 * np.sin(np.pi * np.clip(t / 1.1, 0, 1)) + 14 * np.sin(2 * np.pi * 6.5 * t)
    aa = [(950, 4.0, 1.0), (1350, 5.0, 0.7), (2700, 7.0, 0.35)]
    cry = voice(f0, 1.5, aa, 0.5) * env_swell(1.5, 0.18)
    save("scream", np.tanh(cry * 2.5) + highpass(noise(1.5), 2500) * env_swell(1.5, 0.2) * 0.15, 0.7)
    save("swing_small", swing(0.13, 1300, 5200), 0.4)
    hiss = bandpass(noise(0.55), sweep(500, 1600, 0.55), sweep(2500, 6000, 0.55)) * env_swell(0.55, 0.2)
    save("door_slide", mix(hiss, pad(impact(0.18, 150, 60, 0.3), 0.45)), 0.55)
    release = highpass(noise(1.0), 1500) * env_exp(1.0, 0.25)
    hum = mix(sine(110, 1.6), sine(164.8, 1.6) * 0.6) * env_swell(1.6, 0.45) * 0.5
    save("capsule_open", mix(release * 0.6, pad(hum, 0.15)), 0.5)
    bell = mix(*(pad(sine(f, 0.9) * env_exp(0.9, 0.3), d) for f, d in ((1046.5, 0.0), (1318.5, 0.05), (1568.0, 0.1))))
    echo = mix(bell, pad(bell * 0.5, 0.18), pad(bell * 0.25, 0.36), pad(bell * 0.12, 0.54))
    save("echo", lowpass(echo, 3000), 0.45)
    s = 12.0
    t = t_axis(s)
    mains = (np.sin(2 * np.pi * 60 * t) * 0.6 + np.sin(2 * np.pi * 120 * t) * 0.3 + np.sin(2 * np.pi * 180 * t) * 0.12)
    buzz = bandpass(noise(s), 900, 2600) * (0.5 + 0.5 * np.sin(2 * np.pi * 120 * t)) * 0.12
    air = lowpass(noise(s), 300) * 0.5
    drips = np.zeros_like(t)
    for _ in range(9):
        i = int(rng.integers(0, len(t) - 8000))
        d = sine(rng.uniform(1500, 2600), 0.25) * env_exp(0.25, 0.04) * rng.uniform(0.3, 0.6)
        drips[i:i + len(d)] += d
    save_loop("amb_lab", mains * 0.35 + buzz + air + drips, 0.35)

    # Cidade: Cao de Guerra, Atirador, Civil Cinzento (no fim, pelo mesmo motivo)
    print("Cidade")
    t = t_axis(0.35)
    snarl = np.sign(np.sin(2 * np.pi * (140 + 40 * np.sin(2 * np.pi * 30 * t)) * t)) * 0.5
    snarl = lowpass(snarl + noise(0.35) * 0.4, 1800) * env_exp(0.35, 0.12, 0.01)
    save("bark", mix(snarl, metallic(0.3, 880, 0.05) * 0.4), 0.6)
    crack = highpass(noise(0.08), 1200) * env_exp(0.08, 0.015)
    boom = sine(sweep(180, 60, 0.4, 0.5), 0.4) * env_exp(0.4, 0.09)
    tail = lowpass(noise(0.9), sweep(1500, 200, 0.9)) * env_exp(0.9, 0.3) * 0.5
    save("shot", mix(crack, boom, tail), 0.8)
    oh = [(500, 5.0, 1.0), (850, 6.0, 0.5), (2400, 8.0, 0.2)]
    f0 = sweep(150, 110, 0.9) * (1 + 0.02 * np.sin(2 * np.pi * 5 * t_axis(0.9)))
    save("moan", voice(f0, 0.9, oh, 0.6) * env_swell(0.9, 0.3), 0.45)
    # Sargento Sem Pelotao: o apito (dois toques, com o "trinado" da bolinha)
    t = t_axis(0.7)
    trill = 1 + 0.035 * np.sign(np.sin(2 * np.pi * 34 * t))
    tone = sine(2900 * trill, 0.7) * 0.8 + bandpass(noise(0.7), 2500, 3500) * 0.4
    gate = np.where((t < 0.22) | ((t > 0.3) & (t < 0.68)), 1.0, 0.0)
    save("whistle", lowpass(gate, 60) * tone, 0.5)

    # Sistemas: inventario, forja, Orbe, escudo (no fim, pelo mesmo motivo)
    print("Sistemas")
    chime = mix(*(pad(sine(f, 0.5) * env_exp(0.5, 0.12), d) for f, d in ((1568.0, 0.0), (2093.0, 0.06), (2637.0, 0.12))))
    save("pickup", mix(chime, highpass(noise(0.3), 5000) * env_exp(0.3, 0.05) * 0.2), 0.45)
    thud = lowpass(noise(0.15), 700) * env_exp(0.15, 0.04)
    save("shield_up", mix(thud, metallic(0.15, 620, 0.04) * 0.25), 0.45)
    crash = mix(metallic(0.7, 410, 0.22), impact(0.3, 120, 45, 0.9), highpass(noise(0.5), 2500) * env_exp(0.5, 0.12) * 0.5)
    save("guard_break", np.tanh(crash * 1.8), 0.75)
    ring = mix(metallic(1.2, 980, 0.45), metallic(1.2, 1470, 0.3) * 0.5)
    strikes = mix(ring, pad(ring * 0.7, 0.28), pad(impact(0.12, 300, 120, 0.8), 0.0), pad(impact(0.12, 300, 120, 0.8) * 0.8, 0.28))
    sizzle = pad(highpass(noise(0.9), 3000) * env_swell(0.9, 0.2) * 0.3, 0.55)
    save("forge", mix(strikes, sizzle), 0.65)
    glow = mix(sine(sweep(523.3, 1046.5, 1.4, 0.6), 1.4), sine(sweep(659.3, 1318.5, 1.4, 0.6), 1.4) * 0.6)
    shimmer = bandpass(noise(1.4), 4000, 9000) * env_swell(1.4, 0.7) * 0.25
    save("purify", (glow * env_swell(1.4, 0.55) + shimmer), 0.45)

    # Bosque do Sono Eterno (no fim, pelo mesmo motivo)
    print("Bosque")
    t = t_axis(1.6)
    f0 = sweep(210, 120, 1.6, 0.7) * (1 + 0.02 * np.sin(2 * np.pi * 4 * t))
    ah = [(700, 5.0, 1.0), (1100, 6.0, 0.5), (2500, 8.0, 0.15)]
    save("yawn", voice(f0, 1.6, ah, 0.7) * env_swell(1.6, 0.35), 0.45)
    save("puff", lowpass(noise(0.6), sweep(2500, 400, 0.6)) * env_exp(0.6, 0.18, 0.03), 0.5)
    hoof = impact(0.09, 220, 90, 0.5)
    gallop = mix(*(pad(hoof * (0.8 + 0.2 * (i % 2)), i * 0.11) for i in range(8)))
    save("hooves", gallop, 0.6)
    bell = mix(*(pad(sine(f, 0.8) * env_exp(0.8, 0.25), d) for f, d in ((1760.0, 0.0), (2217.5, 0.07), (2637.0, 0.14))))
    save("chime", lowpass(bell, 5000), 0.35)
    grind = lowpass(noise(1.4), 300) * env_swell(1.4, 0.4) + metallic(1.4, 70, 0.6) * 0.3
    save("stone_wake", mix(grind, pad(impact(0.4, 90, 35, 0.4), 0.9)), 0.75)
    save("burst", mix(lowpass(noise(1.0), sweep(4000, 300, 1.0)) * env_exp(1.0, 0.3, 0.01), sine(sweep(160, 50, 0.8), 0.8) * env_exp(0.8, 0.2)), 0.7)
    s = 12.0
    t = t_axis(s)
    breeze = lowpass(noise(s), 500) * (0.6 + 0.4 * np.sin(2 * np.pi * t / s)) * 0.6
    water = bandpass(noise(s), 600, 2200) * 0.12
    chimes = np.zeros_like(t)
    for _ in range(6):
        i = int(rng.integers(0, len(t) - 40000))
        f = rng.choice([1046.5, 1318.5, 1568.0, 1760.0])
        d = sine(f, 1.2) * env_exp(1.2, 0.5) * rng.uniform(0.08, 0.16)
        chimes[i:i + len(d)] += d
    save_loop("amb_forest", breeze + water + chimes, 0.35)

    # Raizes da Fome (no fim, pelo mesmo motivo): tudo e molhado, mastigado, pulsando
    print("Raizes")
    wet = lowpass(noise(0.45), sweep(2200, 300, 0.45)) * env_exp(0.45, 0.12, 0.01)
    squeeze = sine(sweep(120, 70, 0.45), 0.45) * env_exp(0.45, 0.2) * 0.7
    save("grab", mix(wet, squeeze, pad(impact(0.12, 160, 80, 0.2), 0.0)), 0.7)
    bite = mix(impact(0.1, 260, 110, 0.9), highpass(noise(0.08), 1500) * env_exp(0.08, 0.02) * 0.6)
    save("chomp", mix(bite, pad(bite * 0.7, 0.16), pad(lowpass(noise(0.3), 700) * env_exp(0.3, 0.1) * 0.6, 0.05)), 0.7)
    t = t_axis(0.8)
    gurgle = bandpass(noise(0.8), 200 + 150 * (1 + np.sin(2 * np.pi * 9 * t)), 900) * env_swell(0.8, 0.3)
    save("slurp", mix(gurgle, sine(sweep(400, 900, 0.8, 0.5), 0.8) * env_swell(0.8, 0.6) * 0.25), 0.55)
    splat = mix(lowpass(noise(0.5), sweep(3000, 250, 0.5)) * env_exp(0.5, 0.1, 0.003), sine(sweep(140, 45, 0.4), 0.4) * env_exp(0.4, 0.12))
    save("splat", splat, 0.8)
    crack = mix(lowpass(noise(0.6), 600) * env_exp(0.6, 0.18, 0.02), impact(0.25, 110, 40, 0.5))
    snaps = mix(*(pad(highpass(noise(0.03), 2000) * env_exp(0.03, 0.008) * 0.5, d) for d in (0.05, 0.12, 0.2, 0.27)))
    save("root_burst", mix(crack, snaps), 0.75)
    t = t_axis(0.7)
    uh = [(420, 5.0, 1.0), (800, 6.0, 0.4), (2300, 8.0, 0.1)]
    save("gulp", mix(voice(sweep(130, 70, 0.7), 0.7, uh, 0.4) * env_swell(0.7, 0.4), pad(impact(0.15, 90, 40, 0.1), 0.35)), 0.6)
    s = 12.0
    t = t_axis(s)
    beat = np.zeros_like(t)
    for k in np.arange(0.0, s, 1.25):  # "raizes que pulsam como veias": um coracao lento
        for d, g in ((0.0, 1.0), (0.22, 0.7)):
            i = int((k + d) * SR)
            thump = sine(sweep(70, 40, 0.25), 0.25) * env_exp(0.25, 0.07)
            beat[i:i + len(thump)] += thump[: len(beat) - i] * g
    wind = lowpass(noise(s), 380) * (0.6 + 0.4 * np.sin(2 * np.pi * t / s)) * 0.45
    drips = np.zeros_like(t)
    for _ in range(8):
        i = int(rng.integers(0, len(t) - 8000))
        d = lowpass(noise(0.2), 900) * env_exp(0.2, 0.04) * rng.uniform(0.3, 0.6)
        drips[i:i + len(d)] += d
    save_loop("amb_roots", beat * 0.55 + wind + drips, 0.38)

    # Forjas Ocas (no fim, pelo mesmo motivo): metal, raio e maquinas
    print("Forjas")
    t = t_axis(0.35)
    buzz = np.sign(np.sin(2 * np.pi * 120 * t)) * 0.3 + highpass(noise(0.35), 2500) * 0.7
    save("zap", mix(buzz * env_exp(0.35, 0.09, 0.002), metallic(0.3, 1800, 0.05) * 0.3), 0.6)
    save("clank", mix(metallic(0.35, 520, 0.08), impact(0.12, 200, 90, 0.6) * 0.5), 0.55)
    t = t_axis(0.9)
    save("hum", (sine(sweep(110, 330, 0.9, 0.6), 0.9) + sine(sweep(220, 660, 0.9, 0.6), 0.9) * 0.4) * env_swell(0.9, 0.85), 0.45)
    shimmer = mix(*(pad(sine(f, 1.2) * env_exp(1.2, 0.5), d) for f, d in ((1975.5, 0.0), (2489.0, 0.06), (2960.0, 0.12), (3951.0, 0.18))))
    save("mirror", mix(shimmer, bandpass(noise(1.2), 5000, 9000) * env_swell(1.2, 0.3) * 0.2), 0.4)
    rumble = lowpass(noise(2.2), sweep(200, 60, 2.2)) * env_swell(2.2, 0.15)
    save("quake", mix(rumble, metallic(2.0, 60, 0.9) * 0.4, pad(impact(0.5, 70, 30, 0.6), 0.1)), 0.85)
    s = 12.0
    t = t_axis(s)
    drone = (np.sin(2 * np.pi * 55 * t) * 0.5 + np.sin(2 * np.pi * 82.5 * t) * 0.25) * (0.7 + 0.3 * np.sin(2 * np.pi * t / 6))
    hiss = bandpass(noise(s), 1500, 4000) * 0.06
    hits = np.zeros_like(t)
    for k in np.arange(0.4, s - 1.0, 2.3):  # o martelo distante de alguém que nunca para
        i = int(k * SR)
        ring = metallic(0.8, 700, 0.18) * 0.25
        hits[i:i + len(ring)] += ring[: len(hits) - i]
    save_loop("amb_forge", lowpass(drone, 400) * 0.6 + hiss + hits, 0.38)

    # Montanha Carbonizada (no fim, pelo mesmo motivo): fogo, asas e o vulcao
    print("Montanha")
    roar_f = lowpass(noise(0.7), sweep(3000, 500, 0.7)) * env_exp(0.7, 0.25, 0.01)
    save("fireball", mix(roar_f, pad(impact(0.25, 120, 50, 0.5) * 0.6, 0.35)), 0.6)
    t = t_axis(1.4)
    flame = bandpass(noise(1.4), 300, 2600) * (0.75 + 0.25 * np.sin(2 * np.pi * 13 * t)) * env_swell(1.4, 0.2)
    save("fire_breath", mix(flame, lowpass(noise(1.4), 180) * env_swell(1.4, 0.3) * 0.6), 0.7)
    flap = mix(*(pad(lowpass(noise(0.18), 700) * env_exp(0.18, 0.06, 0.02), d) for d in (0.0, 0.28)))
    save("wing", flap, 0.55)
    s = 12.0
    t = t_axis(s)
    rumble = lowpass(noise(s), 120) * (0.6 + 0.4 * np.sin(2 * np.pi * t / 4))
    crackle = np.zeros_like(t)
    for _ in range(90):  # brasas estalando no ar
        i = int(rng.integers(0, len(t) - 600))
        c = highpass(noise(0.01), 2000) * env_exp(0.01, 0.003) * rng.uniform(0.1, 0.35)
        crackle[i:i + len(c)] += c
    save_loop("amb_volcano", rumble * 1.4 + crackle + bandpass(noise(s), 400, 1200) * 0.04, 0.4)

    # Dominio Congelado (no fim, pelo mesmo motivo): gelo, cristal e vento
    print("Dominio")
    t = t_axis(0.3)
    save("ice_shot", mix(highpass(noise(0.3), 3500) * env_exp(0.3, 0.07), sine(sweep(2400, 900, 0.3), 0.3) * env_exp(0.3, 0.1) * 0.4), 0.5)
    crackle = np.zeros(int(SR * 0.9))
    for _ in range(40):  # o gelo estalando ao se formar
        i = int(rng.integers(0, len(crackle) - 400))
        c = highpass(noise(0.008), 3000) * env_exp(0.008, 0.002) * rng.uniform(0.3, 0.9)
        crackle[i:i + len(c)] += c
    save("freeze", mix(crackle, bandpass(noise(0.9), 2000, 7000) * env_swell(0.9, 0.2) * 0.3), 0.6)
    shards = mix(*(pad(metallic(0.4, f, 0.08) * 0.3, d) for f, d in ((2600, 0.0), (3300, 0.03), (4100, 0.06))))
    save("shatter", mix(shards, highpass(noise(0.4), 2500) * env_exp(0.4, 0.08) * 0.8), 0.6)
    chime = mix(*(pad(sine(f, 0.8) * env_exp(0.8, 0.3), d) for f, d in ((1568.0, 0.0), (2093.0, 0.05), (2637.0, 0.1))))
    save("crystal", chime, 0.4)
    s = 12.0
    t = t_axis(s)
    wind = bandpass(noise(s), 300, 1400) * (0.5 + 0.5 * np.sin(2 * np.pi * t / 5.5)) * 0.5
    tones = np.zeros_like(t)
    for k in np.arange(0.7, s - 1.2, 2.9):  # cristais tilintando longe
        i = int(k * SR)
        ring = sine(2093.0 * float(rng.choice([1.0, 1.25, 1.5])), 1.0) * env_exp(1.0, 0.4) * 0.08
        tones[i:i + len(ring)] += ring[: len(tones) - i]
    save_loop("amb_ice", lowpass(wind, 1200) + tones, 0.4)

    # O Nucleo (no fim, pelo mesmo motivo): gravidade, sino e o coracao da ilha
    print("Nucleo")
    t = t_axis(1.2)
    save("gravity", mix(sine(sweep(50, 140, 1.2, 0.7), 1.2) * env_swell(1.2, 0.8), lowpass(noise(1.2), sweep(200, 900, 1.2)) * env_swell(1.2, 0.8) * 0.5), 0.7)
    bell = mix(*(sine(f, 3.0) * env_exp(3.0, d) * a for f, d, a in ((392.0, 1.4, 1.0), (784.0, 0.9, 0.5), (1176.0, 0.6, 0.3), (987.8, 0.7, 0.25))))
    save("bell", bell, 0.55)
    s = 12.0
    t = t_axis(s)
    beat = np.zeros_like(t)
    for k in np.arange(0.3, s - 0.6, 1.5):  # um coracao lento, de muito longe
        for d, a in ((0.0, 1.0), (0.22, 0.6)):
            i = int((k + d) * SR)
            thump = sine(48.0, 0.25) * env_exp(0.25, 0.08) * a * 0.5
            beat[i:i + len(thump)] += thump[: len(beat) - i]
    pad_tone = (np.sin(2 * np.pi * 220 * t) + 0.5 * np.sin(2 * np.pi * 277.2 * t) + 0.4 * np.sin(2 * np.pi * 329.6 * t)) * 0.05 * (0.6 + 0.4 * np.sin(2 * np.pi * t / 6))
    save_loop("amb_core", beat + pad_tone + bandpass(noise(s), 500, 2500) * 0.02, 0.4)


if __name__ == "__main__":
    main()
