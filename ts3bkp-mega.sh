#!/bin/bash
DIRNAME="~/bkp_ts3"
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YL='\033[1;33m'
TODAY="$( date +"%Y%m%d" )"  #get current date.

USR="ts3"                    #TS3 user, user that is running ts3 server
PATH="/home/$USR/ts3-3.5.1"  #path to the ts3 folder.
PATHBKP="/home/$USR/bkp_ts3" #path to the folder where is going to keep the bkps in local server

PATHMEGA="/Root/your/bkp/folder" #path in mega, must start with /Root/your/folder...
EMAIL="your@email.com"           #email for your account in mega
PASSWD="<PASSWORD>"              #your password

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
/bin/su $USR -c "/usr/bin/zip -r /home/$USR/ts3_bkp_$TODAY.zip $PATH"

echo -e "${GREEN}Backup complete!!!!${NC}"

/bin/mv /home/$USR/ts3_bkp_$TODAY.zip $PATHBKP

echo -e "${YL}Starting all servers...${NC}"
/bin/su $USR -c "$PATH/ts3server_startscript.sh start"

echo ""

echo -e "${YL}Starting to transfer backup to MEGA...${NC}"

/usr/bin/megaput $PATHBKP/ts3_bkp_$TODAY.zip --reload --username=$EMAIL --password=$PASSWD --path=$PATHMEGA --disable-previews

echo ""

echo -e "${GREEN}Done :D${NC}"
