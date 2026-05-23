<div align="center">

# 🔐 Proyecto Final — Ciberseguridad
### Análisis Forense · Pentesting WordPress · ISO 27001:2022
#### 4Geeks Academy · Bootcamp de Ciberseguridad · Mayo 2026

---

![Debian](https://img.shields.io/badge/Target-Debian%20Linux-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![WordPress](https://img.shields.io/badge/Attack%20Surface-WordPress%206.9.4-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![Parrot OS](https://img.shields.io/badge/Attacker-Parrot%20OS-05A8E6?style=for-the-badge&logo=linux&logoColor=white)
![NIST](https://img.shields.io/badge/Framework-NIST%20SP%20800--61-003087?style=for-the-badge)
![ISO 27001](https://img.shields.io/badge/Standard-ISO%2027001%3A2022-00447C?style=for-the-badge)

---

![Status](https://img.shields.io/badge/Estado-Completado-success?style=flat-square)
![Vulns](https://img.shields.io/badge/Vulnerabilidades-5%20identificadas-critical?style=flat-square)
![Remediated](https://img.shields.io/badge/Remediadas-100%25-brightgreen?style=flat-square)
![RCE](https://img.shields.io/badge/RCE-Confirmado-red?style=flat-square)
![ISO](https://img.shields.io/badge/ISO%2027001-67%25%20Implementado-blue?style=flat-square)
![Date](https://img.shields.io/badge/Fecha-22%20Mayo%202026-orange?style=flat-square)

</div>

---

## 📋 Descripción

Proyecto final del Bootcamp de Ciberseguridad de **4Geeks Academy** donde asumo el rol de analista de ciberseguridad encargado de restaurar y proteger un servidor Debian Linux comprometido, simulando un escenario real de respuesta a incidente empresarial.

| Indicador | Valor |
|-----------|-------|
| 🎯 Sistema objetivo | Debian GNU/Linux 6.1.0-25-amd64 · `192.168.1.131` |
| 💻 Máquina atacante | Parrot OS · `192.168.1.11` |
| 🔴 Vulnerabilidades críticas | 3 (FTP, RCE WordPress, credenciales BD) |
| ✅ Remediación | 100% — todas corregidas y verificadas |
| ⚡ Tiempo hasta RCE | < 20 minutos desde reconocimiento |
| 🛡️ ISO 27001 | 6/9 controles implementados (67%) |
| 📅 Fecha | 22 de mayo de 2026 |

---

## 🗂️ Estructura del Repositorio

```
📁 ciberseguridad-4geeks/
│
├── 📄 README.md                          ← Este archivo
│
├── 📁 docs/
│   ├── 📁 fase1/                         ← Análisis forense
│   │   ├── 📄 Informe_Incidente_Seguridad_Fase1.docx
│   │   └── 📄 README.md
│   │
│   ├── 📁 fase2/                         ← Pentesting WordPress
│   │   ├── 📄 Informe_Pentesting_WordPress_Fase2.docx
│   │   └── 📄 README.md
│   │
│   ├── 📁 fase3/                         ← NIST + ISO 27001
│   │   ├── 📄 Plan_Respuesta_SGSI_ISO27001_Fase3.docx
│   │   └── 📄 README.md
│   │
│   └── 📁 presentacion/                  ← Presentación ejecutiva
│       ├── 📄 Presentacion_Ejecutiva_Gerencia.pptx
│       └── 📄 README.md
│
├── 📁 evidencias/
│   ├── 📁 fase1/                         ← Capturas análisis forense
│   │   └── 📄 README.md
│   └── 📁 fase2/                         ← Capturas pentesting
│       └── 📄 README.md
│
├── 📁 red/                               ← Diagramas de red
│   ├── 📄 diagrama-red.md
│   └── 📄 README.md
│
├── 📁 scripts/                           ← Scripts implementados
│   ├── 📄 backup-4geeks.sh
│   └── 📄 README.md
│
└── 📄 .gitignore
```

---

## ⚔️ Fase 1 — Análisis Forense del Servidor Comprometido

> 📄 **Documento:** [`docs/fase1/Informe_Incidente_Seguridad_Fase1.docx`](./docs/fase1/)

### Hallazgos identificados

| # | Hallazgo | Severidad | Servicio |
|---|----------|-----------|----------|
| 1 | FTP transmitiendo credenciales en texto plano | 🔴 CRÍTICO | Puerto 21 · vsftpd |
| 2 | Apache HTTP sin cifrado ni hardening | 🟠 ALTO | Puerto 80 · Apache 2.4.67 |
| 3 | SSH sin restricciones de seguridad | 🟡 MEDIO | Puerto 22 · OpenSSH 9.2p1 |
| 4 | CUPS activo innecesariamente | 🟡 MEDIO | Puerto 631 · cupsd |
| 5 | Logs con evidencia maliciosa desde julio 2024 | 🟠 ALTO | journalctl / auth.log |

### Comandos de remediación ejecutados

```bash
# FTP deshabilitado
systemctl stop vsftpd && systemctl disable vsftpd
ss -tulnp | grep :21   # → Sin salida ✅

# CUPS deshabilitado
systemctl stop cups && systemctl disable cups

# SSH hardening
# /etc/ssh/sshd_config:
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30
systemctl restart sshd

# Sistema actualizado
apt update && apt upgrade -y

# Contraseña cambiada
passwd debian
```

---

## 🕵️ Fase 2 — Pentesting WordPress

> 📄 **Documento:** [`docs/fase2/Informe_Pentesting_WordPress_Fase2.docx`](./docs/fase2/)

### Cadena de ataque (5 pasos)

```
[Parrot OS 192.168.1.11]
        │
        ├─ nmap -sV -sC -O -p- 192.168.1.131
        │  → Puerto 80: WordPress 6.9.4 + /wp-admin/ en robots.txt
        │
        ├─ wpscan → Usuario: wordpress-user (WP JSON API)
        │           XML-RPC habilitado
        │
        ├─ cat /var/www/html/wp-config.php | grep DB_PASSWORD
        │  → DB_PASSWORD = '123456'  ← CRÍTICO
        │
        ├─ mysql → UPDATE wp_users SET user_pass=MD5('hacked123')
        │  → Acceso a http://192.168.1.131/wp-admin/ ✅
        │
        └─ Plugin malicioso shell.php subido e instalado
           curl ".../shell.php?cmd=whoami" → www-data  ← RCE ✅
```

### Vulnerabilidades explotadas

| CWE | Descripción | Severidad |
|-----|-------------|-----------|
| CWE-200 | API REST expone usuarios sin autenticación | 🔴 CRÍTICO |
| CWE-256 | `DB_PASSWORD='123456'` en texto plano | 🔴 CRÍTICO |
| CWE-434 | Editor de plugins → RCE | 🔴 CRÍTICO |
| CWE-749 | XML-RPC expuesto | 🟠 ALTO |
| CWE-16 | `siteurl='localhost'` misconfiguration | 🟠 ALTO |

---

## 🛡️ Fase 3 — Plan de Respuesta + SGSI ISO 27001

> 📄 **Documento:** [`docs/fase3/Plan_Respuesta_SGSI_ISO27001_Fase3.docx`](./docs/fase3/)

### Ciclo NIST SP 800-61

| Fase | Estado | Actividades |
|------|--------|-------------|
| 🔵 Preparación | ✅ | Inventario, herramientas, controles técnicos implementados |
| 🟡 Detección | ✅ | IoCs identificados, logs analizados, WPScan, Nmap |
| 🟠 Contención | ✅ | Servicios detenidos, plugin eliminado, credenciales revocadas |
| 🟢 Recuperación | ✅ | Sistema actualizado, hardening, verificación |

### ISO 27001:2022 — Estado de Controles (22/05/2026)

| Control | Descripción | Estado |
|---------|-------------|--------|
| A.5.1 | Políticas de seguridad | ✅ Implementado |
| A.5.29 | Gestión de incidentes | ✅ Implementado |
| A.8.3 | Accesos privilegiados | ✅ Implementado |
| A.8.13 | Backup automatizado | ✅ Implementado — 22/05/2026 |
| A.8.15 | Retención logs 90 días | ✅ Implementado — 22/05/2026 |
| A.8.20 | Firewall UFW | ✅ Implementado — 22/05/2026 |
| A.8.24 | HTTPS + HSTS | ✅ Implementado — 22/05/2026 |
| A.8.5 | Autenticación segura | 🔄 Parcial |
| A.8.8 | Gestión vulnerabilidades | 🔄 Parcial |
| A.8.32 | Gestión de cambios | ⏳ Pendiente |

> **6/9 controles implementados — 67% de cumplimiento ISO 27001**

---

## 🔧 Controles Técnicos Implementados (22/05/2026)

### A.8.20 — Firewall UFW
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp
ufw enable
# → Status: active ✅
```

### A.8.24 — HTTPS con certificado SSL
```bash
a2enmod ssl headers
# Certificado RSA 2048-bit — CN: 192.168.1.131 — Org: 4Geeks Academy
# HSTS: Strict-Transport-Security: max-age=31536000
curl -k https://192.168.1.131 → HTTP/1.1 200 OK ✅
```

### A.8.13 — Backup automatizado
```bash
# /backup/scripts/backup.sh
# mysqldump + tar.gz → /backup/data/
# Cron: 0 2 * * * root /backup/scripts/backup.sh
# Retención: find -mtime +90 -delete
# Evidencia: db_*.sql.gz (796KB) + web_*.tar.gz (32MB) ✅
```

### A.8.15 — Retención de logs 90 días
```bash
# /etc/systemd/journald.conf:
MaxRetentionSec=90day
SystemMaxUse=500M
# logrotate Apache: rotate 90 + daily + compress ✅
```

---

## 🌐 Topología de Red

> 📄 **Diagrama:** [`red/diagrama-red.md`](./red/diagrama-red.md)

```
ANTES (comprometida)          DESPUÉS (segura)
─────────────────────         ─────────────────────
     Internet                      Internet
         │                              │
     [Switch]                    [Firewall UFW]
    /        \                    22 / 80 / 443
[Parrot]  [Debian]                    │
 :11        :131              [Switch segmentado]
         21·22·80·631         /              \
                          [Parrot]        [Debian]
                           VLAN lab     22·443 only
```

---

## 🎤 Presentación Ejecutiva

> 📄 **Documento:** [`docs/presentacion/Presentacion_Ejecutiva_Gerencia.pptx`](./docs/presentacion/)

10 slides para gerencia no técnica:
1. Portada
2. Resumen ejecutivo (KPIs: 5 vulns, 3 críticas, 100% remediadas, 4h)
3. Hallazgos Fase 1 — forense
4. Cadena de ataque WordPress — Fase 2
5. Impacto en triada CIA
6. Acciones correctivas ejecutadas (9 acciones)
7. Plan NIST + controles ISO 27001
8. Recomendaciones (3 horizontes temporales)
9. **Controles ISO implementados 22/05/2026** ← nueva
10. Conclusión

---

## 🛠️ Herramientas Utilizadas

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| Nmap | 7.95 | Reconocimiento y escaneo de puertos |
| WPScan | 3.8.28 | Enumeración y auditoría WordPress |
| Parrot OS | Latest | Sistema operativo atacante |
| Debian GNU/Linux | 12 Bookworm | Sistema objetivo |
| MariaDB | 10.11 | Base de datos WordPress |
| Apache | 2.4.67 | Servidor web |
| UFW | — | Firewall implementado |
| OpenSSL | — | Certificado SSL RSA 2048 |
| Packet Tracer | 8.x | Diagramas de red |

---

## 📚 Metodologías y Marcos

- **[NIST SP 800-61 Rev. 2](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)** — Computer Security Incident Handling Guide
- **[ISO/IEC 27001:2022](https://www.iso.org/standard/82875.html)** — Information Security Management Systems
- **[PTES](http://www.pentest-standard.org/)** — Penetration Testing Execution Standard
- **[OWASP Top 10:2021](https://owasp.org/Top10/)** — Web Application Security Risks
- **[CIS Controls v8](https://www.cisecurity.org/controls/)** — Center for Internet Security
- **[ENS](https://www.boe.es/eli/es/rd/2022/05/03/311)** — Esquema Nacional de Seguridad (España)

---

## 👤 Autor

<div align="center">

**Bryan Calderón**
Ingeniero en Redes y Telecomunicaciones
Bootcamp de Ciberseguridad — 4Geeks Academy · 2026

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/tu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/tu-usuario)

</div>

---

<div align="center">

*Proyecto desarrollado con fines educativos en entorno de laboratorio controlado.*
*Todo el pentesting se realizó en sistemas propios con autorización explícita.*

**4Geeks Academy · Bootcamp de Ciberseguridad · 22 de mayo de 2026**

</div>
