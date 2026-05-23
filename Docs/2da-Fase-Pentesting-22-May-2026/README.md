# 📁 Fase 2 — Informe de Pentesting WordPress

## Documento

| Archivo | Descripción |
|---------|-------------|
| `Informe_Pentesting_WordPress_Fase2.docx` | Informe de pentesting completo — 10 secciones |

## Contenido del informe

- Resumen ejecutivo (RCE confirmado < 20 minutos)
- Alcance y entorno (Parrot OS 192.168.1.11 → Debian 192.168.1.131)
- Metodología PTES — 7 fases documentadas
- Reconocimiento: Nmap 7.95 + WPScan 3.8.28
- Cadena de explotación completa en 5 pasos
- Tabla de 5 vulnerabilidades con CWE
- Remediación aplicada y verificada
- Conclusiones y referencias

## Cadena de ataque

```
Nmap → WPScan → wp-config.php → MariaDB → wp-admin → RCE (www-data)
```

## Remediación verificada

| Acción | Verificación |
|--------|-------------|
| Plugin shell.php eliminado | curl → 404 ✅ |
| XML-RPC bloqueado | curl → 404 ✅ |
| Contraseña BD fortalecida | grep DB_PASSWORD ✅ |
| DISALLOW_FILE_MODS activo | wp-config.php ✅ |
| Apache funcionando | curl → 200 ✅ |

---
*Bryan Calderón · 4Geeks Academy · 22 de mayo de 2026*
