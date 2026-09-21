import re

filepath = r'c:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\knowledge_base\auto-append-rag.scd'

with open(filepath, 'r', encoding='utf-8') as f:
    file_content = f.read()

sections = re.split(r'(?m)^(?=// Source: )', file_content)
new_sections = []

for sec in sections:
    if not sec.strip():
        continue
        
    lines = sec.split('\n')
    header = lines[0]
    body = '\n'.join(lines[1:])
    
    blocks = []
    stack = []
    start_idx = -1
    for i, char in enumerate(body):
        if char == '(':
            if not stack:
                if i == 0 or body[i-1] == '\n':
                    start_idx = i
                    stack.append(i)
            else:
                stack.append(i)
        elif char == ')':
            if stack:
                stack.pop()
                if not stack:
                    blocks.append((start_idx, i))
                    
    if not blocks:
        new_sections.append(sec)
        continue
        
    new_body = list(body)
    for b_start, b_end in reversed(blocks):
        new_body[b_end] = ' '
        new_body[b_start] = ' '
        
    new_body_str = "".join(new_body).strip()
    
    consolidated = f"{header}\n(\n{new_body_str}\n)\n\n"
    new_sections.append(consolidated)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write("".join(new_sections).strip() + "\n")

print("Consolidation complete.")
