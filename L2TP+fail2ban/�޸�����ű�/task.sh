#!/bin/bash -x
PPP_FILE=/etc/ppp/chap-secrets
XL2TPD_FILE=/var/log/xl2tpd.log
CRON_FILE=/var/spool/cron/root
EXIT_SECRETE()
{
tr -dc _A-Z-a-z-0-9 < /dev/urandom | head -c${1:-32}
}
for ((i=minute;i<=extime;i=i+60))
do
MIN=`date -d @$i +%M`
LOG_TIME=`awk '$3~/hour:'$MIN'/{print $0}' $XL2TPD_FILE`
START_NAME=$(echo "$LOG_TIME"|grep -Po '(?<=username: )[^ ]+(?= Start connection)')
if [[ $i -eq extime ]];then
sed -i "/ER_NAME/s/ER_SECRETE/`EXIT_SECRETE`/g" $PPP_FILE
sed -i '/ER_NAME/d' $CRON_FILE
exit
elif [[ -n $START_NAME ]];then
sed -i '/'$START_NAME'/d' $CRON_FILE
exit
else
continue
fi
done