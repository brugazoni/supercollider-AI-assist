import os
import glob
import shutil
from langchain_community.document_loaders import TextLoader
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document
import config

_cached_embedding_func = None
_cached_db = None


def get_embedding_function():
    global _cached_embedding_func
    if _cached_embedding_func is None:
        _cached_embedding_func = HuggingFaceEmbeddings(model_name=config.EMBEDDING_MODEL)
    return _cached_embedding_func

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
                fname = os.path.basename(file_path)
                doc.metadata["source"] = source_label
                doc.metadata["filename"] = fname
                if fname.startswith("failsafe-") and fname.endswith(".scd"):
                    doc.metadata["use_case"] = fname[len("failsafe-"):-len(".scd")]
                elif fname.startswith("auto-") and fname.endswith("-rag.scd"):
                    doc.metadata["use_case"] = fname[len("auto-"):-len("-rag.scd")]
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
    global _cached_db
    _cached_db = None
    print("\n--- [rag] building knowledge-base index ---")
    if os.path.exists(config.KNOWLEDGE_DB_PATH):
        shutil.rmtree(config.KNOWLEDGE_DB_PATH)

    raw_docs = load_documents(config.CONTEXT_FOLDER, "scd", "knowledge-base")

    if not raw_docs:
        raise RuntimeError("No knowledge-base documents found in '{}'. Add .scd files to the knowledge_base folder.".format(config.CONTEXT_FOLDER))

    chunks = _chunk_documents(raw_docs)
    print(f"Created {len(chunks)} knowledge-base chunks.")

    print(" - embedding vectors...")
    _embed_and_store(chunks, config.KNOWLEDGE_DB_PATH)


def build_all():
    """Build the knowledge base vector store."""
    build_knowledge_base_index()


def count_chunks_for_text(text: str, metadata: dict = None) -> int:
    """Deterministically count how many ChromaDB chunks a text block produces."""
    if not text or not text.strip():
        return 0
    doc = Document(page_content=text, metadata=metadata or {})
    return len(_chunk_documents([doc]))


def ingest_documents_incrementally(raw_docs: list[Document]) -> int:
    """Embed and append new Document objects to the existing ChromaDB store
    without wiping or re-embedding existing knowledge base files.
    If the vector DB does not exist yet, builds the full index instead.
    Returns the number of chunks added.
    """
    global _cached_db
    if not raw_docs:
        return 0

    if not os.path.exists(config.KNOWLEDGE_DB_PATH):
        build_knowledge_base_index()
        return len(_chunk_documents(raw_docs))

    chunks = _chunk_documents(raw_docs)
    if not chunks:
        return 0

    embedding_func = get_embedding_function()
    db = Chroma(persist_directory=config.KNOWLEDGE_DB_PATH, embedding_function=embedding_func)
    batch_size = 100
    for start in range(0, len(chunks), batch_size):
        end = min(start + batch_size, len(chunks))
        db.add_documents(chunks[start:end])

    _cached_db = None
    return len(chunks)


def get_retriever(mode_filter: str = None):
    """Returns a callable(query) that performs vector retrieval from the knowledge base."""
    global _cached_db
    embedding_func = get_embedding_function()

    db_path = config.KNOWLEDGE_DB_PATH
    if not db_path or not os.path.exists(db_path):
        raise ValueError(f"Knowledge base not found at '{db_path}'. Run the build scripts first.")

    if _cached_db is None:
        _cached_db = Chroma(persist_directory=db_path, embedding_function=embedding_func)

    search_kwargs = {"k": config.RAG_K}
    if mode_filter:
        search_kwargs["filter"] = {"filename": f"failsafe-{mode_filter}.scd"}

    retriever = _cached_db.as_retriever(search_kwargs=search_kwargs)

    def retrieve(query):
        return retriever.invoke(query)[:config.RAG_K]

    return retrieve


def query_index(query_text, sources=None):
    """Query the RAG index.

    Args:
        query_text: the search query.
        sources: kept for backward compatibility, ignored.
    """
    # Auto-build if store doesn't exist
    if not os.path.exists(config.KNOWLEDGE_DB_PATH):
        print('Index not found, building now.....')
        build_all()

    try:
        retriever = get_retriever()
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