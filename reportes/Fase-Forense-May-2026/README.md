# 📁 Fase 1 — Informe de Incidente de Seguridad

## Documento

| Archivo | Descripción |
|---------|-------------|
| `Informe_Incidente_Seguridad_Fase1.docx` | Informe forense completo — 9 secciones |

## Contenido del informe

- Resumen ejecutivo con tabla de indicadores
- Alcance y entorno analizado (Debian 192.168.1.131)
- Metodología NIST SP 800-61 Rev. 2 aplicada
- 5 hallazgos con evidencia real de comandos ejecutados
- Acciones correctivas ejecutadas y verificadas
- Análisis de impacto en triada CIA
- Recomendaciones en 3 horizontes temporales
- Conclusiones y referencias normativas

## Hallazgos principales

| Hallazgo | Severidad | Estado |
|----------|-----------|--------|
| FTP expuesto — Puerto 21 vsftpd | 🔴 CRÍTICO | ✅ Remediado |
| Apache HTTP sin cifrado — Puerto 80 | 🟠 ALTO | ✅ Remediado |
| SSH sin hardening — Puerto 22 | 🟡 MEDIO | ✅ Remediado |
| CUPS innecesario — Puerto 631 | 🟡 MEDIO | ✅ Remediado |
| Logs con evidencia de compromiso | 🟠 ALTO | ✅ Documentado |

---
*Bryan Calderón · 4Geeks Academy · 22 de mayo de 2026*
