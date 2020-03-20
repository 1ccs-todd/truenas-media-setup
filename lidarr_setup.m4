include(variables.m4)dnl
echo '{"pkgs":["mediainfo","sqlite3","chromaprint","python37","libinotify","nano"]}' > /tmp/pkg.json
iocage create -n "__LIDARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__LIDARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __LIDARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __LIDARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __LIDARR_JAIL__ "pkg update && pkg upgrade -y"

# Install Mono 6.8.0.105
if [ ! -f __APPS_ROOT__/mono-6.8.0.105.txz ];then
	iocage exec __LIDARR_JAIL__ portsnap fetch extract
	iocage exec __LIDARR_JAIL__ pkg install -y p5-XML-Parser bash cmake autoconf automake libtool bison gmake gettext-tools xorg-vfbserver xorg-fonts-miscbitmaps font-alias
	iocage exec __LIDARR_JAIL__ cp -r /usr/ports/lang/mono /usr/ports/lang/mono68105
	curl -o /tmp/mono-patch-6.8.0.105 "https://bz-attachments.freebsd.org/attachment.cgi?id=211960"
	patch -d __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/ports/lang/ -E < /tmp/mono-patch-6.8.0.105
	rm /tmp/mono-patch-6.8.0.105
	iocage exec __LIDARR_JAIL__ make -C /usr/ports/lang/mono -DBATCH package
	iocage exec __LIDARR_JAIL__ pkg delete -y p5-XML-Parser bash cmake autoconf automake libtool bison gmake gettext-tools xorg-vfbserver xorg-fonts-miscbitmaps font-alias
	cp __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/ports/lang/mono/work/pkg/mono-6.8.0.105.txz __APPS_ROOT__/
	iocage exec __LIDARR_JAIL__ pkg add /usr/ports/lang/mono/work/pkg/mono-6.8.0.105.txz
	# Free ~1GB removing now unneeded PORTS tree
	iocage exec __LIDARR_JAIL__ chflags nouarch /usr/ports/lang/mono/work/mono-6.8.0.105/mono/mini/mono-sgen
	iocage exec __LIDARR_JAIL__ rm -r /usr/ports
	iocage exec __LIDARR_JAIL__ rm -r /var/db/ports
	iocage exec __LIDARR_JAIL__ rm -r /var/db/portsnap
	iocage exec __LIDARR_JAIL__ mkdir /var/db/ports
	iocage exec __LIDARR_JAIL__ mkdir /var/db/portsnap
else
	cp __APPS_ROOT__/mono-6.8.0.105.txz __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/tmp/
	iocage exec __LIDARR_JAIL__ pkg add /tmp/mono-6.8.0.105.txz
	rm __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/tmp/mono-6.8.0.105.txz
fi

# Mount storage
iocage exec __LIDARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__LIDARR_JAIL__
iocage fstab -a __LIDARR_JAIL__ __APPS_ROOT__/__LIDARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __LIDARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Download lidarr
iocage exec __LIDARR_JAIL__ "fetch __LIDARR_FETCH_URL__ -o /usr/local/share"
iocage exec __LIDARR_JAIL__ "tar -xzvf __LIDARR_FETCH_PATH__ -C /usr/local/share"
iocage exec __LIDARR_JAIL__ rm __LIDARR_FETCH_PATH__

# Configure rc.conf
iocage exec __LIDARR_JAIL__ sysrc lidarr_enable=YES
iocage exec __LIDARR_JAIL__ sysrc "lidarr_data_dir=/config"
iocage exec __LIDARR_JAIL__ sysrc lidarr_user=__MEDIA_USER__
iocage exec __LIDARR_JAIL__ sysrc lidarr_group=__MEDIA_GROUP__

# Media Permissions
iocage exec __LIDARR_JAIL__ "pw user add __LIDARR_USER__ -c lidarr -u __LIDARR_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __LIDARR_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __LIDARR_JAIL__ "pw groupmod __MEDIA_GROUP__ -m __LIDARR_USER__"
iocage exec __LIDARR_JAIL__ chown -R __MEDIA_USER__:__MEDIA_GROUP__ /usr/local/share/Lidarr /config

# Install rc.d service
cp lidarr.rc __IOCAGE_ROOT__/jails/__LIDARR_JAIL__/root/usr/local/etc/rc.d/lidarr
iocage exec __LIDARR_JAIL__ chmod u+x /usr/local/etc/rc.d/lidarr

# Start rc.d service
iocage exec __LIDARR_JAIL__ service lidarr start
echo Please open your web browser to http://__LIDARR_IP__:8686
