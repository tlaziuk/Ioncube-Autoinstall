#!/bin/bash
# IonCube Auto Install
# chk.harmony-hosting.com

# Script begin
clear
pushd /root

# Define apt-get variable
APT_GET="apt-get -y -qq"

# Information
echo -e "\\033[1;34m#### \\033[1;33m IonCube Auto install \\033[1;34m #### \\033[0;39m"
echo -e "\\033[1;34m#### \\033[1;33m By Chk: chk.harmony-hosting.com \\033[1;34m #### \\033[0;39m"
echo -e "Run script ..."

# 32 or 64 bits
echo -e "[In progress] Detect Linux architecture ..."
DIST="$(command dpkg --print-architecture)"
if [ "${DIST}" = "i386" ]; then
    DIST="x86"
elif [ "${DIST}" = "amd64" ]; then
    DIST="x86-64"
fi
echo -e "\r\e[0;32m[OK]\e[0m Detect Linux architecture: $DIST"

# download tar.gz archive
echo -e "[In progress] Downloading the ioncube archive ..."
wget -q "http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_${DIST}.tar.gz"
echo -e "\r\e[0;32m[OK]\e[0m ioncube archive downloaded"

# Move in directory
echo -e "[In progress] Move to /usr/local ..."
mv ioncube_loaders_lin_${DIST}.tar.gz /usr/local/ioncube_loaders_lin_${DIST}.tar.gz
echo -e "\r\e[0;32m[OK]\e[0m Move to /usr/local"

# Go to directory
echo -e "[In progress] Go into /usr/local ..."
cd /usr/local
echo -e "\r\e[0;32m[OK]\e[0m Go into /usr"

# Extract
echo -e "[In progress] Extract tar.gz in /usr/local ..."
tar -xzf ioncube_loaders_lin_${DIST}.tar.gz > /dev/null
echo -e "\r\e[0;32m[OK]\e[0m Extract tar.gz in /usr/local"
echo "[In progress] remove the tar.gz file ..."
rm ioncube_loaders_lin_${DIST}.tar.gz
cd
echo -e "\r\e[0;32m[OK]\e[0m remove the tar.gz file "

# php version
echo -e "[In progress] Detect PHP version ..."
VER_PHP="$(command php --version 2>'/dev/null' \
    | command head -n 1 \
    | command cut --characters=5-7)"
echo -e "\r\e[0;32m[OK]\e[0m Detect PHP version: $VER_PHP "

# Add IonCube to PHP
echo -e "[In progress] Add IonCube to PHP ..."
files=(/etc/php5/conf.d/ioncube.ini /etc/php5/mods-available/ioncube.ini /etc/php/7.0/conf.d/ioncube.ini /etc/php/7.0/mods-available/ioncube.ini /etc/php/7.1/mods-available/ioncube.ini /etc/php5/apache2/conf.d/ioncube.ini /etc/php/7.0/apache2/conf.d/ioncube.ini /etc/php/7.1/apache2/conf.d/ioncube.ini)
for file in ${files[*]}
do
    if [ ! -f "$file" ]
    then
        echo "zend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" > "$file"
    fi
done
files=(/etc/php5/apache2/php.ini /etc/php/7.0/apache2/php.ini /etc/php/7.1/apache2/php.ini)
for file in ${files[*]}
do
    if [ -f "$file" ]
    then
        if ! grep -q "zend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" "$file"
        then
            sed -i "1izend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" "$file"
        fi
    fi
done
echo -e "\r\e[0;32m[OK]\e[0m Add IonCube to PHP"

# Reboot apache2 & php
echo -e "[In progress] Reboot apache2 & php ..."
test -e '/etc/init.d/php5'
command service 'php5' 'restart'
test -e '/etc/init.d/apache2'
command service 'apache2' 'restart'
echo -e "\r\e[0;32m[OK]\e[0m Reboot apache2 & php"
echo -e "\\033[1;32m #### Installation réussie #### \\033[0;39m"
popd
