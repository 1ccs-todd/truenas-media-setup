include(variables.m4)dnl
iocage create -n "__TRANSMISSION_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TRANSMISSION_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"

# Update to Latest Repo
iocage exec __JACKETT_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __JACKETT_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Install pkgs
iocage exec __TRANSMISSION_JAIL__ pkg install -y bash unzip unrar transmission openvpn ca_root_nss nano

# Mount storage
iocage exec __TRANSMISSION_JAIL__ mkdir -p /config
iocage fstab -a __TRANSMISSION_JAIL__ __APPS_ROOT__/transmission /config nullfs rw 0 0
iocage fstab -a __TRANSMISSION_JAIL__ __MEDIA_ROOT__ /mnt nullfs rw 0 0
iocage exec __TRANSMISSION_JAIL__ mkdir -p /config/transmission-home

# Configure Transmission
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_enable=YES"
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_conf_dir=/config/transmission-home"
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_download_dir=/mnt/downloads/complete"
iocage exec __TRANSMISSION_JAIL__ sysrc 'transmission_user=__MEDIA_USER__'

# Media permissions
iocage exec __TRANSMISSION_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __TRANSMISSION_JAIL__ "pw groupadd -n __MEDIA_GROUP__ -g __MEDIA_GID__"
iocage exec __TRANSMISSION_JAIL__ "pw groupmod __MEDIA_GROUP__ -m __TRANSMISSION_USER__"
iocage exec __TRANSMISSION_JAIL__  chown -R __MEDIA_USER__:__MEDIA_GROUP__ /config/transmission-home
iocage exec __TRANSMISSION_JAIL__  chown -R __MEDIA_USER__:__MEDIA_GROUP__ /mnt/downloads

iocage exec __TRANSMISSION_JAIL__ service transmission start
