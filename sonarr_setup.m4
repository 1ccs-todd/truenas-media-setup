include(variables.m4)dnl
iocage create -n "__SONARR_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__SONARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"

# update to Latest Repo
iocage exec __SONARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __SONARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# install pkgs
iocage exec __SONARR_JAIL__ pkg install -y mono mediainfo sqlite3 curl
# mount storage
iocage exec __SONARR_JAIL__ mkdir -p /config
iocage exec __SONARR_JAIL__ mkdir -p  /mnt/downloads
iocage exec __SONARR_JAIL__ mkdir -p /mnt/series
iocage fstab -a __SONARR_JAIL__ __APPS_ROOT__/sonarr /config nullfs rw 0 0
iocage fstab -a __SONARR_JAIL__ __MEDIA_ROOT__/downloads /mnt/downloads nullfs rw 0 0
iocage fstab -a __SONARR_JAIL__ __MEDIA_ROOT__/series /mnt/series nullfs rw 0 0

# download sonarr
iocage exec __SONARR_JAIL__ ln -s /usr/local/bin/mono /usr/bin/mono
iocage exec __SONARR_JAIL__ "fetch __SONARR_FETCH_URL__ -o /usr/local/share"
iocage exec __SONARR_JAIL__ "tar -xzvf __SONARR_FETCH_PATH__ -C /usr/local/share"
iocage exec __SONARR_JAIL__ rm __SONARR_FETCH_PATH__

# Media Permissions
iocage exec __SONARR_JAIL__ "pw user add __SONARR_USER__ -c sonarr -u __SONARR_UID__ -d /nonexistent -s /usr/bin/nologin"

iocage exec __SONARR_JAIL__ "pw user add __MEDIA_GROUP__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __SONARR_JAIL__ "pw groupadd -n __MEDIA_GROUP__ -g __MEDIA_GID__"
iocage exec __SONARR_JAIL__ "pw groupmod __MEDIA_GROUP__ -m __SONARR_USER__"
iocage exec __SONARR_JAIL__ chown -R __MEDIA_USER__:__MEDIA_GROUP__ /usr/local/share/Sonarr /config
iocage exec __SONARR_JAIL__  sysrc 'sonarr_user=__MEDIA_USER__'
