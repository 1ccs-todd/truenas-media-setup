include(variables.m4)dnl
# Allow internal LAN traffic
add 03000 allow IP from __TRANSMISSION_IP__/32 to __DEFAULT_ROUTER__/__DEFAULT_CIDR__ keep-state
add 03100 allow IP from __DEFAULT_ROUTER__/__DEFAULT_CIDR__ to __TRANSMISSION_IP__/32 keep-state

# Allow access to Entrace IP for VPN
add 04000 allow IP from __TRANSMISSION_IP__/32 to <IP of VPN Entrance Node> keep-state

# Allow any traffic over the VPN interface
add 05000 allow IP from any to any via tun*

# Deny any other traffic
add 65534 deny IP from any to any
