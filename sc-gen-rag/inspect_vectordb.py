#!/usr/bin/env python3
"""
inspect_vectordb.py
CLI tool to inspect the contents of the ChromaDB vector stores.

Usage:
    python inspect_vectordb.py --stats
    python inspect_vectordb.py --stats --source knowledge-base
    python inspect_vectordb.py --list --source sc-help
    python inspect_vectordb.py --search "FM synthesis"
    python inspect_vectordb.py --dump 0

"""

import argparse
import config
from langchain_chroma import Chroma
from rag_engine import get_embedding_function
from langchain_core.documents import Document


DB_MAP = {
    "knowledge-base": config.KNOWLEDGE_DB_PATH,
}


def get_collection(db_path):
    """Load a ChromaDB collection from the given path."""
    embedding_func = get_embedding_function()
    return Chroma(persist_directory=db_path, embedding_function=embedding_func)


def get_all_data(sources):
    """Load documents and metadatas from the selected source(s)."""
    all_docs = []
    all_metas = []
    for src in sources:
        db_path = DB_MAP.get(src)
        if not db_path:
            continue
        import os
        if not os.path.exists(db_path):
            print(f"  ⚠ Store '{src}' not found at {db_path}, skipping.")
            continue
        db = get_collection(db_path)
        data = db.get()
        all_docs.extend(data["documents"])
        all_metas.extend(data["metadatas"])
    return all_docs, all_metas


def cmd_stats(sources):
    """Print collection summary statistics."""
    docs, metas = get_all_data(sources)
    total = len(docs)

    if total == 0:
        print("Vector DB is empty (selected sources).")
        return

    source_counts = {}
    lengths = []
    for doc, meta in zip(docs, metas):
        src = meta.get("source", "unknown")
        source_counts[src] = source_counts.get(src, 0) + 1
        lengths.append(len(doc))

    print("=" * 50)
    print("  Vector DB Statistics")
    print(f"  Sources: {', '.join(sources)}")
    print(f"  Embedding model: {config.EMBEDDING_MODEL}")
    print("=" * 50)
    print(f"\n  Total chunks: {total}")
    print(f"\n  Source breakdown:")
    for src, count in sorted(source_counts.items()):
        pct = count / total * 100
        print(f"    {src:20s}  {count:5d}  ({pct:.1f}%)")

    print(f"\n  Chunk size (chars):")
    print(f"    Min: {min(lengths):,}")
    print(f"    Avg: {sum(lengths) // total:,}")
    print(f"    Max: {max(lengths):,}")


def cmd_list(sources, limit=50):
    """List chunks with metadata."""
    docs, metas = get_all_data(sources)
    total = len(docs)

    if total == 0:
        print("Vector DB is empty (selected sources).")
        return

    showing = min(limit, total)
    print(f"Showing {showing}/{total} chunks (use --limit N to change)\n")
    print(f"{'#':>5}  {'Source':20s}  {'Filename':35s}  {'Len':>5}  Content Preview")
    print("-" * 120)

    for i in range(showing):
        src = metas[i].get("source", "?")
        fname = metas[i].get("filename", "?")
        preview = docs[i][:120].replace("\n", " ").replace("\r", "")
        print(f"{i:5d}  {src:20s}  {fname:35s}  {len(docs[i]):5d}  {preview}...")


def cmd_search(sources, query, k=5):
    """Run a vector similarity search across selected sources."""
    import os
    all_results = []
    embedding_func = get_embedding_function()

    for src in sources:
        db_path = DB_MAP.get(src)
        if not db_path or not os.path.exists(db_path):
            continue
        db = Chroma(persist_directory=db_path, embedding_function=embedding_func)
        results = db.similarity_search_with_score(query, k=k)
        all_results.extend(results)

    # Sort by score (lower = better for Chroma distance)
    all_results.sort(key=lambda x: x[1])
    all_results = all_results[:k]

    print(f"Search: \"{query}\"")
    print(f"Top {len(all_results)} results:\n")
    print(f"{'#':>3}  {'Score':>7}  {'Source':20s}  {'Filename':35s}  Content Preview")
    print("-" * 120)

    for i, (doc, score) in enumerate(all_results):
        src = doc.metadata.get("source", "?")
        fname = doc.metadata.get("filename", "?")
        preview = doc.page_content[:100].replace("\n", " ").replace("\r", "")
        print(f"{i+1:3d}  {score:7.4f}  {src:20s}  {fname:35s}  {preview}...")


def cmd_dump(sources, index):
    """Print full content of a specific chunk."""
    docs, metas = get_all_data(sources)

    if index < 0 or index >= len(docs):
        print(f"Index {index} out of range (0–{len(docs)-1})")
        return

    meta = metas[index]
    print(f"Chunk #{index}")
    print(f"  Source:   {meta.get('source', '?')}")
    print(f"  Filename: {meta.get('filename', '?')}")
    print(f"  Length:   {len(docs[index])} chars")
    print("-" * 50)
    print(docs[index])





def main():
    parser = argparse.ArgumentParser(description="Inspect the ChromaDB vector stores.")
    parser.add_argument("--stats", action="store_true", help="Show collection statistics")
    parser.add_argument("--list", action="store_true", help="List all chunks with metadata")
    parser.add_argument("--limit", type=int, default=50, help="Max rows for --list (default: 50)")
    parser.add_argument("--search", type=str, help="Vector similarity search query")
    parser.add_argument("--dump", type=int, metavar="INDEX", help="Dump full content of chunk at INDEX")
    parser.add_argument("-k", type=int, default=5, help="Number of search results (default: 5)")

    parser.add_argument(
        "--source",
        type=str,
        choices=["knowledge-base", "sc-help", "all"],
        default="all",
        help="Which store to inspect (default: all).",
    )

    args = parser.parse_args()

    if not any([args.stats, args.list, args.search is not None, args.dump is not None]):
        parser.print_help()
        return

    # Resolve sources
    if args.source == "all":
        sources = ["knowledge-base", "sc-help"]
    else:
        sources = [args.source]

    if args.stats:
        cmd_stats(sources)
    if args.list:
        cmd_list(sources, limit=args.limit)
    if args.search is not None:
        cmd_search(sources, args.search, k=args.k)
    if args.dump is not None:
        cmd_dump(sources, args.dump)



if __name__ == "__main__":
    main()
