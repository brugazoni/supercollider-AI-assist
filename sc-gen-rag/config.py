import os
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
CONTEXT_FOLDER = "knowledge_base"
SC_HELP_PATH = r"C:\Program Files\SuperCollider-3.13.0\HelpSource"

SYSTEM_TEXT_FILE = "system-instruction.md"
SYSTEM_TEXT_FILE_ONESHOT_PLAN = "system-instruction-oneshot-plan.md"
SYSTEM_TEXT_FILE_ONESHOT_GEN = "system-instruction-oneshot-gen.md"
SYSTEM_TEXT_FILE_INCREMENTAL = "system-instruction-incremental.md"
OUTPUT_FILE = "sc-files/test.scd"
MAX_HISTORY_BLOCKS = 10  # Max previous blocks to include in LLM context
IMPROVEMENTS_FILE = "system-improvements.md"

KNOWLEDGE_DB_PATH = "vectordb_knowledge_base"
SCHELP_DB_PATH    = "vectordb_sc_help"
EMBEDDING_MODEL = "BAAI/bge-small-en-v1.5"
RAG_K = 5
USER_LIB_BOOST = 1.5  # >1 favors knowledge-base, <1 favors sc-help, 1.0 = neutral

DOCS_SCOPES = ['https://www.googleapis.com/auth/documents']
DOCUMENT_ID = '1YaAr1jlZ3w5N1t3GeIf_-o8j1za0jvTaTEpcL1JIBdo'
CREDENTIALS_FILE = 'credentials.json'
TOKEN_FILE = 'token.json'

CURRENT_LLM_PROVIDER = "gemini" # Options: "gemini", "ollama", "anthropic", "openai", "deepseek"

GEMINI_MODEL = "gemini-2.5-flash"
OLLAMA_MODEL = "qwen3:4b"
ANTHROPIC_MODEL = "claude-3-7-sonnet-20250219"
OPENAI_MODEL = "gpt-4o"
DEEPSEEK_MODEL = "deepseek-chat"

if CURRENT_LLM_PROVIDER == "gemini":
    CURRENT_MODEL_NAME = GEMINI_MODEL
elif CURRENT_LLM_PROVIDER == "ollama":
    CURRENT_MODEL_NAME = OLLAMA_MODEL
elif CURRENT_LLM_PROVIDER == "anthropic":
    CURRENT_MODEL_NAME = ANTHROPIC_MODEL
elif CURRENT_LLM_PROVIDER == "openai":
    CURRENT_MODEL_NAME = OPENAI_MODEL
elif CURRENT_LLM_PROVIDER == "deepseek":
    CURRENT_MODEL_NAME = DEEPSEEK_MODEL
else:
    CURRENT_MODEL_NAME = GEMINI_MODEL

# Auto-Execute config
AUTO_EXECUTE_ENABLED = False
MAX_SYNTAX_RETRIES = 3
SCLANG_PATH = "sclang"
SCLANG_BOOT_TIMEOUT = 30
AUTO_VALIDATION_DEBUG_MESSAGES = True