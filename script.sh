#!/bin/bash

## This is an small script intended to patch the NTP exploit used in NTP based DDOS attacks
## This is thanks to Frantec / BuyVM whom built the basic iptable rules
## Full Post can be found here: https://vpsboard.com/topic/3564-howto-stop-ntp-amplification-attacks-from-reaching-your-nodes/


## Version!!!!
## 0.6a


if [ -a "/proc/sys/net/bridge/bridge-nf-call-iptables" ]; then
    if grep -q "net.bridge.bridge-nf-call-iptables = 1" "/etc/sysctl.conf"; then
    echo "Sysctl already done!"
    else
    echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
    sysctl -p
    fi
else
    echo "No bridge installed..."
fi

echo "IPTABLES NTP Patch...."
iptables -I FORWARD -p udp --dport 123 -m u32 --u32 "0x1C=0x1700032a && 0x20=0x00000000" -m comment --comment "NTP amplification packets" -j DROP
echo "IPTABLES NTP Patch....Done!"



if grep -q 'iptables -I FORWARD -p udp --dport 123 -m u32 --u32 "0x1C=0x1700032a && 0x20=0x00000000" -m comment --comment "NTP amplification packets" -j DROP &' '/etc/rc.local'; then

echo "rc.local already installed...."

else
    #
    # Added from Magiobiwans Script which can be found at: http://darkrai.unovarpgnet.net/antintp.sh
    #
    echo "Entering the iptables rule to /etc/rc.local"
    sed -i -e '$i \iptables -I FORWARD -p udp --dport 123 -m u32 --u32 "0x1C=0x1700032a && 0x20=0x00000000" -m comment --comment "NTP amplification packets" -j DROP &\n' /etc/rc.local
    echo "/etc/rc.local modified!"
fi
