include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["mono6.8","mediainfo","sqlite3","curl","nano"]}' > /tmp/pkg.json
iocage create -n "__RADARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__RADARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __RADARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __RADARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __RADARR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __RADARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__RADARR_JAIL__
iocage fstab -a __RADARR_JAIL__ __APPS_ROOT__/__RADARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __RADARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# download radarr
iocage exec __RADARR_JAIL__ "fetch https://github.com/Radarr/Radarr/releases/download/__RADARR_VERSION__/Radarr.develop.patsubst(__RADARR_VERSION__,v).linux.tar.gz -o /usr/local/share/Radarr.patsubst(__RADARR_VERSION__,v).linux.tar.gz"
iocage exec __RADARR_JAIL__ "tar -xzvf /usr/local/share/Radarr.patsubst(__RADARR_VERSION__,v).linux.tar.gz -C /usr/local/share"
iocage exec __RADARR_JAIL__ rm /usr/local/share/Radarr.patsubst(__RADARR_VERSION__,v).linux.tar.gz

# Configure rc.conf
iocage exec __RADARR_JAIL__ sysrc radarr_enable=YES
iocage exec __RADARR_JAIL__ sysrc "radarr_data_dir=/config"
iocage exec __RADARR_JAIL__ sysrc radarr_user=media
iocage exec __RADARR_JAIL__ sysrc radarr_group=media

# Media Permissions
iocage exec __RADARR_JAIL__ "pw user add radarr -c radarr -u 352 -d /nonexistent -s /usr/bin/nologin"
iocage exec __RADARR_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec __RADARR_JAIL__ "pw groupmod media -m radarr"
iocage exec __RADARR_JAIL__ chown -R media:media /usr/local/share/Radarr /config

# Start rc.d service
iocage exec __RADARR_JAIL__ mkdir /usr/local/etc/rc.d
cp radarr.rc __IOCAGE_ROOT__/jails/__RADARR_JAIL__/root/usr/local/etc/rc.d/radarr
iocage exec __RADARR_JAIL__ chmod u+x /usr/local/etc/rc.d/radarr
iocage exec __RADARR_JAIL__ service radarr start
echo Please open your web browser to http://__RADARR_IP__:7878
