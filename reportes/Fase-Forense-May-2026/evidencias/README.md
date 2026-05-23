 📸 Evidencias del Proyecto

Esta carpeta contiene las capturas de pantalla tomadas durante el análisis.

## Fase 1 — Forense

| Archivo | Descripción |
|---------|-------------|
| `01-usuarios-sistema.png` | Salida de `cut -d: -f1 /etc/passwd` mostrando todos los usuarios |
| `02-puertos-abiertos.png` | Salida de `ss -tulnp` mostrando puertos 21, 22, 80, 631 activos |
| `03-logs-auth.png` | Logs de `journalctl` con errores de autenticación |
| `04-remediacion-ftp.png` | `systemctl stop vsftpd` — servicio detenido y deshabilitado |
| `05-ssh-hardening.png` | `/etc/ssh/sshd_config` con `PermitRootLogin no` aplicado |
| `06-verificacion-cierre.png` | `ss -tulnp | grep :21` — sin salida, puerto cerrado |
---

*Bryan Calderón · 4Geeks Academy · 2026*
