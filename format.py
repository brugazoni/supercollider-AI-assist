#!/usr/bin/env python
if __name__ == "__main__":
    import subprocess
    import sys
    commit_arg = [sys.argv[1]] if len(sys.argv) > 1 else []
    # Have to use Python interpreter directly since Windows shell doesn't seem to consider Python
    # scripts executable via Python even if the filetype association is there.
    subprocess.call(['python', 'C:/Users/Bruno Gazoni/Desktop/supercollider-project/supercollider-AI-assist/tools/clang-format.py', 'format'] + commit_arg)
