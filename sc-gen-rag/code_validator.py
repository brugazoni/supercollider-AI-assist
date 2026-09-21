import re

def _check_balanced_brackets(code: str) -> bool:
    """Check if (), [], {} are balanced, ignoring contents of comments and quoted strings."""
    # Strip comments
    code_no_comments = re.sub(r'//.*', '', code)
    code_no_comments = re.sub(r'/\*.*?\*/', '', code_no_comments, flags=re.DOTALL)
    
    # Strip quoted strings (naive, assumes no escaped quotes like \")
    code_no_strings = re.sub(r'".*?"', '', code_no_comments)
    code_no_strings = re.sub(r"'.*?'", '', code_no_strings)
    
    stack = []
    pairs = {')': '(', ']': '[', '}': '{'}
    for char in code_no_strings:
        if char in pairs.values():
            stack.append(char)
        elif char in pairs.keys():
            if not stack or stack.pop() != pairs[char]:
                return False
    return len(stack) == 0

def validate_and_fix(code: str) -> tuple[str, list[str]]:
    """
    Applies deterministic regex fixes to known fatal SC bugs.
    Returns (fixed_code, list_of_fixes_applied).
    """
    fixes = []
    
    # 1. Strip artifact headers (e.g. //=========)
    if re.search(r'^\s*//======+', code, re.MULTILINE):
        code = re.sub(r'^\s*//======+.*?\n', '', code, flags=re.MULTILINE)
        fixes.append("stripped //========= header")
        
    # 2. Fix literal arrays with variables (Ref(#[...]))
    if re.search(r'Ref\(\s*#\[', code):
        code = re.sub(r'Ref\(\s*#\[', 'Ref([', code)
        fixes.append("fixed Ref(#[...]) array bug")
        
    # 3. Fix doneAction: 2 in Ndefs
    if re.search(r'Ndef\s*\(\s*\\.*?doneAction:\s*2', code, re.DOTALL):
        if "SynthDef" not in code:
            code = re.sub(r',\s*doneAction:\s*2', '', code)
            code = re.sub(r'doneAction:\s*2\s*,?', '', code)
            fixes.append("stripped doneAction: 2 from Ndef")
            
    # 4. Fix Decay/Decay2 t_trig rate mismatch
    if re.search(r'Decay2?\.ar\(\s*t_trig', code):
        code = re.sub(r'(Decay2?\.ar\(\s*)(t_trig)', r'\1K2A.ar(\2)', code)
        fixes.append("fixed Decay.ar(t_trig) rate mismatch")
        
    # 5. Fix Ndef channel pre-init
    if re.search(r'^\s*Ndef\(\s*\\[\w]+\s*\)\.ar\(\d+\);', code, re.MULTILINE):
        code = re.sub(r'^\s*Ndef\(\s*\\[\w]+\s*\)\.ar\(\d+\);\s*\n?', '', code, flags=re.MULTILINE)
        fixes.append("stripped Ndef.ar() pre-initialization")
        
    # 6. Bracket check
    if not _check_balanced_brackets(code):
        fixes.append("WARNING: brackets are unbalanced")
        
    return code, fixes
