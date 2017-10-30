#!/bin/bash

# This script is just workaround for freezed IPIP tunnels.
#
# Upstream issue: https://github.com/projectcalico/calico/issues/1173

trap "exit 0" SIGINT SIGTERM

while true; do
    # Get all routes destinated to tunl0.
    # Felix is always using tunl0 as link name.
    # See https://github.com/projectcalico/felix/blob/master/intdataplane/ipip_mgr.go#L102
    tunnel_endpoints=$(ip route list | grep 'tunl0' | awk -F/ '{print $1}')
    echo -e "Discovered following endpoints:\n${tunnel_endpoints}"

    # Try to ping every endpoint ip.
    for IP in ${tunnel_endpoints}; do
        echo "Pinging ${IP}"
        ping -c 1 -W 1 ${IP} > /dev/null || echo "Pinging ${IP} failed"
    done

    sleep 30 &
    wait
done

exit 0
