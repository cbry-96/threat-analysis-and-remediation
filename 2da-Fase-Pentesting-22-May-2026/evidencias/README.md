# 📸 Evidencias — Fase 2 Pentesting

| Archivo | Descripción |
|---------|-------------|
| `01-nmap-scan.png` | Resultado del escaneo Nmap mostrando puertos 22 y 80 + `/wp-admin/` en robots.txt |
| `02-wpscan-enum.png` | WPScan encontrando usuario `wordpress-user` via WP JSON API |
| `03-wpconfig-credenciales.png` | `DB_PASSWORD='123456'` en texto plano en wp-config.php |
| `04-wp-admin-acceso.png` | Dashboard de WordPress con "Howdy, wordpress-user" |
| `05-rce-whoami.png` | `curl .../shell.php?cmd=whoami` devolviendo `www-data` |
| `06-remediacion.png` | Plugin eliminado (404) + Apache funcionando (200) |

---

*Bryan Calderón · 4Geeks Academy · 2026*
