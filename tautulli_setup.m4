include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["python2","py27-sqlite3","py27-openssl","git","py27-pycryptodome","ca_root_nss","nano"]}' > /tmp/pkg.json
iocage create -n "__TAUTULLI_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TAUTULLI_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __TAUTULLI_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __TAUTULLI_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Mount storage
iocage exec __TAUTULLI_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__TAUTULLI_JAIL__
iocage fstab -a __TAUTULLI_JAIL__ __APPS_ROOT__/__TAUTULLI_JAIL__ /config nullfs rw 0 0

# Download tautulli
iocage exec __TAUTULLI_JAIL__ git clone __TAUTULLI_REPO__ /usr/local/share/Tautulli

# Media permissions
iocage exec __TAUTULLI_JAIL__ mkdir /usr/local/etc/rc.d
iocage exec __TAUTULLI_JAIL__ "pw user add __TAUTULLI_USER__ -c tautulli -u __TAUTULLI_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __TAUTULLI_JAIL__ chown -R __TAUTULLI_USER__:__TAUTULLI_GROUP__ /usr/local/share/Tautulli /config
iocage exec __TAUTULLI_JAIL__ cp /usr/local/share/Tautulli/init-scripts/init.freenas /usr/local/etc/rc.d/tautulli
iocage exec __TAUTULLI_JAIL__ chmod u+x /usr/local/etc/rc.d/tautulli
iocage exec __TAUTULLI_JAIL__ sysrc "tautulli_enable=YES"
iocage exec __TAUTULLI_JAIL__ sysrc "tautulli_flags=--datadir /config"
iocage exec __TAUTULLI_JAIL__ service tautulli start
echo Please open your web browser to http://__TAUTULLI_IP__:8181
