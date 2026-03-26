import os
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import config

def get_docs_service():
    creds = None
    if os.path.exists(config.TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(config.TOKEN_FILE, config.DOCS_SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            try:
                creds.refresh(Request())
            except Exception as e:
                print(f"Token refresh failed ({e}). Triggering re-authentication...")
                if os.path.exists(config.TOKEN_FILE):
                    os.remove(config.TOKEN_FILE)
                creds = None

        if not creds or not creds.valid:
            if not os.path.exists(config.CREDENTIALS_FILE):
                print(f"Error: {config.CREDENTIALS_FILE} not found.")
                return None
            flow = InstalledAppFlow.from_client_secrets_file(config.CREDENTIALS_FILE, config.DOCS_SCOPES)
            creds = flow.run_local_server(port=0)

        with open(config.TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())

    return build('docs', 'v1', credentials=creds)

def append_to_google_doc(text_content):
    service = get_docs_service()
    if not service: return False
    try:
        requests = [{'insertText': {'text': text_content, 'endOfSegmentLocation': {'segmentId': ''}}}]
        service.documents().batchUpdate(documentId=config.DOCUMENT_ID, body={'requests': requests}).execute()
        return True
    except Exception as e:
        print(f"Error writing to Google Doc: {e}")
        return False

def append_to_local_file(filename, text_content):
    try:
        prefix = "\n\n" if os.path.exists(filename) and os.path.getsize(filename) > 0 else ""
        with open(filename, 'a', encoding='utf-8') as f:
            f.write(prefix + text_content)
        return True
    except Exception as e:
        print(f"Error writing to local file {filename}: {e}")
        return False

def get_multiline_input(prompt_text):
    print(f"\n{prompt_text}\n" + "-"*40 + "\n(Press Enter twice to finish)\n" + "-"*40)
    lines = []
    empty_count = 0
    while True:
        try:
            line = input()
            if line.strip() == '':
                empty_count += 1
                if empty_count >= 2:
                    break
                lines.append(line)
            else:
                empty_count = 0
                lines.append(line)
        except EOFError: break
    # Strip trailing empty lines
    while lines and lines[-1].strip() == '':
        lines.pop()
    return "\n".join(lines)

def load_system_instruction():
    if os.path.exists(config.SYSTEM_TEXT_FILE):
        with open(config.SYSTEM_TEXT_FILE, 'r', encoding='utf-8') as f:
            sys_instr = f.read().strip()
    else:
        sys_instr = "You are an expert SuperCollider programmer."

    if os.path.exists(config.IMPROVEMENTS_FILE):
        try:
            with open(config.IMPROVEMENTS_FILE, 'r', encoding='utf-8') as f:
                improvements = f.read().strip()
                if improvements:
                    sys_instr += f"\n\n=== SYSTEM IMPROVEMENTS ===\n{improvements}"
                    print(f" > Loaded system improvements.")
        except Exception: pass
    return sys_instr