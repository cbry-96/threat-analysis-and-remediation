# 🛡️ Plan de Respuesta a Incidentes + SGSI ISO 27001 — Fase 3

> **Marco:** NIST SP 800-61 Rev. 2 · ISO/IEC 27001:2022  
> **Analista:** Bryan Calderón · 4Geeks Academy · Mayo 2026 

---

## PARTE A — Plan de Respuesta a Incidentes (NIST SP 800-61)

### Clasificación de Incidentes

| Nivel | Severidad | Criterios | Ejemplo del laboratorio |
|-------|-----------|-----------|------------------------|
| P1 | 🔴 CRÍTICO | RCE confirmado, acceso root, exfiltración activa | Plugin malicioso activo · wp-admin comprometido |
| P2 | 🟠 ALTO | Credenciales expuestas, servicio crítico comprometido | wp-config.php con credenciales en texto plano |
| P3 | 🟡 MEDIO | Vuln. confirmada sin explotación activa | SSH sin hardening · Directory listing |
| P4 | 🟢 BAJO | Anomalías sin impacto confirmado | Errores en logs · CUPS activo |

---

### Fase 1 — Preparación

**Herramientas de respuesta:**
- Análisis forense: `journalctl`, `ss`, `ps aux`, `last`, `find`, `chkrootkit`, `rkhunter`
- Escaneo: `nmap`, `wpscan`, `lynis`, `openvas`
- Monitorización: `fail2ban`, `auditd`, `logwatch`

**Inventario de activos críticos:**

| Activo | Tipo | Criticidad |
|--------|------|-----------|
| Servidor Debian `192.168.1.131` | Servidor virtual | 🔴 CRÍTICA |
| WordPress + Apache | Aplicación web | 🔴 CRÍTICA |
| Base de datos MariaDB | BBDD | 🔴 CRÍTICA |
| Servicio SSH | Acceso remoto | 🟠 ALTA |

---

### Fase 2 — Detección y Análisis

**Indicadores de Compromiso (IoC) identificados:**

| IoC | Tipo | Fuente |
|-----|------|--------|
| Plugin desconocido 'Security Tool' | Artefacto malicioso | Revisión manual |
| `DB_PASSWORD='123456'` | Credencial débil | Auditoría de configuración |
| `xmlrpc.php` accesible | Servicio expuesto | WPScan |
| `pam_unix(sudo:auth): conversation failed` | Log autenticación | journalctl |
| `unix_chkpwd: password check failed` | Intento acceso | auth.log |

**Procedimiento forense inicial:**
```bash
# 1. Capturar estado del sistema
ps aux > /tmp/forense-procesos.txt
ss -tulnp > /tmp/forense-puertos.txt
cat /etc/passwd > /tmp/forense-usuarios.txt
find / -mtime -7 -type f 2>/dev/null > /tmp/forense-archivos-recientes.txt

# 2. Revisar logs
journalctl | grep -i "failed\|accepted\|invalid" > /tmp/forense-logs.txt
cat /var/log/auth.log >> /tmp/forense-logs.txt

# 3. Buscar rootkits
chkrootkit
rkhunter --checkall
```

---

### Fase 3 — Contención, Erradicación y Recuperación

**Acciones aplicadas al incidente real:**

| Artefacto / Vulnerabilidad | Acción ejecutada | Verificación |
|---------------------------|-----------------|--------------|
| Plugin malicioso shell.php | `rm -rf .../plugins/shell/` | curl → 404 ✅ |
| vsftpd (FTP) expuesto | `systemctl stop/disable vsftpd` | Puerto 21 cerrado ✅ |
| CUPS innecesario | `systemctl stop/disable cups` | Puerto 631 cerrado ✅ |
| XML-RPC expuesto | `.htaccess: Deny from all` | curl → 404 ✅ |
| Contraseña BD débil | `ALTER USER ... IDENTIFIED BY ...` | wp-config actualizado ✅ |
| SSH sin hardening | `PermitRootLogin no` + MaxAuthTries 3 | `systemctl restart sshd` ✅ |
| Sistema desactualizado | `apt update && apt upgrade -y` | Paquetes actualizados ✅ |

---

### Fase 4 — Post-Incidente

**Métricas del incidente:**

| Métrica | Valor |
|---------|-------|
| Tiempo de exposición estimado | ~10 meses (julio 2024 – mayo 2025) |
| MTTD (tiempo detección) | No monitorizado — detección manual |
| Tiempo de contención | < 1 hora |
| Tiempo de recuperación total | ~4 horas |
| Nivel de severidad | P1 — CRÍTICO |

**Lecciones aprendidas:**

| Lo que falló | Mejora propuesta |
|-------------|------------------|
| Logs sin revisión durante meses | Logwatch + alertas por email |
| Contraseña BD por defecto sin cambiar | Política obligatoria: cambiar credenciales en primer despliegue |
| Servicios innecesarios activos desde instalación | Checklist de hardening post-instalación |
| Sin monitorización activa ni alertas | fail2ban + AIDE + Wordfence |

---

## PARTE B — SGSI ISO/IEC 27001:2022

### Análisis de Riesgos

| Riesgo | Prob. | Impacto | Nivel | Control |
|--------|-------|---------|-------|---------|
| Acceso no autorizado via FTP | 5 | 5 | 🔴 25 CRÍTICO | Deshabilitar FTP → SFTP |
| RCE via plugin malicioso | 4 | 5 | 🔴 20 CRÍTICO | DISALLOW_FILE_MODS |
| Exfiltración credenciales BD | 4 | 5 | 🔴 20 CRÍTICO | Contraseña robusta + permisos 640 |
| Fuerza bruta SSH | 5 | 4 | 🔴 20 CRÍTICO | fail2ban + MaxAuthTries 3 |
| Enumeración usuarios API REST | 5 | 3 | 🟠 15 ALTO | Restringir API REST |
| DoS / Indisponibilidad | 3 | 4 | 🟡 12 MEDIO | Rate limiting UFW |
| Pérdida datos por falta backups | 4 | 4 | 🟠 16 ALTO | Backups diarios cifrados |

---

### Controles ISO 27001:2022 — Declaración de Aplicabilidad

| Control | Descripción | Estado |
|---------|-------------|--------|
| A.5.1 | Políticas de seguridad | ✅ Implementado |
| A.5.29 | Gestión de incidentes | ✅ Implementado |
| A.8.3 | Accesos privilegiados | ✅ Implementado |
| A.8.5 | Autenticación segura | 🔄 Parcial |
| A.8.8 | Gestión de vulnerabilidades | 🔄 Parcial |
| A.8.13 | Backup de información | ⏳ Pendiente |
| A.8.15 | Registro y monitorización | ⏳ Pendiente |
| A.8.20 | Seguridad en redes (UFW) | ⏳ Pendiente |
| A.8.24 | Criptografía — HTTPS TLS 1.3 | ⏳ Pendiente |
| A.8.32 | Gestión de cambios | ⏳ Pendiente |

---

### Políticas DLP

| Clasificación | Ejemplos | Controles |
|---------------|---------|-----------|
| 🔴 CONFIDENCIAL | Credenciales BD, claves SSH, datos personales | Cifrado reposo + tránsito · Mínimo privilegio |
| 🟡 INTERNO | Configuraciones del servidor, usuarios | Control acceso por roles · No publicar |
| 🟢 PÚBLICO | Contenido WordPress, documentación técnica | Verificar antes de publicar |

---

### Plan de Continuidad

| Servicio | RTO | RPO | Prioridad |
|---------|-----|-----|-----------|
| Apache + WordPress | 4 horas | 24 horas | 🔴 CRÍTICA |
| MariaDB | 2 horas | 4 horas | 🔴 CRÍTICA |
| SSH | 1 hora | N/A | 🟠 ALTA |

**Script de backup recomendado:**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
# Backup BD cifrado
mysqldump -u wordpressuser -pWordpress1234 wordpress | \
  gpg -c > /var/backups/db_$DATE.sql.gpg
# Backup archivos cifrado
tar czf - /var/www/html | \
  gpg -c > /var/backups/www_$DATE.tar.gz.gpg
```

---

### Plan de Mejora Continua (12 meses)

| # | Acción | Plazo | Responsable |
|---|--------|-------|-------------|
| 1 | UFW: `ufw default deny incoming` + reglas 22, 80, 443 | Semana 1 | Admin sistemas |
| 2 | HTTPS con TLS 1.3 (Let's Encrypt) | Semana 2 | Admin sistemas |
| 3 | fail2ban para SSH y wp-login.php | Semana 2 | Analista seguridad |
| 4 | Script backup diario con GPG | Semana 3 | Admin sistemas |
| 5 | AIDE para integridad de archivos | Mes 1 | Analista seguridad |
| 6 | API REST WordPress restringida | Mes 1 | Dev WordPress |
| 7 | Primera auditoría interna SGSI | Mes 3 | Analista seguridad |
| 8 | Revisión anual análisis de riesgos | Mes 12 | Dirección + Analista |

---

## Referencias

- NIST SP 800-61 Rev. 2 — https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf
- ISO/IEC 27001:2022 — https://www.iso.org/standard/82875.html
- ISO/IEC 27005:2022 — Information Security Risk Management
- ENS — Real Decreto 311/2022, BOE España
- RGPD — Reglamento (UE) 2016/679
- CIS Controls v8 — https://www.cisecurity.org/controls/

---

*Bryan Calderón · Bootcamp de Ciberseguridad · 4Geeks Academy · 2026*
