#!/bin/bash

#set -e

COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"

#CONFIG
PASS_RESULTS='NULL'
RAW_GIT=https://raw.githubusercontent.com/okfsoft/openlitespeed-autoinstall-centos7/master
WEB_DIR=/usr/local/lsws

#Random Password Generator
function GetRandomPassword {
    dd if=/dev/urandom bs=8 count=1 of=/tmp/random_password >/dev/null 2>&1
    PASS_RESULTS=`cat /tmp/random_password`
    rm /tmp/random_password
    local DATE=`date`
    PASS_RESULTS=`echo "$PASS_RESULTS$RANDOM$DATE" |  md5sum | base64 | head -c 32`
}
GetRandomPassword
PWD_SQL_DATABASE=$PASS_RESULTS
PWD_PHP_MYADMIN=$PASS_RESULTS


#Checking SELinux Status
CheckSelinuxStatus() {
    local DEFAULT_SELINUX
    local CURRENT_SELINUX
    local SELINUX_ENFORCING=0
    if [[ -f /etc/selinux/config ]] && command -v getenforce &> /dev/null; then
        DEFAULT_SELINUX=$(awk -F= '/^SELINUX=/ {print $2}' /etc/selinux/config)
        case "${DEFAULT_SELINUX,,}" in
            enforcing)
                printf "  %b %bDefault SELinux: %s%b\\n" "${CROSS}" "${COL_LIGHT_RED}" "${DEFAULT_SELINUX}" "${COL_NC}"
                SELINUX_ENFORCING=1
                ;;
            *)  # 'permissive' and 'disabled'
                printf "  %b %bDefault SELinux: %s%b\\n" "${TICK}" "${COL_LIGHT_GREEN}" "${DEFAULT_SELINUX}" "${COL_NC}"
                ;;
        esac
        CURRENT_SELINUX=$(getenforce)
        case "${CURRENT_SELINUX,,}" in
            enforcing)
                printf "  %b %bCurrent SELinux: %s%b\\n" "${CROSS}" "${COL_LIGHT_GREEN}" "${CURRENT_SELINUX}" "${COL_NC}"
                SELINUX_ENFORCING=1
                ;;
            *)  # 'permissive' and 'disabled'
                printf "  %b %bCurrent SELinux: %s%b\\n" "${TICK}" "${COL_LIGHT_GREEN}" "${CURRENT_SELINUX}" "${COL_NC}"
                ;;
        esac
    else
        echo -e "  ${INFO} ${COL_LIGHT_GREEN}SELinux not detected${COL_NC}";
    fi
    if [[ "${SELINUX_ENFORCING}" -eq 1 ]]; then
        printf "  Open Lite Speed Web Server Auto Installer does not support SELinux, please disable SELinux on your system to continue with the installation.\\n"
        printf "\\n  %bSELinux Enforcing detected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}";
		read -e -p "Disabled SELinux [y/N] : " disable_selinux
		if [[ ("$disable_selinux" == "y" || "$disable_selinux" == "Y") ]]; then
			sudo sed -i 's/enforcing/disabled/' /etc/selinux/config
			sudo sed -i 's/permissive/disabled/' /etc/selinux/config
			echo -e "  ${TICK} ${COL_LIGHT_GREEN}2sec Reboot System${COL_NC}";
			sleep 2
			reboot
		else
			clear
			exit 1
		fi
    fi
}

show_ascii_okf() {
clear
echo -e ""
echo -e "${COL_LIGHT_GREEN} OOOOOOOOOOO   KKK   KKK  FFFFFFFF  LLL             AAAAA        SSSSSSSSSSS  HHH     HHH 
OOO       OOO  KKK  KKK   FFFFFFFF  LLL            AAA AAA       SSSSSSSSSSS  HHH     HHH
OOO       OOO  KKK KKK    FFF       LLL           AAA   AAA      SSS          HHH     HHH
OOO       OOO  KKKKK      FFFFFFFF  LLL          AAA     AAA     SSSSSSSSSSS  HHHHHHHHHHH${COL_LIGHT_RED}
OOO       OOO  KKKKK      FFFFFFFF  LLL         AAAAAAAAAAAAA    SSSSSSSSSSS  HHHHHHHHHHH
OOO       OOO  KKK KKK    FFF       LLL        AAAAAAAAAAAAAAA           SSS  HHH     HHH
OOO       OOO  KKK  KKK   FFF       LLLLLLLL  AAA           AAA  SSSSSSSSSSS  HHH     HHH
 OOOOOOOOOOO   KKK   KKK  FFF       LLLLLLLL AAA             AAA SSSSSSSSSSS  HHH     HHH${COL_NC}"
echo -e ""
echo -e "${COL_LIGHT_GREEN}Open Lite Speed Web Server Auto Installer - https://www.okflash.net${COL_NC}"
echo -e ""
if [[ "${EUID}" -eq 0 ]]; then
	echo -e "  ${TICK} ${COL_LIGHT_GREEN}Root Access${COL_NC}";
else
	echo -e "  ${CROSS} ${COL_LIGHT_RED}Root Access${COL_NC}";
	printf "  Openlitespeed Web Server Auto Installer, must use an account with root access to do the installation.\\n"
	printf "\\n  %bAccount does not have root access, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}";
	exit 1
fi
CheckSelinuxStatus
}

show_ascii_okf
echo -e ""
echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e "::: Choose a number, PHP version to be installed :::"
echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e ""
echo -e "    1. PHP 5.6"
echo -e "    2. PHP 7.0"
echo -e "    3. PHP 7.1"
echo -e "    4. PHP 7.2"
echo -e "    5. PHP 7.3"
echo -e "    6. PHP 7.4"
echo -e ""
read -e -p "::: SELECT NUMBER : " phpversion

#Select PHP Version
if [[ ("$phpversion" == "1") ]]; then
	phpversioninstallation=56
elif [[ ("$phpversion" == "2") ]]; then
	phpversioninstallation=70
elif [[ ("$phpversion" == "3") ]]; then
	phpversioninstallation=71
elif [[ ("$phpversion" == "4") ]]; then
	phpversioninstallation=72
elif [[ ("$phpversion" == "5") ]]; then
	phpversioninstallation=73
elif [[ ("$phpversion" == "6") ]]; then
	phpversioninstallation=74
else
 exit 1
fi;

show_ascii_okf
echo -e ""
echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e "::: Choose a number, Database type to be installed :::"
echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e ""
echo -e "   1. Percona Server 5.6"
echo -e "   2. MariaDB 10.3"
echo -e ""
read -e -p "::: SELECT NUMBER : " dbversion

if [[ ("$dbversion" == "1") ]]; then
	dbinstall="Percona Server 5.6"
elif [[ ("$dbversion" == "2") ]]; then
	dbinstall="MariaDB 10.3"
else
 exit 1
fi;

show_ascii_okf
echo -e ""
echo -e ":::::::::::::::::::::::"
echo -e "::: Install Proftpd :::"
echo -e ":::::::::::::::::::::::"
echo -e ""
read -e -p "::: Install Proftpd : [y/N] : " PROFTPD
clear
show_ascii_okf
echo -e ""
echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e "::: You are sure you want to install the selected packages :::"
echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e ""
echo -e "   Database Type : $dbinstall"
echo -e "   PHP Version :  $phpversioninstallation"
echo -e "   Install Proftpd : $PROFTPD"
echo -e ""
read -e -p "::: Type (y) to start the installation or N to cancel [y/N] : " STARTINSTALL
clear

if [[ ("$STARTINSTALL" == "y" || "$STARTINSTALL" == "Y") ]]; then

	# Update system
	yum -y install epel-release
	yum -y install wget certbot openssl
	rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm
	yum -y update	
	
	if [[ ("$PROFTPD" == "y" || "$PROFTPD" == "Y") ]]; then
		# Install Proftpd
		yum -y install proftpd
		sed -i "s/ProFTPD server/$HOSTNAME/g" /etc/proftpd.conf
	fi;
	
    #Install Openlitespeed
    mkdir -p /home/defaultdomain/{html,logs}
    yum -y install openlitespeed
	
	#Install lsphp Version
	if [[ ("$phpversioninstallation" == "56" || "$phpversioninstallation" == "70" || "$phpversioninstallation" == "71" || "$phpversioninstallation" == "72" || "$phpversioninstallation" == "73" || "$phpversioninstallation" == "74") ]]; then
		yum -y install lsphp$phpversioninstallation lsphp$phpversioninstallation-bcmath lsphp$phpversioninstallation-common lsphp$phpversioninstallation-dba lsphp$phpversioninstallation-dbg lsphp$phpversioninstallation-devel lsphp$phpversioninstallation-enchant lsphp$phpversioninstallation-gd lsphp$phpversioninstallation-gmp lsphp$phpversioninstallation-imap lsphp$phpversioninstallation-intl lsphp$phpversioninstallation-json lsphp$phpversioninstallation-ldap lsphp$phpversioninstallation-mbstring lsphp$phpversioninstallation-mysqlnd lsphp$phpversioninstallation-odbc lsphp$phpversioninstallation-opcache lsphp$phpversioninstallation-pdo lsphp$phpversioninstallation-pear lsphp$phpversioninstallation-pecl-apcu-devel lsphp$phpversioninstallation-pecl-apcu-panel lsphp$phpversioninstallation-pecl-igbinary lsphp$phpversioninstallation-pecl-igbinary-devel lsphp$phpversioninstallation-pecl-mcrypt lsphp$phpversioninstallation-pecl-memcache lsphp$phpversioninstallation-pecl-msgpack lsphp$phpversioninstallation-pecl-msgpack-devel lsphp$phpversioninstallation-pgsql lsphp$phpversioninstallation-process lsphp$phpversioninstallation-pspell lsphp$phpversioninstallation-recode lsphp$phpversioninstallation-snmp lsphp$phpversioninstallation-soap lsphp$phpversioninstallation-tidy lsphp$phpversioninstallation-xml lsphp$phpversioninstallation-xmlrpc lsphp$phpversioninstallation-zip
	fi;

	#Install Database
	if [[ ("$dbversion" == "2") ]]; then
		wget -O /etc/yum.repos.d/MariaDB.repo $RAW_GIT/repository/MariaDB.repo
		yum -y update
		yum -y install MariaDB-server MariaDB-client
	elif [[ ("$dbversion" == "1") ]]; then
		yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
		yum -y install http://repo.percona.com/centos/7/RPMS/x86_64/Percona-Server-selinux-56-5.6.45-rel86.1.el7.noarch.rpm	
		yum -y update
		yum list | grep percona
		yum install Percona-Server-server-56
	fi;
	
	
	#Setting OpenLiteSpeed Web Server
	touch $WEB_DIR/domain
	mv -f $WEB_DIR/conf/vhosts/Example/ $WEB_DIR/config/vhosts/defaultdomain/
	rm -f $WEB_DIR/conf/vhosts/defaultdomain/vhconf.conf
	rm -f $WEB_DIR/conf/httpd_config.conf
	rm -f $WEB_DIR/admin/conf/admin_config.conf
	
	#Get Cofig
	wget -O $WEB_DIR/conf/vhosts/defaultdomain/vhconf.conf $RAW_GIT/config/vhconf.conf
	wget -O $WEB_DIR/conf/httpd_config.conf $RAW_GIT/config/httpd_config.conf
	wget -O $WEB_DIR/admin/conf/admin_config.conf $RAW_GIT/config/admin_config.conf
	
	#Set Access Cofig
	chown lsadm:lsadm $WEB_DIR/conf/vhosts/defaultdomain/vhconf.conf
	chown lsadm:lsadm $WEB_DIR/conf/httpd_config.conf
	chown lsadm:lsadm $WEB_DIR/admin/conf/admin_config.conf

	# Make and Copy Script
	mkdir /scripts
	wget -O /scripts/lscreate $RAW_GIT/scripts/lscreate
	wget -O /scripts/lsremove $RAW_GIT/scripts/lsremove
	wget -O /scripts/certbot $RAW_GIT/scripts/certbot
	wget -O /scripts/createdb $RAW_GIT/scripts/createdb
	wget -O /usr/bin/lsws $RAW_GIT/scripts/lsws
	chmod +x /usr/bin/lsws
	chmod +x /scripts/*
	
	#Copy Templates
	wget -O $WEB_DIR/conf/templates/incl.conf $RAW_GIT/templates/incl.conf
	wget -O $WEB_DIR/conf/templates/vhconf.conf $RAW_GIT/templates/vhconf.conf
	
# Create Content in Homedir and logs
touch /home/defaultdomain/html/.htaccess
touch /home/defaultdomain/logs/{error.log,access.log}
cat << EOT > /home/defaultdomain/html/index.php
<?php
echo "https://www.okflash.net - Its Works!";
?>
EOT

chown -R nobody:nobody /home/defaultdomain/html/

# Installing PHPMYAdmin
mkdir $WEB_DIR/phpmyadmin
mkdir $WEB_DIR/phpmyadmin/{html,logs}
mkdir $WEB_DIR/conf/vhosts/phpmyadmin
mkdir $WEB_DIR/conf/cert/phpmyadmin
touch $WEB_DIR/phpmyadmin/logs/error.log
touch $WEB_DIR/phpmyadmin/logs/access.log
wget -O $WEB_DIR/conf/vhosts/phpmyadmin/vhconf.conf $RAW_GIT/config/phpmyadmin_vhconf.conf
wget --no-check-certificate -O $WEB_DIR/phpmyadmin/html/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.8.2/phpMyAdmin-4.8.2-all-languages.tar.gz
cd $WEB_DIR/phpmyadmin/html/
tar -xzvf phpmyadmin.tar.gz
mv phpMyAdmin-4.8.2-all-languages/* ./
wget -O config.inc.php $RAW_GIT/config/config.inc.php
sed -i "s/#BLOWFISH#/$PWD_PHP_MYADMIN/g" config.inc.php
mkdir tmp
rm -f phpmyadmin.tar.gz && rm -rf phpMyAdmin-4.8.2-all-languages
cd /
chown -R lsadm:lsadm $WEB_DIR/phpmyadmin/

# Generate cerificare for PMA
openssl genrsa -out $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.key 2048
openssl rsa -in $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.key -out $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.key
openssl req -sha256 -new -key $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.key -out $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.csr -subj "/CN=localhost"
openssl x509 -req -sha256 -days 365 -in $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.csr -signkey $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.key -out $WEB_DIR/conf/cert/phpmyadmin/phpmyadmin.crt

# Open port Needed in Firewall
firewall-cmd --zone=public --permanent --add-port=21/tcp
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=7080/tcp
firewall-cmd --zone=public --permanent --add-port=8090/tcp
firewall-cmd --reload

# Generate SSL for Webadmin
mkdir $WEB_DIR/conf/cert/admin
openssl genrsa -out $WEB_DIR/conf/cert/admin/admin.key 2048
openssl rsa -in $WEB_DIR/conf/cert/admin/admin.key -out $WEB_DIR/conf/cert/admin/admin.key
openssl req -sha256 -new -key $WEB_DIR/conf/cert/admin/admin.key -out $WEB_DIR/conf/cert/admin/admin.csr -subj "/CN=localhost"
openssl x509 -req -sha256 -days 365 -in $WEB_DIR/conf/cert/admin/admin.csr -signkey $WEB_DIR/conf/cert/admin/admin.key -out $WEB_DIR/conf/cert/admin/admin.crt


#Setting MySQL
systemctl start mariadb && systemctl start proftpd && $WEB_DIR/bin/lswsctrl start
mysql -uroot -v -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -uroot -v -e "DROP DATABASE test;"
mysql -uroot -v -e "DELETE FROM mysql.user WHERE User='';"
mysql -uroot -v -e "use mysql;update user set Password=PASSWORD('$PWD_SQL_DATABASE') where user='root'; flush privileges;"

# Save Password root MariaDB
cat << EOT > /root/.MariaDB
$PWD_SQL_DATABASE
EOT

# Create PHP symlink
ln -s /usr/local/lsws/lsphp72/bin/lsphp /usr/bin/php

systemctl enable proftpd
systemctl enable mariadb

elif [[ ("$STARTINSTALL" == "n" || "$STARTINSTALL" == "N") ]]; then
clear
exit 1
set -e
show_ascii_okf
echo -e "::::::::::::::::::::::::::::::::"
echo -e "::: Installation is canceled :::"
echo -e "::::::::::::::::::::::::::::::::"
fi;
