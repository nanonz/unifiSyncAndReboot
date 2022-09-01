#!/bin/sh

IP=192.168.1.
START_IP=10
END_IP=240
IPT=192.168.1.250
LOG=unifi.log
DATE=$(date +%Y-%m-%d" "%R:%S)
SEQ=$(seq $START_IP $END_IP)


SYNCANDREBOOT () {
for i in $ii
do
 echo "$DATE Sync date & time to UniFi access point at $IP$i Start..." >> $LOG
 ssh -o "StrictHostKeyChecking no" admins@$IP$i ntpclient -t -s -h $IPT -i 2 -c 2 > /dev/null 2>&1
 echo "$DATE Sync date & time to UniFi access point at $IP$i Successfully..." >> $LOG
 #sleep 1 echo "Reboot UniFi access point at $IP$i ..." ssh -o "StrictHostKeyChecking no" admins@$IP$i reboot
done
}

CHKSSH () {
echo "$DATE Start on script........" >> $LOG
for ii in $SEQ
do
 V1=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 admins@$IP$ii 'exit 0')
 V=$(echo $?)
  if [ $V -eq 0 ];then
   echo "$DATE IP $IP$ii : connect to unifi AP is OK." >> $LOG
   SYNCANDREBOOT
  else
   echo "$DATE IP $IP$ii : connect to unifi AP is is not OK!" >> $LOG
  fi
done
echo "$DATE End on script........" >> $LOG
}

CHKPINGS () {
echo "$DATE Start function checkPing on script........" >> $LOG
for ii in $SEQ
do
 P=$(ping -l 1 -c 3 $IP$ii | grep 'packets transmitted' | awk '{print $4}')
  if [ $P -eq 3 ];then
   echo "$DATE IP $IP$ii : packets transmitted = 3 packets received = $P is OK." >> $LOG
  else
   echo "$DATE IP $IP$ii : packets transmitted = 3 packets received = $P is not OK!" >> $LOG
  fi
done
echo "$DATE End function checkPing on script........" >> $LOG
}

CHKSSH
#CHKPINGS
