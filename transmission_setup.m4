include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["bash","unzip","unrar","transmission","nano"]}' > /tmp/pkg.json
iocage create -n "__TRANSMISSION_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TRANSMISSION_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo
iocage exec __TRANSMISSION_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __TRANSMISSION_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __TRANSMISSION_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __TRANSMISSION_JAIL__ mkdir -p /config/transmission-home
mkdir -p __APPS_ROOT__/__TRANSMISSION_JAIL__
iocage fstab -a __TRANSMISSION_JAIL__ __APPS_ROOT__/__TRANSMISSION_JAIL__ /config nullfs rw 0 0
iocage fstab -a __TRANSMISSION_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Configure rc.conf
iocage exec __TRANSMISSION_JAIL__ sysrc transmission_enable=YES
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_conf_dir=/config/transmission-home"
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_download_dir=/__MOUNT_LOCATION__/downloads/complete"
iocage exec __TRANSMISSION_JAIL__ sysrc transmission_user=__MEDIA_USER__
iocage exec __TRANSMISSION_JAIL__ sysrc transmission_group=__MEDIA_GROUP__

# Media permissions
iocage exec __TRANSMISSION_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __TRANSMISSION_JAIL__ "pw groupmod __MEDIA_GROUP__ -m transmission"
iocage exec __TRANSMISSION_JAIL__  chown -R __MEDIA_USER__:__MEDIA_GROUP__ /config/transmission-home

# Edit Transmission web-access
iocage exec __TRANSMISSION_JAIL__  service transmission start
iocage exec __TRANSMISSION_JAIL__  service transmission stop
iocage exec __TRANSMISSION_JAIL__  sed -i '' -e 's?"rpc-whitelist-enabled": true?"rpc-whitelist-enabled": false?g' /config/transmission-home/settings.json

# Start rc.d service
iocage exec __TRANSMISSION_JAIL__ service transmission start
echo Please open your web browser to http://__TRANSMISSION_IP__:9091
