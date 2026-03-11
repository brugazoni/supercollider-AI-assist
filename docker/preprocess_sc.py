#!/usr/bin/env python3
"""
SuperCollider Syntax Checker - Preprocessor

This script preprocesses SuperCollider files that contain multiple () blocks,
removing the top-level parentheses that are IDE convenience syntax.

The output can then be sent to sclang for compilation testing.

Usage: python preprocess_sc.py <input_file> > <output_file>
"""

import sys
import os


def remove_top_level_parens(code: str) -> str:
    """
    Remove top-level () blocks used as IDE execution markers.
    These are valid in SC IDE but cause issues when compiling entire file.
    
    We identify top-level parens as:
    - Opening ( that appears at the start of a line (after optional whitespace)
    - Closing ) that appears at the end of a meaningful block
    """
    lines = code.split('\n')
    result_lines = []
    depth = 0
    in_string = False
    in_block_comment = False
    
    for line in lines:
        result_chars = []
        i = 0
        line_start = True  # Track if we're at logical start of line
        
        while i < len(line):
            char = line[i]
            prev_char = line[i-1] if i > 0 else None
            next_char = line[i+1] if i < len(line) - 1 else None
            
            # Track block comments
            if not in_string:
                if not in_block_comment and char == '/' and next_char == '*':
                    in_block_comment = True
                elif in_block_comment and prev_char == '*' and char == '/':
                    in_block_comment = False
                    result_chars.append(char)
                    i += 1
                    continue
            
            # Track strings
            if not in_block_comment:
                if char == '"' and prev_char != '\\':
                    in_string = not in_string
            
            # Skip processing inside strings or comments
            if in_string or in_block_comment:
                result_chars.append(char)
                i += 1
                continue
            
            # Check for line comments
            if char == '/' and next_char == '/':
                # Rest of line is comment
                result_chars.append(line[i:])
                break
            
            # Handle parentheses
            if char == '(':
                if depth == 0 and line_start:
                    # This is a top-level block opener - skip it
                    depth += 1
                    i += 1
                    continue
                else:
                    depth += 1
            elif char == ')':
                depth -= 1
                if depth == 0:
                    # Check if rest of line is just whitespace/comment
                    rest = line[i+1:].strip()
                    if rest == '' or rest.startswith('//'):
                        # This is a top-level block closer - skip it
                        i += 1
                        continue
            
            # Track if we're still at logical line start
            if char not in ' \t':
                line_start = False
            
            result_chars.append(char)
            i += 1
        
        result_lines.append(''.join(result_chars))
    
    return '\n'.join(result_lines)


def main():
    if len(sys.argv) < 2:
        print("Usage: preprocess_sc.py <input_file> [output_file]", file=sys.stderr)
        sys.exit(1)
    
    filepath = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(filepath):
        print(f"Error: File not found: {filepath}", file=sys.stderr)
        sys.exit(1)
    
    with open(filepath, 'r', encoding='utf-8') as f:
        code = f.read()
    
    processed = remove_top_level_parens(code)
    
    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(processed)
    else:
        print(processed)


if __name__ == "__main__":
    main()
