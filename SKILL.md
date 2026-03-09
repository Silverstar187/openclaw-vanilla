---
name: openclaw-vanilla-setup
description: Clean OpenClaw installation without Hostinger patches, using DeepSeek as primary with intelligent fallback chain
metadata:
  short-description: Vanilla OpenClaw with DeepSeek primary
---

# OpenClaw Vanilla Setup

Clean OpenClaw installation without Hostinger patches, using DeepSeek as primary LLM with automatic fallback chain.

## Quick Start (Fresh Server)

```bash
# 1. Clone repository
git clone https://github.com/Silverstar187/openclaw-vanilla.git
cd openclaw-vanilla

# 2. Create .env file with your API keys
cat > .env << 'ENVFILE'
PORT=61457
TZ=Europe/Berlin
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -base64 32)

# LLM Providers (Priority: DeepSeek > Gemini > OpenRouter > ZAI)
DEEPSEEK_API_KEY=sk-...
GEMINI_API_KEY=AIzaSy...
OPENROUTER_API_KEY=sk-or-v1-...
ZAI_API_KEY=...

# Channels
TELEGRAM_BOT_TOKEN=...
WHATSAPP_NUMBER=+49...

# Tools
TAVILY_API_KEY=tvly-...
QDRANT_URL=https://...
QDRANT_API_KEY=...
ENVFILE

# 3. Run setup
./setup.sh
```

## Architecture

### Fallback Chain

| Priority | Provider | Model | Use Case |
|----------|----------|-------|----------|
| 1 | **DeepSeek** | `deepseek-chat` | Primary - fast & cheap |
| 2 | **DeepSeek** | `deepseek-reasoner` | Complex reasoning |
| 3 | **Google** | `gemini-3-flash` | Rate-limit backup |
| 4 | **OpenRouter** | `auto` | Universal fallback |
| 5 | **ZAI** | `glm-4.7` | Emergency fallback |

### Docker Compose Structure

```yaml
services:
  openclaw:
    image: openclaw/openclaw:latest  # Not Hostinger!
    volumes:
      - ./data/.openclaw:/data/.openclaw  # Config & state
      - ./data/.cache:/data/.cache        # Cache
      - ./data/.npm:/data/.npm            # NPM modules
    env_file: .env
```

## Migration from Hostinger Image

### 1. Backup Old Data

```bash
# On old server
cd /docker/openclaw-lith/data/.openclaw
tar -czf ~/openclaw-backup.tar.gz \
  workspace/ skills/ credentials/ telegram/ agents/
```

### 2. Transfer to New Server

```bash
scp ~/openclaw-backup.tar.gz root@new-server:/tmp/
```

### 3. Restore on New Server

```bash
# After running setup.sh
cd openclaw-vanilla
tar -xzf /tmp/openclaw-backup.tar.gz -C data/.openclaw/
docker-compose restart
```

## API Key Locations

| Service | Key | Where to Get |
|---------|-----|--------------|
| DeepSeek | `DEEPSEEK_API_KEY` | https://platform.deepseek.com |
| Gemini | `GEMINI_API_KEY` | https://ai.google.dev |
| OpenRouter | `OPENROUTER_API_KEY` | https://openrouter.ai |
| ZAI | `ZAI_API_KEY` | https://z.ai |
| Tavily | `TAVILY_API_KEY` | https://tavily.com |
| Telegram | `TELEGRAM_BOT_TOKEN` | @BotFather |

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs -f

# Check port availability
netstat -tlnp | grep 61457

# Verify env file
ls -la .env
docker-compose config  # Validate compose file
```

### Model not available

```bash
# List available models
docker exec openclaw openclaw models list

# Check provider status
docker exec openclaw openclaw doctor
```

### Rate limit errors

→ Fallback should activate automatically. Check logs:
```bash
docker-compose logs | grep -i "fallback\|rate\|limit"
```

## Commands Reference

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Execute CLI command
docker exec openclaw openclaw <command>

# Shell access
docker exec -it openclaw /bin/bash
```

## Differences from Hostinger Image

| Feature | Hostinger | Vanilla |
|---------|-----------|---------|
| Image | `ghcr.io/hostinger/hvps-openclaw` | `openclaw/openclaw:latest` |
| Patches | Many | None |
| Data persistence | Fragile | Robust (named volumes) |
| Fallback logic | Broken | Working |
| Config management | Complex | Simple `.env` |
| Restart issues | Common | Rare |

## Links

- **This Repo:** https://github.com/Silverstar187/openclaw-vanilla
- **Old Backup:** https://github.com/Silverstar187/openclaw-backup
- **Skill Repo:** https://github.com/Silverstar187/openclaw-agent-skill
