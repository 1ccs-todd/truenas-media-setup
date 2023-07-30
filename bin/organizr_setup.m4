include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    organizr_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["nginx","php72","php72-filter","php72-curl","php72-hash","php72-json","php72-openssl","php72-pdo","php72-pdo_sqlite","php72-session","php72-simplexml","php72-sqlite3","php72-zip","git-tiny"]}' > /tmp/pkg.json
iocage create -n "__ORGANIZR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__ORGANIZR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo and apply any updates
iocage exec __ORGANIZR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __ORGANIZR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __ORGANIZR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __ORGANIZR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__ORGANIZR_JAIL__
iocage fstab -a __ORGANIZR_JAIL__ __APPS_ROOT__/__ORGANIZR_JAIL__ /config nullfs rw 0 0
iocage exec __ORGANIZR_JAIL__ mkdir -p /config/nginx
iocage exec __ORGANIZR_JAIL__ mkdir /config/Organizr

# Install Organizr
iocage exec __ORGANIZR_JAIL__ git clone -b v2-master https://github.com/causefx/Organizr.git /usr/local/www/Organizr
iocage exec __ORGANIZR_JAIL__ chown -R www:www /usr/local/www /config

# Configure php-fpm
echo 'listen = /var/run/php-fpm.sock' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf
echo 'listen.owner = www' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf
echo 'listen.group = www' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf
echo 'listen.mode = 0660' >> __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/usr/local/etc/php-fpm.conf

# Configure php
iocage exec __ORGANIZR_JAIL__ cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
iocage exec __ORGANIZR_JAIL__ sed -i '' -e 's?;date.timezone =?date.timezone = "Universal"?g' /usr/local/etc/php.ini
iocage exec __ORGANIZR_JAIL__ sed -i '' -e 's?;cgi.fix_pathinfo=1?cgi.fix_pathinfo=0?g' /usr/local/etc/php.ini

# Configure nginx for Oranizer
cp bin/organizr_nginx.conf __IOCAGE_ROOT__/jails/__ORGANIZR_JAIL__/root/config/nginx/nginx.conf
iocage exec __ORGANIZR_JAIL__ rm /usr/local/etc/nginx/nginx.conf
iocage exec __ORGANIZR_JAIL__ ln -s /config/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf

# Configure services
iocage exec __ORGANIZR_JAIL__ sysrc nginx_enable=YES
iocage exec __ORGANIZR_JAIL__ sysrc php_fpm_enable=YES

# Enable services
iocage exec __ORGANIZR_JAIL__ service nginx start
iocage exec __ORGANIZR_JAIL__ service php-fpm start
echo Important step! Navigate to http://__ORGANIZR_IP__ and set the database location to "/config/Organizr" and Organizr for the database name. If you have an exsisting config file in the database location once you complete the setup restart the jail and login with your previous credentials.
