include(variables.m4)dnl
#Note to self: Make sure port forwarding is disabled before removing or rebuilding this jail

iocage create -n "__ORGANIZR_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__ORGANIZR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"

iocage exec __ORGANIZR_JAIL__ pkg install -y nginx git wget php72 php72-curl php72-pdo php72-sqlite3 php72-simplexml php72-zip php72-openssl php72-hash php72-json php72-session php72-pdo_sqlite nano

iocage exec __ORGANIZR_JAIL__ mkdir -p /config
iocage fstab -a __ORGANIZR_JAIL__ __APPS_ROOT__/organizr /config nullfs rw 0 0

iocage console __ORGANIZR_JAIL__
echo 'listen = /var/run/php-fpm.sock' >> /usr/local/etc/php-fpm.conf
echo 'listen.owner = __ORGANIZR_USER__' >> /usr/local/etc/php-fpm.conf
echo 'listen.group = __ORGANIZR_GROUP__' >> /usr/local/etc/php-fpm.conf
echo 'listen.mode = __ORGANIZR_LISTEN_MODE__' >> /usr/local/etc/php-fpm.conf
exit

iocage exec __ORGANIZR_JAIL__ cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
iocage exec __ORGANIZR_JAIL__ sed -i '' -e 's?;date.timezone =?date.timezone = "Universal"?g' /usr/local/etc/php.ini
iocage exec __ORGANIZR_JAIL__ sed -i '' -e 's?;cgi.fix_pathinfo=1?cgi.fix_pathinfo=0?g' /usr/local/etc/php.ini

iocage exec __ORGANIZR_JAIL__ git clone -b __ORGANIZR_BRANCH__ __ORGANIZR_REPO__ /usr/local/www/Organizr
iocage exec __ORGANIZR_JAIL__ chown -R __ORGANIZR_USER__:__ORGANIZR_GROUP__ /usr/local/www /config
