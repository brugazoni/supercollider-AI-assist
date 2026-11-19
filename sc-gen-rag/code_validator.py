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


def _fix_negative_defaults_and_binop(code: str) -> tuple[str, list[str]]:
    """
    Fix SuperCollider's `=-` BINOP lexer trap and negative default values in pipe `|...|`
    or `arg ...;` declarations:
      - In `|...|`, `pan=-0.25` or `pan = -0.25` -> `pan=(-0.25)`
      - In `arg ...;`, `pan=-0.25` -> `pan = -0.25`
      - Anywhere in code (outside comments/strings), `=-0.5` -> `= -0.5`
    """
    applied = []

    # 1. Parenthesize negative default values inside |...| argument declarations
    def _fix_pipe_args(m: re.Match) -> str:
        pipe_body = m.group(1)
        new_body, n_sub = re.subn(
            r'(\b[a-zA-Z_]\w*)\s*=\s*(-\d+(?:\.\d+)?)',
            r'\1=(\2)',
            pipe_body,
        )
        if n_sub > 0 and "parenthesized negative default in |...| args" not in applied:
            applied.append("parenthesized negative default in |...| args")
        return f"|{new_body}|"

    code = re.sub(
        r'\|\s*([a-zA-Z_][\w\s,=.\-\(\)]*?)\s*\|',
        _fix_pipe_args,
        code,
    )

    # 2. Separate any remaining `=-` followed by a number (which sclang lexes as BINOP `=-`)
    if re.search(r'=-(?=\d)', code):
        code = re.sub(r'=-(\d+(?:\.\d+)?)', r'= (\-\1)', code)
        code = code.replace(r'(\-', '(-')
        applied.append("separated =- BINOP before negative number")

    return code, applied


def _skip_sc_ws_and_comments(code: str, pos: int) -> int:
    """Advance `pos` past whitespace, `//` line comments, and `/* ... */` block comments in O(N) time."""
    n = len(code)
    while pos < n:
        if code[pos].isspace():
            pos += 1
        elif code[pos:pos + 2] == '//':
            nl = code.find('\n', pos + 2)
            pos = n if nl == -1 else nl + 1
        elif code[pos:pos + 2] == '/*':
            end = code.find('*/', pos + 2)
            pos = n if end == -1 else end + 2
        else:
            break
    return pos


def _fix_nested_paren_var_blocks(code: str) -> tuple[str, int]:
    """
    In SuperCollider's Bison grammar (lang11d), `( var x = ...; ... )` is ONLY valid at
    the outermost root level (`cmdlinecode`). Inside `{ ... }` or inside an outer `( ... )`
    (bracket depth >= 1), `( ... )` is an `exprseq` and cannot contain `var` declarations
    (causes `ERROR: syntax error, unexpected VAR, expecting CLOSEPAREN`).

    This function finds any nested `(` (at depth >= 1, standing at the start of a statement)
    whose first token inside is `var `, finds its matching `)`, and converts `( ... )` into
    `{ ... }.value`.
    """
    n = len(code)
    i = 0
    stack = []  # list of (char, open_pos, convert_to_closure)
    replacements = []  # list of (pos, old_len, new_str)
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''
    last_sig_char = ''

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c == '"' or c == "'":
            in_string = True
            string_char = c
            last_sig_char = c
            i += 1
            continue

        if c in ('(', '{', '['):
            convert = False
            if c == '(' and len(stack) >= 1:
                # Check if this '(' is at the start of a statement (not a function/method call like `foo(`)
                if last_sig_char in ('', ';', '{', '}', '('):
                    # Check if the first non-whitespace/non-comment token after '(' is `var`
                    ws_end = _skip_sc_ws_and_comments(code, i + 1)
                    if re.match(r'var\b', code[ws_end:]):
                        convert = True
            stack.append((c, i, convert))
            last_sig_char = c
        elif c in (')', '}', ']'):
            if stack:
                open_c, open_pos, convert = stack.pop()
                if c == ')' and open_c == '(' and convert:
                    replacements.append((open_pos, 1, '{'))
                    replacements.append((i, 1, '}.value'))
            last_sig_char = c
        elif not c.isspace():
            last_sig_char = c

        i += 1

    if not replacements:
        return code, 0

    # Apply replacements in reverse order of position so indices remain valid
    replacements.sort(key=lambda r: r[0], reverse=True)
    out = code
    for pos, old_len, new_str in replacements:
        out = out[:pos] + new_str + out[pos + old_len:]

    return out, len(replacements) // 2


def _replace_ident_outside_comments_and_strings(text: str, old_ident: str, new_ident: str) -> str:
    """Replace isolated identifier `old_ident` with `new_ident` outside comments and strings."""
    n = len(text)
    i = 0
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''
    replacements = []

    pattern = re.compile(rf'\b{re.escape(old_ident)}\b')

    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c in ('"', "'"):
            in_string = True
            string_char = c
            i += 1
            continue

        m = pattern.match(text, i)
        if m:
            replacements.append((i, i + len(old_ident)))
            i += len(old_ident)
            continue
        i += 1

    for start, end in reversed(replacements):
        text = text[:start] + new_ident + text[end:]
    return text


def _fix_reserved_pi_identifiers(code: str) -> tuple[str, list[str]]:
    """
    SuperCollider reserves `pi` as the terminal token PIE (Float 3.14159...).
    Declaring `pi` as an argument (`|page, pi|`) or variable (`var pi;`) causes a fatal
    `ERROR: syntax error, unexpected PIE`.
    Detects any function block or variable declaration where `pi` is declared and renames
    the identifier to `pIdx` within that scope.
    """
    applied = []
    n = len(code)
    i = 0
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''
    stack = []
    blocks_to_rename = []

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c in ('"', "'"):
            in_string = True
            string_char = c
            i += 1
            continue

        if c == '{':
            stack.append(i)
        elif c == '}':
            if stack:
                open_pos = stack.pop()
                inner = code[open_pos + 1:i]
                hdr_start = _skip_sc_ws_and_comments(inner, 0)
                m_header = re.match(
                    r'(?:\|(?P<pipe>[^|]+)\||\barg\s+(?P<arg>[^;]+);)',
                    inner[hdr_start:],
                    re.DOTALL
                )
                if m_header:
                    decl_text = m_header.group('pipe') or m_header.group('arg')
                    if re.search(r'\bpi\b', decl_text):
                        blocks_to_rename.append((open_pos, i + 1))
        i += 1

    for start, end in reversed(blocks_to_rename):
        block_text = code[start:end]
        new_block = _replace_ident_outside_comments_and_strings(block_text, 'pi', 'pIdx')
        code = code[:start] + new_block + code[end:]
        if "renamed reserved token 'pi' to 'pIdx' in function arguments" not in applied:
            applied.append("renamed reserved token 'pi' to 'pIdx' in function arguments")

    return code, applied


def _fix_unary_minus_on_identifiers(code: str) -> tuple[str, list[str]]:
    """
    In SuperCollider's grammar, `-` is only a unary prefix operator for numeric literals
    (e.g. -0.5, -10). Writing `-ident` (e.g. `-spread`, `-pan`, `-~pan`) throws
    `ERROR: syntax error, unexpected NAME, expecting ')'`.
    Negating an identifier must be written as `ident.neg`.
    Converts unary `-ident` (preceded by operators, delimiters, or statement start)
    to `ident.neg`.
    """
    applied = []
    n = len(code)
    i = 0
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''
    replacements = []
    last_sig_pos = -1

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c in ('"', "'"):
            in_string = True
            string_char = c
            last_sig_pos = i
            i += 1
            continue

        if c == '-' and nxt not in ('-', '>', '='):
            is_unary = False
            if last_sig_pos == -1:
                is_unary = True
            else:
                prev_char = code[last_sig_pos]
                if not (prev_char.isalnum() or prev_char in ('_', ')', ']', '}', '"', "'")):
                    is_unary = True
                else:
                    sub = code[:last_sig_pos + 1]
                    if re.search(r'\b(return|case|arg|var)\b$', sub):
                        is_unary = True

            if is_unary:
                after = code[i + 1:]
                m_num = re.match(r'^\s*(\d+(?:\.\d+)?|\.\d+)', after)
                if not m_num:
                    m_id = re.match(r'^\s*(~?[a-zA-Z_]\w*)', after)
                    if m_id:
                        ident = m_id.group(1)
                        end_pos = i + 1 + m_id.end()
                        replacements.append((i, end_pos, f'{ident}.neg'))
                        i = end_pos
                        continue
                    m_paren = re.match(r'^\s*\(', after)
                    if m_paren:
                        open_paren = i + 1 + after.find('(')
                        depth = 0
                        close_paren = -1
                        for p in range(open_paren, len(code)):
                            if code[p] == '(':
                                depth += 1
                            elif code[p] == ')':
                                depth -= 1
                                if depth == 0:
                                    close_paren = p
                                    break
                        if close_paren != -1:
                            paren_content = code[open_paren:close_paren + 1]
                            replacements.append((i, close_paren + 1, f'{paren_content}.neg'))
                            i = close_paren + 1
                            continue

        if not c.isspace():
            last_sig_pos = i
        i += 1

    for start, end, repl in reversed(replacements):
        code = code[:start] + repl + code[end:]
        if "converted unary '-' prefix on identifier/expression to .neg" not in applied:
            applied.append("converted unary '-' prefix on identifier/expression to .neg")

    return code, applied


def _fix_jitlib_set_instrument(code: str) -> tuple[str, list[str]]:
    """
    In JITLib, `Ndef(...)[i] = \\set -> Pbindef(...)` controls existing synth arguments.
    Supplying `\\instrument, \\name` causes SuperCollider Event to search `SynthDescLib.global`
    for `\\name`. Since `\\name` is a NodeProxy and not a SynthDef, this returns `nil` and throws
    `ERROR: Message 'canReleaseSynth' not understood. RECEIVER: nil`.
    Strips `\\instrument` pairs from JITLib `\\set` / `\\setsrc` pattern bindings.
    """
    applied = []
    pattern = re.compile(
        r'(\\set(?:src)?\s*->\s*Pbind(?:ef)?\s*\()([^;]*?)(\);?)',
        re.DOTALL
    )

    def _clean_pairs(m: re.Match) -> str:
        prefix = m.group(1)
        body = m.group(2)
        suffix = m.group(3)

        new_body, n1 = re.subn(
            r'\\instrument\s*,\s*(?:\\[a-zA-Z_]\w*|"[^"]*"|\'[^\']*\')\s*,\s*',
            '',
            body
        )
        new_body, n2 = re.subn(
            r',\s*\\instrument\s*,\s*(?:\\[a-zA-Z_]\w*|"[^"]*"|\'[^\']*\')',
            '',
            new_body
        )

        if (n1 + n2) > 0:
            if "stripped redundant \\instrument from JITLib \\set pattern" not in applied:
                applied.append("stripped redundant \\instrument from JITLib \\set pattern")
            return f"{prefix}{new_body}{suffix}"
        return m.group(0)

    code = pattern.sub(_clean_pairs, code)
    return code, applied


def _fix_balance2_on_mono_ugen(code: str) -> tuple[str, list[str]]:
    """
    Calling `Balance2.ar(sig[0], sig[1], ...)` when `sig` is a mono UGen (e.g. `SinOsc.ar`,
    `LPF.ar`, etc.) fails with `ERROR: Message 'at' not understood` because `UGen` does not
    implement `at`.
    Wraps the call in a language-side `if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], ...) } { Pan2.ar(sig, ...) }`
    guard so both mono and stereo signals are handled safely at UGen graph construction time.
    """
    applied = []
    pattern = re.compile(
        r'Balance2\.ar\(\s*(?P<var>~?[a-zA-Z_]\w*)\[0\]\s*,\s*(?P=var)\[1\](?P<extra>\s*,[^)]*)?\)',
        re.DOTALL
    )

    def _replace_b2(m: re.Match) -> str:
        var_name = m.group("var")
        extra_args = m.group("extra") or ""
        start_pos = max(0, m.start() - 60)
        preceding = code[start_pos:m.start()]
        if f"{var_name}.isKindOf(Collection)" in preceding or "isKindOf(Collection)" in preceding:
            return m.group(0)

        applied.append(f"wrapped Balance2.ar({var_name}[0], {var_name}[1]) in isKindOf(Collection) guard with Pan2 fallback")
        return (
            f"if({var_name}.isKindOf(Collection)) {{ "
            f"Balance2.ar({var_name}[0], {var_name}[1]{extra_args}) "
            f"}} {{ "
            f"Pan2.ar({var_name}{extra_args}) "
            f"}}"
        )

    code = pattern.sub(_replace_b2, code)
    return code, applied


def _fix_non_vanilla_classes(code: str) -> tuple[str, list[str]]:
    """
    Detects and normalizes known third-party Quark or `sc3-plugins` classes that are not
    present in vanilla SuperCollider, replacing them with standard vanilla equivalents:
      - `DPW4Saw` (sc3-plugins) -> `Saw`
      - `Decimator.ar(sig, rate, bits)` (sc3-plugins) -> `Latch.ar(sig, Impulse.ar(rate))`
      - `TabbedView` / `PageLayout` (wslib / crucial Quarks) -> `CompositeView`
    """
    applied = []

    # 1. DPW4Saw -> Saw
    if re.search(r'\bDPW4Saw\b', code):
        code = re.sub(r'\bDPW4Saw\b', 'Saw', code)
        applied.append("normalized non-vanilla DPW4Saw to Saw")

    # 2. Decimator.ar(sig, rate, bits) -> Latch.ar(sig, Impulse.ar(rate))
    if re.search(r'\bDecimator\.ar\b', code):
        code = re.sub(
            r'\bDecimator\.ar\(\s*([^,\n]+)\s*,\s*([^,\n]+)(?:\s*,\s*[^)\n]+)?\s*\)',
            r'Latch.ar(\1, Impulse.ar(\2))',
            code,
        )
        applied.append("normalized non-vanilla Decimator.ar to Latch.ar")

    # 3. TabbedView / PageLayout -> CompositeView
    if re.search(r'\b(?:TabbedView|PageLayout)(?:\.new)?\s*\(', code):
        code = re.sub(r'\b(?:TabbedView|PageLayout)(?:\.new)?\s*\(', 'CompositeView(', code)
        applied.append("normalized third-party GUI class (TabbedView/PageLayout) to CompositeView")

    return code, applied


def _fix_array_new_inplace_add(code: str) -> tuple[str, list[str]]:
    """
    In SuperCollider, `Array.new` (from `Object:*new`) creates an Array with
    `maxSize = 0`. Calling `arr.add(item)` as a statement without reassigning
    `arr = arr.add(item)` returns a new Array and leaves `arr` empty (`[]`).
    In paginated Design GUIs (`pages = Array.new; pages.add(page);`) this causes
    tab-switching (`pages.do { |pg| pg.visible = false }`) to iterate over an
    empty array so all zone pages remain visible and overlap on top of each other.
    `List.new` wraps a dynamically growing Array and mutates in-place on `.add`
    while also returning `this` (so both `list.add(x)` and `list = list.add(x)` work).
    """
    applied = []
    converted_vars = []

    # 1. Convert `<var> = Array.new` (or `Array.new(N)`) to `<var> = List.new` when `<var>.add(` is used
    assign_rx = re.compile(r'(~?[A-Za-z_]\w*)\s*=\s*Array\.new(?:\s*\(\s*\d*\s*\))?(?=\s*[;,\n\)])')
    for m in list(assign_rx.finditer(code)):
        var_name = m.group(1)
        if var_name in converted_vars:
            continue
        if re.search(rf'(?<![A-Za-z0-9_]){re.escape(var_name)}\s*\.\s*add\s*\(', code):
            code = re.sub(
                rf'(?<![A-Za-z0-9_])({re.escape(var_name)}\s*=\s*)Array\.new(?:\s*\(\s*\d*\s*\))?(?=\s*[;,\n\)])',
                r'\1List.new',
                code,
            )
            converted_vars.append(var_name)

    # 2. Convert `<var> = []` to `<var> = List.new` when statement-level `<var>.add(` (without reassignment) is used
    empty_lit_rx = re.compile(r'(~?[A-Za-z_]\w*)\s*=\s*\[\s*\](?=\s*[;,\n\)])')
    for m in list(empty_lit_rx.finditer(code)):
        var_name = m.group(1)
        if var_name in converted_vars:
            continue
        if re.search(rf'(?:^|[;\{{\n])\s*{re.escape(var_name)}\s*\.\s*add\s*\(', code, re.MULTILINE):
            code = re.sub(
                rf'(?<![A-Za-z0-9_])({re.escape(var_name)}\s*=\s*)\[\s*\](?=\s*[;,\n\)])',
                r'\1List.new',
                code,
            )
            converted_vars.append(var_name)

    if converted_vars:
        applied.append(f"converted Array.new/[] to List.new for in-place .add() on {', '.join(converted_vars)}")

    return code, applied


def _fix_stray_wait_outside_routines(code: str) -> tuple[str, list[str]]:
    """
    In SuperCollider, `.wait` can ONLY be called inside a `Routine` or `Task`.
    Calling `.wait` outside a Routine (e.g. directly inside `s.waitForBoot({ ... })`
    or at top level) triggers primitive failure:
      `ERROR: yield was called outside of a Routine. Primitive '_RoutineYield' failed.`
    
    This function parses braces and detects any `\\d+(?:\\.\\d+)?\\.wait;` statement
    occurring at depth <= 1 (when `waitForBoot` is present) or depth 0 (when no
    `waitForBoot` is present), and comments it out.
    """
    applied = []
    has_wait_for_boot = bool(re.search(r'\bwaitForBoot\b', code))
    max_illegal_depth = 1 if has_wait_for_boot else 0

    n = len(code)
    i = 0
    brace_depth = 0
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''
    replacements = []

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c == '"' or c == "'":
            in_string = True
            string_char = c
            i += 1
            continue

        if c == '{':
            brace_depth += 1
            i += 1
            continue
        elif c == '}':
            if brace_depth > 0:
                brace_depth -= 1
            i += 1
            continue

        if brace_depth <= max_illegal_depth:
            is_boundary = (i == 0 or not (code[i - 1].isalnum() or code[i - 1] == '_'))
            if is_boundary and (c.isdigit() or (c == '.' and nxt.isdigit())):
                m = re.match(r'(\d+(?:\.\d+)?)\s*\.\s*wait\s*;?', code[i:])
                if m:
                    matched_str = m.group(0)
                    end_pos = i + len(matched_str)
                    replacements.append((i, end_pos, f"// {matched_str.strip()} // removed: .wait outside Routine"))
                    i = end_pos
                    continue
        i += 1

    if replacements:
        for start, end, repl in reversed(replacements):
            code = code[:start] + repl + code[end:]
        applied.append("commented out stray .wait outside Routine")

    return code, applied


def validate_and_fix(code: str) -> tuple[str, list[str]]:
    """
    Applies deterministic regex and AST/lexer fixes to known fatal SC bugs.
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

    # 6. Fix negative default values in |...| and `=-` BINOP lexer trap
    code, neg_fixes = _fix_negative_defaults_and_binop(code)
    fixes.extend(neg_fixes)

    # 6b. Fix reserved `pi` token declared as argument or variable (unexpected PIE)
    code, pi_fixes = _fix_reserved_pi_identifiers(code)
    fixes.extend(pi_fixes)

    # 6c. Fix unary minus on identifiers/expressions (sclang only supports unary minus on numeric literals)
    code, unary_fixes = _fix_unary_minus_on_identifiers(code)
    fixes.extend(unary_fixes)

    # 6d. Fix redundant/invalid \instrument in JITLib \set / \setsrc patterns (avoids nil.canReleaseSynth crash)
    code, jit_fixes = _fix_jitlib_set_instrument(code)
    fixes.extend(jit_fixes)

    # 6e. Guard Balance2.ar(sig[0], sig[1]) against mono UGens (avoids UGen 'at' not understood)
    code, b2_fixes = _fix_balance2_on_mono_ugen(code)
    fixes.extend(b2_fixes)

    # 6f. Normalize non-vanilla classes (DPW4Saw, Decimator, TabbedView, PageLayout)
    code, class_fixes = _fix_non_vanilla_classes(code)
    fixes.extend(class_fixes)

    # 6g. Fix Array.new / [] in-place .add() trap (prevents overlapping GUI pages and lost voice arrays)
    code, array_add_fixes = _fix_array_new_inplace_add(code)
    fixes.extend(array_add_fixes)

    # 7. Fix nested `( var ... )` sub-blocks inside `{ ... }` or `( ... )` -> `{ var ... }.value`
    code, n_paren_var = _fix_nested_paren_var_blocks(code)
    if n_paren_var > 0:
        fixes.append(f"converted {n_paren_var} nested ( var ... ) block(s) to {{ var ... }}.value")

    # 8. Fix stray .wait outside Routines/Tasks (prevents fatal _RoutineYield crash)
    code, wait_fixes = _fix_stray_wait_outside_routines(code)
    fixes.extend(wait_fixes)

    # 8b. Ensure s.sync; is called immediately after SynthDef(\safetyLimiter, ...).add;
    #     before Synth.tail(RootNode(s), \safetyLimiter) is invoked on a running server.
    #     Without s.sync before Synth.tail, scsynth posts:
    #     `*** ERROR: SynthDef safetyLimiter not found` and triggers the failsafe.
    if "waitForBoot" in code and "safetyLimiter" in code:
        pattern_limiter = re.compile(
            r'(SynthDef\s*\(\s*\\safetyLimiter\b.*?\}\s*\)\s*\.add\s*;)'
            r'((?:(?!\bs\.sync\b)[\s\S])*?'
            r'Synth\.(?:tail|head|new)\s*\([^;\n]*\\safetyLimiter)',
            re.DOTALL,
        )
        if pattern_limiter.search(code):
            code = pattern_limiter.sub(r'\1\n\ts.sync;\2', code, count=1)
            fixes.append("inserted s.sync immediately after SynthDef(\\safetyLimiter).add before Synth.tail")

    # 9. Bracket check
    if not _check_balanced_brackets(code):
        fixes.append("WARNING: brackets are unbalanced")
        
    return code, fixes


def _extract_top_level_blocks_and_segments(code: str) -> list[dict]:
    """
    Parse code into ordered segments of either:
      - {'type': 'block', 'text': '...', 'preceding_comments': '...'}
      - {'type': 'other', 'text': '...'}
    Respects line comments (//), block comments (/* */), strings ("..."), and symbols ('...').
    """
    segments = []
    n = len(code)
    i = 0
    depth = 0
    block_start = -1
    last_end = 0
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c == '"' or c == "'":
            in_string = True
            string_char = c
            i += 1
            continue

        if c == '(':
            if depth == 0:
                line_start = code.rfind('\n', 0, i) + 1
                prefix_on_line = code[line_start:i].strip()
                if prefix_on_line == '':
                    block_start = i
                    depth = 1
                else:
                    depth = 1
                    block_start = -1
            else:
                depth += 1
        elif c == ')':
            if depth > 0:
                depth -= 1
                if depth == 0 and block_start >= 0:
                    between = code[last_end:block_start]
                    block_text = code[block_start:i + 1]
                    segments.append({
                        'type': 'block',
                        'between': between,
                        'text': block_text,
                    })
                    last_end = i + 1
                    block_start = -1
        i += 1

    trailing = code[last_end:]
    if trailing.strip():
        segments.append({
            'type': 'trailing',
            'text': trailing,
        })
    elif trailing and segments:
        segments[-1]['trailing'] = trailing

    return segments


def _is_teardown_block(preceding_text: str, block_text: str, mode: str) -> bool:
    """Detect whether a top-level (...) block is a cleanup / teardown / fade-out block."""
    prec_lower = preceding_text.lower()
    body_lower = block_text.lower()

    teardown_headers = [
        "step 5", "cleanup", "clean up", "fade out and ending",
        "fade out", "teardown", "stop all", "// ending"
    ]
    if any(h in prec_lower for h in teardown_headers):
        return True

    if mode == "design":
        creates_gui = any(w in body_lower for w in ("window(", "compositeview(", "ezslider(", "ezknob("))
        if (
            ("mididef.freeall" in body_lower or ".close" in body_lower)
            and not creates_gui
            and "synthdef(" not in body_lower
            and "s.waitforboot" not in body_lower
        ):
            return True

    if mode in ("generate", "append"):
        has_clear_or_stop = ("ndef(" in body_lower and ".clear" in body_lower) or (".stop" in body_lower) or ("ndef.clear" in body_lower)
        has_definition = ("{" in block_text) or ("\\set ->" in body_lower) or ("\\filter ->" in body_lower) or ("pbindef(" in body_lower and "," in block_text)
        if has_clear_or_stop and not has_definition:
            return True

    return False


def _comment_out_lines(text: str, header: str = "// [Auto-Run: Teardown/Cleanup kept commented for manual use]") -> str:
    lines = text.strip().splitlines()
    commented = [f"// {line}" if not line.strip().startswith("//") else line for line in lines]
    return header + "\n" + "\n".join(commented)


def _inject_trailing_code_into_waitforboot(inner_code: str) -> tuple[str, bool]:
    """
    If `inner_code` contains `s.waitForBoot({ ... });` followed by executable post-boot
    statements (such as `defer { ... };` GUI creation in Design mode), move those trailing
    statements inside the end of `s.waitForBoot({ ... })` so `~ccVals` and `~buses` are
    guaranteed to be initialized before the GUI executes.
    """
    m = re.search(r'\b(?:s|Server\.default)\.waitForBoot\s*\(', inner_code)
    if not m:
        return inner_code, False

    open_paren_pos = inner_code.find('(', m.start())
    if open_paren_pos == -1:
        return inner_code, False

    # Find matching ')' for waitForBoot(
    n = len(inner_code)
    i = open_paren_pos
    depth = 0
    close_paren_pos = -1
    last_close_curly_before_paren = -1
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''

    while i < n:
        c = inner_code[i]
        nxt = inner_code[i + 1] if i + 1 < n else ''

        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue

        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c == '"' or c == "'":
            in_string = True
            string_char = c
            i += 1
            continue

        if c == '(':
            depth += 1
        elif c == '}':
            if depth == 1:
                last_close_curly_before_paren = i
        elif c == ')':
            depth -= 1
            if depth == 0:
                close_paren_pos = i
                break
        i += 1

    if close_paren_pos == -1 or last_close_curly_before_paren == -1:
        return inner_code, False

    # Consume optional semicolon after ')'
    after_wait_pos = close_paren_pos + 1
    while after_wait_pos < n and inner_code[after_wait_pos] in (' ', '\t'):
        after_wait_pos += 1
    if after_wait_pos < n and inner_code[after_wait_pos] == ';':
        after_wait_pos += 1

    trailing_code = inner_code[after_wait_pos:].strip()
    if not trailing_code:
        return inner_code, False

    # Check if trailing_code has non-comment executable code
    has_exec = any(
        line.strip() and not line.strip().startswith('//') and not line.strip().startswith('/*')
        for line in trailing_code.splitlines()
    )
    if not has_exec:
        return inner_code, False

    if not trailing_code.endswith(';'):
        trailing_code += ';'

    # If trailing_code starts with `var `, wrap in `{ ... }.value;`
    tc_start = _skip_sc_ws_and_comments(trailing_code, 0)
    if re.match(r'var\b', trailing_code[tc_start:]):
        injected = f"\n\n    {{\n{trailing_code}\n    }}.value;\n"
    else:
        injected = f"\n\n    {trailing_code}\n"

    new_inner = (
        inner_code[:last_close_curly_before_paren]
        + injected
        + inner_code[last_close_curly_before_paren:after_wait_pos]
    )
    return new_inner, True


def _scan_balanced_delim(code: str, open_pos: int) -> int:
    """Given `open_pos` pointing at `(`, `{`, or `[`, return index right after matching closer (or -1)."""
    pairs = {'(': ')', '{': '}', '[': ']'}
    open_ch = code[open_pos]
    if open_ch not in pairs:
        return -1
    n = len(code)
    i = open_pos
    stack = []
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''
        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue
        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c in ('"', "'"):
            in_string = True
            string_char = c
            i += 1
            continue

        if c in pairs:
            stack.append(pairs[c])
        elif c in (')', '}', ']'):
            if not stack or stack.pop() != c:
                return -1
            if not stack:
                return i + 1
        i += 1
    return -1


def _scan_to_statement_semicolon(code: str, start_pos: int) -> int:
    """Scan from `start_pos` until a top-level `;` at bracket depth 0; returns index after `;` (or -1)."""
    n = len(code)
    i = start_pos
    depth = 0
    in_line_comment = False
    in_block_comment = False
    in_string = False
    string_char = ''

    while i < n:
        c = code[i]
        nxt = code[i + 1] if i + 1 < n else ''
        if in_line_comment:
            if c == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if c == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == string_char:
                in_string = False
            i += 1
            continue
        if c == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if c == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if c in ('"', "'"):
            in_string = True
            string_char = c
            i += 1
            continue

        if c in ('(', '{', '['):
            depth += 1
        elif c in (')', '}', ']'):
            if depth == 0:
                # Reached outer closing bracket before any semicolon
                return i
            depth -= 1
        elif c == ';' and depth == 0:
            return i + 1
        i += 1
    return -1


def _build_midi_fallback_sc(dev_var: str = "~myInDevice", uid_var: str = "~myUid", include_if_connect: bool = True, has_var_kw: bool = False) -> str:
    """Build SuperCollider MIDI input discovery with loopMIDI default + BeatStep Pro & hardware fallback."""
    detect_chain = (
        f"MIDIClient.sources.detect {{ |src|\n"
        f"    var label = (src.device.asString ++ \" \" ++ src.name.asString).toLower;\n"
        f"    label.contains(\"loopmidi\")\n"
        f"}} ?? {{\n"
        f"    // Fallback 1: Arturia BeatStep Pro (skip secondary MIDIIN2 sysex port)\n"
        f"    MIDIClient.sources.detect {{ |src|\n"
        f"        var label = (src.device.asString ++ \" \" ++ src.name.asString).toLower;\n"
        f"        label.contains(\"beatstep\") and: {{ label.contains(\"midiin2\").not }} and: {{ label.contains(\"midiin 2\").not }}\n"
        f"    }}\n"
        f"}} ?? {{\n"
        f"    // Fallback 2: Any real external/hardware MIDI device (skip virtual/bridge/system ports)\n"
        f"    MIDIClient.sources.detect {{ |src|\n"
        f"        var label = (src.device.asString ++ \" \" ++ src.name.asString).toLower;\n"
        f"        label.contains(\"bmt\").not\n"
        f"            and: {{ label.contains(\"bome\").not }}\n"
        f"            and: {{ label.contains(\"midiin2\").not }}\n"
        f"            and: {{ label.contains(\"midiin 2\").not }}\n"
        f"            and: {{ label.contains(\"microsoft gs\").not }}\n"
        f"            and: {{ label.contains(\"wavetable\").not }}\n"
        f"            and: {{ label.contains(\"midi through\").not }}\n"
        f"            and: {{ label.contains(\"iac \").not }}\n"
        f"    }}\n"
        f"}} ?? {{\n"
        f"    MIDIClient.sources.detect {{ |src|\n"
        f"        (src.device.asString ++ \" \" ++ src.name.asString).toLower.contains(\"midiin2\").not\n"
        f"    }}\n"
        f"}} ?? {{\n"
        f"    MIDIClient.sources.first\n"
        f"}}"
    )

    if has_var_kw:
        assign_stmt = f"var {dev_var} = (if(MIDIClient.initialized.not) {{ MIDIClient.init }}; {detect_chain});"
    else:
        assign_stmt = f"if(MIDIClient.initialized.not) {{ MIDIClient.init }};\n{dev_var} = {detect_chain};"

    if not include_if_connect:
        return assign_stmt

    connect_block = (
        f"\nif({dev_var}.notNil) {{\n"
        f"    MIDIIn.connect(0, {dev_var});\n"
        f"    (\"MIDI IN connected to: \" ++ {dev_var}.device ++ \" (\" ++ {dev_var}.name ++ \")\").postln;\n"
        f"    {uid_var} = {dev_var}.uid;\n"
        f"}} {{\n"
        f"    \"Warning: No MIDI input devices detected.\".warn;\n"
        f"    {uid_var} = nil;\n"
        f"}};"
    )
    return assign_stmt + connect_block


def _inject_midi_device_fallback(code: str) -> tuple[str, bool]:
    """
    Upgrade Design-mode MIDI device lookup (which typically hardcodes `"loopMIDI Port"`
    or `"Midi"` and leaves ports unconnected when `loopMIDI` is not running) so it:
      1. Connects to `loopMIDI` if active;
      2. Otherwise falls back to Arturia BeatStep Pro (skipping its dead `MIDIIN2` sysex port);
      3. Otherwise falls back to any connected external/hardware MIDI device (skipping BMT/Bome/GS Wavetable);
      4. Calls `MIDIIn.connect(0, dev)` and assigns `~myUid = dev.uid`.
    """
    low = code.lower()
    if "beatstep" in low and "midiin2" in low:
        return code, False

    m = re.search(r'(?P<var_kw>\bvar\s+)?(?P<dev>~?[a-zA-Z_]\w*)\s*=\s*MIDIClient\.sources\.detect\b', code)
    if m:
        has_var_kw = bool(m.group("var_kw"))
        dev_var = m.group("dev")
        stmt_end = _scan_to_statement_semicolon(code, m.end())
        if stmt_end == -1:
            return code, False

        uid_match_global = re.search(r'srcID:\s*(~[a-zA-Z_]\w*)', code)
        uid_var = uid_match_global.group(1) if uid_match_global else "~myUid"

        # Check if an `if(<dev_var>...)` connection block immediately follows
        next_pos = _skip_sc_ws_and_comments(code, stmt_end)
        include_if = False
        replace_end = stmt_end

        if_m = re.match(r'if\s*\(', code[next_pos:])
        if if_m:
            paren_open = code.find('(', next_pos)
            paren_end = _scan_balanced_delim(code, paren_open)
            if paren_end != -1 and dev_var in code[paren_open:paren_end]:
                cur = paren_end
                for _ in range(2):
                    ws_end = _skip_sc_ws_and_comments(code, cur)
                    if ws_end < len(code) and code[ws_end] == '{':
                        blk_end = _scan_balanced_delim(code, ws_end)
                        if blk_end != -1:
                            cur = blk_end
                        else:
                            break
                    else:
                        break
                ws_end = _skip_sc_ws_and_comments(code, cur)
                if ws_end < len(code) and code[ws_end] == ';':
                    cur = ws_end + 1
                if_snippet = code[next_pos:cur]
                uid_local = re.search(
                    r'(~[a-zA-Z_]\w*)\s*=\s*(?:' + re.escape(dev_var) + r'\.uid|nil\b)',
                    if_snippet,
                )
                if uid_local:
                    uid_var = uid_local.group(1)
                include_if = True
                replace_end = cur

        replacement = _build_midi_fallback_sc(
            dev_var=dev_var,
            uid_var=uid_var,
            include_if_connect=include_if,
            has_var_kw=has_var_kw,
        )
        new_code = code[:m.start()] + replacement + code[replace_end:]
        return new_code, True

    # Secondary case: `MIDIClient.init;` is present with `srcID: ~myUid`, but no `MIDIIn.connect` was emitted at all
    if "MIDIClient.init" in code and "MIDIIn.connect" not in code:
        init_m = re.search(r'\bMIDIClient\.init\s*(?:\([^)]*\))?\s*;', code)
        if init_m:
            uid_match_global = re.search(r'srcID:\s*(~[a-zA-Z_]\w*)', code)
            uid_var = uid_match_global.group(1) if uid_match_global else "~myUid"
            replacement = "MIDIClient.init;\n" + _build_midi_fallback_sc(
                dev_var="~myInDevice",
                uid_var=uid_var,
                include_if_connect=True,
                has_var_kw=False,
            )
            new_code = code[:init_m.start()] + replacement + code[init_m.end():]
            return new_code, True

    return code, False


def _unique_ordered(items: list[str]) -> list[str]:
    seen = set()
    out = []
    for item in items:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def _is_in_line_comment(text: str, pos: int) -> bool:
    line_start = text.rfind('\n', 0, pos) + 1
    return '//' in text[line_start:pos]


def _scope_global_teardowns_for_xappend(code: str) -> tuple[str, list[str]]:
    """
    Prevent X-Append blocks (especially fixed-length `compose` Tdef scores) from
    terminating or wiping the shared SuperCollider server at the end of execution:
      - Rewrites `Ndef.clear(...)` / `Ndef.clear` / `Ndef.all.do(...)` to clear ONLY
        the `Ndef(\\name)` proxies defined in `code`.
      - Rewrites `Pbindef.removeAll` / `Pbindef.clear` / `Pbindef.all.do(...)` to
        stop/clear ONLY the `Pbindef(\\name)` patterns defined in `code`.
      - Rewrites `Pdef.removeAll` / `Pdef.clear` / `Pdef.all.do(...)` to stop/clear
        ONLY the local `Pdef`/`Pbindef` patterns defined in `code`.
      - Rewrites `Tdef.removeAll` / `Tdef.clear` / `Tdef.all.do(...)` to stop ONLY
        the `Tdef(\\name)` tasks defined in `code`.
      - Comments out `ServerTree.removeAll`, `s.freeAll`, `Server.freeAll`, `s.quit`,
        `Server.killAll`, and `CmdPeriod.run`.
    """
    applied = []

    # Strip comments before scanning for defined symbol names
    code_no_comments = re.sub(r'//.*', '', code)
    code_no_comments = re.sub(r'/\*.*?\*/', '', code_no_comments, flags=re.DOTALL)

    ndef_names = _unique_ordered(re.findall(r'\bNdef\s*\(\s*\\([a-zA-Z_]\w*)', code_no_comments))
    pbindef_names = _unique_ordered(re.findall(r'\bPbindef\s*\(\s*\\([a-zA-Z_]\w*)', code_no_comments))
    pdef_names = _unique_ordered(re.findall(r'\bPdef\s*\(\s*\\([a-zA-Z_]\w*)', code_no_comments))
    tdef_names = _unique_ordered(re.findall(r'\bTdef\s*\(\s*\\([a-zA-Z_]\w*)', code_no_comments))

    # 1. ServerTree.removeAll -> comment out
    def _sub_servertree(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "commented out ServerTree.removeAll for shared server" not in applied:
            applied.append("commented out ServerTree.removeAll for shared server")
        return "// ServerTree.removeAll; // preserved for shared X-Append server"

    code = re.sub(r'\bServerTree\.removeAll\s*(?:\(\s*\))?\s*;?', _sub_servertree, code)

    # 2. Global server termination / freeAll / quit / CmdPeriod.run -> comment out
    def _sub_server_kill(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "blocked global server freeAll/quit/CmdPeriod" not in applied:
            applied.append("blocked global server freeAll/quit/CmdPeriod")
        return f"// {m.group(0).strip()} // blocked to keep shared X-Append server alive"

    code = re.sub(
        r'\b(?:(?:s|Server(?:\.default)?)\.(?:freeAll|quit|quitAll|killAll)|RootNode\s*\(\s*s\s*\)\.freeAll|s\.defaultGroup\.freeAll|CmdPeriod\.run)\s*(?:\([^;\n]*\))?\s*;?',
        _sub_server_kill,
        code,
    )

    # 2b. Freeing shared audio buses (~synthBus / ~audioBus) -> comment out to keep shared bus alive
    def _sub_shared_bus_free(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "blocked ~synthBus.free to preserve shared routing bus" not in applied:
            applied.append("blocked ~synthBus.free to preserve shared routing bus")
        return f"// {m.group(0).strip()} // preserved for shared X-Append session"

    code = re.sub(
        r'(?<!\w)(~(?:synthBus|audioBus|masterBus))\s*\.free\s*(?:\([^;\n]*\))?\s*;?',
        _sub_shared_bus_free,
        code,
    )

    # 3. Ndef.clear(arg) with parens
    def _sub_ndef_clear_arg(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        arg = m.group(1).strip()
        if "scoped Ndef.clear to block-local Ndefs" not in applied:
            applied.append("scoped Ndef.clear to block-local Ndefs")
        if not ndef_names:
            return "// Ndef.clear; // skipped: no local Ndefs in block"
        if arg:
            return " ".join(f"Ndef(\\{n}).clear({arg});" for n in ndef_names)
        return " ".join(f"Ndef(\\{n}).clear;" for n in ndef_names)

    code = re.sub(r'\bNdef\.clear\s*\(\s*([^)]*?)\s*\)\s*;?', _sub_ndef_clear_arg, code)

    # 4. Ndef.clear without parens, or Ndef.all.do(...) / Ndef.dictFor(...).clear(...)
    def _sub_ndef_clear_bare(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "scoped Ndef.clear to block-local Ndefs" not in applied:
            applied.append("scoped Ndef.clear to block-local Ndefs")
        if not ndef_names:
            return "// Ndef.clear; // skipped: no local Ndefs in block"
        return " ".join(f"Ndef(\\{n}).clear;" for n in ndef_names)

    code = re.sub(
        r'\bNdef\.(?:clear\b(?!\s*\()|all\.do\s*(?:\([^;\n]*\)|\{[^}]*\})|dictFor\([^)]*\)\.clear\s*(?:\([^;\n]*\))?)\s*;?',
        _sub_ndef_clear_bare,
        code,
    )

    # 5. Pbindef.removeAll / Pbindef.clear
    def _sub_pbindef_remove(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "scoped Pbindef.removeAll/clear to block-local Pbindefs" not in applied:
            applied.append("scoped Pbindef.removeAll/clear to block-local Pbindefs")
        if not pbindef_names:
            return "// Pbindef.removeAll; // skipped: no local Pbindefs in block"
        return " ".join(f"Pbindef(\\{n}).stop; Pbindef(\\{n}).clear;" for n in pbindef_names)

    code = re.sub(r'\bPbindef\.(?:removeAll|clear)\s*(?:\(\s*\))?\s*;?', _sub_pbindef_remove, code)

    # 6. Pbindef.all.do(...)
    def _sub_pbindef_all_do(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "scoped Pbindef.all to block-local Pbindefs" not in applied:
            applied.append("scoped Pbindef.all to block-local Pbindefs")
        if not pbindef_names:
            return "// Pbindef.all.do(_.stop); // skipped: no local Pbindefs in block"
        if "clear" in m.group(0):
            return " ".join(f"Pbindef(\\{n}).stop; Pbindef(\\{n}).clear;" for n in pbindef_names)
        return " ".join(f"Pbindef(\\{n}).stop;" for n in pbindef_names)

    code = re.sub(r'\bPbindef\.all\.do\s*(?:\([^;\n]*\)|\{[^}]*\})\s*;?', _sub_pbindef_all_do, code)

    # 7. Pdef.removeAll / Pdef.clear / Pdef.all.do(...)
    def _sub_pdef_global(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "scoped Pdef.removeAll/clear to block-local patterns" not in applied:
            applied.append("scoped Pdef.removeAll/clear to block-local patterns")
        targets = pdef_names or pbindef_names
        cls = "Pdef" if pdef_names else "Pbindef"
        if not targets:
            return "// Pdef.removeAll; // skipped: no local Pdefs in block"
        return " ".join(f"{cls}(\\{n}).stop; {cls}(\\{n}).clear;" for n in targets)

    code = re.sub(
        r'\bPdef\.(?:removeAll|clear|all\.do\s*(?:\([^;\n]*\)|\{[^}]*\}))\s*(?:\(\s*\))?\s*;?',
        _sub_pdef_global,
        code,
    )

    # 8. Tdef.removeAll / Tdef.clear / Tdef.all.do(...)
    def _sub_tdef_global(m: re.Match) -> str:
        if _is_in_line_comment(code, m.start()):
            return m.group(0)
        if "scoped Tdef.removeAll/all to block-local Tdefs" not in applied:
            applied.append("scoped Tdef.removeAll/all to block-local Tdefs")
        if not tdef_names:
            return "// Tdef.removeAll; // skipped: no local Tdefs in block"
        return " ".join(f"Tdef(\\{n}).stop;" for n in tdef_names)

    code = re.sub(
        r'\bTdef\.(?:removeAll|clear|all\.do\s*(?:\([^;\n]*\)|\{[^}]*\}))\s*(?:\(\s*\))?\s*;?',
        _sub_tdef_global,
        code,
    )

    return code, applied


DESIGN_PRE_CLEANUP_MARKER = "// [Pre-Design Cleanup: freeing previous Design synthesizer resources]"


def get_design_cleanup_sc(as_block: bool = True) -> str:
    """
    Return SuperCollider code that safely tears down a previously generated
    Design synthesizer (`~guiRoutine`, GUI windows, `MIDIdef`s, `~notes`/`~zoneNotes`,
    mono/FX synths, `~synthGroup`/`~fxGroup`/`~masterGroup`, `~buses`, design audio
    buses, and any `subtractiveDesign` fallback) while leaving shared `Ndef`, `Pbindef`,
    `Tdef`, and `~synthBus` layers from `append`/`compose`/`generate` untouched.
    """
    body = (
        f"{DESIGN_PRE_CLEANUP_MARKER}\n"
        "{\n"
        "    if(~guiRoutine.notNil) { try { ~guiRoutine.stop } {}; ~guiRoutine = nil };\n"
        "    [~mainWin, ~surWin, ~win, ~guiWin, ~synthWin].do { |w|\n"
        "        if(w.notNil) { try { w.close } {} };\n"
        "    };\n"
        "    ~mainWin = nil; ~surWin = nil; ~win = nil; ~guiWin = nil; ~synthWin = nil;\n"
        "    try { Window.closeAll } {};\n"
        "    try { MIDIdef.freeAll } {};\n"
        "    if(~notes.notNil) {\n"
        "        try {\n"
        "            ~notes.do { |item|\n"
        "                if(item.notNil) {\n"
        "                    if(item.isKindOf(Collection)) {\n"
        "                        item.do { |sn| if(sn.notNil) { try { sn.free } {} } };\n"
        "                    } {\n"
        "                        try { item.free } {};\n"
        "                    };\n"
        "                };\n"
        "            };\n"
        "        } {};\n"
        "        ~notes = nil;\n"
        "    };\n"
        "    if(~zoneNotes.notNil) {\n"
        "        try {\n"
        "            ~zoneNotes.do { |zone|\n"
        "                if(zone.notNil) {\n"
        "                    zone.do { |sn| if(sn.notNil) { try { sn.free } {} } };\n"
        "                };\n"
        "            };\n"
        "        } {};\n"
        "        ~zoneNotes = nil;\n"
        "    };\n"
        "    ~activeCount = 0;\n"
        "    [\n"
        "        ~subSynth, ~monoSynth, ~leadSynth, ~droneSynth, ~synth,\n"
        "        ~fxSynth, ~masterFx, ~celestialFx, ~ancientFx, ~reverbSynth, ~delaySynth,\n"
        "        ~synthGroup, ~fxGroup, ~masterGroup, ~sourceGroup\n"
        "    ].do { |node|\n"
        "        if(node.notNil) { try { node.free } {} };\n"
        "    };\n"
        "    ~subSynth = nil; ~monoSynth = nil; ~leadSynth = nil; ~droneSynth = nil; ~synth = nil;\n"
        "    ~fxSynth = nil; ~masterFx = nil; ~celestialFx = nil; ~ancientFx = nil; ~reverbSynth = nil; ~delaySynth = nil;\n"
        "    ~synthGroup = nil; ~fxGroup = nil; ~masterGroup = nil; ~sourceGroup = nil;\n"
        "    if(~buses.notNil) {\n"
        "        try { ~buses.do { |b| if(b.notNil) { try { b.free } {} } } } {};\n"
        "        ~buses = nil;\n"
        "    };\n"
        "    [~fxBus, ~celestialBus, ~ancientBus, ~reverbBus, ~delayBus].do { |b|\n"
        "        if(b.notNil) { try { b.free } {} };\n"
        "    };\n"
        "    ~fxBus = nil; ~celestialBus = nil; ~ancientBus = nil; ~reverbBus = nil; ~delayBus = nil;\n"
        "    try {\n"
        "        if(Pbindef.all.notNil and: { Pbindef.all[\\subtractiveDesignSeq].notNil }) {\n"
        "            Pbindef(\\subtractiveDesignSeq).stop;\n"
        "            Pbindef(\\subtractiveDesignSeq).clear;\n"
        "        };\n"
        "    } {};\n"
        "    try {\n"
        "        if(Ndef.dictFor(s).notNil and: { Ndef.dictFor(s)[\\subtractiveDesign].notNil }) {\n"
        "            Ndef(\\subtractiveDesign).clear(0.1);\n"
        "        };\n"
        "    } {};\n"
        "}.value;"
    )
    if as_block:
        return f"(\n{body}\n)"
    return body


def prepend_design_cleanup(code: str) -> tuple[str, bool]:
    """
    Inject the pre-design synthesizer cleanup closure at the start of a single-block
    (...) Design script so a previously generated Design synthesizer is cleanly
    stopped/freed before the new Design synthesizer initializes.
    Wraps the main body in `{ ... }.value;` so any top-level `var` declarations in
    the main body remain at the top of their closure scope.
    """
    if not code or not code.strip():
        return code, False
    if DESIGN_PRE_CLEANUP_MARKER in code:
        return code, False

    cleanup_closure = get_design_cleanup_sc(as_block=False)
    segments = _extract_top_level_blocks_and_segments(code)
    block_segments = [s for s in segments if s['type'] == 'block']

    if not block_segments:
        inner = code.strip()
        if not inner.endswith(';'):
            inner += ';'
        return f"(\n{cleanup_closure}\n{{\n{inner}\n}}.value;\n)", True

    first_blk = block_segments[0]
    btext = first_blk['text'].strip()
    inner = btext[1:-1].strip() if (btext.startswith('(') and btext.endswith(')')) else btext
    if not inner.endswith(';'):
        inner += ';'

    prefix = (first_blk.get('between', '').strip() + "\n") if first_blk.get('between', '').strip() else ""
    trailing_parts = []
    for seg in segments[1:]:
        if seg.get('between', '').strip():
            trailing_parts.append(seg['between'].strip())
        if seg.get('text', '').strip():
            trailing_parts.append(seg['text'].strip())
    suffix = ("\n\n" + "\n\n".join(trailing_parts)) if trailing_parts else ""

    wrapped = f"{prefix}(\n{cleanup_closure}\n{{\n{inner}\n}}.value;\n){suffix}"
    return wrapped, True


def normalize_for_xappend(
    code: str,
    mode: str = "append",
    cleanup_previous_design: bool = False,
) -> tuple[str, list[str]]:
    """
    Ensure LLM-generated code for X-Append (append, compose, design, generate) is
    auto-runnable as a single top-level (...) block:
      1. Runs validate_and_fix() first.
      2. Strips `s.makeGui` if present in automated runs, and forces `~enableRecording = false;` in compose.
      3. In `design` mode, injects hardware MIDI auto-detection fallback (BeatStep Pro / external MIDI when loopMIDI is absent).
      4. Comments out redundant `s.boot;` when `s.waitForBoot` is present in the same script.
      5. Detects trailing cleanup/teardown blocks (e.g. Design Step 5 Cleanup or Generate fade-out)
         and comments them out so they do not immediately kill the sound upon auto-evaluation.
      6. Consolidates multiple top-level (...) blocks into a single outer ( ... ) block, wrapping
         individual sub-blocks in `{ ... }.value;` when merging multiple blocks so local `var`
         declarations in later blocks never cause SuperCollider 'var declaration after statement' errors.
    """
    if not code or not code.strip():
        return code, []

    code, fixes = validate_and_fix(code)

    # In design mode, ensure MIDI device discovery includes BeatStep Pro / external hardware fallback
    if mode == "design":
        code, midi_injected = _inject_midi_device_fallback(code)
        if midi_injected:
            fixes.append("injected hardware MIDI fallback (BeatStep Pro / external MIDI when loopMIDI is absent)")

    # If s.waitForBoot is present, comment out redundant standalone `s.boot;` so it doesn't
    # print "server already booting / running"
    if "waitForBoot" in code and re.search(r'^\s*s\.boot\s*;', code, re.MULTILINE):
        code = re.sub(r'^(\s*)s\.boot\s*;', r'\1// s.boot; // handled by s.waitForBoot', code, flags=re.MULTILINE)
        fixes.append("commented out redundant s.boot before s.waitForBoot")

    # In compose mode, ensure ~enableRecording is false by default and strip s.makeGui
    if mode == "compose":
        if re.search(r'^\s*~enableRecording\s*=\s*true\s*;', code, re.MULTILINE):
            code = re.sub(r'^(\s*)~enableRecording\s*=\s*true\s*;', r'\1~enableRecording = false; // disabled for auto-run', code, flags=re.MULTILINE)
            fixes.append("disabled ~enableRecording = true for auto-run")
        if re.search(r'\bs\.makeGui\s*;?', code):
            code = re.sub(r'\bs\.makeGui\s*;?', '// s.makeGui;', code)
            fixes.append("commented out s.makeGui for auto-run")

    segments = _extract_top_level_blocks_and_segments(code)
    block_segments = [s for s in segments if s['type'] == 'block']

    # Case A: No top-level (...) blocks at all — wrap entire code in ( ... )
    if not block_segments:
        stripped = code.strip()
        if mode == "design":
            stripped, moved = _inject_trailing_code_into_waitforboot(stripped)
            if moved:
                fixes.append("moved post-waitForBoot GUI code inside s.waitForBoot")
        stripped, scope_fixes = _scope_global_teardowns_for_xappend(stripped)
        fixes.extend(scope_fixes)
        if not (stripped.startswith('(') and stripped.endswith(')')):
            code = f"(\n{stripped}\n)"
            fixes.append("wrapped unparenthesized code in single (...) block")
        else:
            code = stripped
        if mode == "design" and cleanup_previous_design:
            code, prepended = prepend_design_cleanup(code)
            if prepended:
                fixes.append("prepended pre-design synthesizer cleanup for previous design instance")
        return code, fixes

    # Partition blocks into active blocks vs teardown blocks
    active_parts = []
    commented_teardowns = []

    for idx, seg in enumerate(segments):
        if seg['type'] == 'block':
            between = seg.get('between', '')
            btext = seg['text'].strip()
            inner = btext[1:-1].strip() if (btext.startswith('(') and btext.endswith(')')) else btext

            between_lines = between.splitlines()
            between_comments = []
            between_code = []
            for line in between_lines:
                sline = line.strip()
                if not sline or sline.startswith('//') or sline.startswith('/*') or sline.startswith('*'):
                    between_comments.append(line)
                else:
                    between_code.append(line)

            if between_code:
                active_parts.append({
                    'comments': "\n".join(between_comments).strip(),
                    'inner': "\n".join(between_code).strip(),
                })
                between_for_block = ""
            else:
                between_for_block = "\n".join(between_comments).strip()

            if idx > 0 and _is_teardown_block(between, btext, mode):
                td_text = (between_for_block + "\n" + btext).strip() if between_for_block else btext
                commented_teardowns.append(_comment_out_lines(td_text))
                fixes.append(f"commented out teardown/cleanup block #{idx + 1}")
            else:
                active_parts.append({
                    'comments': between_for_block,
                    'inner': inner,
                })
        elif seg['type'] == 'trailing':
            ttext = seg['text'].strip()
            if not ttext:
                continue
            tlines = ttext.splitlines()
            has_exec = any(
                l.strip() and not l.strip().startswith('//') and not l.strip().startswith('/*')
                for l in tlines
            )
            if has_exec:
                commented_teardowns.append(
                    _comment_out_lines(ttext, header="// [Auto-Run: Live tweaks kept commented for manual evaluation]")
                )
                fixes.append("commented out trailing unparenthesized live tweaks")
            else:
                commented_teardowns.append(ttext)

    if len(active_parts) == 1:
        part = active_parts[0]
        inner_body = part['inner']
        if mode == "design":
            inner_body, moved = _inject_trailing_code_into_waitforboot(inner_body)
            if moved:
                fixes.append("moved post-waitForBoot GUI code inside s.waitForBoot")
        inner_body, scope_fixes = _scope_global_teardowns_for_xappend(inner_body)
        fixes.extend(scope_fixes)
        prefix = (part['comments'] + "\n") if part['comments'] else ""
        teardown_section = ("\n\n" + "\n\n".join(commented_teardowns)) if commented_teardowns else ""
        normalized = f"{prefix}(\n{inner_body}\n){teardown_section}"
        if mode == "design" and cleanup_previous_design:
            normalized, prepended = prepend_design_cleanup(normalized)
            if prepended:
                fixes.append("prepended pre-design synthesizer cleanup for previous design instance")
        return normalized, fixes

    # Multiple active blocks (e.g. Design Steps 0..4 or Generate Instruments/Effects/Sequences):
    # Consolidate into a SINGLE (...) block.
    if mode == "design" and len(active_parts) > 1:
        wait_idx = -1
        for i, p in enumerate(active_parts):
            if "s.waitForBoot" in p['inner']:
                wait_idx = i
                break
        if wait_idx != -1 and wait_idx + 1 < len(active_parts):
            remaining_after = []
            injected_chunks = []
            for p in active_parts[wait_idx + 1:]:
                p_inner = p['inner'].strip()
                if not p_inner.endswith(';'):
                    p_inner += ';'
                p_header = (p['comments'] + "\n") if p['comments'] else ""
                injected_chunks.append(f"{p_header}{{\n{p_inner}\n}}.value;")
            wait_code = active_parts[wait_idx]['inner']
            m_close = re.search(r'\}\s*\)\s*;?\s*$', wait_code)
            if m_close:
                insert_pos = m_close.start()
                injected_str = "\n\n    // --- Consolidated Post-Boot Step(s) ---\n    " + "\n\n    ".join(injected_chunks) + "\n"
                active_parts[wait_idx]['inner'] = wait_code[:insert_pos] + injected_str + wait_code[insert_pos:]
                active_parts = active_parts[:wait_idx + 1] + remaining_after
                fixes.append("injected post-boot GUI step inside s.waitForBoot")

    merged_chunks = []
    for part in active_parts:
        chunk_lines = []
        if part['comments']:
            chunk_lines.append(part['comments'])
        inner_code = part['inner'].strip()
        if not inner_code:
            continue
        if not inner_code.endswith(';'):
            inner_code += ';'
        chunk_lines.append(f"{{\n{inner_code}\n}}.value;")
        merged_chunks.append("\n".join(chunk_lines))

    fixes.append(f"consolidated {len(active_parts)} blocks into single (...) block")
    single_block = "(\n" + "\n\n".join(merged_chunks) + "\n)"
    single_block, scope_fixes = _scope_global_teardowns_for_xappend(single_block)
    fixes.extend(scope_fixes)
    if commented_teardowns:
        single_block += "\n\n" + "\n\n".join(commented_teardowns)
    if mode == "design" and cleanup_previous_design:
        single_block, prepended = prepend_design_cleanup(single_block)
        if prepended:
            fixes.append("prepended pre-design synthesizer cleanup for previous design instance")

    return single_block, fixes


def _strip_markdown_fences(code: str) -> str:
    """Remove leading/trailing markdown code fences if present."""
    stripped = code.strip()
    if stripped.startswith("```"):
        stripped = re.sub(r'^```[a-zA-Z0-9_-]*\s*\n?', '', stripped)
        stripped = re.sub(r'\n?```\s*$', '', stripped)
    return stripped.strip()


def _strip_ide_injected_helpers(code: str) -> str:
    """Remove IDE-injected quiet-texture comments and pre-design cleanup closures."""
    # Remove quiet-texture helper block injected by AiAssistWidget
    code = re.sub(
        r'// --- Quiet new textures \(uncomment to reduce volume to ~1/10\) ---\n(?://Ndef\(\\\w+\)\.set\(\\amp,\s*[\d.]+\);\n?)*',
        '',
        code,
    )
    # Remove DESIGN_PRE_CLEANUP_MARKER closure if present
    if DESIGN_PRE_CLEANUP_MARKER in code:
        idx = code.find(DESIGN_PRE_CLEANUP_MARKER)
        brace_pos = code.find('{', idx)
        if brace_pos != -1:
            end_brace = _scan_balanced_delim(code, brace_pos)
            if end_brace != -1:
                tail = code[end_brace:]
                m_val = re.match(r'\s*\.value\s*;?', tail)
                remove_end = end_brace + (m_val.end() if m_val else 0)
                code = code[:idx] + code[remove_end:]
    return code.strip()


def classify_sc_block(code: str, hint_mode: str = "") -> dict:
    """
    Programmatically classify a SuperCollider code block into one of:
      'generate', 'compose', 'design', 'append'
    without any LLM calls. Also determines whether the block is eligible for
    failsafe RAG ingestion (excluding pure teardown/silence or fallback blocks).
    """
    if not code or not code.strip():
        return {"mode": hint_mode or "append", "is_rag_eligible": False, "reason": "empty", "signals": []}

    if "[FAILSAFE APPLIED]" in code:
        return {"mode": hint_mode or "append", "is_rag_eligible": False, "reason": "failsafe_fallback", "signals": []}

    cleaned = _strip_markdown_fences(code)
    cleaned = _strip_ide_injected_helpers(cleaned)
    if not cleaned:
        return {"mode": hint_mode or "append", "is_rag_eligible": False, "reason": "empty_after_strip", "signals": []}

    # Strip comments and strings for structural token analysis
    code_no_comments = re.sub(r'//.*', '', cleaned)
    code_no_comments = re.sub(r'/\*.*?\*/', '', code_no_comments, flags=re.DOTALL)
    code_no_strings = re.sub(r'"(?:\\.|[^"\\])*"', '""', code_no_comments)
    code_no_strings = re.sub(r"'(?:\\.|[^'\\])*'", "''", code_no_strings)
    raw_lower = cleaned.lower()

    # Check if block is purely teardown/silence (no synthesis/pattern/GUI creation)
    has_synthesis_or_ui = any(
        kw in code_no_strings
        for kw in ("{", "SynthDef(", "Ndef(", "Pbindef(", "Pbind(", "Tdef(", "Window(", "CompositeView(")
    )
    has_active_def = bool(
        re.search(r'\bSynthDef\s*\(', code_no_strings)
        or re.search(r'\bNdef\s*\(\s*\\\w+\s*,', code_no_strings)
        or re.search(r'\bPbindef\s*\(\s*\\\w+\s*,', code_no_strings)
        or re.search(r'\bPbind\s*\(', code_no_strings)
        or re.search(r'\bTdef\s*\(\s*\\\w+\s*,', code_no_strings)
        or re.search(r'\bNdef\s*\(\s*\\\w+\s*\)\s*\[\s*\d+\s*\]\s*=', code_no_strings)
        or re.search(r'\bNdef\s*\(\s*\\\w+\s*\)\s*\.\s*x?set\s*\(', code_no_strings)
        or re.search(r'\b(?:Window|CompositeView)\s*\(', code_no_strings)
    )
    if not has_synthesis_or_ui or not has_active_def:
        return {"mode": hint_mode or "append", "is_rag_eligible": False, "reason": "no_active_definition", "signals": []}

    if _is_teardown_block("", cleaned, hint_mode or "append"):
        return {"mode": hint_mode or "append", "is_rag_eligible": False, "reason": "teardown_only", "signals": []}

    # 1. Design signatures (MIDI + GUI + ~ccVals / ~buses / ~notes / Groups)
    design_signals = []
    if re.search(r'\b(?:MIDIClient|MIDIIn\.connect|MIDIdef\.(?:noteOn|noteOff|cc))\b', code_no_strings):
        design_signals.append("midi_setup")
    if re.search(r'\b(?:Window|CompositeView|EZSlider|EZKnob|EZRanger|FlowLayout)\s*\(', code_no_strings):
        design_signals.append("gui_widgets")
    if re.search(r'~(?:ccVals|cc|buses|zoneNotes|notes|synthGroup|fxGroup|masterGroup)\b', code_no_strings):
        design_signals.append("design_env_state")
    if ".asMap" in code_no_strings:
        design_signals.append("bus_asMap")

    if len(design_signals) >= 2 or "midi_setup" in design_signals or "gui_widgets" in design_signals:
        return {"mode": "design", "is_rag_eligible": True, "reason": "design_signatures", "signals": design_signals}

    # 2. Compose signatures (Tdef timeline + .wait + safetyLimiter / ~synthBus / ~enableRecording / SynthDef)
    compose_signals = []
    has_tdef = bool(re.search(r'\bTdef\s*\(\s*\\\w+\s*,', code_no_strings))
    has_wait = bool(re.search(r'\b\d+(?:\.\d+)?\s*\.\s*wait\b', code_no_strings))
    if has_tdef:
        compose_signals.append("tdef")
    if has_wait:
        compose_signals.append("wait_timeline")
    if re.search(r'\\safetyLimiter\b', code_no_strings) or "ServerTree.add" in code_no_strings:
        compose_signals.append("safety_limiter")
    if "~synthBus" in code_no_strings or "Ndef(\\masterMix" in code_no_strings:
        compose_signals.append("master_bus_routing")
    if re.search(r'~(?:enableRecording|startRecording|stopRecording)\b|\\diskRecorder\b', code_no_strings):
        compose_signals.append("multitrack_recording")
    if re.search(r'\bSynthDef\s*\(', code_no_strings):
        compose_signals.append("synthdef")

    if (has_tdef and has_wait) or ("safety_limiter" in compose_signals and "synthdef" in compose_signals) or len(compose_signals) >= 3:
        return {"mode": "compose", "is_rag_eligible": True, "reason": "compose_signatures", "signals": compose_signals}

    # 3. Generate vs Append (JITLib Ndef + Pbindef)
    ndef_sources = set(re.findall(r'\bNdef\s*\(\s*\\([a-zA-Z_]\w*)\s*,\s*\{', code_no_strings))
    has_gen_headers = any(
        h in raw_lower
        for h in ("instruments ---", "effects ---", "sequences ---", "live coding tweaks ---")
    )
    has_append_markers = any(
        m in raw_lower
        for m in ("add_instrument", "add_effects", "tweak_instrument", "tweak_sequence", "tweak_effects", "// rollback", "// revert")
    )
    segments = _extract_top_level_blocks_and_segments(cleaned)
    top_blocks = [s for s in segments if s.get("type") == "block"]

    jitlib_signals = [f"ndef_sources:{len(ndef_sources)}", f"top_blocks:{len(top_blocks)}"]
    if has_gen_headers:
        jitlib_signals.append("gen_section_headers")
    if has_append_markers:
        jitlib_signals.append("append_markers")

    if has_gen_headers:
        return {"mode": "generate", "is_rag_eligible": True, "reason": "gen_section_headers", "signals": jitlib_signals}

    if has_append_markers and hint_mode == "append":
        return {"mode": "append", "is_rag_eligible": True, "reason": "incremental_markers", "signals": jitlib_signals}

    if len(ndef_sources) >= 2 or (len(top_blocks) >= 3 and len(ndef_sources) >= 1 and not has_append_markers):
        if hint_mode == "append":
            return {"mode": "append", "is_rag_eligible": True, "reason": "hint_append_multi_layer", "signals": jitlib_signals}
        return {"mode": "generate", "is_rag_eligible": True, "reason": "multi_layer_soundscape", "signals": jitlib_signals}

    if has_append_markers:
        return {"mode": "append", "is_rag_eligible": True, "reason": "incremental_markers", "signals": jitlib_signals}

    if hint_mode in ("generate", "append") and len(ndef_sources) == 1:
        return {"mode": hint_mode, "is_rag_eligible": True, "reason": f"hint_{hint_mode}", "signals": jitlib_signals}

    return {"mode": "append", "is_rag_eligible": True, "reason": "default_incremental", "signals": jitlib_signals}


def _unpack_consolidated_closures(inner_code: str) -> list[str]:
    """
    If `inner_code` consists of one or more top-level `{ ... }.value;` closures
    (created when normalize_for_xappend merged multiple blocks), unpack each
    closure into its own standalone `( ... )` block.
    """
    n = len(inner_code)
    pos = _skip_sc_ws_and_comments(inner_code, 0)
    if pos >= n or inner_code[pos] != '{':
        return []

    unpacked = []
    cur = 0
    while cur < n:
        ws_pos = _skip_sc_ws_and_comments(inner_code, cur)
        if ws_pos >= n:
            break
        if inner_code[ws_pos] != '{':
            return []
        close_pos = _scan_balanced_delim(inner_code, ws_pos)
        if close_pos == -1:
            return []
        tail_pos = _skip_sc_ws_and_comments(inner_code, close_pos)
        m_val = re.match(r'\.\s*value\s*;?', inner_code[tail_pos:])
        if not m_val:
            return []
        leading_comments = inner_code[cur:ws_pos].strip()
        body = inner_code[ws_pos + 1:close_pos - 1].strip()
        if body:
            block_str = f"(\n{leading_comments}\n{body}\n)" if leading_comments else f"(\n{body}\n)"
            unpacked.append(block_str)
        cur = tail_pos + m_val.end()

    return unpacked if len(unpacked) >= 2 else []


def extract_executable_rag_blocks(code: str, mode: str = "append") -> list[str]:
    """
    Break a verified SuperCollider generation into clean, standalone `(...)`
    executable blocks suitable for per-use-case failsafe RAGs.
    """
    if not code or not code.strip():
        return []

    cleaned = _strip_markdown_fences(code)
    cleaned = _strip_ide_injected_helpers(cleaned)
    cleaned, _ = validate_and_fix(cleaned)
    cleaned, _ = _scope_global_teardowns_for_xappend(cleaned)

    segments = _extract_top_level_blocks_and_segments(cleaned)
    block_segments = [s for s in segments if s.get("type") == "block"]

    exec_blocks: list[str] = []

    if not block_segments:
        stripped = cleaned.strip()
        if stripped and not _is_teardown_block("", stripped, mode):
            if not (stripped.startswith("(") and stripped.endswith(")")):
                stripped = f"(\n{stripped}\n)"
            if _check_balanced_brackets(stripped):
                exec_blocks.append(stripped)
        return exec_blocks

    for idx, seg in enumerate(segments):
        if seg.get("type") == "block":
            between = seg.get("between", "")
            btext = seg["text"].strip()

            # Check for unparenthesized executable statements between blocks
            between_comments = []
            between_code = []
            for line in between.splitlines():
                sline = line.strip()
                if not sline or sline.startswith("//") or sline.startswith("/*") or sline.startswith("*"):
                    between_comments.append(line)
                else:
                    between_code.append(line)

            if between_code:
                stmt_text = "\n".join(between_code).strip()
                if stmt_text and not _is_teardown_block("\n".join(between_comments), stmt_text, mode):
                    comment_hdr = "\n".join(between_comments).strip()
                    wrapped_stmt = f"(\n{comment_hdr}\n{stmt_text}\n)" if comment_hdr else f"(\n{stmt_text}\n)"
                    if _check_balanced_brackets(wrapped_stmt):
                        exec_blocks.append(wrapped_stmt)
                between_comments = []

            if idx > 0 and _is_teardown_block(between, btext, mode):
                continue

            inner = btext[1:-1].strip() if (btext.startswith("(") and btext.endswith(")")) else btext
            if not inner:
                continue

            # For generate/append without waitForBoot, unpack consolidated { ... }.value; closures
            if mode in ("generate", "append") and "waitForBoot" not in inner:
                unpacked = _unpack_consolidated_closures(inner)
                if unpacked:
                    for ub in unpacked:
                        if _check_balanced_brackets(ub):
                            exec_blocks.append(ub)
                    continue

            comment_hdr = "\n".join(between_comments).strip()
            formatted = f"(\n{comment_hdr}\n{inner}\n)" if comment_hdr else f"(\n{inner}\n)"
            if _check_balanced_brackets(formatted):
                exec_blocks.append(formatted)

        elif seg.get("type") == "trailing":
            ttext = seg["text"].strip()
            if not ttext:
                continue
            has_exec = any(
                l.strip() and not l.strip().startswith("//") and not l.strip().startswith("/*")
                for l in ttext.splitlines()
            )
            if not has_exec or _is_teardown_block("", ttext, mode):
                continue
            wrapped_trailing = f"(\n{ttext}\n)"
            if _check_balanced_brackets(wrapped_trailing):
                exec_blocks.append(wrapped_trailing)

    return exec_blocks


def _find_sclang_executable(sclang_path: str = None) -> str | None:
    """Locate sclang executable for headless -i scval verification."""
    import os
    import shutil

    if sclang_path and os.path.exists(sclang_path):
        return sclang_path

    here = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(here)
    candidates = [
        os.path.join(repo_root, "build", "Install", "SuperCollider", "sclang.exe"),
        os.path.join(repo_root, "build", "editors", "sc-ide", "Release", "sclang.exe"),
        os.path.join(repo_root, "build", "lang", "Release", "sclang.exe"),
        os.path.join(repo_root, "editors", "sc-ide", "Release", "sclang.exe"),
        os.path.join(repo_root, "lang", "Release", "sclang.exe"),
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    return shutil.which("sclang") or shutil.which("sclang.exe")


def verify_blocks_with_sclang_scval(entries: list[dict], sclang_path: str = None, timeout_per_entry: float = 6.0) -> list[dict]:
    """
    Headless safety net: verify any RAG entries not yet marked `val_server_verified`
    by running each extracted `()` block sequentially inside `sclang -i scval`.
    Returns the subset of entries whose `()` blocks compile and execute cleanly.
    """
    import os
    import subprocess
    import tempfile
    import threading
    import time

    need_check = [e for e in entries if not e.get("val_server_verified", False)]
    if not need_check:
        return list(entries)

    exe = _find_sclang_executable(sclang_path)
    if not exe:
        print("[scval] sclang executable not found; skipping headless fallback verification.", flush=True)
        return list(entries)

    proc = None
    output_buf = []
    buf_lock = threading.Lock()

    try:
        proc = subprocess.Popen(
            [exe, "-i", "scval", "-u", "57130"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            cwd=os.path.dirname(exe),
        )

        def _reader():
            while True:
                line = proc.stdout.readline()
                if not line:
                    break
                decoded = line.decode("utf-8", errors="replace")
                with buf_lock:
                    output_buf.append(decoded)

        t = threading.Thread(target=_reader, daemon=True)
        t.start()

        # Wait for class library compilation
        deadline = time.time() + 12.0
        ready = False
        while time.time() < deadline:
            with buf_lock:
                joined = "".join(output_buf)
            if "Welcome to SuperCollider" in joined or "compile done" in joined:
                ready = True
                break
            time.sleep(0.1)

        if not ready:
            print("[scval] sclang -i scval timed out booting.", flush=True)
            return list(entries)

        # Boot muted virtual validation server on port 57131
        with buf_lock:
            output_buf.clear()
        init_sc = (
            '(\n'
            '~valServer = Server(\\valServerBatch, NetAddr("127.0.0.1", 57131));\n'
            '~valServer.options.numOutputBusChannels = 2;\n'
            '~valServer.options.numInputBusChannels = 0;\n'
            'Server.default = s = ~valServer;\n'
            's.boot;\n'
            '"__SCVAL_READY__".postln;\n'
            ')\n\x0c'
        )
        proc.stdin.write(init_sc.encode("utf-8"))
        proc.stdin.flush()

        deadline = time.time() + 5.0
        while time.time() < deadline:
            with buf_lock:
                if "__SCVAL_READY__" in "".join(output_buf):
                    break
            time.sleep(0.05)

        verified_entries = []
        with tempfile.TemporaryDirectory(prefix="scval_rag_") as tmpdir:
            for idx, entry in enumerate(entries):
                if entry.get("val_server_verified", False):
                    verified_entries.append(entry)
                    continue

                blocks = entry.get("executable_blocks") or []
                if not blocks:
                    continue

                # Write each () block to a temp file and compile+execute sequentially
                file_exprs = []
                for b_idx, blk in enumerate(blocks):
                    val_code = re.sub(r'\.\s*waitForBoot\s*\(', '.do(', blk)
                    val_code = re.sub(r'\b(?:s|Server\.default)\s*\.\s*sync\s*;', 'nil;', val_code)
                    b_path = os.path.join(tmpdir, f"entry_{idx}_blk_{b_idx}.scd").replace("\\", "/")
                    with open(b_path, "w", encoding="utf-8") as bf:
                        bf.write(val_code)
                    file_exprs.append(
                        f'fn = thisProcess.interpreter.compileFile("{b_path}"); '
                        f'if(fn.isNil) {{ ok = false; "__VAL_ERROR__: compile failed".postln }} {{ fn.value }};'
                    )

                cleanup = "CmdPeriod.run; Ndef.clear; Pdef.removeAll; Tdef.removeAll; MIDIdef.freeAll; Window.closeAll;"
                wrapper = (
                    "try {\n"
                    "    var fn, ok = true;\n"
                    f"    {' '.join(file_exprs)}\n"
                    f"    try {{ {cleanup} }} {{ }};\n"
                    "    if(ok) { \"__VAL_VALID__\".postln };\n"
                    "} { |err|\n"
                    f"    try {{ {cleanup} }} {{ }};\n"
                    "    (\"__VAL_ERROR__: \" ++ err.errorString).postln;\n"
                    "};\n\x0c"
                )

                with buf_lock:
                    output_buf.clear()
                proc.stdin.write(wrapper.encode("utf-8"))
                proc.stdin.flush()

                end_time = time.time() + timeout_per_entry
                passed = False
                while time.time() < end_time:
                    with buf_lock:
                        out_text = "".join(output_buf)
                    if "__VAL_ERROR__:" in out_text or "syntax error" in out_text.lower() or "\nERROR:" in out_text or out_text.lstrip().startswith("ERROR:"):
                        passed = False
                        break
                    if "__VAL_VALID__" in out_text:
                        passed = True
                        break
                    time.sleep(0.05)

                if passed:
                    updated = dict(entry)
                    updated["val_server_verified"] = True
                    verified_entries.append(updated)
                else:
                    print(f"[scval] Rejected unverified RAG entry #{idx} ({entry.get('detected_mode', '?')}).", flush=True)

        return verified_entries
    except Exception as e:
        print(f"[scval] Headless verification error: {e}", flush=True)
        return list(entries)
    finally:
        if proc is not None:
            try:
                proc.stdin.write(b"0.exit\n\x0c")
                proc.stdin.flush()
                proc.wait(timeout=1.5)
            except Exception:
                try:
                    proc.kill()
                except Exception:
                    pass
