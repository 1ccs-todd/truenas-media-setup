include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["mediainfo","sqlite3","chromaprint","python37","libinotify","nano"]}' > /tmp/pkg.json
iocage create -n "__SONARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__SONARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo
iocage exec __SONARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __SONARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __SONARR_JAIL__ "pkg update && pkg upgrade -y"

# Install Mono 6.8.0.105
if [ ! -f __APPS_ROOT__/mono-6.8.0.105.txz ];then
	iocage exec __SONARR_JAIL__ portsnap fetch extract
	iocage exec __SONARR_JAIL__ pkg install -y p5-XML-Parser bash cmake autoconf automake libtool bison gmake gettext-tools xorg-vfbserver xorg-fonts-miscbitmaps font-alias
	iocage exec __SONARR_JAIL__ cp -r /usr/ports/lang/mono /usr/ports/lang/mono68105
	curl -o /tmp/mono-patch-6.8.0.105 "https://bz-attachments.freebsd.org/attachment.cgi?id=211960"
	patch -d __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/ports/lang/ -E < /tmp/mono-patch-6.8.0.105
	rm /tmp/mono-patch-6.8.0.105
	iocage exec __SONARR_JAIL__ make -C /usr/ports/lang/mono -DBATCH package
	iocage exec __SONARR_JAIL__ pkg delete -y p5-XML-Parser bash cmake autoconf automake libtool bison gmake gettext-tools xorg-vfbserver xorg-fonts-miscbitmaps font-alias
	cp __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/ports/lang/mono/work/pkg/mono-6.8.0.105.txz __APPS_ROOT__/
	iocage exec __SONARR_JAIL__ pkg add /usr/ports/lang/mono/work/pkg/mono-6.8.0.105.txz
	# Free ~1GB removing now unneeded PORTS tree
	iocage exec __SONARR_JAIL__ chflags nouarch /usr/ports/lang/mono/work/mono-6.8.0.105/mono/mini/mono-sgen
	iocage exec __SONARR_JAIL__ rm -r /usr/ports
	iocage exec __SONARR_JAIL__ rm -r /var/db/ports
	iocage exec __SONARR_JAIL__ rm -r /var/db/portsnap
	iocage exec __SONARR_JAIL__ mkdir /var/db/ports
	iocage exec __SONARR_JAIL__ mkdir /var/db/portsnap
else
	cp __APPS_ROOT__/mono-6.8.0.105.txz __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/tmp/
	iocage exec __SONARR_JAIL__ pkg add /tmp/mono-6.8.0.105.txz
	rm __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/tmp/mono-6.8.0.105.txz
fi

# Mount Storage
iocage exec __SONARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__SONARR_JAIL__
iocage fstab -a __SONARR_JAIL__ __APPS_ROOT__/__SONARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __SONARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Install Sonarr
iocage exec __SONARR_JAIL__ fetch "__SONARR_FETCH_URL__" -o __SONARR_FETCH_PATH__
iocage exec __SONARR_JAIL__ "tar -xzvf __SONARR_FETCH_PATH__ -C /usr/local/share"
iocage exec __SONARR_JAIL__ rm __SONARR_FETCH_PATH__

# Configure rc.conf
iocage exec __SONARR_JAIL__ sysrc sonarr_enable=YES
iocage exec __SONARR_JAIL__ sysrc "sonarr_data_dir=/config"
iocage exec __SONARR_JAIL__ sysrc sonarr_user=__MEDIA_USER__
iocage exec __SONARR_JAIL__ sysrc sonarr_group=__MEDIA_GROUP__

# Media permissions
iocage exec __SONARR_JAIL__ "pw user add __SONARR_USER__ -c sonarr -u __SONARR_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __SONARR_JAIL__ "pw user add __MEDIA_USER__ -c media -u __MEDIA_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __SONARR_JAIL__ "pw groupmod __MEDIA_GROUP__ -m __SONARR_USER__"
iocage exec __SONARR_JAIL__ chown -R __MEDIA_USER__:__MEDIA_GROUP__ /usr/local/share/Sonarr /config

# Start rc.d service
iocage exec __SONARR_JAIL__ mkdir /usr/local/etc/rc.d
cp sonarr.rc __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ chmod u+x /usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ service sonarr start
echo Please open your web browser to http://__SONARR_IP__:8989
