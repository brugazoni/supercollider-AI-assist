#!/usr/bin/env python3
"""
validate_knowledge_db.py

All-in-one validation script for the knowledge base vector DB.
Runs a battery of checks and prints a clear PASS/FAIL verdict.

Checks:
  1. Database existence
  2. Emptiness (must have > 0 chunks)
  3. Source file breakdown (files indexed and chunk counts)
  4. Chunk size statistics (min / avg / max)
  5. Source cross-reference (indexed files vs. files on disk)
  6. Pollution scan (API errors / rate limits leaked into chunks)

Usage:
    python validate_knowledge_db.py
"""

import os
import sys

try:
    from langchain_chroma import Chroma
    from langchain_huggingface import HuggingFaceEmbeddings
except ImportError:
    print("Error: Missing dependencies. Run 'pdm install'.")
    sys.exit(1)

import config

# ---------------------------------------------------------------------------
# Pollution patterns – superset from all previous scripts
# ---------------------------------------------------------------------------
POLLUTION_PATTERNS = [
    "quota exceeded",
    "rate limit",
    "api key",
    "internal server error",
    "service unavailable",
    "model is overloaded",
    "maximum context length",
    "invalid request",
    "resource exhausted",
    "credit",
    "api error",
]


def _is_false_positive(doc_lower: str, pattern: str) -> bool:
    """Filter out known false positives (e.g. 'slew rate' in SuperCollider)."""
    if pattern == "rate limit" and "slew rate" in doc_lower:
        return True
    return False


# ---------------------------------------------------------------------------
# Individual checks
# ---------------------------------------------------------------------------

def check_existence(db_path: str) -> bool:
    """Verify the database directory exists."""
    print("\n[1] Database Existence")
    if not os.path.exists(db_path):
        print(f"    [FAIL] Directory '{db_path}' does not exist.")
        print("    Run `python build_knowledge_db.py` to generate it.")
        return False
    print(f"    [PASS] Directory exists at '{db_path}'.")
    return True


def check_not_empty(docs: list) -> bool:
    """Verify the database contains at least one chunk."""
    print("\n[2] Emptiness Check")
    total = len(docs)
    if total == 0:
        print("    [FAIL] Database is empty (0 chunks).")
        return False
    print(f"    [PASS] {total} chunk(s) loaded.")
    return True


def report_file_breakdown(metas: list):
    """Print a per-file chunk count breakdown."""
    print("\n[3] Source File Breakdown")
    files_tally: dict[str, int] = {}
    for meta in metas:
        fname = meta.get("filename", meta.get("file", "unknown"))
        files_tally[fname] = files_tally.get(fname, 0) + 1

    total = sum(files_tally.values())
    for fname, count in sorted(files_tally.items()):
        pct = count / total * 100
        print(f"    {fname:40s}  {count:4d} chunks  ({pct:.1f}%)")
    return files_tally


def report_chunk_stats(docs: list):
    """Print min / avg / max chunk sizes in characters."""
    print("\n[4] Chunk Size Statistics")
    lengths = [len(d) for d in docs]
    total = len(lengths)
    print(f"    Min: {min(lengths):,} chars")
    print(f"    Avg: {sum(lengths) // total:,} chars")
    print(f"    Max: {max(lengths):,} chars")


def check_cross_reference(indexed_files: dict[str, int]) -> bool:
    """Compare indexed filenames against what is on disk in knowledge_base/."""
    print("\n[5] Source Cross-Reference")
    kb_path = config.CONTEXT_FOLDER
    if not os.path.isdir(kb_path):
        print(f"    [WARN] knowledge_base directory '{kb_path}' not found, skipping.")
        return True

    on_disk = set(os.listdir(kb_path))
    indexed = set(indexed_files.keys())

    missing_from_db = on_disk - indexed
    extra_in_db = indexed - on_disk

    ok = True
    if missing_from_db:
        print(f"    [WARN] {len(missing_from_db)} file(s) on disk but NOT indexed:")
        for f in sorted(missing_from_db):
            print(f"        - {f}")
        ok = False
    if extra_in_db:
        print(f"    [WARN] {len(extra_in_db)} file(s) indexed but NOT on disk:")
        for f in sorted(extra_in_db):
            print(f"        - {f}")
        ok = False
    if ok:
        print("    [PASS] All files on disk are indexed and vice-versa.")
    return ok


def check_pollution(docs: list, metas: list) -> bool:
    """Scan every chunk for API error / pollution patterns."""
    print("\n[6] Pollution Scan")
    polluted = []

    for i, (doc, meta) in enumerate(zip(docs, metas)):
        fname = meta.get("filename", meta.get("file", "unknown"))
        lower_doc = doc.lower()
        hits = [
            p for p in POLLUTION_PATTERNS
            if p in lower_doc and not _is_false_positive(lower_doc, p)
        ]
        if hits:
            polluted.append((i, fname, hits, doc[:150].replace("\n", " ")))

    if not polluted:
        print("    [PASS] No pollution patterns detected.")
        return True

    # Summary by file
    by_file: dict[str, int] = {}
    for _, fname, _, _ in polluted:
        by_file[fname] = by_file.get(fname, 0) + 1

    print(f"    [FAIL] {len(polluted)} polluted chunk(s) detected!")
    print()
    print("    Pollution by file:")
    for fname, count in sorted(by_file.items()):
        print(f"        {fname}: {count} bad chunk(s)")

    print()
    show = min(5, len(polluted))
    print(f"    First {show} polluted chunk(s):")
    for idx, fname, patterns, snippet in polluted[:show]:
        print(f"      #{idx} | {fname} | Matched: {', '.join(patterns)}")
        print(f"        Snippet: {snippet[:120]}...")
        print()
    if len(polluted) > show:
        print(f"    ... and {len(polluted) - show} more.")
    return False


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    db_path = config.KNOWLEDGE_DB_PATH

    print("=" * 60)
    print("  KNOWLEDGE BASE — VECTOR DB VALIDATION")
    print("=" * 60)
    print(f"  DB path : {db_path}")
    print(f"  KB dir  : {config.CONTEXT_FOLDER}")
    print(f"  Model   : {config.EMBEDDING_MODEL}")

    # 1. Existence
    if not check_existence(db_path):
        sys.exit(1)

    # Load database once
    print("\n    Loading database...")
    embeddings = HuggingFaceEmbeddings(model_name=config.EMBEDDING_MODEL)
    db = Chroma(persist_directory=db_path, embedding_function=embeddings)
    data = db.get()
    docs = data.get("documents", [])
    metas = data.get("metadatas", [])

    # 2. Emptiness
    if not check_not_empty(docs):
        sys.exit(1)

    # 3-6: remaining checks (collect pass/fail)
    issues = 0

    file_breakdown = report_file_breakdown(metas)
    report_chunk_stats(docs)

    if not check_cross_reference(file_breakdown):
        issues += 1

    if not check_pollution(docs, metas):
        issues += 1

    # Final verdict
    print()
    print("=" * 60)
    if issues == 0:
        print("  VERDICT: ALL CHECKS PASSED ✓")
    else:
        print(f"  VERDICT: {issues} CHECK(S) FAILED ✗")
        print("  Review warnings above; rebuild DB if pollution is present.")
    print("=" * 60)


if __name__ == "__main__":
    main()
