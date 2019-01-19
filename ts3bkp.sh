#!/bin/bash
DIRNAME="~/bkp_ts3"
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YL='\033[1;33m'
TODAY="$( date +"%Y%m%d" )" #get current date.

USR="ts3" #TS3 user, user that is running ts3 server
PATH="/home/$USR/ts3-3.5.1" #path to the ts3 folder.
PATHBKP="/home/$USR/bkp_ts3" #path to the folder where is going to keep the bkps in local server

BKPUSR="bkp" #user to sftp the bkp to (other server)
BKPDIRSRV="/home/$BKPUSR/ts3" #path to sftp bkp to, where it will store the bkp (otherserver)
IPSFTP="localhost" #your bkp server, could be something like: example.com or 1.1.1.1
PORTSFTP="22" #this is the port where your server is running sftp(SSH)

if [ ! -d "$DIRNAME" ]; then
    echo -e "${YL}Creating bkp folder in: ~/bkp_ts3${NC}"
    /bin/su $USR -c "/bin/mkdir -p $PATHBKP"
fi

if /usr/bin/pgrep -x "ts3server" > /dev/null
then
    echo -e "${YL}Stoping all servers...${NC}"
    /bin/su $USR -c "$PATH/ts3server_startscript.sh stop"
fi
echo -e "${YL}Starting buckup process...${NC}"
/bin/su $USR -c "/usr/bin/zip -r /home/$USR/ts3_bkp_$TODAY.zip $PATH &>/dev/null"

echo -e "${GREEN}Backup complete!!!!${NC}"

/bin/mv /home/$USR/ts3_bkp_$TODAY.zip $PATHBKP

echo -e "${YL}Starting all servers...${NC}"
/bin/su $USR -c "$PATH/ts3server_startscript.sh start"

echo ""

echo -e "${YL}Starting to transfer backup to server...${NC}"
/usr/bin/sftp -i /home/$USR/.ssh/id_rsa -P $PORTSFTP $BKPUSR@$IPSFTP << !
lcd $PATHBKP
cd $BKPDIRSRV
put ts3_bkp_$TODAY.zip
bye
!

