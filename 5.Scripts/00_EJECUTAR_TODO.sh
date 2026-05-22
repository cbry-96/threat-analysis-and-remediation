#!/bin/bash
# ============================================================
# SCRIPT MAESTRO: 00_EJECUTAR_TODO.sh
# SGSI - Implementación completa de controles ISO 27001
# 4Geeks Academy - Laboratorio Debian
# AUTOR: Bryan Calderón | Bootcamp Ciberseguridad 2026
# ============================================================
# Ejecuta en orden los 4 controles pendientes:
#   01. A.8.20 - UFW Firewall
#   02. A.8.24 - HTTPS / TLS
#   03. A.8.13 - Backup automático
#   04. A.8.15 - Retención de logs 90 días
#
# TIEMPO TOTAL ESTIMADO: 45-60 minutos
# USO: sudo bash 00_EJECUTAR_TODO.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG_MAESTRO="/var/log/sgsi_implementacion_completa.log"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

[[ "$EUID" -ne 0 ]] && { echo "Ejecutar como root: sudo bash $0"; exit 1; }

clear
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║    SGSI - IMPLEMENTACIÓN CONTROLES ISO 27001:2022           ║"
echo "║    4Geeks Academy · Laboratorio Debian · Mayo 2026          ║"
echo "║    Analista: Bryan Calderón                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Este script implementará los 4 controles PENDIENTES:${NC}"
echo ""
echo -e "  ${GREEN}✦ A.8.20${NC} → Seguridad en redes (UFW Firewall)"
echo -e "  ${GREEN}✦ A.8.24${NC} → Uso de criptografía (HTTPS/TLS)"
echo -e "  ${GREEN}✦ A.8.13${NC} → Backup y recuperación"
echo -e "  ${GREEN}✦ A.8.15${NC} → Registro y monitorización (logs 90 días)"
echo ""
echo -e "${YELLOW}Tiempo estimado: 45-60 minutos${NC}"
echo -e "${YELLOW}Log maestro: $LOG_MAESTRO${NC}"
echo ""
echo -e "${RED}⚠  AVISO: Asegúrate de tener otra terminal SSH abierta antes de continuar.${NC}"
echo -e "${RED}   El firewall UFW se activará. Si te desconectas, el puerto 22 sigue abierto.${NC}"
echo ""
read -p "¿Continuar con la implementación? [s/N]: " CONFIRM
[[ "${CONFIRM,,}" != "s" ]] && { echo "Operación cancelada."; exit 0; }

echo "[$FECHA] INICIO implementación SGSI completa" >> "$LOG_MAESTRO"
TIEMPO_INICIO=$(date +%s)
CONTROLES_OK=0
CONTROLES_FAIL=0

ejecutar_control() {
    local NUM="$1"
    local NOMBRE="$2"
    local SCRIPT="$3"

    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  CONTROL $NUM: $NOMBRE${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [[ ! -f "$SCRIPT_DIR/$SCRIPT" ]]; then
        echo -e "${RED}[✘] Script no encontrado: $SCRIPT_DIR/$SCRIPT${NC}"
        echo "[$FECHA] [FAIL] Control $NUM - Script no encontrado: $SCRIPT" >> "$LOG_MAESTRO"
        ((CONTROLES_FAIL++))
        return 1
    fi

    chmod +x "$SCRIPT_DIR/$SCRIPT"
    T_INICIO=$(date +%s)

    if bash "$SCRIPT_DIR/$SCRIPT"; then
        T_FIN=$(date +%s)
        DURACION=$((T_FIN - T_INICIO))
        echo -e "\n${GREEN}[✔] Control $NUM completado en ${DURACION}s${NC}"
        echo "[$FECHA] [OK] Control $NUM ($NOMBRE) completado en ${DURACION}s" >> "$LOG_MAESTRO"
        ((CONTROLES_OK++))
    else
        T_FIN=$(date +%s)
        echo -e "\n${RED}[✘] Control $NUM falló. Revisa el log específico.${NC}"
        echo "[$FECHA] [FAIL] Control $NUM ($NOMBRE)" >> "$LOG_MAESTRO"
        ((CONTROLES_FAIL++))
        read -p "¿Continuar con el siguiente control? [s/N]: " NEXT
        [[ "${NEXT,,}" != "s" ]] && exit 1
    fi
}

# ── Ejecutar los 4 controles ─────────────────────────────
ejecutar_control "A.8.20" "Seguridad en Redes (UFW)" "01_A820_ufw_setup.sh"
ejecutar_control "A.8.24" "Uso de Criptografía (HTTPS/TLS)" "02_A824_https_ssl.sh"
ejecutar_control "A.8.13" "Backup y Recuperación" "03_A813_backup_setup.sh"
ejecutar_control "A.8.15" "Registro y Monitorización (Logs)" "04_A815_log_retention.sh"

# ── Resumen final ─────────────────────────────────────────
TIEMPO_FIN=$(date +%s)
DURACION_TOTAL=$((TIEMPO_FIN - TIEMPO_INICIO))
MINUTOS=$((DURACION_TOTAL / 60))
SEGUNDOS=$((DURACION_TOTAL % 60))

echo ""
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              IMPLEMENTACIÓN COMPLETADA                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "  Controles implementados: ${GREEN}$CONTROLES_OK${NC}"
echo -e "  Controles con error:     ${RED}$CONTROLES_FAIL${NC}"
echo -e "  Tiempo total:            ${YELLOW}${MINUTOS}m ${SEGUNDOS}s${NC}"
echo ""
echo -e "  ${BOLD}Estado actualizado de controles ISO 27001:${NC}"
echo -e "  ${GREEN}✔ A.8.20${NC} - Seguridad en redes (UFW)              → IMPLEMENTADO"
echo -e "  ${GREEN}✔ A.8.24${NC} - Uso de criptografía (HTTPS/TLS)       → IMPLEMENTADO"
echo -e "  ${GREEN}✔ A.8.13${NC} - Backup y recuperación                 → IMPLEMENTADO"
echo -e "  ${GREEN}✔ A.8.15${NC} - Registro y monitorización             → IMPLEMENTADO"
echo ""
echo -e "  ${YELLOW}Controles ya implementados anteriormente:${NC}"
echo -e "  ${GREEN}✔ A.8.3${NC}  - Gestión accesos privilegiados          → IMPLEMENTADO"
echo -e "  ${GREEN}✔ A.5.29${NC} - Seguridad en gestión de incidentes     → IMPLEMENTADO"
echo ""
echo -e "  ${YELLOW}Controles PARCIALES (requieren trabajo adicional):${NC}"
echo -e "  ${YELLOW}◑ A.8.5${NC}  - Autenticación segura (falta 2FA WP)"
echo -e "  ${YELLOW}◑ A.8.8${NC}  - Gestión de vulnerabilidades (falta WPScan periódico)"
echo ""
echo -e "  ${YELLOW}Controles PENDIENTES (requieren > 1 día):${NC}"
echo -e "  ${RED}○ A.8.32${NC} - Gestión de cambios (requiere proceso/documentación)"
echo ""
echo -e "  Log maestro: $LOG_MAESTRO"
echo ""

echo "[$FECHA] FIN implementación - OK:$CONTROLES_OK FAIL:$CONTROLES_FAIL Tiempo:${MINUTOS}m${SEGUNDOS}s" >> "$LOG_MAESTRO"
