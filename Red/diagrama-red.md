# 🌐 Diagrama de Red — Topología del Laboratorio

**Herramienta:** Cisco Packet Tracer  
**Archivo:** `Diagrama_Red_BryanCalderon.pkt` *(adjuntar archivo .pkt aquí)*

---

## Topología ANTES — Red Comprometida

```
                    ┌─────────────┐
                    │   Internet  │
                    └──────┬──────┘
                           │  (sin firewall)
                    ┌──────┴──────┐
                    │   Switch    │  Red: 192.168.1.0/24
                    │ sin segmen. │  Sin VLANs
                    └──┬──────┬───┘
                       │      │
            ┌──────────┘      └──────────────┐
            │                                │
   ┌────────┴────────┐             ┌─────────┴────────┐
   │   Parrot OS     │──── ataca ─▶│  Debian (víctima)│
   │  192.168.1.11   │             │  192.168.1.131   │
   └─────────────────┘             │                  │
                                   │ 21  FTP ❌        │
                                   │ 22  SSH ⚠️        │
                                   │ 80  HTTP ⚠️       │
                                   │ 631 CUPS ❌        │
                                   └──────────────────┘
```

**Problemas identificados:**
- ❌ Sin firewall entre Internet y red interna
- ❌ Parrot OS en la misma VLAN que el servidor
- ❌ Puerto 21 FTP — credenciales en texto plano
- ❌ Puerto 80 HTTP — sin cifrado
- ❌ Puerto 631 CUPS — servicio innecesario

---

## Topología DESPUÉS — Red Segura

```
                    ┌─────────────┐
                    │   Internet  │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │  Firewall   │  UFW activo
                    │    UFW      │  Allow: 22, 80, 443
                    │ 192.168.1.1 │  Deny: todo lo demás
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │   Switch    │  VLANs segmentadas
                    │ segmentado  │  admin / lab / DMZ
                    └──┬──────┬───┘
                       │      │
               VLAN lab│      │VLAN DMZ
            ┌──────────┘      └──────────────┐
            │                                │
   ┌────────┴────────┐             ┌─────────┴────────┐
   │   Parrot OS     │             │  Debian (seguro) │
   │  192.168.1.11   │             │  192.168.1.131   │
   │   (lab)         │             │                  │
   └─────────────────┘             │ 22  SSH ✅        │
                                   │ 443 HTTPS ✅      │
                                   │ UFW activo ✅     │
                                   │ Backup diario ✅  │
                                   └──────────────────┘
```

**Cambios implementados:**
- ✅ Firewall UFW: `ufw default deny incoming`
- ✅ Solo puertos 22, 80, 443 permitidos
- ✅ Puerto 21 (FTP): deshabilitado
- ✅ Puerto 631 (CUPS): deshabilitado
- ✅ XML-RPC bloqueado via `.htaccess`
- ✅ SSH hardening: `PermitRootLogin no` / `MaxAuthTries 3`
- ✅ HTTPS TLS con certificado SSL RSA 2048
- ✅ Backup diario automatizado

---

## Dispositivos (Packet Tracer)

| Dispositivo | Modelo PT | IP | Rol |
|-------------|-----------|-----|-----|
| Cloud | Cloud-PT | — | Internet |
| Firewall | Router 1841 | 192.168.1.1 | UFW / Control de acceso |
| Switch | 2960-24TT | — | Conmutación / VLANs |
| Parrot OS | PC-PT | 192.168.1.11 | Atacante (lab) |
| Debian | Server-PT | 192.168.1.131 | Servidor objetivo |

---
*Bryan Calderón · 4Geeks Academy · 22 de mayo de 2026*
