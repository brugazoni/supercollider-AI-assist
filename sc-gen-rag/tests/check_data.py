import json
import os
import sys

base_dir = r"C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output"

p_10 = os.path.join(base_dir, "run_20261111_214444", "benchmark_report.json")
d_10 = json.load(open(p_10, encoding="utf-8")) if os.path.exists(p_10) else None

p_8 = os.path.join(base_dir, "run_20261112_191506", "benchmark_report.json")
d_8 = json.load(open(p_8, encoding="utf-8")) if os.path.exists(p_8) else None

p_8_qual = os.path.join(base_dir, "run_20261112_191506", "qualitative_eval_report.json")
d_8_qual = json.load(open(p_8_qual, encoding="utf-8")) if os.path.exists(p_8_qual) else None

p_fast_ab = os.path.join(base_dir, "kb_ab_20261113_082808", "unified_ab_report.json")
d_fast_ab = json.load(open(p_fast_ab, encoding="utf-8")) if os.path.exists(p_fast_ab) else None

p_next_ab = os.path.join(base_dir, "kb_ab_next_20261113_100344", "unified_ab_report.json")
d_next_ab = json.load(open(p_next_ab, encoding="utf-8")) if os.path.exists(p_next_ab) else None

print("Loaded all datasets successfully!")
print("10-Round models:", len(d_10['models']))
print("8-Round models:", len(d_8['models']))
print("Fast-Tier A/B models:", len(d_fast_ab['quant_no_kb']['models']))
print("Next-Tier A/B models:", len(d_next_ab['quant_no_kb']['models']))
