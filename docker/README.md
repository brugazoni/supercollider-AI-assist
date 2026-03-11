# SuperCollider Docker Syntax Checker

This Docker setup provides a headless SuperCollider environment for validating syntax of LLM-generated code.

## Quick Start

### 1. Build the Docker Image

```bash
cd docker
docker-compose build
```

> ⚠️ **Note**: The first build may take 15-30 minutes as it compiles SuperCollider from source.

### 2. Start the Container

```bash
docker-compose up -d
```

This starts the container in detached mode, keeping it running for syntax checks.

### 3. Check Code Syntax

**PowerShell (Windows):**
```powershell
.\Check-SCCode.ps1 -CodeInput "{ SinOsc.ar(440) }.play"
```

**Bash (Linux/Mac/WSL):**
```bash
./check_code.sh "{ SinOsc.ar(440) }.play"
```

**Or check a file:**
```powershell
.\Check-SCCode.ps1 -CodeInput "C:\path\to\code.scd"
```

### 4. Direct Docker Usage

You can also run the syntax checker directly:

```bash
# Check inline code
docker exec sc_syntax_checker sclang -e "{ SinOsc.ar }.play.compile; 'OK'.postln; 0.exit"

# Check a file (mount it first or use the code_input volume)
echo "{ SinOsc.ar(440) }.play" > docker/code_input/test.scd
docker exec sc_syntax_checker sclang /app/check_syntax.scd /app/code_input/test.scd
```

## Output Format

The syntax checker outputs structured data for easy parsing:

### Success:
```
SYNTAX_OK
---CODE_START---
{ SinOsc.ar(440) }.play
---CODE_END---
```
Exit code: `0`

### Failure:
```
SYNTAX_ERROR:
Parse error at line 1: unexpected token...
```
Exit code: `1`

## Integration with LLM Pipeline

Here's an example of how to integrate this into a Python LLM pipeline:

```python
import subprocess
import tempfile
import os

def check_sc_syntax(code: str) -> tuple[bool, str]:
    """
    Check SuperCollider code syntax.
    
    Returns:
        (is_valid, message): Tuple with validity flag and message
    """
    # Write code to temp file in mounted volume
    code_input_dir = "docker/code_input"
    temp_file = tempfile.NamedTemporaryFile(
        mode='w', 
        suffix='.scd', 
        dir=code_input_dir,
        delete=False
    )
    temp_file.write(code)
    temp_file.close()
    
    filename = os.path.basename(temp_file.name)
    
    try:
        result = subprocess.run(
            ["docker", "exec", "sc_syntax_checker", 
             "sclang", "/app/check_syntax.scd", f"/app/code_input/{filename}"],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            return True, code
        else:
            return False, result.stdout + result.stderr
    finally:
        os.unlink(temp_file.name)

# Usage
code = "{ SinOsc.ar(440) }.play"
is_valid, result = check_sc_syntax(code)

if is_valid:
    print("Code is valid, sending forward...")
    # send_to_next_stage(result)
else:
    print(f"Syntax error: {result}")
    # handle_error(result)
```

## Verification Tests

After building, run these tests to verify the setup:

```bash
# Test 1: Server boot (verifies JACK dummy driver works)
docker run --rm supercollider-syntax-checker \
    sclang -e "s.waitForBoot { 'Server booted!'.postln; 0.exit }"

# Test 2: GUI class access (verifies Xvfb works)
docker run --rm supercollider-syntax-checker \
    sclang -e "Window.new.close; 'GUI OK'.postln; 0.exit"

# Test 3: Basic syntax check
docker exec sc_syntax_checker \
    sclang -e "{ |x| x + 1 }.compile; 'Compile OK'.postln; 0.exit"

# Test 4: Syntax error detection
docker exec sc_syntax_checker \
    sclang -e "{ |x x + 1 }.compile; 0.exit"  # Missing comma - should error
```

## Directory Structure

```
docker/
├── Dockerfile              # Multi-stage build for SuperCollider
├── docker-compose.yml      # Container orchestration
├── entrypoint.sh          # Starts JACK + Xvfb
├── check_syntax.scd       # SC syntax checker script
├── check_code.sh          # Bash wrapper
├── Check-SCCode.ps1       # PowerShell wrapper
├── code_input/            # Mount point for code files (created on first run)
├── user_extensions/       # Persisted SC extensions
├── quarks/               # Persisted quarks
└── config/               # Persisted SC config
```

## Stopping the Container

```bash
docker-compose down
```

## Troubleshooting

### Container won't start
Check if Docker is running and has sufficient resources (the build needs ~4GB RAM).

### Compilation errors during build
The SuperCollider repository may have changed. Try updating the Dockerfile to use a specific release tag:
```dockerfile
RUN git clone --recursive --branch Version-3.13.0 https://github.com/supercollider/supercollider.git /tmp/sc
```

### Slow execution
First runs may be slower as sclang compiles the class library. Subsequent checks are faster.

---

## GUI Mode (Full SuperCollider IDE)

This Docker setup also supports running the **full SuperCollider IDE** with graphical interface via X11 forwarding.

### Prerequisites (Windows)

1. **Install an X Server** - Choose one:
   - **Windows 11**: WSLg is built-in, no extra installation needed
   - **Windows 10/other**: Install [VcXsrv](https://sourceforge.net/projects/vcxsrv/)

2. **VcXsrv Configuration** (if not using WSLg):
   - Launch XLaunch
   - Choose "Multiple windows"
   - Select "Start no client"
   - **Check "Disable access control"** (important!)
   - Save configuration for future use

### Building the GUI Image

```powershell
cd docker
.\run-sc-gui.ps1 -Build
```

> ⚠️ **Note**: First build takes **30-60 minutes** as it compiles SuperCollider with the IDE from source.

### Running the IDE

```powershell
.\run-sc-gui.ps1
```

The SuperCollider IDE window will appear on your Windows desktop.

### Testing Auto-Reload Feature

This build includes a modification that **automatically reloads files** when external changes are detected:

1. Open a `.scd` file in the IDE from `/app/code_input` (mapped to `docker/code_input`)
2. Edit the same file with an external editor
3. The IDE will reload the file automatically, showing only a status message (no confirmation dialog)

### Directory Mounts

| Host Directory | Container Path | Purpose |
|----------------|----------------|---------|
| `docker/code_input/` | `/app/code_input` | Your SC working files |
| `docker/user_extensions/` | `~/.local/share/SuperCollider/Extensions` | Custom extensions |
| `docker/quarks/` | `~/.local/share/SuperCollider/downloaded-quarks` | Downloaded quarks |
| `docker/config/` | `~/.config/SuperCollider` | IDE settings |

### GUI Troubleshooting

**IDE doesn't appear:**
- Ensure VcXsrv is running (check system tray)
- Make sure "Disable access control" is checked in VcXsrv
- Try running: `docker compose -f docker-compose.gui.yml run --rm supercollider-gui xeyes` (test X11)

**"Cannot open display" error:**
- Check that DISPLAY is set correctly
- Verify Windows Firewall allows VcXsrv connections

**Audio issues:**
- The container uses a dummy JACK driver (no real audio output)
- Audio synthesis works internally for testing/development
