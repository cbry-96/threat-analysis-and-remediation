#!/bin/bash
# ============================================================
# Script de Backup Automatizado — Control ISO 27001 A.8.13
# 4Geeks Academy · Bootcamp de Ciberseguridad
# Autor: Bryan Calderón
# Fecha: 22 de mayo de 2026
# Servidor: Debian GNU/Linux — 192.168.1.131
# ============================================================
#
# Instalación:
#   cp backup-4geeks.sh /backup/scripts/backup.sh
#   chmod +x /backup/scripts/backup.sh
#
# Programación cron (/etc/cron.d/backup-iso27001):
#   0 2 * * * root /backup/scripts/backup.sh
#
# ============================================================

FECHA=$(date +%Y%m%d_%H%M%S)
DIR=/backup/data
LOG=/var/log/backup.log

# Crear directorio si no existe
mkdir -p $DIR

echo "[$FECHA] Iniciando backup" >> $LOG

# --- Backup de archivos web ---
tar -czf $DIR/web_$FECHA.tar.gz /var/www/html 2>/dev/null
if [ $? -eq 0 ]; then
    echo "[$FECHA] Web backup OK — $(du -sh $DIR/web_$FECHA.tar.gz | cut -f1)" >> $LOG
else
    echo "[$FECHA] ERROR: Web backup fallido" >> $LOG
fi

# --- Backup de base de datos WordPress ---
mysqldump --all-databases -u root 2>/dev/null | gzip > $DIR/db_$FECHA.sql.gz
if [ $? -eq 0 ]; then
    echo "[$FECHA] DB backup OK — $(du -sh $DIR/db_$FECHA.sql.gz | cut -f1)" >> $LOG
else
    echo "[$FECHA] ERROR: DB backup fallido" >> $LOG
fi

# --- Purga automática de backups > 90 días ---
ELIMINADOS=$(find $DIR -name "*.gz" -mtime +90 -delete -print | wc -l)
echo "[$FECHA] Purga: $ELIMINADOS archivos eliminados (>90 días)" >> $LOG

echo "[$FECHA] Backup completado" >> $LOG
echo "---" >> $LOG
