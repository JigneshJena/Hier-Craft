# Firebase Remote Config Setup Guide

## AI Configuration (Groq & Gemini)

### JSON Configuration

Firebase Console → Remote Config → **Add Parameter** ya **Import from file**

```json
{
  "parameters": {
    "groq_api_key": {
      "defaultValue": {
        "value": ""
      },
      "description": "Groq API Key (Preferred)",
      "valueType": "STRING"
    },
    "gemini_key": {
      "defaultValue": {
        "value": ""
      },
      "description": "Gemini API Key (Fallback)",
      "valueType": "STRING"
    },
    "api_provider": {
      "defaultValue": {
        "value": "groq"
      },
      "description": "Current AI Provider (groq or gemini)",
      "valueType": "STRING"
    }
  }
}
```

### Steps (For Groq):

1. **Get Groq API Key:**
   - Visit: https://console.groq.com/keys
   - Create new API key
   - Copy the key (starts with `gsk_...`)

2. **Update Firebase:**
   - Firebase Console → Your Project → Remote Config
   - Add parameter: `groq_api_key` → Paste your Groq key
   - Add parameter: `api_provider` → Set value to `groq`
   - Click **"Publish changes"** (IMPORTANT!)

3. **Test:**
   - Restart app
   - Select domain & level
   - AI interview will use Groq Llama 3.3 model!

### App Behavior:

- **Provider: "groq"** = Uses `groq_api_key` and Llama 3.3 model (High speed).
- **Provider: "gemini"** = Uses `gemini_key` and Gemini 2.0 Flash model.
- **Offline Mode** = Auto-fallback to Offline Practice Questions from JSON if internet is down.

Simple, clean, aur powerfull! 🚀
