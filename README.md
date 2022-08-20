# Security monitoring scripts

This repo contains scripts to monitor Socket systems and detect if they can be accessed as intended. Started with scripts to monitor website content hashes and DNS resolutions. It is recomended to setup a cron for these sctipts in multiple regions. Each cron will get data and store in `/tmp/` folder. Values are then compared when cron is triggered next time. Notifications are sent on discord when a change is detected for these. More script will be added with need.

### Setup crons

Open an editor to edit cron tasks.

```bash
crontab -e
```

### DNS Monitoring Cron

```bash!
* * * * * MACHINE_NAME="<discord_bot_name>" DISCORD_WEBHOOK="<discord_webhook_url>" <path_of_check-dns.sh> "<domain_name>" >/dev/null 2>&1
```

### Website Monitoring Cron

```bash!
* * * * * MACHINE_NAME="<discord_bot_name>" DISCORD_WEBHOOK="<discord_webhook_url>" <path_of_check-website.sh> "<domain_name>" >/dev/null 2>&1
```
