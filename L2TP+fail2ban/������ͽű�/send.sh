#!/bin/bash
PPP_FILE=/etc/ppp/chap-secrets
XL2TPD_FILE=/var/log/xl2tpd.log
SENDINFO=/data/vpn/weixin-info
CRON_FILE=/var/spool/cron/root
RANDOM_SECRETE()
{
tr -dc _A-Z-a-z-0-9 < /dev/urandom | head -c${1:-10}
}
EXIT_SECRETE()
{
tr -dc _A-Z-a-z-0-9 < /dev/urandom | head -c${1:-32}
}
tail -fn0 $XL2TPD_FILE|while read line
do
if [[ $line =~ "failed CHAP authentication" ]];then
ERR_NAME=$(echo "$line"|grep -Po '(?<=Peer )[^ ]+(?= failed CHAP authentication)')
SECRETE=`awk '$1~/'${ERR_NAME}'/{print $3}' $PPP_FILE`
sed -i "/$ERR_NAME/s/$SECRETE/`RANDOM_SECRETE`/g" $PPP_FILE
NEW_SECRETE=`awk '$1~/'${ERR_NAME}'/{print $3}' $PPP_FILE`
OPEN=`awk '$1~/'${ERR_NAME}'/{print $2}' $SENDINFO`
SN=`awk '$1~/'${ERR_NAME}'/{print $3}' $SENDINFO`
curl http://hd.51wan.com/active_all_wxsendmsgByMoban_0.html?openid=$OPEN\&message=$NEW_SECRETE\&sign=$SN 1>/mnt/curl.log 2>&1
sleep 5
MINUTE=`date +%M`
TIME_CHUO=`date +%s`
CUO_MINUTE=`expr $TIME_CHUO + 120`
HOUR=`date -d @$CUO_MINUTE +%H`
EX_MINUTE=`expr $MINUTE + 2`
CUO_EX_MINUTE=`date -d @$CUO_MINUTE +%M`
if [[ $MINUTE == "0"[0-9] ]];then
MINUTE=`echo $MINUTE | cut -b 2`
fi
if [[ $EX_MINUTE == "0"[0-9] ]];then
EX_MINUTE=`echo $EX_MINUTE | cut -b 2`
fi
sed -e 's/hour/'$HOUR'/g' -e 's/minute/'$TIME_CHUO'/g' -e 's/extime/'$CUO_MINUTE'/g' -e 's/ER_NAME/'$ERR_NAME'/g' -e 's/ER_SECRETE/'$NEW_SECRETE'/g' /data/vpn/task.sh > /data/vpn_user/$ERR_NAME"_task.sh"
chmod +x /data/vpn_user/$ERR_NAME"_task.sh"
cron_grep=`awk -F "/" '$4~/'$ERR_NAME'/{print $0}' $CRON_FILE`
if [[ -n $cron_grep ]];then
cron_value=`awk '$0~/'$ERR_NAME'/{print $1}' $CRON_FILE`
#cron_hour=`awk '$0~/'$ERR_NAME'/{print $2}' $CRON_FILE`
sed -i '/'$ERR_NAME'/s/'$cron_value'/'$CUO_EX_MINUTE'/g' $CRON_FILE
#sed -i '/'$ERR_NAME'/s/'$cron_hour'/'$HOUR'/g' $CRON_FILE
else
echo $CUO_EX_MINUTE "*" "*" "*" "*" /data/vpn_user/$ERR_NAME"_task.sh 1>/mnt/cron.log 2>&1" >> $CRON_FILE
fi
fi
if [[ $line =~ "Stop_Time" ]];then
STOP_NAME=$(echo "$line"|grep -Po '(?<=username: )[^ ]+(?= End connection)')
STOP_SECRETE=`awk '$1~/'${STOP_NAME}'/{print $3}' $PPP_FILE`
sed -i "/$STOP_NAME/s/$STOP_SECRETE/`EXIT_SECRETE`/g" $PPP_FILE
fi
done
