include(variables.m4)dnl
# allow all local traffic on the loopback interface
ipfw add 00001 allow all from any to any via lo0

# Allow internal LAN traffic
ipfw add 03000 allow IP from __TORRENT_IP__/32 to __DEFAULT_ROUTER__/__DEFAULT_CIDR__ keep-state
ipfw add 03100 allow IP from __DEFAULT_ROUTER__/__DEFAULT_CIDR__ to __TORRENT_IP__/32 keep-state

# Allow access to Entrace IP for VPN
ipfw add 04000 allow IP from __TORRENT_IP__/32 to __TORRENT_SVRIP__ keep-state

# Allow any traffic over the VPN interface
ipfw add 05000 allow IP from any to any via tun0

# Deny any other traffic
ipfw add 65534 deny IP from any to any
