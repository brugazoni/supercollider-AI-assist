import json
import re


def _empty_patch_state() -> dict:
    return {
        "version": 2,
        "ndefs": {},
        "pbindefs": {},
        "synthdefs": {},
        "tdefs": {},
        "design": {
            "active": False,
            "gui_vars": [],
            "groups": [],
            "mididefs": [],
            "cc_keys": [],
        },
        "buses": [],
    }


def _strip_comments_and_strings(code: str) -> str:
    """Strip SuperCollider comments while preserving string literals safely."""
    clean = re.sub(r'//.*', '', code)
    clean = re.sub(r'/\*.*?\*/', '', clean, flags=re.DOTALL)
    return clean


def _find_matching_brace(text: str, open_pos: int) -> int:
    """Return index of matching '}' for '{' at open_pos, or -1."""
    if open_pos < 0 or open_pos >= len(text) or text[open_pos] != '{':
        return -1
    depth = 0
    in_line = False
    in_block = False
    in_str = False
    str_ch = ''
    i = open_pos
    n = len(text)
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ''
        if in_line:
            if c == '\n':
                in_line = False
            i += 1
            continue
        if in_block:
            if c == '*' and nxt == '/':
                in_block = False
                i += 2
                continue
            i += 1
            continue
        if in_str:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == str_ch:
                in_str = False
            i += 1
            continue
        if c == '/' and nxt == '/':
            in_line = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block = True
            i += 2
            continue
        if c in ('"', "'"):
            in_str = True
            str_ch = c
            i += 1
            continue
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def _extract_func_args(body: str) -> list[str]:
    """Extract |a=1, b=2| or arg a=1, b=2; parameter declarations from the top of a SC closure."""
    stripped = body.lstrip()
    if stripped.startswith('|'):
        end_pipe = stripped.find('|', 1)
        if end_pipe != -1:
            raw_args = stripped[1:end_pipe]
            return [a.strip() for a in raw_args.split(',') if a.strip()]
    m_arg = re.match(r'\s*arg\s+([^;]+);', stripped, re.DOTALL)
    if m_arg:
        return [a.strip() for a in m_arg.group(1).split(',') if a.strip()]
    return []


def _extract_paren_body(text: str, open_paren_pos: int) -> str:
    """Extract content inside balanced (...) starting at open_paren_pos."""
    if open_paren_pos < 0 or open_paren_pos >= len(text) or text[open_paren_pos] != '(':
        return ""
    depth = 0
    in_str = False
    str_ch = ''
    for i in range(open_paren_pos, len(text)):
        c = text[i]
        if in_str:
            if c == '\\':
                continue
            if c == str_ch:
                in_str = False
            continue
        if c in ('"', "'"):
            in_str = True
            str_ch = c
            continue
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return text[open_paren_pos + 1:i]
    return ""


def parse_state_to_dict(previous_state: str) -> dict:
    """Parse previous state (either embedded Patch JSON, raw JSON, or legacy text) into a canonical dict."""
    state = _empty_patch_state()
    if not previous_state or previous_state.strip() in ("", "(Empty)"):
        return state

    # 1. Fast path: embedded Patch JSON block
    m_json = re.search(r'(?m)^Patch JSON:\s*\n(\{.*\})\s*$', previous_state)
    if m_json:
        try:
            loaded = json.loads(m_json.group(1))
            if isinstance(loaded, dict):
                for k in state:
                    if k in loaded:
                        state[k] = loaded[k]
                return state
        except Exception:
            pass

    # 2. Pure JSON string
    stripped = previous_state.strip()
    if stripped.startswith('{') and stripped.endswith('}'):
        try:
            loaded = json.loads(stripped)
            if isinstance(loaded, dict):
                for k in state:
                    if k in loaded:
                        state[k] = loaded[k]
                return state
        except Exception:
            pass

    # 3. Legacy bullet-list text format parser (backward compatibility)
    current_ndef = None
    current_section = None
    for line in previous_state.split('\n'):
        line = line.strip()
        if not line:
            continue
        if line.startswith("Active Ndefs"):
            current_section = "ndefs"
            current_ndef = None
            continue
        elif line.startswith("Active Pbindefs"):
            current_section = "pbindefs"
            current_ndef = None
            continue
        elif line.startswith("Loaded SynthDefs"):
            current_section = "synthdefs"
            current_ndef = None
            continue
        elif line.startswith("Active Tdefs"):
            current_section = "tdefs"
            current_ndef = None
            continue
        elif line.startswith("Shared Buses"):
            current_section = "buses"
            current_ndef = None
            continue

        m_item = re.match(r'-\s*\\(\w+)', line)
        if m_item:
            name = m_item.group(1)
            if current_section == "ndefs":
                current_ndef = name
                state["ndefs"].setdefault(name, {
                    "args": [],
                    "playing": True,
                    "bound_pbindef": None,
                    "slots": {},
                    "params": {},
                })
            elif current_section == "pbindefs":
                state["pbindefs"].setdefault(name, {"keys": [], "out_bus": None, "playing": True})
            elif current_section == "synthdefs":
                state["synthdefs"].setdefault(name, {"args": []})
            elif current_section == "tdefs":
                state["tdefs"].setdefault(name, {"playing": True})
            continue

        if current_section == "buses" and line.startswith("- ~"):
            bname = line[2:].strip()
            if bname not in state["buses"]:
                state["buses"].append(bname)
            continue

        if current_ndef and line.startswith('- Slot'):
            m_slot = re.search(r'Slot\s+(\d+):\s*(.*)', line)
            if m_slot:
                state["ndefs"][current_ndef]["slots"][m_slot.group(1)] = m_slot.group(2).strip()
                continue

        if current_ndef and (line.startswith('- wet') or line.startswith('- \\wet')):
            m_wet = re.search(r'\\?(wet\d+):\s*(.*)', line)
            if m_wet:
                state["ndefs"][current_ndef]["params"][m_wet.group(1)] = m_wet.group(2).strip()

    return state


def apply_code_to_patch_state(state: dict, new_code: str) -> dict:
    """Update a canonical patch state dict deterministically from newly generated SC code."""
    if not new_code or not new_code.strip():
        return state

    clean_code = _strip_comments_and_strings(new_code)

    # Track global wipes and their positions so additions after them still take effect
    global_ndef_clears = [m.end() for m in re.finditer(r'\bNdef\.(?:clear|all\.do)\b', clean_code)]
    global_pbind_clears = [m.end() for m in re.finditer(r'\bP(?:bindef|def)\.(?:removeAll|clear)\b', clean_code)]
    global_tdef_clears = [m.end() for m in re.finditer(r'\bTdef\.(?:removeAll|clear)\b', clean_code)]
    global_midi_clears = [m.end() for m in re.finditer(r'\bMIDIdef\.freeAll\b', clean_code)]

    last_global_ndef_clear = max(global_ndef_clears) if global_ndef_clears else -1
    last_global_pbind_clear = max(global_pbind_clears) if global_pbind_clears else -1
    last_global_tdef_clear = max(global_tdef_clears) if global_tdef_clears else -1
    last_global_midi_clear = max(global_midi_clears) if global_midi_clears else -1

    if last_global_ndef_clear != -1:
        state["ndefs"] = {}
    if last_global_pbind_clear != -1:
        state["pbindefs"] = {}
    if last_global_tdef_clear != -1:
        state["tdefs"] = {}
    if last_global_midi_clear != -1:
        state["design"]["mididefs"] = []

    # 1. Ndef(\name, { ... }) definitions
    ndef_additions = {}
    for m in re.finditer(r'\bNdef\(\s*\\(\w+)\s*,\s*\{', clean_code):
        ndef = m.group(1)
        brace_pos = m.end() - 1
        close_brace = _find_matching_brace(clean_code, brace_pos)
        body = clean_code[brace_pos + 1:close_brace] if close_brace != -1 else ""
        args = _extract_func_args(body)

        entry = state["ndefs"].setdefault(ndef, {
            "args": [],
            "playing": True,
            "bound_pbindef": None,
            "slots": {},
            "params": {},
        })
        if args:
            entry["args"] = args
        entry["playing"] = True
        ndef_additions[ndef] = m.end()

    # 2. Pbindef(\name, ...) definitions & updates
    pbindef_additions = {}
    for m in re.finditer(r'\bPbindef\(\s*\\(\w+)\s*,', clean_code):
        pbindef = m.group(1)
        open_paren = clean_code.find('(', m.start())
        body = _extract_paren_body(clean_code, open_paren)
        keys = []
        for km in re.finditer(r'\\([a-zA-Z_]\w*)\s*,', body):
            k = km.group(1)
            if k != pbindef and k not in keys:
                keys.append(k)
        out_bus = None
        m_out = re.search(r'\\out\s*,\s*(~[a-zA-Z_]\w*|0)\b', body)
        if m_out:
            out_bus = m_out.group(1)

        entry = state["pbindefs"].setdefault(pbindef, {"keys": [], "out_bus": None, "playing": True})
        for k in keys:
            if k not in entry["keys"]:
                entry["keys"].append(k)
        if out_bus is not None:
            entry["out_bus"] = out_bus
        entry["playing"] = True
        pbindef_additions[pbindef] = m.end()

    # 3. JITLib slot bindings: Ndef(\name)[1] = \set -> Pbindef(\seq)
    for m in re.finditer(r'\bNdef\(\s*\\(\w+)\s*\)\s*\[\s*\d+\s*\]\s*=\s*\\set(?:src)?\s*->\s*Pbindef\(\s*\\(\w+)', clean_code):
        ndef, pseq = m.group(1), m.group(2)
        if ndef in state["ndefs"]:
            state["ndefs"][ndef]["bound_pbindef"] = pseq

    # 4. Effect slots: Ndef(\name)[N] = \filter -> { ... }
    for m in re.finditer(r'\bNdef\(\s*\\(\w+)\s*\)\s*\[\s*(\d+)\s*\]\s*=\s*\\filter\s*->\s*\{', clean_code):
        ndef = m.group(1)
        slot = m.group(2)
        brace_pos = m.end() - 1
        close_brace = _find_matching_brace(clean_code, brace_pos)
        func = clean_code[brace_pos + 1:close_brace].strip() if close_brace != -1 else ""
        summary = re.search(r'(\w+\.ar[^\)]*\))', func)
        desc = summary.group(1) if summary else "effect filter"
        entry = state["ndefs"].setdefault(ndef, {
            "args": [],
            "playing": True,
            "bound_pbindef": None,
            "slots": {},
            "params": {},
        })
        entry["slots"][slot] = desc

    # 5. Parameter updates: Ndef(\name).set(...) / .xset(...)
    for m in re.finditer(r'\bNdef\(\s*\\(\w+)\s*\)\.[x]?set\(', clean_code):
        ndef = m.group(1)
        open_paren = clean_code.find('(', m.end() - 1)
        args_body = _extract_paren_body(clean_code, open_paren)
        if ndef in state["ndefs"] or m.end() > last_global_ndef_clear:
            entry = state["ndefs"].setdefault(ndef, {
                "args": [],
                "playing": True,
                "bound_pbindef": None,
                "slots": {},
                "params": {},
            })
            for pm in re.finditer(r'\\([a-zA-Z_]\w*)\s*,\s*([^,\)\n]+)', args_body):
                entry["params"][pm.group(1)] = pm.group(2).strip()

    # 6. SynthDef(\name, { ... })
    for m in re.finditer(r'\bSynthDef\(\s*\\(\w+)\s*,\s*\{', clean_code):
        sdef = m.group(1)
        if sdef in ("safetyLimiter", "diskRecorder"):
            continue
        brace_pos = m.end() - 1
        close_brace = _find_matching_brace(clean_code, brace_pos)
        body = clean_code[brace_pos + 1:close_brace] if close_brace != -1 else ""
        args = _extract_func_args(body)
        state["synthdefs"][sdef] = {"args": args}

    # 7. Tdef(\name, { ... })
    tdef_additions = {}
    for m in re.finditer(r'\bTdef\(\s*\\(\w+)\s*,\s*\{', clean_code):
        tname = m.group(1)
        state["tdefs"][tname] = {"playing": True}
        tdef_additions[tname] = m.end()

    # 8. Shared audio buses: ~varName = Bus.audio(...)
    for m in re.finditer(r'(~[a-zA-Z_]\w*)\s*=\s*Bus\.audio\s*\(', clean_code):
        bvar = m.group(1)
        if bvar not in state["buses"]:
            state["buses"].append(bvar)
    for m in re.finditer(r'(~[a-zA-Z_]\w*)\.free\b', clean_code):
        bvar = m.group(1)
        if bvar in state["buses"]:
            state["buses"].remove(bvar)

    # 9. Design synthesizer resources (MIDIdefs, Groups, Windows, ~cc / ~ccVals)
    design_mididefs = re.findall(r'\bMIDIdef\.(?:noteOn|noteOff|cc|polytouch|bend|program)\s*\(\s*\\(\w+)', clean_code)
    for md in design_mididefs:
        if md not in state["design"]["mididefs"]:
            state["design"]["mididefs"].append(md)
    design_groups = re.findall(r'(~(?:synthGroup|fxGroup|masterGroup|sourceGroup))\s*=\s*Group\.', clean_code)
    for grp in design_groups:
        if grp not in state["design"]["groups"]:
            state["design"]["groups"].append(grp)
    design_wins = re.findall(r'(~[a-zA-Z_]\w*Win)\s*=\s*Window\s*\(', clean_code)
    for w in design_wins:
        if w not in state["design"]["gui_vars"]:
            state["design"]["gui_vars"].append(w)
    m_cc = re.search(r'~ccVals\s*=\s*\(', clean_code)
    if m_cc:
        cc_body = _extract_paren_body(clean_code, m_cc.end() - 1)
        cc_keys = re.findall(r'\b([a-zA-Z_]\w*)\s*:', cc_body)
        if cc_keys:
            state["design"]["cc_keys"] = cc_keys[:24]

    if design_mididefs or design_groups or design_wins or m_cc or "~cc =" in clean_code or "~buses =" in clean_code:
        state["design"]["active"] = True

    # If a design teardown (close windows + freeAll + group free) ran after the last addition
    if last_global_midi_clear != -1 and not design_mididefs and not m_cc and not design_wins:
        state["design"] = _empty_patch_state()["design"]

    # 10. Individual removals (Ndef.clear, Pbindef.stop/clear, Tdef.stop/clear)
    for m in re.finditer(r'\bNdef\(\s*\\(\w+)\s*\)\.clear', clean_code):
        ndef = m.group(1)
        if ndef not in ndef_additions or m.end() > ndef_additions[ndef]:
            state["ndefs"].pop(ndef, None)

    for m in re.finditer(r'\bP(?:bindef|def)\(\s*\\(\w+)\s*\)\.(?:stop|clear)', clean_code):
        pbindef = m.group(1)
        if pbindef not in pbindef_additions or m.end() > pbindef_additions[pbindef]:
            state["pbindefs"].pop(pbindef, None)

    for m in re.finditer(r'\bTdef\(\s*\\(\w+)\s*\)\.(?:stop|clear)', clean_code):
        tname = m.group(1)
        # Keep Tdef if its .stop is inside its own closure (fixed-timeline self-stop)
        if tname not in tdef_additions:
            state["tdefs"].pop(tname, None)

    return state


def format_patch_state(state: dict, include_json: bool = True) -> str:
    """Format canonical patch state dict into LLM-readable sections + compact Patch JSON."""
    ndefs = state.get("ndefs", {})
    pbindefs = state.get("pbindefs", {})
    synthdefs = state.get("synthdefs", {})
    tdefs = state.get("tdefs", {})
    design = state.get("design", {})
    buses = state.get("buses", [])

    has_any = bool(ndefs or pbindefs or synthdefs or tdefs or buses or design.get("active"))
    if not has_any:
        return "(Empty)"

    out = []

    if ndefs:
        out.append("Active Ndefs:")
        for ndef in sorted(ndefs.keys()):
            info = ndefs[ndef]
            args = info.get("args") or []
            bound = info.get("bound_pbindef")
            meta_parts = []
            if args:
                meta_parts.append(f"args: {', '.join(args[:8])}")
            if bound:
                meta_parts.append(f"seq: \\{bound}")
            suffix = f" ({'; '.join(meta_parts)})" if meta_parts else ""
            out.append(f"- \\{ndef}{suffix}")

            slots = info.get("slots", {})
            for slot_id in sorted(slots.keys(), key=lambda x: int(x) if str(x).isdigit() else 0):
                out.append(f"  - Slot {slot_id}: {slots[slot_id]}")

            params = info.get("params", {})
            for p_name in sorted(params.keys()):
                out.append(f"  - \\{p_name}: {params[p_name]}")

    if pbindefs:
        if out:
            out.append("")
        out.append("Active Pbindefs:")
        for pb in sorted(pbindefs.keys()):
            info = pbindefs[pb]
            keys = info.get("keys") or []
            out_bus = info.get("out_bus")
            details = []
            if keys:
                details.append(f"keys: {', '.join('\\' + k for k in keys[:8])}")
            if out_bus:
                details.append(f"out: {out_bus}")
            suffix = f" ({'; '.join(details)})" if details else ""
            out.append(f"- \\{pb}{suffix}")

    if synthdefs:
        if out:
            out.append("")
        out.append("Loaded SynthDefs:")
        for sd in sorted(synthdefs.keys()):
            args = synthdefs[sd].get("args") or []
            suffix = f" (args: {', '.join(args[:8])})" if args else ""
            out.append(f"- \\{sd}{suffix}")

    if tdefs:
        if out:
            out.append("")
        out.append("Active Tdefs:")
        for td in sorted(tdefs.keys()):
            out.append(f"- \\{td}")

    if design.get("active"):
        if out:
            out.append("")
        out.append("Active Design Synth:")
        if design.get("mididefs"):
            out.append(f"- MIDIdefs: {', '.join('\\' + m for m in design['mididefs'])}")
        if design.get("groups"):
            out.append(f"- Groups: {', '.join(design['groups'])}")
        if design.get("gui_vars"):
            out.append(f"- Windows: {', '.join(design['gui_vars'])}")
        if design.get("cc_keys"):
            out.append(f"- CC/Bus params: {', '.join(design['cc_keys'][:16])}")

    if buses:
        if out:
            out.append("")
        out.append("Shared Buses:")
        for b in sorted(buses):
            out.append(f"- {b}")

    if include_json:
        out.append("")
        out.append("Patch JSON:")
        out.append(json.dumps(state, separators=(",", ":")))

    return "\n".join(out)


def get_patch_state_json(state_str: str) -> dict:
    """Return the structured dict representation of a composition state string."""
    return parse_state_to_dict(state_str)


def update_composition_state(previous_state: str, new_code: str) -> str:
    """
    Deterministically update the composition state by parsing the generated SC code
    across all X-Append use cases (append, generate, compose, design) into both
    human-readable summary sections and structured Patch JSON (<5ms, zero LLM calls).
    """
    state = parse_state_to_dict(previous_state)
    state = apply_code_to_patch_state(state, new_code)
    return format_patch_state(state, include_json=True)
