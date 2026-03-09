#!/bin/bash
# OpenClaw Vanilla Setup Script
# Für frische Installation ohne Hostinger-Image

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)] WARN:${NC} $1"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)] ERROR:${NC} $1"; }

log "=== OpenClaw Vanilla Setup ==="
log "DeepSeek Primary + Fallback Chain"

# Prüfe Docker
if ! command -v docker &> /dev/null; then
    log "Docker wird installiert..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# Prüfe Docker Compose
if ! command -v docker-compose &> /dev/null; then
    log "Docker Compose wird installiert..."
    pip3 install docker-compose || apt-get install -y docker-compose
fi

# Verzeichnisse erstellen
log "Erstelle Verzeichnisstruktur..."
mkdir -p data/{.openclaw,.cache,.npm,linuxbrew}

# Berechtigungen
chmod 600 .env

# Container starten
log "Starte OpenClaw Container..."
docker-compose up -d

# Warte auf Healthcheck
log "Warte auf OpenClaw..."
sleep 10

for i in {1..30}; do
    if curl -s http://localhost:61457/health > /dev/null 2>&1; then
        log "✅ OpenClaw läuft!"
        break
    fi
    echo -n "."
    sleep 2
done

# Status prüfen
if docker ps | grep -q openclaw; then
    log ""
    log "=== SETUP ERFOLGREICH ==="
    log "Gateway: http://localhost:61457"
    log ""
    log "Teste die Fallback-Kette:"
    docker exec openclaw openclaw models list
else
    error "Container konnte nicht gestartet werden"
    docker-compose logs
    exit 1
fi
