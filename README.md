# Scripts for monitoring infra

## DNS Monitoring
### Setup
```bash
export MACHINE_NAME="Mumbai Guard"
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/123/w3bh00k_t0k3n"
./init-dns-check.sh "bungee.exchange"
```

### Start
Start cron for `check-dns.sh "bungee.exchange"`

## Website Monitoring
### Setup
```bash
export MACHINE_NAME="Mumbai Guard"
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/123/w3bh00k_t0k3n"
./init-website-check.sh "bungee.exchange"
```

### Start
Start cron for `check-website.sh "bungee.exchange"`
