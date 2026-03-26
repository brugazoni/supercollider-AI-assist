# Tier 2 Validation Information Flow

The "Tier 2" validation dynamically verifies LLM-generated SuperCollider code using a real headless `sclang` subprocess. Because SuperCollider does not have a formal linting API, the system essentially creates a REPL (Read-Eval-Print Loop) interaction with the `sclang` executable and parses `stdout` to detect whether the evaluated block was syntactically correct.

## Information Flow and Architecture

### 1. Persistent Subprocess (`sclang_validator.py`)
To prevent the overhead of booting the SuperCollider class library for every single generation attempt (which takes ~1-3 seconds), a persistent background `sclang` process is spawned when `Auto-Execute` is enabled.
- The process is started with pipes attached to `stdin`, `stdout`, and `stderr`.
- A dedicated background daemon thread continuously reads from `stdout` and appends incoming lines to a thread-safe buffer.

### 2. Code Ingestion (`agent_graph_incremental.py`)
When the LLM generates a block of code during the `generate_block` node, it undergoes Tier 1 (local string evaluation for matching parentheses). If it passes, it is sent to Tier 2 out to the `SclangValidator`.

### 3. File Execution Workaround
Because `sclang` in interactive terminal mode parses code on a line-by-line basis, directly passing large, multi-line blocks over `stdin` on Windows causes severe truncation and `Parse Error: unexpected end of file` issues (because the REPL attempts to evaluate incomplete expressions immediately when encountering newlines).
To reliably evaluate code regions:
1. The generated code code block is immediately written to a temporary local file (e.g., `temp.scd`).
2. A single-line wrapper command is dynamically generated:
   ```supercollider
   try { "C:/Path/To/temp.scd".load ; "__SCLANG_VALID__".postln } { |err| ("__SCLANG_ERROR__: " ++ err.errorString).postln }
   ```

### 4. Sending the Payload Over `stdin`
The wrapper command is encoded to UTF-8. Crucially (especially on Windows), the string MUST be terminated by a newline (`\\n`) followed by a Form Feed execution character (`\\x0c`). Without the trailing newline, the `cmd.exe` linebuffer does not forward the evaluation instruction to `sclang`, leaving the interactive interpreter endlessly hanging at the `sc3>` shell prompt.
   ```python
   payload = wrapped_string.encode('utf-8')
   process.stdin.write(payload + b'\\x0c')
   ```

### 5. Output Trapping and Parsing
The code is evaluated by `.load`ing the temp file inside SuperCollider. The outcome is printed to `stdout`.
The `SclangValidator` loops over the background output buffer for 5 seconds waiting for the operation to resolve.

- **Valid Code:** Parses properly, evaluating successfully. The `__SCLANG_VALID__` signature is posted to the console. The validator detects this and returns `True`.
- **Invalid Syntax:** If the code string has syntax errors (e.g. missing semicolons, unbalanced brackets), `.load` fails immediately with an `ERROR: Parse error`. The validator traps the stack trace string by searching for `ERROR: Parse` and returns `False`.
- **Runtime Errors:** If the syntax is perfectly valid, but the internal variables/methods fail at execution time (e.g. `Message 'play' not understood`), the `try/catch` wrapper intercepts the failure gracefully. It posts `__SCLANG_ERROR__:` along with the `errorString`. The validator detects this marker and explicitly returns `False` along with the error description to feed backward to the LLM agent for self-correction.

### 6. Synchronizing the Environment
Because incremental validation evaluates code block-by-block, if Block 1 initializes `Ndef(\\sine)`, Block 2 needs `\\sine` to exist in memory to tweak it.
Once the entire generated code chunk has passed all internal checks, the `SclangValidator` calls `.mirror_block()`. It repeats the `.load` procedure silently, so the continuous background `sclang` interpreter actually instantiates the objects in its runtime state, preparing it to correctly validate the next incremental block.
