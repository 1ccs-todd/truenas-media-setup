changequote(`[[[', `]]]')dnl
include(variables.m4)
iocage create -n "__LIDARR_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__JACKETT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"

# Update to Latest Repo
iocage exec __LIDARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __LIDARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# install pkgs
iocage exec __LIDARR_JAIL__ pkg install -y libepoxy-1.5.2 llvm80 curl nano
iocage exec __LIDARR_JAIL__ portsnap fetch extract
iocage exec __LIDARR_JAIL__ curl -o /tmp/mono-patch-5.20.1.34 https://bz-attachments.freebsd.org/attachment.cgi?id=209650
patch -d /mnt/TANK/iocage/jails/lidarr/root/usr/ports/lang/mono/ -E < /mnt/TANK/iocage/jails/lidarr/root/tmp/mono-patch-5.20.1.34
iocage exec __LIDARR_JAIL__ make -C /usr/ports/lang/mono install clean

# mount storage
iocage exec __LIDARR_JAIL__ mkdir -p /config
iocage fstab -a __LIDARR_JAIL__ __APPS_ROOT__/jackett /config nullfs rw 0 0

# download lidarr
iocage exec __LIDARR_JAIL__ ln -s /usr/local/bin/mono /usr/bin/mono
iocage exec __LIDARR_JAIL__ "fetch __JACKETT_FETCH_URL__ -o /usr/local/share"
iocage exec __LIDARR_JAIL__ "tar -xzvf __JACKETT_FETCH_PATH__ -C /usr/local/share"
iocage exec __LIDARR_JAIL__ rm __JACKETT_FETCH_PATH__

# Media Permissions
iocage exec __LIDARR_JAIL__ "pw user add __JACKETT_USER__ -c jackett -u __JACKETT_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __LIDARR_JAIL__ chown -R __JACKETT_USER__:__JACKETT_GROUP__ /usr/local/share/Jackett /config
iocage exec __LIDARR_JAIL__ mkdir /usr/local/etc/rc.d
