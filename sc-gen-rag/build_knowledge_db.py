#!/usr/bin/env python3
"""
build_knowledge_db.py
Build the ChromaDB vector store from the knowledge_base/ folder (.scd files).

Usage:
    pdm run build-knowledge-db                     # build only if DB doesn't exist
    pdm run build-knowledge-db --force             # wipe and rebuild
    pdm run build-knowledge-db -- --knowledge-dir ./my_docs
"""

import argparse
import os
import time

import config
import rag_engine


def main():
    parser = argparse.ArgumentParser(
        description="Build the knowledge-base vector store (.scd files)."
    )
    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Wipe and rebuild the vector DB even if it already exists.",
    )
    parser.add_argument(
        "--knowledge-dir",
        type=str,
        default=None,
        help=f"Override the knowledge-base folder (default: {config.CONTEXT_FOLDER}).",
    )
    args = parser.parse_args()

    if args.knowledge_dir:
        config.CONTEXT_FOLDER = args.knowledge_dir

    db_exists = os.path.exists(config.KNOWLEDGE_DB_PATH)

    if db_exists and not args.force:
        print(f"Knowledge-base DB already exists at '{config.KNOWLEDGE_DB_PATH}'.")
        print("Use --force to wipe and rebuild.")
        return

    print("=" * 50)
    print("  Knowledge-Base DB Builder")
    print(f"  Source dir  : {config.CONTEXT_FOLDER}")
    print(f"  DB output   : {config.KNOWLEDGE_DB_PATH}")
    print(f"  Embedding   : {config.EMBEDDING_MODEL}")

    print("=" * 50)

    start = time.time()

    try:
        rag_engine.build_knowledge_base_index()
    except Exception as e:
        print(f"\n✗ Build failed: {e}")
        raise SystemExit(1)

    elapsed = time.time() - start
    print(f"\n✓ Knowledge-base DB ready at '{config.KNOWLEDGE_DB_PATH}'  ({elapsed:.1f}s)")


if __name__ == "__main__":
    main()
