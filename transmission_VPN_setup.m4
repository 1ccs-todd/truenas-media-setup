include(variables.m4)dnl
read -rp $'IMPORTANT: Place your working openvpn.conf and any linked files (ca,key,pass) into __APPS_ROOT__/__TRANSMISSION_JAIL__/  (Press any key to continue)\n' key
iocage exec __TRANSMISSION_JAIL__ service transmission stop
iocage set allow_tun="1" __TRANSMISSION_JAIL__
iocage exec __TRANSMISSION_JAIL__ pkg install -y openvpn
cp -n transmission_ipfw.rules __IOCAGE_ROOT__/jails/__TRANSMISSION_JAIL__/root/config/ipfw.rules
iocage exec __TRANSMISSION_JAIL__ "chown 0:0 /config/ipfw.rules"
iocage exec __TRANSMISSION_JAIL__ "chmod 600 /config/ipfw.rules"
iocage exec __TRANSMISSION_JAIL__ sysrc firewall_enable="YES"
iocage exec __TRANSMISSION_JAIL__ sysrc firewall_script="/config/ipfw.rules"
iocage exec __TRANSMISSION_JAIL__ sysrc openvpn_enable="YES"
iocage exec __TRANSMISSION_JAIL__ sysrc openvpn_dir="/config"
iocage exec __TRANSMISSION_JAIL__ sysrc openvpn_configfile="/config/openvpn.conf"
iocage exec __TRANSMISSION_JAIL__ service openvpn start
read -rp $'IMPORTANT: Make sure you edit tun* device and your IP for VPN entrance node to __TRANSMISSION_JAIL__ /config/ipfw.rules  (Press <Enter> to continue)\n' key
iocage restart __TRANSMISSION_JAIL__
