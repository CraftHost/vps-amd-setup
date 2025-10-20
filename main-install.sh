#!/bin/bash

echo "======================================="
echo "🚀 VPS AMD Custom Setup"
echo "======================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status
print_status() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root: sudo ./main-install.sh"
    exit 1
fi

# Update system
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install basic tools
print_status "Installing essential tools..."
apt install -y curl wget git nano htop net-tools ufw fail2ban

# Setup Firewall
print_status "Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Install ClamAV Antivirus
print_status "Installing antivirus..."
apt install -y clamav clamav-daemon
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam
systemctl enable clamav-daemon

# Configure fail2ban for Anti-DDoS
print_status "Configuring fail2ban (Anti-DDoS)..."
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

[sshd-ddos]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 5
findtime = 300
bantime = 7200
EOF

systemctl enable fail2ban
systemctl start fail2ban

# Setup monitoring tools
print_status "Installing monitoring tools..."
apt install -y sysstat

# Create system monitor script
print_status "Creating monitoring scripts..."
cat > /usr/local/bin/system-monitor.sh << 'EOF'
#!/bin/bash
echo "=== System Status ==="
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
echo "Memory: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
echo "Disk: $(df -h / | awk 'NR==2{print $5}')"
echo "Uptime: $(uptime -p)"
EOF

chmod +x /usr/local/bin/system-monitor.sh

# Create auto-recovery script
print_status "Setting up auto-recovery..."
cat > /usr/local/bin/auto-recovery.sh << 'EOF'
#!/bin/bash
SERVICES=("ssh" "fail2ban" "clamav-daemon")

for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet $service; then
        echo "$(date): Service $service is down, restarting..." >> /var/log/auto-recovery.log
        systemctl restart $service
    fi
done
EOF

chmod +x /usr/local/bin/auto-recovery.sh

# Add to crontab for auto-recovery every 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/auto-recovery.sh") | crontab -

# Security hardening
print_status "Applying security settings..."
# Disable root SSH login
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Install automatic updates
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

print_status "Setup completed successfully!"
echo ""
echo "======================================="
echo "🎉 VPS AMD Custom Setup Complete!"
echo "======================================="
echo "✅ Firewall configured"
echo "✅ Antivirus installed"
echo "✅ Anti-DDoS protection active"
echo "✅ Auto-recovery system enabled"
echo "✅ Security hardening applied"
echo ""
echo "Next steps:"
echo "1. Check status: systemctl status fail2ban"
echo "2. Test firewall: ufw status"
echo "3. Monitor system: /usr/local/bin/system-monitor.sh"
echo "======================================="
