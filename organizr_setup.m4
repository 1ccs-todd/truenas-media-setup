include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["nginx","php72","php72-filter","php72-curl","php72-hash","php72-json","php72-openssl","php72-pdo","php72-pdo_sqlite","php72-session","php72-simplexml","php72-sqlite3","php72-zip","git"]}' > /tmp/pkg.json
iocage create -n "__ORGANIZR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__ORGANIZR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __ORGANIZR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __ORGANIZR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __ORGANIZR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __ORGANIZR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__ORGANIZR_JAIL__
iocage fstab -a __ORGANIZR_JAIL__ __APPS_ROOT__/__ORGANIZR_JAIL__ /config nullfs rw 0 0
iocage exec __ORGANIZR_JAIL__ mkdir -p /config/nginx
iocage exec __ORGANIZR_JAIL__ mkdir -p /config/Organizr

# Configure php-fpm
echo 'listen = /var/run/php-fpm.sock' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf
echo 'listen.owner = __ORGANIZR_USER__' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf
echo 'listen.group = __ORGANIZR_GROUP__' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf
echo 'listen.mode = __ORGANIZR_LISTEN_MODE__' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf

# Configure php
iocage exec __ORGANIZR_JAIL__ cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
iocage exec __ORGANIZR_JAIL__ sed -i '' -e 's?;date.timezone =?date.timezone = "Universal"?g' /usr/local/etc/php.ini
iocage exec __ORGANIZR_JAIL__ sed -i '' -e 's?;cgi.fix_pathinfo=1?cgi.fix_pathinfo=0?g' /usr/local/etc/php.ini

# Configure nginx
cp organizr_nginx.conf __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/config/nginx/nginx.conf
iocage exec __ORGANIZR_JAIL__ rm /usr/local/etc/nginx/nginx.conf
iocage exec __ORGANIZR_JAIL__ ln -s /config/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf

# Install Organizr
iocage exec __ORGANIZR_JAIL__ git clone -b __ORGANIZR_BRANCH__ __ORGANIZR_REPO__ /usr/local/www/Organizr
iocage exec __ORGANIZR_JAIL__ chown -R __ORGANIZR_USER__:__ORGANIZR_GROUP__ /usr/local/www /config

# Enable services
iocage exec __ORGANIZR_JAIL__ sysrc nginx_enable=YES
iocage exec __ORGANIZR_JAIL__ sysrc php_fpm_enable=YES
iocage exec __ORGANIZR_JAIL__ service nginx start
iocage exec __ORGANIZR_JAIL__ service php-fpm start

#important step Navigate to http://__ORGANIZR_IP__ and set the follow the setup database location to "/config/Organizr" and Organizr for the database name. If you have an exsisting config file in the database location once you complete the setup restart the jail and login with you exsisting credentials.
