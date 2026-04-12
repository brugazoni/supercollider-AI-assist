import os
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# LangSmith Observability
LANGCHAIN_API_KEY = os.getenv("LANGCHAIN_API_KEY")
if LANGCHAIN_API_KEY:
    os.environ["LANGCHAIN_API_KEY"] = LANGCHAIN_API_KEY
    os.environ["LANGCHAIN_TRACING_V2"] = "true"
    os.environ["LANGCHAIN_PROJECT"] = os.getenv("LANGCHAIN_PROJECT", "SuperCollider-AI-Assist")

CONTEXT_FOLDER = "knowledge_base"

SYSTEM_TEXT_FILE = "system_messages/base/system-instruction.md"
SYSTEM_TEXT_FILE_ONESHOT_PLAN = "system_messages/generate/system-instruction-oneshot-plan.md"
SYSTEM_TEXT_FILE_ONESHOT_GEN = "system_messages/generate/system-instruction-oneshot-gen.md"
SYSTEM_TEXT_FILE_INCREMENTAL = "system_messages/append/system-instruction-incremental.md"
OUTPUT_FILE = "sc-files/test.scd"
MAX_HISTORY_BLOCKS = 10  # Max previous blocks to include in LLM context
IMPROVEMENTS_FILE = "system_messages/improvements/system-improvements.md"

SYSTEM_TEXT_FILE_FIX = "system_messages/fix/system-instruction-fix.md"
SYSTEM_TEXT_FILE_REMAKE = "system_messages/remake/system-instruction-remake.md"
SYSTEM_TEXT_FILE_LEARN = "system_messages/learn/system-instruction-learn.md"

KNOWLEDGE_DB_PATH = "vectordb_knowledge_base"
EMBEDDING_MODEL = "BAAI/bge-small-en-v1.5"
RAG_K = 5
USER_LIB_BOOST = 1.5  # >1 favors knowledge-base, <1 favors sc-help, 1.0 = neutral

DOCS_SCOPES = ['https://www.googleapis.com/auth/documents']
DOCUMENT_ID = '1YaAr1jlZ3w5N1t3GeIf_-o8j1za0jvTaTEpcL1JIBdo'
CREDENTIALS_FILE = 'credentials.json'
TOKEN_FILE = 'token.json'

CURRENT_LLM_PROVIDER = "gemini" # Options: "gemini", "anthropic", "openai"

GEMINI_MODEL = "gemini-2.5-flash"
GEMINI_PRO_MODEL = "gemini-3.1-pro-preview"
ANTHROPIC_MODEL = "claude-3-7-sonnet-20250219"
OPENAI_MODEL = "gpt-4o"

if CURRENT_LLM_PROVIDER == "gemini":
    CURRENT_MODEL_NAME = GEMINI_PRO_MODEL
elif CURRENT_LLM_PROVIDER == "anthropic":
    CURRENT_MODEL_NAME = ANTHROPIC_MODEL
elif CURRENT_LLM_PROVIDER == "openai":
    CURRENT_MODEL_NAME = OPENAI_MODEL
else:
    CURRENT_MODEL_NAME = GEMINI_MODEL

# Auto-Execute config
AUTO_EXECUTE_ENABLED = False
MAX_SYNTAX_RETRIES = 3

# Available models for the UI dropdown
AVAILABLE_MODELS = {
    "gemini/gemini-2.5-flash": {"provider": "gemini", "model": GEMINI_MODEL, "min_temp": 0.0, "max_temp": 2.0, "default_temp": 0.7},
    "gemini/gemini-3.1-pro-preview": {"provider": "gemini", "model": GEMINI_PRO_MODEL, "min_temp": 0.0, "max_temp": 2.0, "default_temp": 0.7},
    "anthropic/claude-3-7-sonnet": {"provider": "anthropic", "model": ANTHROPIC_MODEL, "min_temp": 0.0, "max_temp": 1.0, "default_temp": 0.5},
    "openai/gpt-4o": {"provider": "openai", "model": OPENAI_MODEL, "min_temp": 0.0, "max_temp": 2.0, "default_temp": 0.7},
}

# Pricing schema (USD per 1M tokens) - Fallback if Logfire native tracking misses
PRICING_PER_1M_TOKENS = {
    "gemini-2.5-flash": {"in": 0.0, "out": 0.0},
    "gemini-3.1-pro-preview": {"in": 3.50, "out": 15.00},
    "claude-3-7-sonnet-20250219": {"in": 3.00, "out": 15.00},
    "gpt-4o": {"in": 2.50, "out": 10.00},
}

# Context Window Bounds
CONTEXT_WINDOW_SIZES = {
    "gemini-2.5-flash": 1048576,
    "gemini-3.1-pro-preview": 2097152,
    "claude-3-7-sonnet-20250219": 200000,
    "gpt-4o": 128000,
}