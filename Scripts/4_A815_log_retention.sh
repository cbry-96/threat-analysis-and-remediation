#!/bin/bash
# ============================================================
# SCRIPT: 04_A815_log_retention.sh
# CONTROL ISO 27001: A.8.15 - Registro y monitorización
# PROYECTO: SGSI - 4Geeks Academy - Laboratorio Debian
# AUTOR: Bryan Calderón | Bootcamp Ciberseguridad 2026
# VERSIÓN: 1.0
# DESCRIPCIÓN: Configura retención de logs a 90 días para:
#   - journald (systemd): journald.conf
#   - Apache2: /etc/logrotate.d/apache2
#   - Auth logs: /etc/logrotate.d/rsyslog
#   - WordPress: activar WP_DEBUG_LOG
#   Bonus: instala logwatch para resumen diario de logs
# TIEMPO ESTIMADO: ~20 minutos
# ============================================================
# USO:  sudo bash 04_A815_log_retention.sh
# ============================================================

set -euo pipefail

LOG_FILE="/var/log/sgsi_logs_setup.log"
FECHA=$(date '+%Y-%m-%d %H:%M:%S')

# ── Colores ───────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log()     { echo -e "${GREEN}[✔] $1${NC}";   echo "[$FECHA] [OK] $1"    >> "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[⚠] $1${NC}";  echo "[$FECHA] [WARN] $1"  >> "$LOG_FILE"; }
err()     { echo -e "${RED}[✘] $1${NC}";    echo "[$FECHA] [ERROR] $1"  >> "$LOG_FILE"; exit 1; }
section() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

[[ "$EUID" -ne 0 ]] && err "Ejecutar como root: sudo bash $0"

section "A.8.15 - CONFIGURACIÓN RETENCIÓN DE LOGS (90 días)"

# ─────────────────────────────────────────────────────────
# PASO 1: Configurar journald - retención 90 días
# ─────────────────────────────────────────────────────────
section "PASO 1 / 5 - Configurar journald (SystemMaxUse + MaxRetentionSec)"

JOURNALD_CONF="/etc/systemd/journald.conf"
cp "$JOURNALD_CONF" "${JOURNALD_CONF}.bak_$(date +%Y%m%d)"
log "Backup creado: ${JOURNALD_CONF}.bak_$(date +%Y%m%d)"

# Aplicar configuración de retención
# MaxRetentionSec=7776000  = 90 días en segundos
# SystemMaxUse=500M        = máximo 500MB para logs en disco
# SystemKeepFree=100M      = dejar siempre 100MB libres
# Compress=yes             = comprimir logs rotados

sed -i 's/^#\?Storage=.*/Storage=persistent/'           "$JOURNALD_CONF"
sed -i 's/^#\?Compress=.*/Compress=yes/'                "$JOURNALD_CONF"
sed -i 's/^#\?SystemMaxUse=.*/SystemMaxUse=500M/'       "$JOURNALD_CONF"
sed -i 's/^#\?SystemKeepFree=.*/SystemKeepFree=100M/'   "$JOURNALD_CONF"
sed -i 's/^#\?MaxRetentionSec=.*/MaxRetentionSec=7776000/' "$JOURNALD_CONF"
sed -i 's/^#\?MaxFileSec=.*/MaxFileSec=1month/'         "$JOURNALD_CONF"
sed -i 's/^#\?RateLimitIntervalSec=.*/RateLimitIntervalSec=30s/' "$JOURNALD_CONF"
sed -i 's/^#\?RateLimitBurst=.*/RateLimitBurst=10000/'  "$JOURNALD_CONF"

# Verificar que las líneas existen (añadir si no están)
grep -q "^Storage=" "$JOURNALD_CONF"       || echo "Storage=persistent"     >> "$JOURNALD_CONF"
grep -q "^Compress=" "$JOURNALD_CONF"      || echo "Compress=yes"           >> "$JOURNALD_CONF"
grep -q "^SystemMaxUse=" "$JOURNALD_CONF"  || echo "SystemMaxUse=500M"      >> "$JOURNALD_CONF"
grep -q "^MaxRetentionSec=" "$JOURNALD_CONF" || echo "MaxRetentionSec=7776000" >> "$JOURNALD_CONF"

systemctl restart systemd-journald
log "journald reiniciado con retención de 90 días"
log "  → Storage: persistent (logs sobreviven reinicios)"
log "  → MaxRetentionSec: 7776000 segundos (90 días)"
log "  → SystemMaxUse: 500MB"
log "  → Compress: yes"

# ─────────────────────────────────────────────────────────
# PASO 2: Configurar logrotate para Apache2 - 90 días
# ─────────────────────────────────────────────────────────
section "PASO 2 / 5 - Configurar logrotate Apache2 (90 días)"

APACHE_LOGROTATE="/etc/logrotate.d/apache2"

if [[ -f "$APACHE_LOGROTATE" ]]; then
    cp "$APACHE_LOGROTATE" "${APACHE_LOGROTATE}.bak_$(date +%Y%m%d)"
    log "Backup creado: ${APACHE_LOGROTATE}.bak_$(date +%Y%m%d)"
fi

cat > "$APACHE_LOGROTATE" << 'LOGROTATE_APACHE'
# SGSI - ISO 27001 A.8.15 - Retención logs Apache 90 días
# Bryan Calderón | 4Geeks Academy 2026
/var/log/apache2/*.log {
    daily
    rotate 90
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        if invoke-rc.d apache2 status > /dev/null 2>&1; then
            invoke-rc.d apache2 reload > /dev/null 2>&1;
        fi
    endscript
    su root adm
}
LOGROTATE_APACHE

log "Logrotate Apache2 configurado: rotación diaria, 90 copias (90 días)"

# ─────────────────────────────────────────────────────────
# PASO 3: Configurar logrotate para auth.log y syslog - 90 días
# ─────────────────────────────────────────────────────────
section "PASO 3 / 5 - Configurar logrotate rsyslog (auth.log, syslog) 90 días"

RSYSLOG_LOGROTATE="/etc/logrotate.d/rsyslog"

if [[ -f "$RSYSLOG_LOGROTATE" ]]; then
    cp "$RSYSLOG_LOGROTATE" "${RSYSLOG_LOGROTATE}.bak_$(date +%Y%m%d)"
fi

cat > "$RSYSLOG_LOGROTATE" << 'LOGROTATE_RSYSLOG'
# SGSI - ISO 27001 A.8.15 - Retención auth.log y syslog 90 días
# Bryan Calderón | 4Geeks Academy 2026
/var/log/syslog
/var/log/auth.log
/var/log/kern.log
/var/log/user.log
{
    rotate 90
    daily
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
LOGROTATE_RSYSLOG

log "Logrotate rsyslog configurado: auth.log, syslog, kern.log → 90 días"

# ─────────────────────────────────────────────────────────
# PASO 4: Activar log persistente en WordPress (wp-debug)
# ─────────────────────────────────────────────────────────
section "PASO 4 / 5 - Activar logging WordPress (WP_DEBUG_LOG)"

WP_CONFIG="/var/www/html/wp-config.php"

if [[ -f "$WP_CONFIG" ]]; then
    cp "$WP_CONFIG" "${WP_CONFIG}.bak_$(date +%Y%m%d)"

    # Verificar si ya está definido, si no, añadir antes de la línea "That's all"
    if ! grep -q "WP_DEBUG_LOG" "$WP_CONFIG"; then
        sed -i "/\/\* That's all/i\\
\\
\\/\\* SGSI A.8.15 - Registro de actividad WordPress *\\/\\
define('WP_DEBUG', false);\\
define('WP_DEBUG_LOG', true);\\
define('WP_DEBUG_DISPLAY', false);\\
@ini_set('log_errors', 'On');\\
@ini_set('error_log', WP_CONTENT_DIR . '\\/debug.log');" "$WP_CONFIG"
        log "WordPress debug log activado: /var/www/html/wp-content/debug.log"
    else
        log "WordPress debug log ya estaba configurado"
    fi

    # Asegurar permisos correctos en wp-content para escritura de logs
    chown www-data:www-data /var/www/html/wp-content/
    log "Permisos wp-content ajustados para escritura de logs"
else
    warn "wp-config.php no encontrado en $WP_CONFIG - Saltando configuración WordPress"
fi

# ─────────────────────────────────────────────────────────
# PASO 5: Instalar logwatch para resumen diario
# ─────────────────────────────────────────────────────────
section "PASO 5 / 5 - Instalar logwatch (resumen diario de logs)"

if apt-get install -y logwatch 2>/dev/null; then
    log "logwatch instalado correctamente"

    # Configurar logwatch
    LOGWATCH_CONF="/etc/logwatch/conf/logwatch.conf"
    mkdir -p /etc/logwatch/conf/

    cat > "$LOGWATCH_CONF" << 'LOGWATCH_CONFIG'
# SGSI - ISO 27001 A.8.15 - Configuración logwatch
# Genera resumen diario de logs del sistema
Output = file
Filename = /var/log/logwatch_daily.log
Format = text
Encode = none
MailTo =
Detail = Med
Range = yesterday
Service = All
mailer = /bin/cat
LOGWATCH_CONFIG

    log "logwatch configurado: resumen diario en /var/log/logwatch_daily.log"

    # Programar logwatch en cron.daily (si no existe ya)
    if [[ ! -L /etc/cron.daily/logwatch ]] && [[ ! -f /etc/cron.daily/0logwatch ]]; then
        cat > /etc/cron.daily/sgsi-logwatch << 'LOGWATCH_CRON'
#!/bin/bash
# SGSI A.8.15 - Resumen diario de logs con logwatch
/usr/sbin/logwatch --output file --filename /var/log/logwatch_daily.log \
    --format text --detail med --range yesterday --service All
LOGWATCH_CRON
        chmod +x /etc/cron.daily/sgsi-logwatch
        log "Cron diario logwatch instalado: /etc/cron.daily/sgsi-logwatch"
    fi
else
    warn "logwatch no pudo instalarse (puede ser problema de red en el lab)"
    warn "Instalar manualmente: apt install logwatch"
fi

# ── Aplicar logrotate inmediatamente para verificar ───────
section "VERIFICACIÓN - Aplicar y verificar configuración"
echo ""
echo "--- Verificando configuración logrotate ---"
logrotate --debug /etc/logrotate.d/apache2 2>&1 | head -20
echo ""
echo "--- Estado actual de journald ---"
journalctl --disk-usage 2>/dev/null || true
echo ""
echo "--- Configuración journald activa ---"
grep -E "^(Storage|Compress|SystemMaxUse|MaxRetentionSec)" /etc/systemd/journald.conf || true
echo ""
echo "--- Tamaño actual de logs Apache ---"
ls -lah /var/log/apache2/ 2>/dev/null | head -10 || echo "  (directorio Apache no existe aún)"
echo ""
echo "--- Tamaño logs sistema ---"
du -sh /var/log/ 2>/dev/null || true

echo ""
echo "============================================================"
echo " RESUMEN DE IMPLEMENTACIÓN - A.8.15 Registro y Monitorización"
echo "============================================================"
echo " Control ISO 27001: A.8.15"
echo " Estado anterior:   PENDIENTE"
echo " Estado actual:     IMPLEMENTADO"
echo " Lo configurado:"
echo "   - journald: retención 90 días, persistente, comprimido"
echo "   - Apache2 logs: rotación diaria, 90 copias"
echo "   - auth.log / syslog: rotación diaria, 90 copias"
echo "   - WordPress debug.log: activado en wp-content/"
echo "   - logwatch: resumen diario en /var/log/logwatch_daily.log"
echo " Logs principales:"
echo "   /var/log/apache2/access.log  → acceso web"
echo "   /var/log/apache2/error.log   → errores Apache"
echo "   /var/log/auth.log            → autenticaciones SSH"
echo "   /var/log/syslog              → sistema general"
echo "   /var/www/html/wp-content/debug.log → WordPress"
echo " Fecha/Hora:        $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
warn "PENDIENTE (requiere más configuración): Alertas automáticas por email."
warn "Para alertas: configurar SMTP en logwatch o usar fail2ban + sendmail."
warn "Revisar logs diariamente: journalctl -n 100 -p warning"
warn "Revisar accesos SSH: cat /var/log/auth.log | grep 'Failed\|Accepted'"

echo "[$FECHA] [FIN] Script A.8.15 completado" >> "$LOG_FILE"
