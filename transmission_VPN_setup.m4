include(variables.m4)dnl
iocage exec __TRANSMISSION_JAIL__ service transmission stop
iocage set allow_tun="1" __TRANSMISSION_JAIL__ 
iocage exec __TRANSMISSION_JAIL__ pkg install -y openvpn
cp transmission_ipfw.rules __IOCAGE_ROOT__/jails/__TRANSMISSION_JAIL__/root/config/ipfw_rules
iocage exec __TRANSMISSION_JAIL__ "chown 0:0 /config/ipfw_rules"
iocage exec __TRANSMISSION_JAIL__ "chmod 600 /config/ipfw_rules"
iocage exec __TRANSMISSION_JAIL__ sysrc "firewall_enable=YES"
iocage exec __TRANSMISSION_JAIL__ sysrc "firewall_type=/config/ipfw_rules"
iocage exec __TRANSMISSION_JAIL__ sysrc "openvpn_enable=YES"
iocage exec __TRANSMISSION_JAIL__ sysrc "openvpn_dir=/config"
iocage exec __TRANSMISSION_JAIL__ sysrc "openvpn_configfile=/config/openvpn.conf"
iocage exec __TRANSMISSION_JAIL__ service ipfw start
echo "IMPORTANT: Place your working openvpn.conf file into __APPS_ROOT__/__TRANSMISSION_JAIL__/"
set req = $<
iocage exec __TRANSMISSION_JAIL__ service openvpn start
iocage exec __TRANSMISSION_JAIL__ service transmission start
