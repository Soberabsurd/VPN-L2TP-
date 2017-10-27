#!/bin/bash 
SYSTIME=`date +"%Y-%m-%d--%H:%M"`
JX=`ps -elf | grep send`
PID_SEND=`pgrep send`
if [[ $PID_SEND == "" ]];then
echo $SYSTIME "send script don't" | mailx -s "send.sh faild" wangdong@51wan.com
echo $SYSTIME "send.sh faild" >> /var/log/send.log
/root/send.sh &
sleep 5
pgrep send > /root/send.pid
echo $SYSTIME "send already start" | mailx -s "send.sh start" wangdong@51wan.com
echo $SYSTIME "send.sh start" >> /var/log/send.log
exit
fi
for x in `cat /root/send.pid`;
do
if [[ $PID_SEND =~ $x ]];then
echo 
else
kill $PID_SEND
echo $SYSTIME "kill send.sh" | mailx -s "send.sh kill" wangdong@51wan.com
echo $SYSTIME "kill send.sh" >> /var/log/send.log
/root/send.sh &
sleep 5
pgrep send > "/root/send.pid"
echo $SYSTIME "kill send.sh -- start" | mailx -s "send.sh kill--start" wangdong@51wan.com
echo $SYSTIME "kill send.sh -- start" >> /var/log/send.log
exit
fi
done
