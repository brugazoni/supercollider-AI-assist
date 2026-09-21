import re

def update_composition_state(previous_state: str, new_code: str) -> str:
    """
    Deterministically update the composition state by parsing the generated SC code.
    This replaces a 10-15s background LLM call with a <5ms regex parse.
    """
    # 1. Parse previous state into structured memory
    active_ndefs = set()
    active_pbindefs = set()
    effects = {} # key: ndef_name, value: list of "slot_index: description"
    wetness = {} # key: ndef_name, value: list of "wetN: value"
    
    # Parse previous state
    current_ndef = None
    current_section = None
    if previous_state and previous_state != "(Empty)":
        for line in previous_state.split('\n'):
            line = line.strip()
            if not line:
                continue
                
            if line.startswith("Active Ndefs"):
                current_section = "ndefs"
                continue
            elif line.startswith("Active Pbindefs"):
                current_section = "pbindefs"
                continue
                
            # Match Ndef/Pbindef item
            m_item = re.match(r'-\s*\\(\w+)', line)
            if m_item:
                if current_section == "ndefs":
                    current_ndef = m_item.group(1)
                    active_ndefs.add(current_ndef)
                elif current_section == "pbindefs":
                    active_pbindefs.add(m_item.group(1))
                continue
                
            # Match Effects under current_ndef
            if current_ndef and line.startswith('- Slot'):
                m_slot = re.search(r'Slot (\d+):\s*(.*)', line)
                if m_slot:
                    if current_ndef not in effects:
                        effects[current_ndef] = []
                    effects[current_ndef].append(f"slot {m_slot.group(1)}: {m_slot.group(2)}")
                    continue
                    
            # Match Wetness under current_ndef
            if current_ndef and (line.startswith('- wet') or line.startswith('- \\wet')):
                m_wet = re.search(r'\\?wet(\d+):\s*(.*)', line)
                if m_wet:
                    if current_ndef not in wetness:
                        wetness[current_ndef] = []
                    wetness[current_ndef].append(f"wet{m_wet.group(1)}: {m_wet.group(2)}")
                
    # 2. Extract new state from generated code
    # Clean code: remove comments
    clean_code = re.sub(r'//.*', '', new_code)
    clean_code = re.sub(r'/\*.*?\*/', '', clean_code, flags=re.DOTALL)
    
    # New Ndefs
    ndef_additions = {}
    for match in re.finditer(r'Ndef\(\s*\\(\w+)\s*,', clean_code):
        ndef = match.group(1)
        active_ndefs.add(ndef)
        ndef_additions[ndef] = match.end()
        
    # New Pbindefs
    pbindef_additions = {}
    for match in re.finditer(r'Pbindef\(\s*\\(\w+)\s*,', clean_code):
        pbindef = match.group(1)
        active_pbindefs.add(pbindef)
        pbindef_additions[pbindef] = match.end()
        
    # Effect slots: Ndef(\name)[N] = \filter ->
    for match in re.finditer(r'Ndef\(\s*\\(\w+)\s*\)\s*\[\s*(\d+)\s*\]\s*=\s*\\filter\s*->\s*\{([^\}]*)\}', clean_code):
        ndef = match.group(1)
        slot = match.group(2)
        func = match.group(3).strip()
        # Extract a short summary of the function (e.g. "GVerb.ar(...)")
        summary = re.search(r'(\w+\.ar[^\)]*\))', func)
        desc = summary.group(1) if summary else "effect filter"
        
        if ndef not in effects:
            effects[ndef] = []
        
        # Remove existing effect at this slot if any
        effects[ndef] = [e for e in effects[ndef] if not e.startswith(f"slot {slot}:")]
        effects[ndef].append(f"slot {slot}: {desc}")
        
    # Wetness levels: Ndef(\name).xset(\wetN, val) or .set
    for match in re.finditer(r'Ndef\(\s*\\(\w+)\s*\)\.[x]?set\(\s*\\wet(\d+)\s*,\s*([\d\.]+)', clean_code):
        ndef = match.group(1)
        slot = match.group(2)
        val = match.group(3)
        
        if ndef not in wetness:
            wetness[ndef] = []
            
        wetness[ndef] = [w for w in wetness[ndef] if not w.startswith(f"wet{slot}:")]
        wetness[ndef].append(f"wet{slot}: {val}")
        
    # Removals: Ndef(\name).clear
    for match in re.finditer(r'Ndef\(\s*\\(\w+)\s*\)\.clear', clean_code):
        ndef = match.group(1)
        # Only remove if the clear comes after the last addition in this block
        if ndef not in ndef_additions or match.end() > ndef_additions[ndef]:
            if ndef in active_ndefs:
                active_ndefs.remove(ndef)
            if ndef in effects:
                del effects[ndef]
            if ndef in wetness:
                del wetness[ndef]
            
    # Removals: Pbindef(\name).stop
    for match in re.finditer(r'Pbindef\(\s*\\(\w+)\s*\)\.stop', clean_code):
        pbindef = match.group(1)
        # Only remove if the stop comes after the last addition
        if pbindef not in pbindef_additions or match.end() > pbindef_additions[pbindef]:
            if pbindef in active_pbindefs:
                active_pbindefs.remove(pbindef)
            
    # 3. Format output
    if not active_ndefs and not active_pbindefs:
        return "(Empty)"
        
    out = []
    
    if active_ndefs:
        out.append("Active Ndefs:")
        for ndef in sorted(active_ndefs):
            out.append(f"- \\{ndef}")
            if ndef in effects and effects[ndef]:
                for eff in sorted(effects[ndef]):
                    out.append(f"  - Slot {eff.replace('slot ', '')}")
            if ndef in wetness and wetness[ndef]:
                for wet in sorted(wetness[ndef]):
                    out.append(f"  - \\{wet}")
                    
    if active_pbindefs:
        if out:
            out.append("")
        out.append("Active Pbindefs:")
        for pbindef in sorted(active_pbindefs):
            out.append(f"- \\{pbindef}")
            
    return "\n".join(out)
