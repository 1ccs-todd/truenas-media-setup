include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["mono","curl","ca_root_nss","nano"]}' > /tmp/pkg.json
iocage create -n "__JACKETT_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__JACKETT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __JACKETT_JAIL__ mkdir -p /usr/local/etc/pkg/repos
iocage exec __JACKETT_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __JACKETT_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __JACKETT_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__JACKETT_JAIL__
iocage fstab -a __JACKETT_JAIL__ __APPS_ROOT__/__JACKETT_JAIL__ /config nullfs rw 0 0

# download jackett
iocage exec __JACKETT_JAIL__ ln -s /usr/local/bin/mono /usr/bin/mono
iocage exec __JACKETT_JAIL__ "fetch __JACKETT_FETCH_URL__ -o /usr/local/share"
iocage exec __JACKETT_JAIL__ "tar -xzvf __JACKETT_FETCH_PATH__ -C /usr/local/share"
iocage exec __JACKETT_JAIL__ rm __JACKETT_FETCH_PATH__

# Media permissions
iocage exec __JACKETT_JAIL__ "pw user add __JACKETT_USER__ -c jackett -u __JACKETT_UID__ -d /nonexistent -s /usr/bin/nologin"
iocage exec __JACKETT_JAIL__ chown -R __JACKETT_USER__:__JACKETT_GROUP__ /usr/local/share/Jackett /config

# Install rc.d service
iocage exec __JACKETT_JAIL__ mkdir /usr/local/etc/rc.d
cp jackett.rc __IOCAGE_ROOT__/jails/__JACKETT_JAIL__/root/usr/local/etc/rc.d/jackett
iocage exec __JACKETT_JAIL__ chmod u+x /usr/local/etc/rc.d/jackett
iocage exec __JACKETT_JAIL__ sysrc "jackett_enable=YES"
iocage exec __JACKETT_JAIL__ service jackett start
echo Please open your web browser to http://__JACKETT_IP__:9117
