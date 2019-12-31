include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["mediainfo","sqlite3","p5-XML-Parser","bash","cmake","autoconf","automake","libtool","bison","gmake","python37","gettext-tools","xorg-vfbserver","xorg-fonts-miscbitmaps","font-alias","libinotify","nano"]}' > /tmp/pkg.json
iocage create -n "__SONARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__SONARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# update to Latest Repo
iocage exec __SONARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __SONARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __SONARR_JAIL__ "pkg update && pkg upgrade -y"

# install Mono 5.20.1.34
iocage exec __SONARR_JAIL__ portsnap fetch extract
iocage exec __SONARR_JAIL__ curl -o /tmp/mono-patch-5.20.1.34 https://bz-attachments.freebsd.org/attachment.cgi?id=209650
patch -d __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/ports/lang/mono/ -E < __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/tmp/mono-patch-5.20.1.34
iocage exec __SONARR_JAIL__ rm /tmp/mono-patch-5.20.1.34
iocage exec __SONARR_JAIL__ make -C /usr/ports/lang/mono -DBATCH install clean

# Free ~1GB removing now unneeded PORTS tree
iocage exec __SONARR_JAIL__ rm -r /usr/ports
iocage exec __SONARR_JAIL__ rm -r /var/db/ports
iocage exec __SONARR_JAIL__ rm -r /var/db/portsnap
iocage exec __SONARR_JAIL__ mkdir /var/db/ports
iocage exec __SONARR_JAIL__ mkdir /var/db/portsnap

# mount storage
iocage exec __SONARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__SONARR_JAIL__
iocage fstab -a __SONARR_JAIL__ __APPS_ROOT__/__SONARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __SONARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# download sonarr
iocage exec __SONARR_JAIL__ ln -s /usr/local/bin/mono /usr/bin/mono
iocage exec __SONARR_JAIL__ fetch "__SONARR_FETCH_URL__" -o __SONARR_FETCH_PATH__
iocage exec __SONARR_JAIL__ "tar -xzvf __SONARR_FETCH_PATH__ -C /usr/local/share"
iocage exec __SONARR_JAIL__ rm __SONARR_FETCH_PATH__

# Media Permissions
iocage exec __SONARR_JAIL__ "pw user add __SONARR_USER__ -c sonarr -u __SONARR_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __SONARR_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __SONARR_JAIL__ "pw groupmod __MEDIA_GROUP__ -m __SONARR_USER__"
iocage exec __SONARR_JAIL__ chown -R __MEDIA_USER__:__MEDIA_GROUP__ /usr/local/share/Sonarr /config

# Install rc.d service
iocage exec __SONARR_JAIL__ mkdir /usr/local/etc/rc.d
cp sonarr.rc __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ chmod u+x /usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ sysrc "sonarr_enable=YES"
iocage exec __SONARR_JAIL__ service sonarr start
echo Please open your web browser to http://__SONARR_IP__:8989
