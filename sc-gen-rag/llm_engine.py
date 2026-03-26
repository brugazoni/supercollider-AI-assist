import config
import sys

# Attempt lazy-loading of providers so the application doesn't crash 
# if the user hasn't pip-installed the new external dependencies yet.
try:
    import google.generativeai as genai
except ImportError:
    genai = None

try:
    import ollama
except ImportError:
    ollama = None

try:
    from openai import OpenAI
except ImportError:
    OpenAI = None

try:
    import anthropic
except ImportError:
    anthropic = None


class LLMClient:
    def __init__(self):
        self.provider = config.CURRENT_LLM_PROVIDER
        self.model_name = config.CURRENT_MODEL_NAME

        if self.provider == "gemini":
            if not config.GEMINI_API_KEY:
                print("Gemini API key missing")
                sys.exit(1)
            genai.configure(api_key=config.GEMINI_API_KEY)

        elif self.provider == "openai":
            if not config.OPENAI_API_KEY:
                print("OpenAI API key missing")
                sys.exit(1)
            if not OpenAI:
                print("The 'openai' python package is required. pip install openai")
                sys.exit(1)
            self.openai_client = OpenAI(api_key=config.OPENAI_API_KEY)

        elif self.provider == "anthropic":
            if not config.ANTHROPIC_API_KEY:
                print("Anthropic API key missing")
                sys.exit(1)
            if not anthropic:
                print("The 'anthropic' python package is required. pip install anthropic")
                sys.exit(1)
            self.anthropic_client = anthropic.Anthropic(api_key=config.ANTHROPIC_API_KEY)

        elif self.provider == "deepseek":
            if not config.DEEPSEEK_API_KEY:
                print("DeepSeek API key missing")
                sys.exit(1)
            if not OpenAI:
                print("The 'openai' python package is required for DeepSeek. pip install openai")
                sys.exit(1)
            # DeepSeek provides an OpenAI-compatible API endpoint
            self.deepseek_client = OpenAI(
                api_key=config.DEEPSEEK_API_KEY, 
                base_url="https://api.deepseek.com"
            )

    def generate(self, prompt, system_instruction=None):
        if self.provider == "gemini":
            return self._generate_gemini(prompt, system_instruction)
        elif self.provider == "ollama":
            return self._generate_ollama(prompt, system_instruction)
        elif self.provider == "openai":
            return self._generate_openai(prompt, system_instruction)
        elif self.provider == "anthropic":
            return self._generate_anthropic(prompt, system_instruction)
        elif self.provider == "deepseek":
            return self._generate_deepseek(prompt, system_instruction)
        else:
            raise ValueError(f"unknown provider: {self.provider}")

    def _generate_gemini(self, prompt, system_instruction):
        model = genai.GenerativeModel(
            model_name=self.model_name,
            system_instruction=system_instruction
        )
        try:
            response = model.generate_content(prompt)
            usage = response.usage_metadata
            text = response.text.replace("```supercollider", "").replace("```", "").strip()
            token_info = f"Tokens: In {usage.prompt_token_count} / Out {usage.candidates_token_count}"
            return text, token_info
        except Exception as e:
            return f"// API error: {str(e)}", "Tokens: Error"

    def _generate_ollama(self, prompt, system_instruction):
        try:
            messages = []
            if system_instruction:
                messages.append({'role': 'system', 'content': system_instruction})
            messages.append({'role': 'user', 'content': prompt})

            response = ollama.chat(model=self.model_name, messages=messages)
            text = response['message']['content'].replace("```supercollider", "").replace("```", "").strip()

            in_tokens = response.get('prompt_eval_count', 0)
            out_tokens = response.get('eval_count', 0)
            token_info = f"Tokens: In {in_tokens} / Out {out_tokens} (Ollama)"

            return text, token_info
        except Exception as e:
            print(f"Ollama Error: {e}")
            return f"// LOCAL MODEL ERROR: {str(e)}", "Tokens: Error"

    def _generate_openai(self, prompt, system_instruction):
        try:
            messages = []
            if system_instruction:
                messages.append({'role': 'system', 'content': system_instruction})
            messages.append({'role': 'user', 'content': prompt})

            response = self.openai_client.chat.completions.create(
                model=self.model_name,
                messages=messages
            )
            text = response.choices[0].message.content.replace("```supercollider", "").replace("```", "").strip()
            
            usage = response.usage
            token_info = f"Tokens: In {usage.prompt_tokens} / Out {usage.completion_tokens} (OpenAI)"
            return text, token_info
        except Exception as e:
            return f"// API error: {str(e)}", "Tokens: Error"

    def _generate_anthropic(self, prompt, system_instruction):
        try:
            kwargs = {
                "model": self.model_name,
                "max_tokens": 4096,
                "messages": [{"role": "user", "content": prompt}]
            }
            if system_instruction:
                kwargs["system"] = system_instruction
                
            response = self.anthropic_client.messages.create(**kwargs)
            text = response.content[0].text.replace("```supercollider", "").replace("```", "").strip()
            
            in_tokens = response.usage.input_tokens
            out_tokens = response.usage.output_tokens
            token_info = f"Tokens: In {in_tokens} / Out {out_tokens} (Anthropic)"
            return text, token_info
        except Exception as e:
            return f"// API error: {str(e)}", "Tokens: Error"

    def _generate_deepseek(self, prompt, system_instruction):
        try:
            messages = []
            if system_instruction:
                messages.append({'role': 'system', 'content': system_instruction})
            messages.append({'role': 'user', 'content': prompt})

            # DeepSeek uses the OpenAI Python client signature
            response = self.deepseek_client.chat.completions.create(
                model=self.model_name,
                messages=messages
            )
            text = response.choices[0].message.content.replace("```supercollider", "").replace("```", "").strip()
            
            usage = response.usage
            token_info = f"Tokens: In {usage.prompt_tokens} / Out {usage.completion_tokens} (DeepSeek)"
            return text, token_info
        except Exception as e:
            return f"// API error: {str(e)}", "Tokens: Error"
