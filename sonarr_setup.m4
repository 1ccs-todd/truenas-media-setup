include(variables.m4)dnl
echo '{"pkgs":["mediainfo","sqlite3","ca_root_nss","curl","libepoxy-1.5.2","llvm80","python27","libffi","py27-pillow","tk86","libXrender","libX11","libxcb","libXdmcp","xorgproto","libXau","libpthread-stubs","libXext","libXScrnSaver","libXft","fontconfig","expat","freetype2","tcl86","py27-tkinter","py27-setuptools","webp","tiff","jpeg-turbo","jbigkit","png","giflib","openjpeg","lcms2","py27-olefile","libinotify","bash","p5-XML-Parser","cmake","autoconf","automake","libtool","bison","gmake","gettext-tools","xorg-vfbserver","xorg-fonts-miscbitmaps","font-alias","xkeyboard-config","xkbcomp","perl5","nano"]}' > /tmp/pkg.json
iocage create -n "__SONARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__SONARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# update to Latest Repo
iocage exec __SONARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __SONARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# install Mono 5.20.1.34
iocage exec __SONARR_JAIL__ portsnap fetch extract
iocage exec __SONARR_JAIL__ curl -o /tmp/mono-patch-5.20.1.34 https://bz-attachments.freebsd.org/attachment.cgi?id=209650
patch -d __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/ports/lang/mono/ -E < __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/tmp/mono-patch-5.20.1.34
iocage exec __SONARR_JAIL__ rm /tmp/mono-patch-5.20.1.34
iocage exec __SONARR_JAIL__ make -C /usr/ports/lang/mono -DBATCH install clean

# mount storage
iocage exec __SONARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__SONARR_JAIL__
iocage fstab -a __SONARR_JAIL__ __APPS_ROOT__/__SONARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __SONARR_JAIL__ __MEDIA_ROOT__ /mnt nullfs rw 0 0

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

# Install rc.d service
iocage exec __SONARR_JAIL__ mkdir /usr/local/etc/rc.d
cp sonarr.rc __IOCAGE_ROOT__/jails/__SONARR_JAIL__/root/usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ chmod u+x /usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ sysrc "sonarr_enable=YES"
iocage exec __SONARR_JAIL__ service sonarr start
echo Please open your web browser to http://__SONARR_IP__:8989
