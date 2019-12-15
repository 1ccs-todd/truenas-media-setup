changequote(`[[[', `]]]')dnl
include(variables.m4)
echo '{"pkgs":["mediainfo","sqlite3","chromaprint","p5-XML-Parser","bash","cmake","autoconf","automake","libtool","bison","gmake","python36","gettext-tools","xorg-vfbserver","xorg-fonts-miscbitmaps","font-alias","libinotify","nano"]}' > /tmp/pkg.json
iocage create -n "__LIDARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__LIDARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __LIDARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __LIDARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Install Mono 5.20.1.34  
iocage exec __LIDARR_JAIL__ portsnap fetch extract
iocage exec __LIDARR_JAIL__ curl -o /tmp/mono-patch-5.20.1.34 https://bz-attachments.freebsd.org/attachment.cgi?id=209650
patch -d __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/ports/lang/mono/ -E < __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/tmp/mono-patch-5.20.1.34
iocage exec __LIDARR_JAIL__ rm /tmp/mono-patch-5.20.1.34
iocage exec __LIDARR_JAIL__ make -C /usr/ports/lang/mono -DBATCH install clean

# Free ~1GB removing now unneeded PORTS tree
iocage exec __LIDARR_JAIL__ rm -rf /usr/ports
iocage exec __LIDARR_JAIL__ rm -rf /var/db/ports
iocage exec __LIDARR_JAIL__ rm -rf /var/db/portsnap

# Mount storage
iocage exec __LIDARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__LIDARR_JAIL__
iocage fstab -a __LIDARR_JAIL__ __APPS_ROOT__/__LIDARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __LIDARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Download lidarr
iocage exec __LIDARR_JAIL__ ln -s /usr/local/bin/mono /usr/bin/mono
iocage exec __LIDARR_JAIL__ "fetch __LIDARR_FETCH_URL__ -o /usr/local/share"
iocage exec __LIDARR_JAIL__ "tar -xzvf __LIDARR_FETCH_PATH__ -C /usr/local/share"
iocage exec __LIDARR_JAIL__ rm __LIDARR_FETCH_PATH__

# Media Permissions
iocage exec __LIDARR_JAIL__ "pw user add __LIDARR_USER__ -c __LIDARR_USER__ -u __LIDARR_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __LIDARR_JAIL__ chown -R __LIDARR_USER__:__LIDARR_GROUP__ /usr/local/share/Lidarr /config

# Install rc.d service script
iocage exec __LIDARR_JAIL__ mkdir /usr/local/etc/rc.d
cp lidarr.rc __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/local/etc/rc.d/lidarr
iocage exec __LIDARR_JAIL__ chmod u+x /usr/local/etc/rc.d/lidarr
iocage exec __LIDARR_JAIL__ sysrc "lidarr_enable=YES"
iocage exec __LIDARR_JAIL__ service lidarr start
echo Please open your web browser to http://__LIDARR_IP__:8686
