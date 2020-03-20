include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["git","python3","py37-pip","py37-libxml2","libxslt","py37-sqlite3","nano"]}' > /tmp/pkg.json
iocage create -n "__BAZARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__BAZARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __BAZARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __BAZARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __BAZARR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __BAZARR_JAIL__ mkdir /config
mkdir -p __APPS_ROOT__/__BAZARR_JAIL__
iocage fstab -a __BAZARR_JAIL__ __APPS_ROOT__/__BAZARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __BAZARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Install Bazarr
iocage exec __BAZARR_JAIL__ git clone __BAZARR_REPO__ /usr/local/share/bazarr
iocage exec __BAZARR_JAIL__  pip install -r /usr/local/share/bazarr/requirements.txt

# Configure Bazarr
iocage exec __BAZARR_JAIL__ sysrc bazarr_enable=YES
iocage exec __BAZARR_JAIL__ sysrc "bazarr_conf_dir=/config"
iocage exec __BAZARR_JAIL__ sysrc bazarr_user=__MEDIA_USER__
iocage exec __BAZARR_JAIL__ sysrc bazarr_group=__MEDIA_GROUP__

# Media permissions
iocage exec __BAZARR_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __BAZARR_JAIL__ "pw user add __BAZARR_USER__ -c bazarr -u __BAZARR_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __BAZARR_JAIL__ "pw groupmod __MEDIA_GROUP__ -m bazarr"
iocage exec __BAZARR_JAIL__ chown -R __MEDIA_USER__:__MEDIA_GROUP__ /usr/local/share/bazarr /config

# Install rc.d service
cp bazarr.rc __IOCAGE_ROOT__/jails/__BAZARR_JAIL__/root/usr/local/etc/rc.d/bazarr
iocage exec __BAZARR_JAIL__ chmod u+x /usr/local/etc/rc.d/bazarr

# Start rc.d service
iocage exec __BAZARR_JAIL__ service bazarr start
echo Please open your web browser to http://__BAZARR_IP__:6767
