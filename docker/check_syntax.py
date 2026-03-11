#!/usr/bin/env python3
"""
SuperCollider Syntax Checker

This script preprocesses SuperCollider files that contain multiple () blocks,
then validates the syntax using sclang.

Usage: python check_syntax.py <path_to_file>
"""

import sys
import subprocess
import tempfile
import os
import re

def remove_top_level_parens(code: str) -> str:
    """
    Remove top-level () blocks used as IDE execution markers.
    These are valid in SC IDE but cause issues when compiling entire file.
    """
    result = []
    depth = 0
    i = 0
    in_string = False
    in_line_comment = False
    in_block_comment = False
    
    while i < len(code):
        char = code[i]
        prev_char = code[i-1] if i > 0 else None
        next_char = code[i+1] if i < len(code) - 1 else None
        
        # Track string state
        if not in_line_comment and not in_block_comment:
            if char == '"' and prev_char != '\\':
                in_string = not in_string
        
        # Track comments
        if not in_string:
            if not in_block_comment and char == '/' and next_char == '/':
                in_line_comment = True
            if in_line_comment and char == '\n':
                in_line_comment = False
            if not in_line_comment and char == '/' and next_char == '*':
                in_block_comment = True
            if in_block_comment and prev_char == '*' and char == '/':
                in_block_comment = False
        
        # Only process parens outside strings and comments
        if not in_string and not in_line_comment and not in_block_comment:
            if char == '(':
                if depth == 0:
                    # Check if this is a top-level block paren
                    # by looking at surrounding context
                    before = code[:i].rstrip()
                    if len(before) == 0 or before[-1] in ';\n)}\r':
                        # This is a top-level block opener - skip it
                        i += 1
                        depth += 1
                        continue
                depth += 1
            elif char == ')':
                depth -= 1
                if depth == 0:
                    # Check if this was a top-level block closer
                    after = code[i+1:].lstrip()
                    if len(after) == 0 or after[0] in '\n\r' or after.startswith('//'):
                        # This is a top-level block closer - skip it  
                        i += 1
                        continue
        
        result.append(char)
        i += 1
    
    return ''.join(result)


def check_syntax(filepath: str) -> tuple[bool, str]:
    """
    Check SuperCollider file syntax.
    Returns (is_valid, message)
    """
    if not os.path.exists(filepath):
        return False, f"File not found: {filepath}"
    
    with open(filepath, 'r', encoding='utf-8') as f:
        original_code = f.read()
    
    # Preprocess to remove top-level () blocks
    processed_code = remove_top_level_parens(original_code)
    
    # Wrap in function for compilation test
    test_code = f"{{ {processed_code} }}.compile.notNil.if {{ \"SYNTAX_OK\".postln; 0.exit }} {{ \"SYNTAX_ERROR\".postln; 1.exit }};"
    
    # Write to temp file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.scd', delete=False) as f:
        f.write(test_code)
        temp_path = f.name
    
    try:
        # Run sclang
        result = subprocess.run(
            ['sclang', temp_path],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        output = result.stdout + result.stderr
        
        if 'SYNTAX_OK' in output:
            return True, original_code
        elif 'ERROR:' in output:
            # Extract error message
            error_lines = [l for l in output.split('\n') if 'ERROR:' in l or 'line' in l.lower()]
            return False, '\n'.join(error_lines[:10])
        else:
            return False, output[-2000:] if len(output) > 2000 else output
            
    except subprocess.TimeoutExpired:
        return False, "Timeout waiting for sclang"
    except Exception as e:
        return False, str(e)
    finally:
        os.unlink(temp_path)


def main():
    if len(sys.argv) < 2:
        print("SYNTAX_ERROR: No file path provided")
        sys.exit(1)
    
    filepath = sys.argv[1]
    is_valid, message = check_syntax(filepath)
    
    if is_valid:
        print("SYNTAX_OK")
        print("---CODE_START---")
        print(message)
        print("---CODE_END---")
        sys.exit(0)
    else:
        print("SYNTAX_ERROR:")
        print(message)
        sys.exit(1)


if __name__ == "__main__":
    main()
