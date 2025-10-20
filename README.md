# 🛡️ VPS AMD Custom Setup

Repository untuk setup otomatis VPS AMD dengan perlindungan keamanan lengkap.

## ✨ Fitur

- ✅ **Anti-DDoS** dengan fail2ban
- ✅ **Antivirus** dengan ClamAV
- ✅ **Firewall** dengan UFW
- ✅ **Auto-recovery** system
- ✅ **Security hardening**
- ✅ **Monitoring** tools

## 🚀 Cara Menggunakan

### 1. Setup GitHub Secrets

Di repository Settings → Secrets → Actions, tambahkan:

- `VPS_HOST` = IP address VPS Anda
- `VPS_USER` = username VPS (biasanya root)
- `VPS_SSH_KEY` = private SSH key Anda

### 2. Deploy Otomatis

- Push ke branch `main` → auto deploy
- Atau manual di GitHub Actions → Run workflow

## 📊 Setelah Install

Cek status sistem:
```bash
systemctl status fail2ban
ufw status
systemctl status clamav-daemon
/usr/local/bin/system-monitor.sh
