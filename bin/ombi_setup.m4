include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["mono","ca_root_nss","unzip","sqlite3","nano"]}' > /tmp/pkg.json
iocage create -n "__OMBI_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__OMBI_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __OMBI_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __OMBI_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __OMBI_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __OMBI_JAIL__ mkdir /config
mkdir -p __APPS_ROOT__/__OMBI_JAIL__
iocage fstab -a __OMBI_JAIL__ __APPS_ROOT__/__OMBI_JAIL__ /config nullfs rw 0 0

# download ombi
iocage exec __OMBI_JAIL__ "fetch https://github.com/tidusjar/Ombi/releases/download/v2.2.1/Ombi.zip -o /usr/local/share"
iocage exec __OMBI_JAIL__ "unzip -d /usr/local/share /usr/local/share/Ombi.zip"
iocage exec __OMBI_JAIL__ mv /usr/local/share/Release /usr/local/share/ombi
iocage exec __OMBI_JAIL__ rm /usr/local/share/Ombi.zip

# Configure rc.conf
iocage exec __OMBI_JAIL__ sysrc ombi_enable=YES
iocage exec __OMBI_JAIL__ sysrc "ombi_data_dir=/config"

# Setup Database
if [ ! -f __APPS_ROOT__/Ombi.slqite ];then
	iocage exec ombi sqlite3 /config/Ombi.sqlite "create table aTable(field1 int); drop table aTable;"
	iocage exec ombi mkdir -p /config/Backups
fi
iocage exec __OMBI_JAIL__ ln -s /config/Ombi.sqlite /usr/local/share/ombi/Ombi.sqlite
iocage exec __OMBI_JAIL__ ln -s /config/Backups /usr/local/share/ombi/Backups

# Media Permissions
iocage exec __OMBI_JAIL__ "pw user add ombi -c ombi -u 819 -d /nonexistent -s /usr/bin/nologin"
iocage exec __OMBI_JAIL__ chown -R ombi:ombi /usr/local/share/ombi /config

# Start rc.d service
iocage exec __OMBI_JAIL__ mkdir -p /usr/local/etc/rc.d
cp ombi.rc __IOCAGE_ROOT__/jails/__OMBI_JAIL__/root/usr/local/etc/rc.d/ombi
iocage exec __OMBI_JAIL__ chmod u+x /usr/local/etc/rc.d/ombi
iocage exec __OMBI_JAIL__ service ombi start
echo Please open your web browser to http://__OMBI_IP__:3579
