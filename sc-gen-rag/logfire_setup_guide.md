# Pydantic Logfire & EcoLogits Setup Guide

In order to enable enhanced telemetry and track live system impact footprints across generations, SuperCollider AI Assist now routes usage metrics internally using Logfire and EcoLogits.

## 1. Install Dependencies
Run the following inside your existing Python virtual environment (`sc-gen-rag` folder):
```bash
pip install -r requirements.txt
```
*(Or manually: `pip install logfire ecologits`)*

## 2. Obtain Logfire Token
1. Go to [logfire.pydantic.dev](https://logfire.pydantic.dev/) and sign up or sign in.
2. Create a new project (e.g. `sc-ai-assist`).
3. In the project dashboard, locate your **Write Token**.

## 3. Update Environment variables
Open the `.env` file located in `supercollider-AI-assist/sc-gen-rag/.env` and append your token:
```env
LOGFIRE_TOKEN=your_token_here
```

Your system will now dynamically query token loads using Logfire context traces, and route your environment footprint variables locally into your Session tabs!
