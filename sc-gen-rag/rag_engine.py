import os
import glob
import shutil
from langchain_community.document_loaders import TextLoader
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document
import config

def get_embedding_function():
    return HuggingFaceEmbeddings(model_name=config.EMBEDDING_MODEL)

def load_documents(folder_path, extension, source_label):
    """Load text files from a folder and tag them with a source label."""
    documents = []
    if not os.path.exists(folder_path):
        return []
    
    files = glob.glob(os.path.join(folder_path, "**", f"*.{extension}"), recursive=True)
    print(f"    - Found {len(files)} {source_label} files.")

    for file_path in files:
        try:
            loader = TextLoader(file_path, encoding='utf-8')
            raw_docs = loader.load()

            for doc in raw_docs:
                doc.metadata["source"] = source_label
                doc.metadata["filename"] = os.path.basename(file_path)
                documents.append(doc)
            
        except Exception:
            pass
    
    return documents


def _chunk_documents(raw_docs):
    """Split raw documents into semantic chunks."""
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=4000,
        chunk_overlap=400,
        separators=["\n\n", "\n", "{", "(", ";"]
    )
    return text_splitter.split_documents(raw_docs)


def _embed_and_store(chunks, db_path):
    """Embed chunks and persist them to a ChromaDB directory."""
    embedding_func = get_embedding_function()

    batch_size = 100
    total = len(chunks)
    db = None
    for start in range(0, total, batch_size):
        end = min(start + batch_size, total)
        batch = chunks[start:end]
        print(f"   embedding batch {start // batch_size + 1}/{(total + batch_size - 1) // batch_size}  "
              f"(chunks {start + 1}–{end}/{total})", end="\r")
        if start == 0:
            db = Chroma.from_documents(
                documents=batch,
                embedding=embedding_func,
                persist_directory=db_path,
            )
        else:
            db.add_documents(batch)

    print(f"\n   index saved to {db_path}")
    return db


def build_knowledge_base_index():
    """Build the vector store for knowledge_base/ (.scd files)."""
    print("\n--- [rag] building knowledge-base index ---")
    if os.path.exists(config.KNOWLEDGE_DB_PATH):
        shutil.rmtree(config.KNOWLEDGE_DB_PATH)

    raw_docs = load_documents(config.CONTEXT_FOLDER, "scd", "knowledge-base")

    if not raw_docs:
        print("No knowledge-base documents found.")
        return

    chunks = _chunk_documents(raw_docs)
    print(f"Created {len(chunks)} knowledge-base chunks.")

    print(" - embedding vectors...")
    _embed_and_store(chunks, config.KNOWLEDGE_DB_PATH)


def build_sc_help_index():
    """Build the vector store for SC HelpSource (.schelp files)."""
    print("\n--- [rag] building sc-help index ---")
    if os.path.exists(config.SCHELP_DB_PATH):
        shutil.rmtree(config.SCHELP_DB_PATH)

    if not os.path.exists(config.SC_HELP_PATH):
        print(f"  ⚠ SC_HELP_PATH not found: {config.SC_HELP_PATH}")
        return

    raw_docs = load_documents(config.SC_HELP_PATH, "schelp", "sc-help")

    if not raw_docs:
        print("No SC Help documents found.")
        return

    chunks = _chunk_documents(raw_docs)
    print(f"Created {len(chunks)} sc-help chunks.")

    print(" - embedding vectors...")
    _embed_and_store(chunks, config.SCHELP_DB_PATH)


def build_all():
    """Build both vector stores sequentially."""
    build_knowledge_base_index()
    build_sc_help_index()


def _weighted_rrf(doc_lists, weights, k=60):
    """Weighted Reciprocal Rank Fusion – merges ranked lists into one."""
    scores = {}   # page_content -> cumulative score
    doc_map = {}  # page_content -> Document (keep first seen)

    for docs, weight in zip(doc_lists, weights):
        for rank, doc in enumerate(docs):
            key = doc.page_content
            scores[key] = scores.get(key, 0.0) + weight / (rank + k)
            if key not in doc_map:
                doc_map[key] = doc

    # Apply source boost: multiply knowledge-base scores by the boost factor
    boost = config.USER_LIB_BOOST
    if boost != 1.0:
        for key, doc in doc_map.items():
            if doc.metadata.get("source") == "knowledge-base":
                scores[key] *= boost

    sorted_keys = sorted(scores, key=scores.get, reverse=True)
    return [doc_map[k] for k in sorted_keys]


def get_retriever(sources=None):
    """Returns a callable(query) that performs vector retrieval.

    Args:
        sources: list of source stores to query.
                 Valid values: "knowledge-base", "sc-help".
                 Defaults to both.
    """
    if sources is None:
        sources = ["knowledge-base", "sc-help"]

    embedding_func = get_embedding_function()

    # Collect documents from requested stores
    vector_retrievers = []

    db_map = {
        "knowledge-base": config.KNOWLEDGE_DB_PATH,
        "sc-help": config.SCHELP_DB_PATH,
    }

    for src in sources:
        db_path = db_map.get(src)
        if not db_path or not os.path.exists(db_path):
            print(f"  ⚠ Store '{src}' not found at {db_path}, skipping.")
            continue

        db = Chroma(persist_directory=db_path, embedding_function=embedding_func)
        vector_retrievers.append(db.as_retriever(search_kwargs={"k": config.RAG_K}))

    if not vector_retrievers:
        raise ValueError("No documents found in selected stores. Run the build scripts first.")

    def retrieve(query):
        vector_results_lists = []
        for vr in vector_retrievers:
            vector_results_lists.append(vr.invoke(query))
        
        # Use RRF to merge results from multiple vector databases
        return _weighted_rrf(
            vector_results_lists,
            weights=[1.0] * len(vector_results_lists),
        )[:config.RAG_K]

    return retrieve


def query_index(query_text, sources=None):
    """Query the RAG index, optionally filtering by source.

    Args:
        query_text: the search query.
        sources: list of stores to search ("knowledge-base", "sc-help").
                 Defaults to both.
    """
    # Auto-build if neither store exists
    db_paths = [config.KNOWLEDGE_DB_PATH, config.SCHELP_DB_PATH]
    if not any(os.path.exists(p) for p in db_paths):
        print('Indexes not found, building now.....')
        build_all()

    try:
        retriever = get_retriever(sources=sources)
        results = retriever(query_text)

        context_str = ""

        for i, doc in enumerate(results):
            src = doc.metadata.get("filename", "unknown")
            type_ = doc.metadata.get("source", "unknown")
            clean_content = doc.page_content
            context_str += f"\n--- RETRIEVED {i+1} ({type_}: {src}) ---\n{clean_content}\n"
        
        return context_str
    except Exception as e:
        return f"Retrieval Error: {e}"