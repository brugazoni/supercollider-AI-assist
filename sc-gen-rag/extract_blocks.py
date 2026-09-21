import glob
import re
import os

files = glob.glob('sc-files/*.scd')
output_path = 'knowledge_base/auto-append-rag.scd'
os.makedirs('knowledge_base', exist_ok=True)

results = []

def extract_paren_blocks(text):
    blocks = []
    stack = []
    start_idx = -1
    
    for i, char in enumerate(text):
        if char == '(':
            if not stack:
                start_idx = i
            stack.append(i)
        elif char == ')':
            if stack:
                stack.pop()
                if not stack:
                    blocks.append(text[start_idx:i+1])
                    
    return blocks

for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    blocks = extract_paren_blocks(content)
    
    valid_blocks = []
    for block in blocks:
        if 'Ndef' in block and 'Pbindef' in block:
            valid_blocks.append(f"// Source: {os.path.basename(file_path)}\n{block}")
            
    if valid_blocks:
        results.extend(valid_blocks)
        
with open(output_path, 'w', encoding='utf-8') as f:
    f.write("\n\n".join(results))
    
print(f"Extracted {len(results)} valid blocks from {len(files)} files.")
