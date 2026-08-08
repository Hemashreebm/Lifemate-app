# Lifemate v2.0 — Secure Gemini AI Setup & Architecture Guide

## Overview

Lifemate v2.0 uses a **Secure Server-Side Architecture** for Google Gemini AI processing to ensure that production API keys and secret credentials are **never exposed** in client APKs, Dart source code, or version control repositories.

---

## 1. System Architecture

```text
+-----------------------+              HTTPS POST              +-------------------------------------+
|                       |  --------------------------------->  | Supabase Edge Function: gemini-chat |
|  Lifemate Flutter App |                                      |  (Server Environment: GEMINI_API_KEY)|
|                       |  <---------------------------------  +-------------------------------------+
+-----------------------+               JSON Reply                               │
                                                                                 │ Server-Side Call
                                                                                 ▼
                                                                     +-----------------------+
                                                                     | Google Gemini REST API|
                                                                     +-----------------------+
```

### Security Guarantees:
1. **Server-Side Protection**: The production `GEMINI_API_KEY` is configured as a secret inside the Supabase Edge Function environment.
2. **Zero Key Exposure**: The client application receives only the generated AI text response (`reply`). The secret key is never sent over the wire or stored in client storage.
3. **No Direct Client Keys**: Production builds do not hardcode API keys in Dart code, `pubspec.yaml`, `android/app/build.gradle`, or SharedPreferences.

---

## 2. Local Development & Testing Configuration

For local development builds without deploying the Edge Function, developers can supply a local test key at build time using Flutter's `--dart-define` flag:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_local_development_api_key_here
```

Or for debug APK builds:

```bash
flutter build apk --debug --dart-define=GEMINI_API_KEY=your_local_development_api_key_here
```

### Secrets Isolation Rules:
- Never commit `--dart-define` keys to version control.
- Any local `.env` or `secrets.json` files are automatically ignored by Git (configured in `.gitignore`).

---

## 3. Deploying the Supabase Edge Function (`gemini-chat`)

To deploy the production-secure server-side proxy function to Supabase:

1. Install Supabase CLI and log in:
   ```bash
   supabase login
   ```

2. Set the server-side environment secret:
   ```bash
   supabase secrets set GEMINI_API_KEY=your_actual_google_gemini_api_key --project-ref your_project_ref
   ```

3. Deploy the Edge Function:
   ```bash
   supabase functions deploy gemini-chat --project-ref your_project_ref
   ```

---

## 4. Key Rotation & Compromise Response

If a developer API key is accidentally exposed or compromised:

1. **Google AI Studio**: Go to [Google AI Studio API Keys](https://aistudio.google.com/app/apikey), find the compromised key, and click **Delete Key**.
2. **Generate New Key**: Click **Create API Key**.
3. **Update Server Secret**: Run `supabase secrets set GEMINI_API_KEY=new_key`.
4. **Local Dev Update**: Update your local `--dart-define` configuration. No APK update is required for server-side architecture users.

---

## 5. Privacy & Data Minimization

- **Sensitive Data Exclusion**: The AI Memory Service (`AiMemoryService`) automatically rejects storing passwords, OTPs, PINs, CVVs, or financial credentials.
- **Context Minimization**: Prompts are sanitized and capped at 2,000 characters. Personal financial transaction logs and private credentials are never sent in AI system contexts.
