```bash
#!/bin/bash
# Script untuk update system manual

echo "🔄 Updating VPS System..."
apt update && apt upgrade -y
freshclam
fail2ban-client status
echo "✅ System updated!"
