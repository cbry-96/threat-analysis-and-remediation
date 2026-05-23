#!/bin/bash
# ============================================================
# SCRIPT: 02_A824_https_ssl.sh
# CONTROL ISO 27001: A.8.24 - Uso de criptografía
# PROYECTO: SGSI - 4Geeks Academy - Laboratorio Debian
# AUTOR: Bryan Calderón | Bootcamp Ciberseguridad 2026
# VERSIÓN: 1.0
# DESCRIPCIÓN: Habilita HTTPS en Apache usando certificado
#   - OPCIÓN A (lab interno): Certificado autofirmado OpenSSL
#   - OPCIÓN B (producción): Let's Encrypt / Certbot
#   Para entorno 192.168.x.x usamos OPCIÓN A (no hay dominio público)
# TIEMPO ESTIMADO: ~15 minutos
# ============================================================
# USO:  sudo bash 02_A824_https_ssl.sh
# ============================================================

set -euo pipefail

LOG_FILE="/var/log/sgsi_https_setup.log"
FECHA=$(date '+%Y-%m-%d %H:%M:%S')
DOMAIN="laboratorio.4geeks.local"
IP_SERVIDOR="192.168.1.131"
CERT_DIR="/etc/ssl/sgsi-lab"
APACHE_SSL_CONF="/etc/apache2/sites-available/wordpress-ssl.conf"
APACHE_HTTP_CONF="/etc/apache2/sites-available/000-default.conf"

# ── Colores ───────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log() { echo -e "${GREEN}[✔] $1${NC}"; echo "[$FECHA] [OK] $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[⚠] $1${NC}"; echo "[$FECHA] [WARN] $1" >> "$LOG_FILE"; }
err() { echo -e "${RED}[✘] $1${NC}"; echo "[$FECHA] [ERROR] $1" >> "$LOG_FILE"; exit 1; }
section() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

[[ "$EUID" -ne 0 ]] && err "Ejecutar como root: sudo bash $0"

section "A.8.24 - CONFIGURACIÓN HTTPS / TLS EN APACHE"

# ── Paso 1: Verificar Apache instalado ────────────────────
section "PASO 1 / 6 - Verificar Apache"
command -v apache2 &>/dev/null || err "Apache2 no está instalado. Instálalo primero: apt install apache2"
log "Apache2 detectado: $(apache2 -v 2>&1 | head -1)"

# ── Paso 2: Instalar openssl (suele estar presente) ────────
section "PASO 2 / 6 - Instalar dependencias SSL"
apt-get install -y openssl
a2enmod ssl
a2enmod headers
a2enmod rewrite
log "Módulos SSL, headers y rewrite habilitados en Apache"

# ── Paso 3: Generar certificado autofirmado ────────────────
section "PASO 3 / 6 - Generar certificado SSL autofirmado (válido 3 años)"
mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 1095 \
    -newkey rsa:2048 \
    -keyout "$CERT_DIR/sgsi-lab.key" \
    -out    "$CERT_DIR/sgsi-lab.crt" \
    -subj "/C=ES/ST=Laboratorio/L=4Geeks/O=4Geeks Academy/OU=Ciberseguridad/CN=$IP_SERVIDOR" \
    -addext "subjectAltName=IP:$IP_SERVIDOR,DNS:$DOMAIN" 2>/dev/null

chmod 600 "$CERT_DIR/sgsi-lab.key"
chmod 644 "$CERT_DIR/sgsi-lab.crt"
log "Certificado autofirmado generado en: $CERT_DIR/"
log "  → Clave privada: sgsi-lab.key (permisos 600)"
log "  → Certificado:  sgsi-lab.crt (válido 3 años, CN=$IP_SERVIDOR)"

# Verificar el certificado generado
openssl x509 -in "$CERT_DIR/sgsi-lab.crt" -noout -subject -dates

# ── Paso 4: Crear VirtualHost HTTPS ─────────────────────
section "PASO 4 / 6 - Crear VirtualHost HTTPS (:443)"

cat > "$APACHE_SSL_CONF" << 'APACHESSL'
<VirtualHost *:443>
    ServerName 192.168.1.131
    DocumentRoot /var/www/html

    # ── Certificado SSL ──────────────────────────────────
    SSLEngine on
    SSLCertificateFile      /etc/ssl/sgsi-lab/sgsi-lab.crt
    SSLCertificateKeyFile   /etc/ssl/sgsi-lab/sgsi-lab.key

    # ── Forzar TLS 1.2 y 1.3 (deshabilitar TLS 1.0/1.1) ─
    SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256
    SSLHonorCipherOrder     off
    SSLSessionTickets       off

    # ── Headers de seguridad ─────────────────────────────
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"

    # ── Ocultar versión de Apache ─────────────────────────
    ServerTokens Prod
    ServerSignature Off

    # ── WordPress: permitir .htaccess ────────────────────
    <Directory /var/www/html>
        AllowOverride All
        Options -Indexes
        Require all granted
    </Directory>

    # ── Logs ──────────────────────────────────────────────
    ErrorLog  ${APACHE_LOG_DIR}/error_ssl.log
    CustomLog ${APACHE_LOG_DIR}/access_ssl.log combined

</VirtualHost>
APACHESSL

log "VirtualHost HTTPS creado: $APACHE_SSL_CONF"

# ── Paso 5: Redirigir HTTP → HTTPS ──────────────────────
section "PASO 5 / 6 - Redirigir HTTP (80) a HTTPS (443)"

cat > "$APACHE_HTTP_CONF" << 'APACHEHTTP'
<VirtualHost *:80>
    ServerName 192.168.1.131
    DocumentRoot /var/www/html

    # Redirigir TODO el tráfico HTTP a HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Ocultar versión de Apache
    ServerTokens Prod
    ServerSignature Off

    ErrorLog  ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
APACHEHTTP

log "Redirección HTTP→HTTPS configurada en: $APACHE_HTTP_CONF"

# ── Paso 6: Activar sitio y reiniciar Apache ─────────────
section "PASO 6 / 6 - Activar configuración y reiniciar Apache"

a2ensite wordpress-ssl.conf
a2dissite default-ssl.conf 2>/dev/null || true  # Deshabilitar el default SSL si existe

# Verificar configuración antes de reiniciar
apache2ctl configtest && log "Sintaxis Apache: OK" || err "Error en la configuración de Apache. Revisa los logs."

systemctl restart apache2
log "Apache reiniciado correctamente con SSL habilitado"

# ── Verificación final ────────────────────────────────────
section "VERIFICACIÓN - Estado final HTTPS"
echo ""
echo "--- Módulos SSL activos ---"
apache2ctl -M 2>/dev/null | grep -E "ssl|rewrite|headers" || true

echo ""
echo "--- Verificación del certificado instalado ---"
openssl x509 -in "$CERT_DIR/sgsi-lab.crt" -noout -text | grep -E "Subject:|Not Before:|Not After :|Subject Alternative"

echo ""
echo "--- Test local de conectividad HTTPS ---"
if curl -sk --connect-timeout 5 https://127.0.0.1/ -o /dev/null -w "Código HTTP HTTPS: %{http_code}\n"; then
    log "HTTPS responde correctamente en localhost"
else
    warn "No se pudo verificar HTTPS localmente (puede ser normal en algunos labs)"
fi

echo ""
echo "============================================================"
echo " RESUMEN DE IMPLEMENTACIÓN - A.8.24 Uso de Criptografía"
echo "============================================================"
echo " Control ISO 27001: A.8.24"
echo " Estado anterior:   PENDIENTE"
echo " Estado actual:     IMPLEMENTADO"
echo " Certificado:       Autofirmado RSA-2048, válido 3 años"
echo " Protocolo:         TLS 1.2 + TLS 1.3 (TLS 1.0/1.1 DESACTIVADOS)"
echo " Puerto 443:        ACTIVO con SSL/TLS"
echo " Puerto 80:         Redirige automáticamente a HTTPS (301)"
echo " Ubicación cert:    $CERT_DIR/"
echo " Log del script:    $LOG_FILE"
echo " Fecha/Hora:        $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
warn "NOTA LAB: El certificado es autofirmado. El navegador mostrará advertencia."
warn "En producción, sustituir por Let's Encrypt: sudo apt install certbot python3-certbot-apache"
warn "Accede via: https://$IP_SERVIDOR (acepta excepción de seguridad en el lab)"

echo "[$FECHA] [FIN] Script A.8.24 completado exitosamente" >> "$LOG_FILE"
