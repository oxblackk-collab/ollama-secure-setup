#!/bin/zsh
# Script de configuración de reglas pf para Ollama
# Ejecutar con: sudo zsh ~/setup-pf-ollama.sh

set -e

echo "=== Configurando reglas pf para Ollama ==="

# 1. Detectar interfaces de red activas
echo "\n[1/4] Detectando interfaces de red..."
INTERFACES=$(networksetup -listallhardwareports | grep "Device:" | awk '{print $2}')
echo "Interfaces encontradas: $INTERFACES"

# 2. Crear archivo anchor
echo "\n[2/4] Creando /etc/pf.anchors/ollama..."
cat > /etc/pf.anchors/ollama << 'EOF'
# Bloquear acceso externo al puerto 11434 (Ollama)
block in quick on en0 proto tcp from any to any port 11434
block in quick on en1 proto tcp from any to any port 11434
block in quick on en2 proto tcp from any to any port 11434
# Permitir solo localhost
pass in quick on lo0 proto tcp from 127.0.0.1 to 127.0.0.1 port 11434
EOF
echo "Archivo creado."

# 3. Agregar anchor a pf.conf si no existe
echo "\n[3/4] Actualizando /etc/pf.conf..."
if ! grep -q "ollama" /etc/pf.conf; then
    cp /etc/pf.conf /etc/pf.conf.backup.$(date +%Y%m%d%H%M%S)
    cat >> /etc/pf.conf << 'EOF'

# Ollama security anchor
anchor "ollama"
load anchor "ollama" from "/etc/pf.anchors/ollama"
EOF
    echo "Anchor agregado a pf.conf (backup creado)."
else
    echo "Anchor de ollama ya existe en pf.conf, sin cambios."
fi

# 4. Cargar reglas
echo "\n[4/4] Cargando reglas pf..."
pfctl -E -f /etc/pf.conf 2>&1 || true
pfctl -a ollama -f /etc/pf.anchors/ollama 2>&1

# Verificación
echo "\n=== Verificación ==="
echo "Estado de pf:"
pfctl -s info | head -3
echo "\nReglas del anchor ollama:"
pfctl -a ollama -s rules 2>/dev/null || echo "(sin reglas cargadas aún - normal en primera ejecución)"

echo "\n✅ Configuración de pf completada."
