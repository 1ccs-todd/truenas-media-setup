changequote(`[[[', `]]]')dnl
include(variables.m4)
iocage create -n "__LIDARR_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__JACKETT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"

# Update to Latest Repo
iocage exec __LIDARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __LIDARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Install pkgs
iocage exec __LIDARR_JAIL__ pkg install -y mediainfo sqkite3 ca_root_nss curl chromaprint libepoxy-1.5.2 llvm80 nano
iocage exec __LIDARR_JAIL__ portsnap fetch extract
iocage exec __LIDARR_JAIL__ curl -o /tmp/mono-patch-5.20.1.34 https://bz-attachments.freebsd.org/attachment.cgi?id=209650
patch -d __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/ports/lang/mono/ -E < __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/tmp/mono-patch-5.20.1.34
iocage exec __LIDARR_JAIL__ rm /tmp/mono-patch-5.20.1.34
iocage exec __LIDARR_JAIL__ make -DBATCH -C /usr/ports/lang/mono install clean

# Mount storage
iocage exec __LIDARR_JAIL__ mkdir -p /config
iocage exec __LIDARR_JAIL__ mkdir -p /mnt/music
iocage exec __LIDARR_JAIL__ mkdir -p /mnt/torrents
iocage fstab -a __LIDARR_JAIL__ __APPS_ROOT__/__LIDARR_JAIL__ /config nullfs rw 0 0

# Download lidarr
iocage exec __LIDARR_JAIL__ ln -s /usr/local/bin/mono /usr/bin/mono
iocage exec __LIDARR_JAIL__ "fetch __LIDARR_FETCH_URL__ -o /usr/local/share"
iocage exec __LIDARR_JAIL__ "tar -xzvf __LIDARR_FETCH_PATH__ -C /usr/local/share"
iocage exec __LIDARR_JAIL__ rm __LIDARR_FETCH_PATH__

# Media Permissions
iocage exec __LIDARR_JAIL__ "pw user add __LIDARR_USER__ -c __LIDARR_USER__ -u __LIDARR_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __LIDARR_JAIL__ chown -R __LIDARR_USER__:__LIDARR_GROUP__ /usr/local/share/Lidarr /config

# Install rc.d service script
cp lidarr.sh __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/local/etc/rc.d/lidarr
iocage exec __LIDARR_JAIL__ chmod u+x /usr/local/etc/rc.d/jackett
iocage exec __LIDARR_JAIL__ sysrc "jackett_enable=YES"
iocage exec __LIDARR_JAIL__ service jackett start
