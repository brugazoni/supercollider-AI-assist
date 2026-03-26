#!/usr/bin/env python3
"""
build_schelp_db.py
Build the ChromaDB vector store from SuperCollider HelpSource (.schelp files).

Usage:
    pdm run build-schelp-db                        # build only if DB doesn't exist
    pdm run build-schelp-db --force                # wipe and rebuild
    pdm run build-schelp-db -- --sc-help-path "C:\\...\\HelpSource"
"""

import argparse
import os
import time

import config
import rag_engine


def main():
    parser = argparse.ArgumentParser(
        description="Build the SC Help vector store (.schelp files)."
    )
    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Wipe and rebuild the vector DB even if it already exists.",
    )
    parser.add_argument(
        "--sc-help-path",
        type=str,
        default=None,
        help=f"Override the SC HelpSource path (default: {config.SC_HELP_PATH}).",
    )
    args = parser.parse_args()

    if args.sc_help_path:
        config.SC_HELP_PATH = args.sc_help_path

    db_exists = os.path.exists(config.SCHELP_DB_PATH)

    if db_exists and not args.force:
        print(f"SC Help DB already exists at '{config.SCHELP_DB_PATH}'.")
        print("Use --force to wipe and rebuild.")
        return

    print("=" * 50)
    print("  SC Help DB Builder")
    print(f"  Source dir : {config.SC_HELP_PATH}")
    print(f"  DB output  : {config.SCHELP_DB_PATH}")
    print(f"  Embedding  : {config.EMBEDDING_MODEL}")
    print("=" * 50)

    start = time.time()

    try:
        rag_engine.build_sc_help_index()
    except Exception as e:
        print(f"\n✗ Build failed: {e}")
        raise SystemExit(1)

    elapsed = time.time() - start
    print(f"\n✓ SC Help DB ready at '{config.SCHELP_DB_PATH}'  ({elapsed:.1f}s)")


if __name__ == "__main__":
    main()
