# OpenClaw Vanilla Setup

Saubere OpenClaw-Installation **ohne Hostinger-Image**, mit DeepSeek als Primär-Provider und intelligenter Fallback-Kette.

## 🎯 Features

- ✅ **DeepSeek V3** als Primary Model
- ✅ **Fallback-Kette**: DeepSeek → Gemini → OpenRouter → ZAI
- ✅ Kein Hostinger-Patch-Image (vanilla OpenClaw)
- ✅ Persistente Daten (volumes)
- ✅ Alle API-Keys via `.env` konfigurierbar
- ✅ Healthchecks & Auto-Restart

## 🚀 Schnellstart

```bash
# 1. Repository klonen
git clone https://github.com/Silverstar187/openclaw-vanilla.git
cd openclaw-vanilla

# 2. .env anpassen (optional)
nano .env

# 3. Setup ausführen
./setup.sh
```

## 📁 Struktur

```
.
├── docker-compose.yml      # Container-Definition
├── .env                    # API-Keys & Config
├── setup.sh               # Automatisches Setup
├── data/
│   ├── .openclaw/         # OpenClaw Config & State
│   ├── .cache/            # Cache-Daten
│   └── linuxbrew/         # Linuxbrew
└── README.md
```

## 🔗 Fallback-Kette

| Priorität | Provider | Modell | Verwendung |
|-----------|----------|--------|------------|
| 1 | **DeepSeek** | `deepseek-chat` | Primär |
| 2 | **DeepSeek** | `deepseek-reasoner` | Reasoning Tasks |
| 3 | **Google** | `gemini-3-flash-preview` | Rate-Limit Fallback |
| 4 | **OpenRouter** | `openrouter/auto` | Universal Fallback |
| 5 | **ZAI** | `glm-4.7` | Notfall-Fallback |

## 🔧 Manuelle Befehle

```bash
# Container starten
docker-compose up -d

# Logs ansehen
docker-compose logs -f

# OpenClaw CLI
docker exec -it openclaw openclaw doctor
docker exec -it openclaw openclaw models list
docker exec -it openclaw openclaw agent --agent main --message "Test"

# Neustart
docker-compose restart

# Stoppen
docker-compose down
```

## 📊 Troubleshooting

### Rate Limit (Gemini)
→ Automatischer Fallback auf DeepSeek

### DeepSeek nicht erreichbar
→ Fallback auf Gemini/OpenRouter

### Container startet nicht
```bash
docker-compose logs
# Prüfe ob Port 61457 frei ist
netstat -tlnp | grep 61457
```

## 🔐 Sicherheit

- `.env` ist in `.gitignore`
- Gateway Token ist required
- Loopback-binding (localhost only)
- Persönliche Daten in volumes

## 📚 Backup

Alte Daten vom Hostinger-Server:
https://github.com/Silverstar187/openclaw-backup

