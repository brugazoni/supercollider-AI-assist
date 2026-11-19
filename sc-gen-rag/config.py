import os
from pathlib import Path
from dotenv import load_dotenv

# Ensure .env in sc-gen-rag directory is always loaded even if cwd is different
_CONFIG_DIR = Path(__file__).resolve().parent
_ENV_PATH = _CONFIG_DIR / ".env"
if _ENV_PATH.exists():
    load_dotenv(dotenv_path=_ENV_PATH, override=True)
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

# LangSmith Observability
LANGCHAIN_API_KEY = os.getenv("LANGCHAIN_API_KEY")
if LANGCHAIN_API_KEY:
    os.environ["LANGCHAIN_API_KEY"] = LANGCHAIN_API_KEY
    os.environ["LANGCHAIN_TRACING_V2"] = "true"
    os.environ["LANGCHAIN_PROJECT"] = os.getenv("LANGCHAIN_PROJECT", "SuperCollider-AI-Assist")
    os.environ.setdefault("LANGCHAIN_REVISION_ID", "local")

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
SYSTEM_TEXT_FILE_COMPOSE_PLAN = "system_messages/compose/system-instruction-compose-plan.md"
SYSTEM_TEXT_FILE_COMPOSE_IMPLEMENT = "system_messages/compose/system-instruction-compose-implement.md"

KNOWLEDGE_DB_PATH = "vectordb_knowledge_base"
EMBEDDING_MODEL = "BAAI/bge-small-en-v1.5"
RAG_K = 5
USER_LIB_BOOST = 1.5  # >1 favors knowledge-base, <1 favors sc-help, 1.0 = neutral

DOCS_SCOPES = ['https://www.googleapis.com/auth/documents']
DOCUMENT_ID = '1yUxqk0vSTqYZlTNWUiQ6rAMlMuUxnGxBOiWGgAX2fEs'
CREDENTIALS_FILE = 'credentials.json'
TOKEN_FILE = 'token.json'

CURRENT_LLM_PROVIDER = "gemini" # Options: "gemini", "anthropic", "openai"

GEMINI_MODEL = "gemini-3.8-flash"
GEMINI_FLASH_35_MODEL = "gemini-3.8-flash"
GEMINI_PRO_MODEL = "gemini-3.1-pro-preview"
ANTHROPIC_MODEL = "claude-3-7-sonnet-20250219"
OPENAI_MODEL = "gpt-4o"

if CURRENT_LLM_PROVIDER == "gemini":
    CURRENT_MODEL_NAME = GEMINI_MODEL
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
    "gemini/gemini-3.8-flash": {"provider": "gemini", "model": GEMINI_FLASH_35_MODEL, "min_temp": 0.0, "max_temp": 2.0, "default_temp": 0.7},
    "gemini/gemini-3.1-pro-preview": {"provider": "gemini", "model": GEMINI_PRO_MODEL, "min_temp": 0.0, "max_temp": 2.0, "default_temp": 0.7},
    "anthropic/claude-3-7-sonnet": {"provider": "anthropic", "model": ANTHROPIC_MODEL, "min_temp": 0.0, "max_temp": 1.0, "default_temp": 0.5},
    "openai/gpt-4o": {"provider": "openai", "model": OPENAI_MODEL, "min_temp": 0.0, "max_temp": 2.0, "default_temp": 0.7},
}

# Pricing schema (USD per 1M tokens) - Fallback if Logfire native tracking misses
PRICING_PER_1M_TOKENS = {
    "gemini-3.8-flash": {"in": 1.50, "out": 9.00},
    "gemini-3.1-pro-preview": {"in": 3.50, "out": 15.00},
    "claude-3-7-sonnet-20250219": {"in": 3.00, "out": 15.00},
    "gpt-4o": {"in": 2.50, "out": 10.00},
    # OpenRouter vendor-prefixed defaults (overridden dynamically when /api/v1/models is fetched)
    "google/gemini-3.8-flash": {"in": 0.75, "out": 3.75},
    "google/gemini-4-hydrogen": {"in": 1.50, "out": 7.50},
    "google/gemini-4-carbon": {"in": 2.00, "out": 10.00},
    "google/gemini-3.5-flash": {"in": 1.50, "out": 9.00},
    "google/gemini-2.5-pro": {"in": 1.25, "out": 10.00},
    "google/gemini-3.1-pro-preview": {"in": 2.00, "out": 12.00},
    "~google/gemini-flash-latest": {"in": 0.75, "out": 3.75},
    "~google/gemini-pro-latest": {"in": 2.00, "out": 10.00},
    "anthropic/claude-3-7-sonnet": {"in": 3.00, "out": 15.00},
    "anthropic/claude-haiku-5.5": {"in": 0.10, "out": 0.50},
    "anthropic/claude-sonnet-5.5": {"in": 2.00, "out": 10.00},
    "anthropic/claude-opus-5.5": {"in": 4.00, "out": 20.00},
    "deepseek/deepseek-v4.1-flash": {"in": 0.006, "out": 0.50},
    "deepseek/deepseek-v4-pro": {"in": 0.90, "out": 1.50},
    "openai/gpt-4o": {"in": 2.50, "out": 10.00},
    "openai/gpt-6-luna": {"in": 0.10, "out": 0.50},
    "openai/gpt-6.1-sol": {"in": 2.00, "out": 10.00},
}

# Context Window Bounds
CONTEXT_WINDOW_SIZES = {
    "gemini-3.8-flash": 1000000,
    "gemini-3.1-pro-preview": 2097152,
    "claude-3-7-sonnet-20250219": 200000,
    "gpt-4o": 128000,
    # OpenRouter vendor-prefixed defaults
    "google/gemini-3.8-flash": 1048576,
    "google/gemini-4-hydrogen": 1048576,
    "google/gemini-4-carbon": 1048576,
    "google/gemini-3.5-flash": 1048576,
    "anthropic/claude-haiku-5.5": 1000000,
    "anthropic/claude-sonnet-5.5": 1000000,
    "anthropic/claude-opus-5.5": 1000000,
    "deepseek/deepseek-v4.1-flash": 1048576,
    "deepseek/deepseek-v4-pro": 1048576,
    "openai/gpt-6-luna": 1050000,
    "openai/gpt-6.1-sol": 1050000,
    "google/gemini-2.5-pro": 1048576,
    "google/gemini-3.1-pro-preview": 1048576,
    "~google/gemini-flash-latest": 1048576,
    "~google/gemini-pro-latest": 1048576,
    "anthropic/claude-3-7-sonnet": 200000,
    "openai/gpt-4o": 128000,
}
