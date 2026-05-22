#!/bin/bash
# ============================================================
# SCRIPT: 01_A820_ufw_setup.sh
# CONTROL ISO 27001: A.8.20 - Seguridad en redes
# PROYECTO: SGSI - 4Geeks Academy - Laboratorio Debian
# AUTOR: Bryan Calderón | Bootcamp Ciberseguridad 2026
# VERSIÓN: 1.0
# DESCRIPCIÓN: Activa UFW con política deny-all y abre solo
#              los puertos estrictamente necesarios: 22, 80, 443
# TIEMPO ESTIMADO: ~5 minutos
# ============================================================
# USO:  sudo bash 01_A820_ufw_setup.sh
# ============================================================

set -euo pipefail

LOG_FILE="/var/log/sgsi_ufw_setup.log"
FECHA=$(date '+%Y-%m-%d %H:%M:%S')

# ── Colores para terminal ──────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log() { echo -e "${GREEN}[✔] $1${NC}"; echo "[$FECHA] [OK] $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[⚠] $1${NC}"; echo "[$FECHA] [WARN] $1" >> "$LOG_FILE"; }
err() { echo -e "${RED}[✘] $1${NC}"; echo "[$FECHA] [ERROR] $1" >> "$LOG_FILE"; exit 1; }
section() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ── Verificar ejecución como root ─────────────────────────
[[ "$EUID" -ne 0 ]] && err "Este script debe ejecutarse como root: sudo bash $0"

section "A.8.20 - CONFIGURACIÓN DE FIREWALL UFW"
echo "Registro: $LOG_FILE"
echo "Inicio: $FECHA"

# ── Instalar UFW si no está presente ──────────────────────
section "PASO 1 / 5 - Instalar UFW"
if ! command -v ufw &>/dev/null; then
    apt-get update -qq && apt-get install -y ufw
    log "UFW instalado correctamente"
else
    log "UFW ya está instalado: $(ufw --version | head -1)"
fi

# ── Restablecer configuración a estado limpio ─────────────
section "PASO 2 / 5 - Resetear configuración UFW"
ufw --force reset
log "Configuración UFW reseteada a estado limpio"

# ── Política por defecto: DENEGAR TODO ───────────────────
section "PASO 3 / 5 - Aplicar política deny-all"
ufw default deny incoming
ufw default allow outgoing
log "Política aplicada: DENY incoming | ALLOW outgoing"

# ── Abrir solo puertos necesarios ────────────────────────
section "PASO 4 / 5 - Abrir puertos necesarios"

# Puerto 22 - SSH (acceso remoto)
ufw allow 22/tcp comment 'SSH - Acceso remoto administrativo'
log "Puerto 22/tcp (SSH) abierto"

# Puerto 80 - HTTP (WordPress / Apache)
ufw allow 80/tcp comment 'HTTP - Servidor web Apache'
log "Puerto 80/tcp (HTTP) abierto"

# Puerto 443 - HTTPS (cifrado TLS)
ufw allow 443/tcp comment 'HTTPS - Servidor web cifrado TLS'
log "Puerto 443/tcp (HTTPS) abierto"

# ── Activar UFW ──────────────────────────────────────────
section "PASO 5 / 5 - Activar firewall"
ufw --force enable
log "UFW activado y habilitado en arranque del sistema"

# ── Verificación y reporte final ─────────────────────────
section "VERIFICACIÓN - Estado final del firewall"
echo ""
ufw status verbose

echo ""
echo "============================================================"
echo " RESUMEN DE IMPLEMENTACIÓN - A.8.20 Seguridad en Redes"
echo "============================================================"
echo " Control ISO 27001: A.8.20"
echo " Estado anterior:   PENDIENTE"
echo " Estado actual:     IMPLEMENTADO"
echo " Política entrada:  DENY ALL (deny-all por defecto)"
echo " Puertos abiertos:  22/tcp (SSH), 80/tcp (HTTP), 443/tcp (HTTPS)"
echo " Log del script:    $LOG_FILE"
echo " Fecha/Hora:        $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
warn "IMPORTANTE: Verifica que la conexión SSH sigue activa antes de cerrar la sesión actual."
warn "Ejecuta en otra terminal: ssh usuario@192.168.1.131"

echo "[$FECHA] [FIN] Script A.8.20 completado exitosamente" >> "$LOG_FILE"
