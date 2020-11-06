include(variables.m4)dnl
iocage exec __TRANSMISSION_JAIL__ mkdir -p /config/openvpn
mkdir -p __APPS_ROOT__/openvpn
iocage fstab -a __TRANSMISSION_JAIL__ __APPS_ROOT__/openvpn /config/openvpn nullfs rw 0 0
read -rp $'IMPORTANT: Place your working openvpn.conf and any linked files (ca,key,pass) into __APPS_ROOT__/openvpn/  (Press <Enter> to continue)\n' key
iocage exec __TRANSMISSION_JAIL__ service transmission stop
iocage set allow_tun="1" __TRANSMISSION_JAIL__
iocage exec __TRANSMISSION_JAIL__ pkg install -y openvpn
if [ ! -f __IOCAGE_ROOT__/jails/__TRANSMISSION_JAIL__/root/config/openvpn/ipfw.rules ];then
	cp -n torrent_ipfw.rules __IOCAGE_ROOT__/jails/__TRANSMISSION_JAIL__/root/config/ipfw.rules
fi
iocage exec __TRANSMISSION_JAIL__ "chown 0:0 /config/openvpn/ipfw.rules"
iocage exec __TRANSMISSION_JAIL__ "chmod 600 /config/openvpn/ipfw.rules"
iocage exec __TRANSMISSION_JAIL__ sysrc firewall_enable="YES"
iocage exec __TRANSMISSION_JAIL__ sysrc firewall_script="/config/openvpn/ipfw.rules"
iocage exec __TRANSMISSION_JAIL__ sysrc openvpn_enable="YES"
iocage exec __TRANSMISSION_JAIL__ sysrc openvpn_dir="/config/openvpn"
iocage exec __TRANSMISSION_JAIL__ sysrc openvpn_configfile="/config/openvpn/openvpn.conf"
iocage exec __TRANSMISSION_JAIL__ service openvpn start
read -rp $'IMPORTANT: Make sure you edit tun* device and your IP for VPN entrance node to __TRANSMISSION_JAIL__ /config/openvpn/ipfw.rules  (Press <Enter> to continue)\n' key
iocage restart __TRANSMISSION_JAIL__
