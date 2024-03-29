#!/bin/bash

ZEBRA=/usr/sbin/zebra
OSPFD=/usr/sbin/ospfd
CONF=/etc/quagga
VAR=/var/run/quagga
ROUTERS=("r1" "r2" "r3" "h1" "h2" "h3")

case "$1" in 
	create)
		for router in ${ROUTERS[@]}
		do
			ip netns add ${router} 
		done 
	
		ip link add r1_r2 type veth peer name r2_r1
		ip link add r2_r3 type veth peer name r3_r2
		ip link add r1_h1 type veth peer name h1_r1
		ip link add r2_h2 type veth peer name h2_r2
		ip link add r3_h3 type veth peer name h3_r3
		ip link set netns r1 dev r1_r2 up
		ip link set netns r2 dev r2_r1 up
		ip link set netns r2 dev r2_r3 up
		ip link set netns r3 dev r3_r2 up
		ip link set netns r1 dev r1_h1 up
		ip link set netns h1 dev h1_r1 up
		ip link set netns r2 dev r2_h2 up
		ip link set netns h2 dev h2_r2 up
		ip link set netns r3 dev r3_h3 up
		ip link set netns h3 dev h3_r3 up
		ip netns exec r1 ip addr add 10.0.12.1/24 dev r1_r2
		ip netns exec r2 ip addr add 10.0.12.2/24 dev r2_r1
		ip netns exec r2 ip addr add 10.0.23.2/24 dev r2_r3
		ip netns exec r3 ip addr add 10.0.23.3/24 dev r3_r2
		ip netns exec r1 ip addr add 10.0.1.1/24 dev r1_h1
		ip netns exec h1 ip addr add 10.0.1.2/24 dev h1_r1
		ip netns exec r2 ip addr add 10.0.2.1/24 dev r2_h2
		ip netns exec h2 ip addr add 10.0.2.2/24 dev h2_r2
		ip netns exec r3 ip addr add 10.0.3.1/24 dev r3_h3
		ip netns exec h3 ip addr add 10.0.3.2/24 dev h3_r3
		;;
	
	run)
		for router in ${ROUTERS[@]}
		do
			echo ${router}
			ip netns exec ${router} ${ZEBRA} -d \
				-f ${CONF}/${router}_zebra.conf \
				-i ${VAR}/${router}_zebra.pid \
				-A 127.0.0.1 \
				-z ${VAR}/${router}_zebra.vty
		
			ip netns exec ${router} ${OSPFD} -d \
				-f ${CONF}/${router}_ospfd.conf \
				-i ${VAR}/${router}_ospfd.pid \
				-A 127.0.0.1 \
				-z ${VAR}/${router}_zebra.vty
		done
		;;
	
	*)
		echo nothing to do 
		;;	
esac
