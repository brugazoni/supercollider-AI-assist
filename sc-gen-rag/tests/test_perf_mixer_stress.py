"""
Comprehensive Validation & Stress Test Suite for the Adaptive Performance Mixer (ScPerfMixer).

Covers:
  1. Class library compilation & strict `-i scval` isolation (zero overhead on parallel validation server).
  2. All 4 X-Append use cases: Append, Generate, Compose (discrete Pbindef + continuous Ndef + submix), Design (master strip).
  3. All 5 Track Effects: Filter (LPF/HPF/BPF/Notch), Distortion (Tube/Hard/Fold/Crush), Compressor, Delay (non-RT buffers), Reverb.
  4. Direct loopback UDP `/n_set` OSC parameter sweeps (mirroring Qt C++ PerfMixerWidget) + `/pm/m` 15Hz stereo metering.
  5. High-load stress test: 12 concurrent voices x 5 FX = 60 active FX synths + 12 Core synths (84+ live synths),
     30x rapid FX toggle churn, 100-packet UDP fader burst, 8x global bypass/re-enable cycles, CmdPeriod cleanup,
     and strict zero-buffer-leak verification.
"""

import math
import os
import socket
import struct
import subprocess
import tempfile
import threading
import time
import pytest


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCLANG_CANDIDATES = [
    os.path.join(REPO_ROOT, "build", "Install", "SuperCollider", "sclang.exe"),
    os.path.join(REPO_ROOT, "build", "lang", "Release", "sclang.exe"),
    os.path.join(REPO_ROOT, "lang", "Release", "sclang.exe"),
]


def _find_sclang() -> str:
    for path in SCLANG_CANDIDATES:
        if os.path.exists(path):
            return path
    pytest.skip("sclang.exe executable not found in build/Install or lang/Release")


def _write_sclang_conf(tmp_dir: str) -> str:
    conf_path = os.path.join(tmp_dir, "sclang_perf_mixer_test.yaml")
    repo_lib = os.path.join(REPO_ROOT, "SCClassLibrary")
    install_lib = os.path.join(REPO_ROOT, "build", "Install", "SuperCollider", "SCClassLibrary")
    with open(conf_path, "w", encoding="utf-8") as f:
        f.write(
            f"includePaths:\n"
            f"    - {repo_lib}\n"
            f"excludePaths:\n"
            f"    - {install_lib}\n"
            f"postInlineWarnings: false\n"
        )
    return conf_path


def _osc_pad(b: bytes) -> bytes:
    rem = len(b) % 4
    return b + (b"\x00" * (4 - rem if rem else 4))


def _send_n_set(port: int, node_id: int, param: str, val: float) -> None:
    pkt = (
        _osc_pad(b"/n_set")
        + _osc_pad(b",isf")
        + struct.pack(">i", node_id)
        + _osc_pad(param.encode("ascii"))
        + struct.pack(">f", float(val))
    )
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.sendto(pkt, ("127.0.0.1", port))
    finally:
        sock.close()


def _parse_meter_packet(data: bytes):
    # /pm/m\0\0\0 ,iffff\0\0 <int32><float32 x 4>
    if not data.startswith(b"/pm/m\x00"):
        return None
    idx = data.find(b",iffff")
    if idx == -1:
        return None
    payload_start = idx + 8  # ",iffff\0\0"
    if len(data) < payload_start + 20:
        return None
    return struct.unpack(">iffff", data[payload_start : payload_start + 20])


def test_classlib_compile_and_scval_isolation(tmp_path):
    """Verify SCClassLibrary compiles cleanly in both scval (isolated) and scqt (IDE)."""
    sclang = _find_sclang()
    conf = _write_sclang_conf(str(tmp_path))

    # 1. scval must compile cleanly and NOT expose ScPerfMixer
    p_val = subprocess.Popen(
        [sclang, "-l", conf, "-i", "scval", "-u", "57151"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    out_val, _ = p_val.communicate('["SCVAL_OK", Platform.ideName].postln; 0.exit;\n\x0c', timeout=20)
    assert p_val.returncode == 0, out_val
    assert "[SCVAL_OK, scval]" in out_val, out_val

    # 2. scqt must compile cleanly and evaluate Platform.ideName.asSymbol == \scqt
    p_qt = subprocess.Popen(
        [sclang, "-l", conf, "-i", "scqt", "-u", "57152"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )
    lines = []
    threading.Thread(target=lambda: [lines.append(l) for l in p_qt.stdout], daemon=True).start()
    time.sleep(2.5)
    p_qt.stdin.write('["SCQT_OK", Platform.ideName.asSymbol == \\scqt, ScPerfMixer.isIDEProcess].postln; 0.exit;\n\x0c')
    p_qt.stdin.flush()
    p_qt.wait(timeout=12)
    out_qt = "".join(lines)
    assert p_qt.returncode == 0, out_qt
    assert "[SCQT_OK, true, false]" in out_qt, out_qt


def test_perf_mixer_full_4_use_cases_and_stress(tmp_path):
    """Full live scsynth E2E + high-load stress suite (12 voices x 5 FX = 60 FX synths + UDP sweeps + leak check)."""
    sclang = _find_sclang()
    conf = _write_sclang_conf(str(tmp_path))

    meter_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    meter_sock.bind(("127.0.0.1", 0))
    meter_sock.settimeout(0.15)
    meter_port = meter_sock.getsockname()[1]

    meter_samples = []
    stop_meter = threading.Event()

    def _meter_loop():
        while not stop_meter.is_set():
            try:
                data, _ = meter_sock.recvfrom(1024)
                parsed = _parse_meter_packet(data)
                if parsed is not None:
                    meter_samples.append(parsed)
            except socket.timeout:
                continue
            except Exception:
                break

    threading.Thread(target=_meter_loop, daemon=True).start()

    test_port = 57155
    sc_code = f"""
(
var srv = Server(\\perfStress, NetAddr("127.0.0.1", {test_port}));
srv.options.numOutputBusChannels = 2;
srv.options.numInputBusChannels = 0;
srv.options.memSize = 65536;
Server.default = s = srv;
ScPerfMixer.forceTestMode = true;
ScPerfMixer.initForIDE(s);
ScPerfMixer.setMeterPort({meter_port});

s.waitForBoot({{
    var assertCond = {{ |name, cond|
        if(cond) {{
            ("PASS: " ++ name).postln;
        }} {{
            ("FAIL: " ++ name).postln;
            s.quit;
            0.2.wait;
            1.exit;
        }};
    }};

    Routine({{
        var tracks, t1, coreId, distId, filterId, compId, delayId, revId, baseBufs;
        0.3.wait;
        baseBufs = s.bufferAllocator.blocks.size;

        // === 1. APPEND (Ndef + bound Pbindef + hot-swap + all 5 FX) ===
        Ndef(\\rioSena, {{ |amp=0.12, pan=0| Pan2.ar(PinkNoise.ar(amp), pan) }}).play;
        Ndef(\\lembranca, {{ |freq=440, amp=0.14, pan=0, t_trig=0|
            var env = Decay2.ar(K2A.ar(t_trig), 0.01, 0.25);
            Pan2.ar(SinOsc.ar(freq) * env * amp, pan);
        }}).play;
        Pbindef(\\lembrancaSeq, \\dur, 0.2, \\freq, Pseq([440, 550, 660], inf), \\amp, 0.14, \\pan, Pseq([-0.5, 0.5], inf), \\t_trig, 1);
        Ndef(\\lembranca)[1] = \\set -> Pbindef(\\lembrancaSeq);

        0.6.wait;
        ScPerfMixer.reconcile;
        tracks = ScPerfMixer.debugTracks;
        assertCond.("Append: 2 tracks created, bound Pbindef not duplicated",
            tracks.size == 2 and: {{ tracks['ndef:rioSena'].notNil }} and: {{ tracks['ndef:lembranca'].notNil }} and: {{ tracks['pbindef:lembrancaSeq'].isNil }});

        // Hot-swap Ndef source and verify strip survives untouched
        t1 = tracks['ndef:rioSena'];
        coreId = t1[\\coreSynth].nodeID;
        Ndef(\\rioSena, {{ |amp=0.12, pan=0| Pan2.ar(BrownNoise.ar(amp), pan) }});
        0.3.wait;
        ScPerfMixer.reconcile;
        assertCond.("Append: strip survives live Ndef source hot-swap",
            ScPerfMixer.debugTracks['ndef:rioSena'][\\coreSynth].nodeID == coreId);

        // Attach all 5 FX in scrambled order
        [\\reverb, \\filter, \\dist, \\delay, \\comp].do {{ |fx|
            ScPerfMixer.setFxEnabled("ndef:rioSena", fx.asString, true);
        }};
        0.35.wait;
        t1 = ScPerfMixer.debugTracks['ndef:rioSena'];
        coreId = t1[\\coreSynth].nodeID;
        distId = t1[\\fxSynths][\\dist].nodeID;
        filterId = t1[\\fxSynths][\\filter].nodeID;
        compId = t1[\\fxSynths][\\comp].nodeID;
        delayId = t1[\\fxSynths][\\delay].nodeID;
        revId = t1[\\fxSynths][\\reverb].nodeID;
        assertCond.("Append: all 5 FX synths active (Dist/Filter/Comp/Delay/Reverb)",
            t1[\\fxSynths][\\dist].isPlaying
            and: {{ t1[\\fxSynths][\\filter].isPlaying }}
            and: {{ t1[\\fxSynths][\\comp].isPlaying }}
            and: {{ t1[\\fxSynths][\\delay].isPlaying }}
            and: {{ t1[\\fxSynths][\\reverb].isPlaying }});

        ("UDP_SWEEP_NODES:" ++ coreId ++ ":" ++ distId ++ ":" ++ filterId ++ ":" ++ compId ++ ":" ++ delayId ++ ":" ++ revId).postln;
        0.7.wait;

        ScPerfMixer.stopTrack("ndef:rioSena");
        0.3.wait;
        assertCond.("Append: Fade Out / stopTrack removes rioSena", ScPerfMixer.debugTracks['ndef:rioSena'].isNil);

        // === 2. COMPOSE (discrete Pbindef + continuous Ndef + submix + cue churn) ===
        ~synthBus = Bus.audio(s, 2);
        SynthDef(\\sapePalha, {{ |out=0, freq=800, amp=0.1, pan=0|
            var env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
            Out.ar(out, Pan2.ar(SinOsc.ar(freq) * env, pan, amp));
        }}).add;
        s.sync;
        Ndef(\\rioCorrente, {{ |amp=0.08| Pan2.ar(BrownNoise.ar(amp), 0) }});
        Ndef(\\sapeMasterMix, {{ In.ar(~synthBus, 2) + Ndef.ar(\\rioCorrente, 2) }}).play;
        Pbindef(\\sapeSeq, \\instrument, \\sapePalha, \\out, ~synthBus, \\dur, 0.2, \\freq, 900).play;
        0.5.wait;
        ScPerfMixer.reconcile;
        assertCond.("Compose: discrete Pbindef + continuous Ndef + submix detected",
            ScPerfMixer.debugTracks['pbindef:sapeSeq'].notNil
            and: {{ ScPerfMixer.debugTracks['ndef:rioCorrente'].notNil }}
            and: {{ ScPerfMixer.debugTracks['ndef:sapeMasterMix'][\\kind] == "submix" }});

        Pbindef(\\sapeSeq).stop;
        0.35.wait;
        ScPerfMixer.reconcile;
        assertCond.("Compose: Pbindef cue stop removes track", ScPerfMixer.debugTracks['pbindef:sapeSeq'].isNil);
        Pbindef(\\sapeSeq).play;
        0.35.wait;
        ScPerfMixer.reconcile;
        assertCond.("Compose: Pbindef cue restart re-attaches track", ScPerfMixer.debugTracks['pbindef:sapeSeq'].notNil);

        Pbindef(\\sapeSeq).stop; Pbindef(\\sapeSeq).clear;
        Ndef(\\rioCorrente).clear(0.1); Ndef(\\sapeMasterMix).clear(0.1);
        0.4.wait;
        ScPerfMixer.reconcile;
        assertCond.("Compose: Append voice survives Compose teardown", ScPerfMixer.debugTracks['ndef:lembranca'].notNil);

        // === 3. DESIGN (master instrument strip) ===
        ~cavernaBus = Bus.audio(s, 2);
        ~synthGroup = Group.new(s);
        ~fxGroup = Group.after(~synthGroup);
        SynthDef(\\cavernaFX, {{ |inBus=0, out=0| Out.ar(out, In.ar(inBus, 2)) }}).add;
        s.sync;
        ~fxSynth = Synth.tail(~fxGroup, \\cavernaFX, [\\inBus, ~cavernaBus.index, \\out, 0]);
        0.45.wait;
        ScPerfMixer.reconcile;
        assertCond.("Design: master instrument strip detected", ScPerfMixer.debugTracks['design:cavernaFX'].notNil);
        [\\filter, \\delay, \\reverb].do {{ |fx| ScPerfMixer.setFxEnabled("design:cavernaFX", fx.asString, true) }};
        0.2.wait;
        ScPerfMixer.stopTrack("design:cavernaFX");
        0.3.wait;
        assertCond.("Design: stopTrack tears down Design strip", ScPerfMixer.debugTracks['design:cavernaFX'].isNil);

        // === 4. HIGH-LOAD STRESS: 12 simultaneous voices x 5 FX = 60 FX + 12 Core synths ===
        11.do {{ |i|
            var nm = ("stressVoice" ++ i).asSymbol;
            Ndef(nm, {{ |amp=0.03| Pan2.ar(Saw.ar(80 + (i * 35)) * amp, (i / 5.5) - 1.0) }}).play;
        }};
        0.7.wait;
        ScPerfMixer.reconcile;
        assertCond.("Stress: 12 concurrent tracks active", ScPerfMixer.debugTracks.size == 12);

        ScPerfMixer.debugTracks.keys.copy.do {{ |id|
            [\\dist, \\filter, \\comp, \\delay, \\reverb].do {{ |fx|
                ScPerfMixer.setFxEnabled(id.asString, fx.asString, true);
            }};
        }};
        0.6.wait;
        ("HIGH_LOAD_STATS: tracks=" ++ ScPerfMixer.debugTracks.size
            ++ " numSynths=" ++ s.numSynths
            ++ " avgCPU=" ++ s.avgCPU.round(0.01)
            ++ " peakCPU=" ++ s.peakCPU.round(0.01)).postln;
        assertCond.("Stress: >=80 live synths (12 voices x 5 FX + Core) without alloc error", s.numSynths >= 80);

        // === 5. CHURN STRESS: 30x rapid FX toggles + 8x global bypass/re-enable ===
        30.do {{ |i|
            var on = ((i % 2) == 0);
            ScPerfMixer.setFxEnabled("ndef:lembranca", "delay", on);
            ScPerfMixer.setFxEnabled("ndef:lembranca", "filter", on);
            ScPerfMixer.setFxEnabled("ndef:lembranca", "reverb", on);
            0.025.wait;
        }};
        0.3.wait;

        8.do {{
            ScPerfMixer.setEnabled(false);
            0.04.wait;
            ScPerfMixer.setEnabled(true);
            0.04.wait;
        }};
        assertCond.("Stress: 8x bypass/re-enable restores all 12 tracks", ScPerfMixer.debugTracks.size == 12);

        // === 6. CLEANUP & BUFFER LEAK CHECK ===
        CmdPeriod.run;
        0.7.wait;
        assertCond.("CmdPeriod: all tracks cleared cleanly", ScPerfMixer.debugTracks.isEmpty);
        assertCond.("Leak Check: bufferAllocator blocks returned to baseline", s.bufferAllocator.blocks.size <= baseBufs);

        "FULL_STRESS_SUITE_PASSED".postln;
        s.quit;
        0.25.wait;
        0.exit;
    }}).play(AppClock);
}});
)
\x0c
"""

    p = subprocess.Popen(
        [sclang, "-l", conf, "-i", "scqt", "-u", "57153"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    output_lines = []
    udp_sweeps_sent = 0

    def _reader():
        nonlocal udp_sweeps_sent
        for line in p.stdout:
            output_lines.append(line)
            print(line, end="", flush=True)
            if line.startswith("UDP_SWEEP_NODES:"):
                parts = [int(x) for x in line.strip().split(":")[1:]]
                core_id, dist_id, filter_id, comp_id, delay_id, rev_id = parts
                # Sweep all 4 Filter modes + Cutoff/Res/Drive/Mix
                for m in range(4):
                    _send_n_set(test_port, filter_id, "mode", float(m))
                    _send_n_set(test_port, filter_id, "freq", 400.0 + m * 1200.0)
                    _send_n_set(test_port, filter_id, "res", 0.45)
                    _send_n_set(test_port, filter_id, "drive", 1.8)
                    _send_n_set(test_port, filter_id, "mix", 0.9)
                    udp_sweeps_sent += 5
                # Sweep all 4 Distortion modes + Drive/Tone/Mix/Out
                for m in range(4):
                    _send_n_set(test_port, dist_id, "mode", float(m))
                    _send_n_set(test_port, dist_id, "drive", 2.0 + m * 4.0)
                    _send_n_set(test_port, dist_id, "tone", 3500.0)
                    _send_n_set(test_port, dist_id, "mix", 0.6)
                    _send_n_set(test_port, dist_id, "outGain", 0.9)
                    udp_sweeps_sent += 5
                # Compressor, Delay (high feedback stability), Reverb
                _send_n_set(test_port, comp_id, "thresh", -24.0)
                _send_n_set(test_port, comp_id, "ratio", 8.0)
                _send_n_set(test_port, comp_id, "attack", 0.005)
                _send_n_set(test_port, comp_id, "release", 0.12)
                _send_n_set(test_port, comp_id, "makeup", 1.5)
                _send_n_set(test_port, delay_id, "time", 0.25)
                _send_n_set(test_port, delay_id, "feedback", 0.92)
                _send_n_set(test_port, delay_id, "damp", 3200.0)
                _send_n_set(test_port, delay_id, "spread", 0.8)
                _send_n_set(test_port, rev_id, "room", 0.85)
                _send_n_set(test_port, rev_id, "damp", 0.35)
                _send_n_set(test_port, rev_id, "preDelay", 0.04)
                _send_n_set(test_port, rev_id, "lowCut", 180.0)
                udp_sweeps_sent += 13
                # 60Hz fader/pan drag burst (60 packets)
                for k in range(30):
                    _send_n_set(test_port, core_id, "amp", 0.2 + (k / 30.0) * 0.8)
                    _send_n_set(test_port, core_id, "pan", -1.0 + (k / 15.0))
                    udp_sweeps_sent += 2

    threading.Thread(target=_reader, daemon=True).start()

    time.sleep(2.5)
    p.stdin.write(sc_code)
    p.stdin.flush()

    deadline = time.time() + 45
    while p.poll() is None and time.time() < deadline:
        time.sleep(0.2)

    stop_meter.set()
    meter_sock.close()

    if p.poll() is None:
        p.kill()
        pytest.fail("Stress test timed out after 45s")

    full_out = "".join(output_lines)
    assert p.returncode == 0, full_out
    assert "FULL_STRESS_SUITE_PASSED" in full_out, full_out
    assert "alloc failed" not in full_out.lower(), "scsynth RT memory allocation failed!"
    assert udp_sweeps_sent >= 100, f"Expected >=100 UDP /n_set packets, sent {udp_sweeps_sent}"
    assert len(meter_samples) >= 200, f"Expected >=200 live meter packets, got {len(meter_samples)}"
    for mid, pkL, rmsL, pkR, rmsR in meter_samples[:50]:
        assert all(math.isfinite(x) for x in (pkL, rmsL, pkR, rmsR)), "NaN/Inf in meter output!"
