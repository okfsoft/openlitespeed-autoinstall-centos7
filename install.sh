#!/bin/bash

#CONFIG
PASSRESULTS='NULL'
GREEN='\033[0;32m'
SET='\033[0m'
#
RAW_GIT=--header 'Authorization: token cfba07f91d8081d7f14189f4512348333c534e89' https://raw.githubusercontent.com/okfsoft/openlitespeed-autoinstall-centos/master
LSWSDIR=/usr/local/lsws

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

# Update System
#yum -y install epel-release
#yum -y install wget certbot openssl
wget -O /etc/yum.repos.d/MariaDB.repo https://raw.githubusercontent.com/okfsoft/openlitespeed-autoinstall-centos/master/repository/MariaDB.repo?token=ALAZOKSRP3YNT6E473CIHVK7MUE2Y
yum -y update
