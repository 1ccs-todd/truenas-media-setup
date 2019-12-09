include(variables.m4)dnl
iocage create -n "__TRANSMISSION_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TRANSMISSION_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"

iocage exec __TRANSMISSION_JAIL__ pkg install -y transmission

iocage exec __TRANSMISSION_JAIL__ mkdir -p /config/transmission-home
iocage exec __TRANSMISSION_JAIL__ mkdir -p  /mnt/downloads
iocage fstab -a __TRANSMISSION_JAIL__ __APPS_ROOT__/transmission /config nullfs rw 0 0
iocage fstab -a __TRANSMISSION_JAIL__ __MEDIA_ROOT__/downloads /mnt/downloads nullfs rw 0 0

iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_enable=YES"
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_conf_dir=/config/transmission-home"
iocage exec __TRANSMISSION_JAIL__ sysrc "transmission_download_dir=/mnt/downloads/complete"

iocage exec __TRANSMISSION_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __TRANSMISSION_JAIL__ "pw groupadd -n __MEDIA_GROUP__ -g __MEDIA_GID__"
iocage exec __TRANSMISSION_JAIL__ "pw groupmod __MEDIA_GROUP__ -m __TRANSMISSION_USER__"
iocage exec __TRANSMISSION_JAIL__  chown -R __MEDIA_USER__:__MEDIA_GROUP__ /config/transmission-home
iocage exec __TRANSMISSION_JAIL__  chown -R __MEDIA_USER__:__MEDIA_GROUP__ /mnt/downloads
iocage exec __TRANSMISSION_JAIL__  sysrc 'transmission_user=__MEDIA_USER__'

iocage exec __TRANSMISSION_JAIL__ service transmission start
