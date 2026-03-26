#!/usr/bin/env python3
"""
test_queries.py
Runs example queries through the Vector RAG pipeline to verify retrieval
from both knowledge_base (.scd) and SC HelpSource (.schelp).

Usage:
    python test_queries.py
    python test_queries.py --query "custom query here"
"""

import argparse
import os
import config
import rag_engine

# Queries designed to hit different sources
EXAMPLE_QUERIES = [
    # Should pull from knowledge-base
    ("Knowledge Base: FM Synthesis", "FM synthesis modulator carrier ratio frequency modulation"),
    ("Knowledge Base: Granular", "granular synthesis live audio input grains"),
    ("Knowledge Base: Distortion", "distortion waveshaping overdrive clipping"),

    # Should pull from SC HelpSource
    ("SC Help: SinOsc", "SinOsc arguments frequency phase audio rate"),
    ("SC Help: Pbind", "Pbind pattern sequencing duration notes"),
    ("SC Help: EnvGen", "EnvGen envelope ADSR gate doneAction"),

    # Should pull from both
    ("Vector: Ambient Drone", "dark ambient drone with reverb and filtering"),
    ("Vector: Ndef Live Coding", "Ndef live coding proxy space crossfade"),
]


def run_query(label, query_text, verbose=False):
    """Run a single query and print results summary."""
    print(f"\n{'─' * 70}")
    print(f"  {label}")
    print(f"  Query: \"{query_text}\"")
    print(f"{'─' * 70}")

    if not os.path.exists(config.KNOWLEDGE_DB_PATH) and not os.path.exists(config.SCHELP_DB_PATH):
        print("  ✗ Vector DB not found. Run build_vectordb.py first.")
        return

    try:
        retriever = rag_engine.get_retriever()
        results = retriever(query_text)
    except Exception as e:
        print(f"  ✗ Retrieval error: {e}")
        return

    if not results:
        print("  ✗ No results returned.")
        return

    source_counts = {}
    for i, doc in enumerate(results):
        src = doc.metadata.get("source", "unknown")
        fname = doc.metadata.get("filename", "unknown")
        source_counts[src] = source_counts.get(src, 0) + 1
        preview = doc.page_content[:120].replace("\n", " ").replace("\r", "")
        print(f"  {i+1}. [{src}] {fname}")
        if verbose:
            print(f"     {preview}...")

    print(f"\n  Sources: ", end="")
    print(" | ".join(f"{src}: {cnt}" for src, cnt in sorted(source_counts.items())))


def main():
    parser = argparse.ArgumentParser(description="Test RAG retrieval quality.")
    parser.add_argument("--query", type=str, help="Run a custom query instead of examples")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show content previews")
    args = parser.parse_args()

    print("=" * 70)
    print("  RAG Retrieval Test Suite")
    print(f"  KB DB: {config.KNOWLEDGE_DB_PATH}  |  SC DB: {config.SCHELP_DB_PATH}  |  K: {config.RAG_K}")
    print("=" * 70)

    if args.query:
        run_query("Custom Query", args.query, verbose=args.verbose)
    else:
        for label, query in EXAMPLE_QUERIES:
            run_query(label, query, verbose=args.verbose)

    print(f"\n{'=' * 70}")
    print("  Done.")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    main()
