# mar/31/2022 15:36:09 by RouterOS 6.49.5
# software id = 964Q-KFL6
#
# model = CCR2004-1G-12S+2XS
# serial number = D4F00E4C683D
/interface bridge
add frame-types=admit-only-vlan-tagged name=bridge protocol-mode=none pvid=3 vlan-filtering=yes
/interface bridge port
dd bridge=bridge frame-types=admit-only-vlan-tagged interface=sfp-sfpplus1
/interface bridge vlan
add bridge=bridge tagged=sfp-sfpplus1 vlan-ids=99,110
/interface vlan
add interface=bridge name=Admin vlan-id=99
add interface=bridge name=Teaching vlan-id=110
/ip address
address=10.10.99.1/24 interface=Admin network=10.10.99.0
address=10.10.110.1/24 interface=Teaching network=10.10.110.0
/ip pool
name=TeachingPool ranges=10.10.110.50-10.10.110.75
/ip dhcp-server
add address-pool=TeachingPool disabled=no interface=Teaching name=TeachingDhcpServer
/ip dhcp-server lease
add address=10.10.110.2 mac-address=CE:67:EE:0D:B0:BE server=TeachingDhcpServer
add address=10.10.110.11 mac-address=08:00:27:A4:A4:A1 server=TeachingDhcpServer
add address=10.10.110.12 mac-address=08:00:27:A4:A4:A2 server=TeachingDhcpServer
add address=10.10.110.13 mac-address=08:00:27:A4:A4:A3 server=TeachingDhcpServer
add address=10.10.110.21 mac-address=08:00:27:A4:A4:B1 server=TeachingDhcpServer
add address=10.10.110.22 mac-address=08:00:27:A4:A4:B2 server=TeachingDhcpServer
add address=10.10.110.23 mac-address=08:00:27:A4:A4:B3 server=TeachingDhcpServer


