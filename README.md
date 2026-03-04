# Ollama Secure Setup — macOS

Setup seguro de Ollama en macOS para uso local, como base para consultoría AI en PyMEs argentinas.

## Capas de seguridad implementadas

| Capa | Descripción |
|------|-------------|
| Firewall macOS | Bloqueando conexiones no esenciales |
| FileVault | Cifrado de disco activo |
| Variables de entorno | Ollama solo escucha en `127.0.0.1:11434` |
| Reglas pf | Puerto 11434 bloqueado externamente en todas las interfaces |
| SSH/SMB | Desactivados |
| Nginx proxy | SSL autofirmado + auth básica + rate limiting en `127.0.0.1:8443` |
| Open WebUI | Interfaz gráfica solo en `127.0.0.1:3000`, registro cerrado |
| Script de monitoreo | Verificación automática cada hora via cron |

## Archivos

- `setup-pf-ollama.sh` — Configura las reglas de pf (packet filter). Ejecutar con `sudo`.
- `start-ollama-webui.sh` — Inicia Ollama + Open WebUI.
- `ollama-security-check.sh` — Script de monitoreo de seguridad (corre cada hora).
- `nginx-ollama.conf` — Configuración de Nginx como reverse proxy.

## Uso

### Iniciar el sistema
```bash
~/start-ollama-webui.sh
```
Abre automáticamente `http://127.0.0.1:3000` en el navegador.

### Configurar reglas pf (primera vez o tras reinicio)
```bash
sudo zsh ~/setup-pf-ollama.sh
```

### Ver log de seguridad
```bash
cat ~/ollama-security.log
```

## Modelos instalados

- `llama3.2:3b` — Meta Llama 3.2, 2GB, soporte oficial de español

## Requisitos

- macOS Tahoe (macOS 26)
- Ollama: `/Applications/Ollama.app`
- Nginx: instalado via Homebrew
- Open WebUI: instalado via pip en conda env `openwebui`
- Python 3.11 (Anaconda)

## Notas de seguridad

- Las credenciales de Nginx están en `~/ollama-credentials.txt` (no incluido en el repo)
- Los certificados SSL están en `/opt/homebrew/etc/nginx/ssl/` (no incluidos en el repo)
- El archivo `.htpasswd` está en `/opt/homebrew/etc/nginx/.htpasswd` (no incluido en el repo)
