include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["bash","unzip","unrar","deluge","nano"]}' > /tmp/pkg.json
iocage create -n "__DELUGE_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TORRENT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo
iocage exec __DELUGE_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __DELUGE_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __DELUGE_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __DELUGE_JAIL__ mkdir -p /config/deluge
mkdir -p __APPS_ROOT__/__DELUGE_JAIL__
iocage fstab -a __DELUGE_JAIL__ __APPS_ROOT__/__DELUGE_JAIL__ /config/deluge nullfs rw 0 0
iocage fstab -a __DELUGE_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Configure rc.conf
iocage exec __DELUGE_JAIL__ sysrc deluged_enable=YES
iocage exec __DELUGE_JAIL__ sysrc deluge_web_enable=YES
iocage exec __DELUGE_JAIL__ sysrc "deluged_confdir=/config/deluge"
iocage exec __DELUGE_JAIL__ sysrc "deluge_web_confdir=/config/deluge"
iocage exec __DELUGE_JAIL__ sysrc deluged_user=media
iocage exec __DELUGE_JAIL__ sysrc deluge_web_user=media

# Media permissions
iocage exec __DELUGE_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec __DELUGE_JAIL__  chown -R media:media /config

# Edit Deluge web-access
iocage exec __DELUGE_JAIL__ service deluged start
iocage exec __DELUGE_JAIL__ service deluged stop
iocage exec __DELUGE_JAIL__ sed -i '' -e 's?"allow_remote": false?"allow_remote": true?g' /config/deluge/core.conf
# Fix web-access rc script
iocage exec __DELUGE_JAIL__ sed -i '' -e 's?deluge_web_home=$(pw user show ${deluge_web_user} | cut -d : -f 9)?deluge_web_home=$deluge_web_confdir?g' /usr/local/etc/rc.d/deluge_web

# Configure downloads
iocage exec __DELUGE_JAIL__ sed -i '' -e 's?"download_location": "/Downloads"?"download_location": "/media/downloads/z_incomplete"?g' /config/deluge/core.conf
iocage exec __DELUGE_JAIL__ sed -i '' -e 's?"move_completed": false?"move_completed": true?g' /config/deluge/core.conf
iocage exec __DELUGE_JAIL__ sed -i '' -e 's?"move_completed_path": "/Downloads"?"move_completed_path": "/media/downloads/completed"?g' /config/deluge/core.conf

# Start rc.d service
iocage exec __DELUGE_JAIL__ service deluged start
iocage exec __DELUGE_JAIL__ service deluge_web start
echo Please open your web browser to http://__TORRENT_IP__:8112
