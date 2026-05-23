# 📁 Scripts — Implementaciones técnicas ISO 27001

## backup-4geeks.sh

Script de backup automatizado implementado como control **A.8.13 — Respaldo de Información**.

### Instalación en el servidor.

```bash
# Copiar al servidor
cp backup-4geeks.sh /backup/scripts/backup.sh
chmod +x /backup/scripts/backup.sh

# Configurar cron
echo "0 2 * * * root /backup/scripts/backup.sh" > /etc/cron.d/backup-iso27001

# Ejecutar manualmente para probar
/backup/scripts/backup.sh
cat /var/log/backup.log
```

### Qué hace

- 💾 Backup completo de `/var/www/html` → `web_YYYYMMDD_HHMMSS.tar.gz`
- 🗄️ Backup de todas las bases de datos → `db_YYYYMMDD_HHMMSS.sql.gz`
- 🗑️ Purga automática de backups con más de 90 días
- 📝 Log de auditoría en `/var/log/backup.log`
- ⏰ Ejecución diaria automática a las 02:00 AM

### Evidencia de ejecución (22/05/2026)

```
[20260522_102633] Iniciando backup
[20260522_102633] Web backup OK — 32M
[20260522_102633] DB backup OK — 796K
[20260522_102633] Purga: 0 archivos eliminados (>90 días)
[20260522_102633] Backup completado
```

---
*Bryan Calderón · 4Geeks Academy · 22 de mayo de 2026*
