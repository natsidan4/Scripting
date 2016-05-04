# Rsync platform for failover
0,30 * * * * /mnt/nfs/web/crm/scripts/cron/conditional-run prod "cd /mnt/nfs/web/crm && bash scripts/platform/common/rsync.sh /mnt/nfs/web/ >> /mnt/nfs/web/logs/rsync-web-`date "+\%Y-\%m-\%d"`.out 2>&1" > /dev/null 2>&1
0 * * * * /mnt/nfs/web/crm/scripts/cron/conditional-run prod "cd /mnt/nfs/web/crm && bash scripts/platform/common/rsync.sh  /mnt/nfs/docs/ >> /mnt/nfs/web/logs/rsync-web-`date "+\%Y-\%m-\%d"`.out 2>&1" > /dev/null 2>&1

