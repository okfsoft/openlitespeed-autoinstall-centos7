#!/bin/bash

#CONFIG
PASSRESULTS='NULL'
GREEN='\033[0;32m'
SET='\033[0m'

#Random Password Generator
function GetRandomPassword {
    dd if=/dev/urandom bs=8 count=1 of=/tmp/randpasswdtmpfile >/dev/null 2>&1
    PASSRESULTS=`cat /tmp/randpasswdtmpfile`
    rm /tmp/randpasswdtmpfile
    local DATE=`date`
    PASSRESULTS=`echo "$PASSRESULTS$RANDOM$DATE" |  md5sum | base64 | head -c 32`
}
GetRandomPassword
ROOTSQLPWD=$PASSRESULTS
PMABLOWFISH=$PASSRESULTS
#

echo -e "${GREEN}-----> $ROOTSQLPWD ${SET}"
