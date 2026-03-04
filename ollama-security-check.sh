#!/bin/zsh
# Script de monitoreo de seguridad para Ollama
# Se ejecuta automáticamente cada hora via cron

LOG="/Users/guidoperassolopuhl/ollama-security.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
ISSUES=0

echo "\n========================================" >> $LOG
echo "[$DATE] Chequeo de seguridad" >> $LOG
echo "========================================" >> $LOG

# 1. Ollama escucha solo en localhost
echo "\n[1] Puerto 11434:" >> $LOG
LISTENING=$(lsof -i :11434 2>/dev/null | grep LISTEN)
if [ -z "$LISTENING" ]; then
    echo "    ℹ️  Ollama no está corriendo" >> $LOG
elif echo "$LISTENING" | grep -qE "127\.0\.0\.1|localhost"; then
    echo "    ✅ Ollama escucha solo en localhost" >> $LOG
else
    echo "    ⚠️  ALERTA: Ollama podría estar expuesto externamente" >> $LOG
    ISSUES=$((ISSUES + 1))
fi

# 2. Firewall activo
echo "\n[2] Firewall:" >> $LOG
FW=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
if echo "$FW" | grep -q "enabled\|State = 1\|State = 2"; then
    echo "    ✅ Firewall activo" >> $LOG
else
    echo "    ⚠️  ALERTA: Firewall desactivado" >> $LOG
    ISSUES=$((ISSUES + 1))
fi

# 3. FileVault activo
echo "\n[3] FileVault:" >> $LOG
FV=$(fdesetup status 2>/dev/null)
if echo "$FV" | grep -q "On"; then
    echo "    ✅ FileVault activo" >> $LOG
else
    echo "    ⚠️  ALERTA: FileVault desactivado" >> $LOG
    ISSUES=$((ISSUES + 1))
fi

# 4. Modelos instalados
echo "\n[4] Modelos Ollama:" >> $LOG
if curl -s http://127.0.0.1:11434 > /dev/null 2>&1; then
    MODELS=$(/Applications/Ollama.app/Contents/Resources/ollama list 2>/dev/null | tail -n +2)
    if [ -n "$MODELS" ]; then
        echo "    ✅ Modelos instalados:" >> $LOG
        echo "$MODELS" | while read line; do echo "       - $line" >> $LOG; done
    else
        echo "    ℹ️  Sin modelos instalados" >> $LOG
    fi
else
    echo "    ℹ️  Ollama no está corriendo" >> $LOG
fi

# 5. Conexiones activas al puerto 11434
echo "\n[5] Conexiones activas a Ollama:" >> $LOG
CONNS=$(lsof -i :11434 2>/dev/null | grep ESTABLISHED | wc -l | tr -d ' ')
echo "    ℹ️  $CONNS conexión(es) activa(s)" >> $LOG

# 6. Nginx corriendo
echo "\n[6] Nginx proxy:" >> $LOG
if pgrep -x nginx > /dev/null 2>&1; then
    echo "    ✅ Nginx corriendo" >> $LOG
else
    echo "    ⚠️  Nginx no está corriendo" >> $LOG
fi

# Resumen
echo "\n[Resumen] Problemas encontrados: $ISSUES" >> $LOG
if [ $ISSUES -eq 0 ]; then
    echo "✅ Todo OK" >> $LOG
else
    echo "⚠️  Revisar el log: $LOG" >> $LOG
fi
