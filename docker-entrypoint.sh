#!/bin/bash

# This script is just workaround for freezed IPIP tunnels.
#
# Upstream issue: https://github.com/projectcalico/calico/issues/1173

# Following variables should be passed:
# ETCD_ENDPOINTS
# ETCD_CA_CERT_FILE
# ETCD_KEY_FILE
# ETCD_CERT_FILE

trap "exit 0" SIGINT SIGTERM

etcdctl_cmd="etcdctl --endpoints ${ETCD_ENDPOINTS} \
                     --cert-file ${ETCD_CERT_FILE} \
                     --key-file ${ETCD_KEY_FILE} \
                     --ca-file ${ETCD_CA_CERT_FILE}"

declare -a TUNNEL_ENDPOINTS

# Get tunnel endpoint ip from Calico etcd.
function get_tunnel_endpoints {
    TUNNEL_ENDPOINTS=()
    for i in `${etcdctl_cmd} ls /calico/v1/host/`; do
        ip=`${etcdctl_cmd} get ${i}/config/IpInIpTunnelAddr`
        [ -z "${ip}" ] && continue
        TUNNEL_ENDPOINTS+=(${ip})
    done
    echo -e "Discovered following endpoints: ${TUNNEL_ENDPOINTS[@]}"
}

function ping_tunnel_endpoints {
    # Try to ping every endpoint ip.
    for ip in ${TUNNEL_ENDPOINTS[@]}; do
        echo "Pinging ${ip}"
        ping -c 1 -W 1 ${ip} > /dev/null || echo "Pinging ${ip} failed"
    done
}

# Just fail if we can not access etcd.
${etcdctl_cmd} cluster-health > /dev/null || exit 1

while true; do
    # Create tunnel_endpoints array with info from etcd.
    get_tunnel_endpoints
    ping_tunnel_endpoints
    sleep 30 &
    wait
done

exit 0
