#!/bin/bash
# ============================================================
# SCRIPT: 03_A813_backup_setup.sh
# CONTROL ISO 27001: A.8.13 - Backup y recuperación de información
# PROYECTO: SGSI - 4Geeks Academy - Laboratorio Debian
# AUTOR: Bryan Calderón | Bootcamp Ciberseguridad 2026
# VERSIÓN: 1.0
# DESCRIPCIÓN: Instala y configura backup diario automático de:
#   - Base de datos MariaDB WordPress (mysqldump)
#   - Archivos del sitio /var/www/html (tar.gz)
#   - Configuración crítica (/etc/ssh, /etc/apache2)
#   Retención: 30 días | Ejecución: 02:00 AM diario (cron)
# TIEMPO ESTIMADO: ~20 minutos
# ============================================================
# USO:  sudo bash 03_A813_backup_setup.sh
# ============================================================

set -euo pipefail

LOG_FILE="/var/log/sgsi_backup_setup.log"
FECHA=$(date '+%Y-%m-%d %H:%M:%S')

# ── Configuración (ajustar según entorno) ─────────────────
BACKUP_DIR="/var/backups/sgsi"
DB_USER="wordpressuser"
DB_PASS="Wordpress1234"
DB_NAME="wordpress"
WEB_DIR="/var/www/html"
RETENCION_DIAS=30
BACKUP_SCRIPT="/usr/local/bin/sgsi_backup.sh"
CRON_FILE="/etc/cron.d/sgsi_backup"
LOG_BACKUP="/var/log/sgsi_backup.log"

# ── Colores ───────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log()     { echo -e "${GREEN}[✔] $1${NC}";   echo "[$FECHA] [OK] $1"    >> "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[⚠] $1${NC}";  echo "[$FECHA] [WARN] $1"  >> "$LOG_FILE"; }
err()     { echo -e "${RED}[✘] $1${NC}";    echo "[$FECHA] [ERROR] $1"  >> "$LOG_FILE"; exit 1; }
section() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

[[ "$EUID" -ne 0 ]] && err "Ejecutar como root: sudo bash $0"

section "A.8.13 - CONFIGURACIÓN DE BACKUP AUTOMÁTICO"

# ── Paso 1: Crear directorio de backups ───────────────────
section "PASO 1 / 4 - Crear estructura de directorios"
mkdir -p "$BACKUP_DIR"/{db,www,config}
chmod 750 "$BACKUP_DIR"
log "Directorio de backups creado: $BACKUP_DIR"
log "  → $BACKUP_DIR/db/      (base de datos)"
log "  → $BACKUP_DIR/www/     (archivos web)"
log "  → $BACKUP_DIR/config/  (configuración del sistema)"

# ── Paso 2: Crear el script de backup principal ───────────
section "PASO 2 / 4 - Crear script de backup /usr/local/bin/sgsi_backup.sh"

cat > "$BACKUP_SCRIPT" << BACKUPSCRIPT
#!/bin/bash
# ============================================================
# sgsi_backup.sh - Script de backup diario SGSI
# ISO 27001 A.8.13 | 4Geeks Academy Lab | Bryan Calderón 2026
# ============================================================

DATE=\$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="$BACKUP_DIR"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
WEB_DIR="$WEB_DIR"
RETENCION_DIAS=$RETENCION_DIAS
LOG_BACKUP="$LOG_BACKUP"
EXITCODE=0

log_backup() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S') [\$1] \$2" | tee -a "\$LOG_BACKUP"
}

log_backup "INICIO" "============================================"
log_backup "INICIO" "Backup SGSI iniciado - Fecha: \$DATE"
log_backup "INICIO" "============================================"

# ── 1. Backup de base de datos (mysqldump) ───────────────
log_backup "BD" "Iniciando backup de base de datos: \$DB_NAME"
BACKUP_DB_FILE="\$BACKUP_DIR/db/db_\${DATE}.sql.gz"

if mysqldump -u "\$DB_USER" -p"\$DB_PASS" "\$DB_NAME" \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-table \
    2>>/tmp/sgsi_backup_err.txt | gzip > "\$BACKUP_DB_FILE"; then
    DB_SIZE=\$(du -sh "\$BACKUP_DB_FILE" | cut -f1)
    log_backup "BD" "OK - Backup BD completado: \$BACKUP_DB_FILE (\$DB_SIZE)"
else
    log_backup "ERROR" "FALLO en backup de base de datos. Ver /tmp/sgsi_backup_err.txt"
    EXITCODE=1
fi

# ── 2. Backup de archivos web (/var/www/html) ────────────
log_backup "WWW" "Iniciando backup de archivos web: \$WEB_DIR"
BACKUP_WWW_FILE="\$BACKUP_DIR/www/www_\${DATE}.tar.gz"

if tar czf "\$BACKUP_WWW_FILE" \
    --exclude="\$WEB_DIR/wp-content/cache" \
    --exclude="\$WEB_DIR/wp-content/uploads/cache" \
    "\$WEB_DIR" 2>>/tmp/sgsi_backup_err.txt; then
    WWW_SIZE=\$(du -sh "\$BACKUP_WWW_FILE" | cut -f1)
    log_backup "WWW" "OK - Backup web completado: \$BACKUP_WWW_FILE (\$WWW_SIZE)"
else
    log_backup "ERROR" "FALLO en backup de archivos web"
    EXITCODE=1
fi

# ── 3. Backup de configuración crítica ──────────────────
log_backup "CFG" "Iniciando backup de configuración del sistema"
BACKUP_CFG_FILE="\$BACKUP_DIR/config/config_\${DATE}.tar.gz"

tar czf "\$BACKUP_CFG_FILE" \
    /etc/ssh/sshd_config \
    /etc/apache2/ \
    /var/www/html/wp-config.php \
    /var/www/html/.htaccess \
    2>>/tmp/sgsi_backup_err.txt || true

CFG_SIZE=\$(du -sh "\$BACKUP_CFG_FILE" | cut -f1)
log_backup "CFG" "OK - Backup config completado: \$BACKUP_CFG_FILE (\$CFG_SIZE)"

# ── 4. Limpieza de backups antiguos (retención 30 días) ──
log_backup "LIMPIEZA" "Eliminando backups con más de \$RETENCION_DIAS días"
BORRADOS=\$(find "\$BACKUP_DIR" -type f \( -name "*.gz" -o -name "*.gpg" \) -mtime +\$RETENCION_DIAS | wc -l)
find "\$BACKUP_DIR" -type f \( -name "*.gz" -o -name "*.gpg" \) -mtime +\$RETENCION_DIAS -delete
log_backup "LIMPIEZA" "Archivos eliminados: \$BORRADOS"

# ── 5. Resumen final ─────────────────────────────────────
log_backup "FIN" "============================================"
log_backup "FIN" "Backup completado - ExitCode: \$EXITCODE"
log_backup "FIN" "  BD:     \${BACKUP_DB_FILE##*/} (\$DB_SIZE)"
log_backup "FIN" "  WWW:    \${BACKUP_WWW_FILE##*/} (\$WWW_SIZE)"
log_backup "FIN" "  CONFIG: \${BACKUP_CFG_FILE##*/} (\$CFG_SIZE)"
log_backup "FIN" "============================================"

# ── 6. Mostrar espacio usado por backups ─────────────────
log_backup "INFO" "Espacio total de backups: \$(du -sh \$BACKUP_DIR | cut -f1)"

exit \$EXITCODE
BACKUPSCRIPT

chmod 750 "$BACKUP_SCRIPT"
log "Script de backup creado: $BACKUP_SCRIPT"

# ── Paso 3: Crear tarea cron (02:00 AM diario) ────────────
section "PASO 3 / 4 - Programar tarea cron (02:00 AM diario)"

cat > "$CRON_FILE" << CRONFILE
# SGSI - ISO 27001 A.8.13 - Backup diario automático
# Autor: Bryan Calderón | 4Geeks Academy 2026
# Ejecución: diaria a las 02:00 AM
# Log: $LOG_BACKUP
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 2 * * * root $BACKUP_SCRIPT >> $LOG_BACKUP 2>&1
CRONFILE

chmod 644 "$CRON_FILE"
log "Tarea cron configurada: todos los días a las 02:00 AM"
log "Cron file: $CRON_FILE"

# Reiniciar cron para aplicar cambios
systemctl restart cron 2>/dev/null || systemctl restart crond 2>/dev/null || true
log "Servicio cron reiniciado"

# ── Paso 4: Ejecutar backup inicial de prueba ─────────────
section "PASO 4 / 4 - Ejecutar backup inicial de verificación"
echo ""
echo "Ejecutando primer backup para verificar funcionamiento..."
echo "Esto puede tardar 1-2 minutos..."
echo ""

if bash "$BACKUP_SCRIPT"; then
    log "Backup inicial ejecutado correctamente"
else
    warn "El backup inicial reportó errores. Revisa: $LOG_BACKUP"
fi

# ── Mostrar contenido del directorio de backups ───────────
section "VERIFICACIÓN - Contenido del directorio de backups"
echo ""
ls -lah "$BACKUP_DIR/db/" 2>/dev/null || echo "  (sin archivos db aún)"
ls -lah "$BACKUP_DIR/www/" 2>/dev/null || echo "  (sin archivos www aún)"
ls -lah "$BACKUP_DIR/config/" 2>/dev/null || echo "  (sin archivos config aún)"

echo ""
echo "--- Últimas líneas del log de backup ---"
tail -20 "$LOG_BACKUP" 2>/dev/null || echo "  (log no generado aún)"

echo ""
echo "--- Espacio en disco utilizado ---"
df -h /var/backups/
du -sh "$BACKUP_DIR" 2>/dev/null || true

echo ""
echo "============================================================"
echo " RESUMEN DE IMPLEMENTACIÓN - A.8.13 Backup"
echo "============================================================"
echo " Control ISO 27001: A.8.13"
echo " Estado anterior:   PENDIENTE"
echo " Estado actual:     IMPLEMENTADO"
echo " Qué se respalda:"
echo "   - Base de datos MariaDB (mysqldump + gzip)"
echo "   - Archivos web /var/www/html (tar.gz)"
echo "   - Configuración SSH y Apache (tar.gz)"
echo " Retención:         $RETENCION_DIAS días"
echo " Programación:      Diario a las 02:00 AM (cron)"
echo " Directorio backup: $BACKUP_DIR"
echo " Log de backups:    $LOG_BACKUP"
echo " Script de backup:  $BACKUP_SCRIPT"
echo " Cron file:         $CRON_FILE"
echo " Fecha/Hora:        $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
warn "PENDIENTE (no se hace en 1 hora): Prueba de restauración completa."
warn "Programar simulacro de restauración en los próximos 7 días:"
warn "  Pasos: Borrar WordPress → Restaurar desde backup → Verificar funcionamiento"
warn "BUENA PRÁCTICA: Copiar backups a ubicación externa (USB, NFS, S3, SFTP)."

echo "[$FECHA] [FIN] Script A.8.13 completado" >> "$LOG_FILE"
