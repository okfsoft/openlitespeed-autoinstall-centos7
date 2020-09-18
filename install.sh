#!/bin/bash

#CONFIG
PASSRESULTS='NULL'
RAW_GIT=https://raw.githubusercontent.com/okfsoft/openlitespeed-autoinstall-centos7/master
OLS_DIR=/usr/local/lsws

#Random Password Generator
function GetRandomPassword {
    dd if=/dev/urandom bs=8 count=1 of=/tmp/randompassword >/dev/null 2>&1
    PASSRESULTS=`cat /tmp/randompassword`
    rm /tmp/randompassword
    local DATE=`date`
    PASSRESULTS=`echo "$PASSRESULTS$RANDOM$DATE" |  md5sum | base64 | head -c 32`
}
GetRandomPassword
PWD_SQL=$PASSRESULTS
PWD_PMA=$PASSRESULTS
#
clear
echo -e "
	 OOOOOOOOOOO   KKK   KKK  FFFFFFFF  LLL             AAAAA        SSSSSSSSSSS  HHH     HHH 
	OOO       OOO  KKK  KKK   FFFFFFFF  LLL            AAA AAA       SSSSSSSSSSS  HHH     HHH
	OOO       OOO  KKK KKK    FFF       LLL           AAA   AAA      SSS          HHH     HHH
	OOO       OOO  KKKKK      FFFFFFFF  LLL          AAA     AAA     SSSSSSSSSSS  HHHHHHHHHHH
	OOO       OOO  KKKKK      FFFFFFFF  LLL         AAAAAAAAAAAAA    SSSSSSSSSSS  HHHHHHHHHHH
	OOO       OOO  KKK KKK    FFF       LLL        AAAAAAAAAAAAAAA   SSS          HHH     HHH
	OOO       OOO  KKK  KKK   FFF       LLLLLLLL  AAA           AAA  SSSSSSSSSSS  HHH     HHH
	 OOOOOOOOOOO   KKK   KKK  FFF       LLLLLLLL AAA             AAA SSSSSSSSSSS  HHH     HHH"
read -e ""
read -e "Open Lite Speed Auto Installer - https://www.okflash.net"
read -e ""

read -e -p "PHP type to be installed [56/70/71/72/73/N] : " phpversion
read -e -p "Install MariaDB 10.3 [y/N] : " mariadb
