#!/bin/bash

ZEBRA=/usr/sbin/zebra
OSPF6D=/usr/sbin/ospf6d
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
		ip netns exec r1 ip addr add fe00:12::1/64 dev r1_r2
		ip netns exec r2 ip addr add fe00:12::2/64 dev r2_r1
		ip netns exec r2 ip addr add fe00:23::2/64 dev r2_r3
		ip netns exec r3 ip addr add fe00:23::3/64 dev r3_r2
		ip netns exec r1 ip addr add fe00:a::1/64 dev r1_h1
		ip netns exec h1 ip addr add fe00:a::2/64 dev h1_r1
		ip netns exec r2 ip addr add fe00:b::1/64 dev r2_h2
		ip netns exec h2 ip addr add fe00:b::2/64 dev h2_r2
		ip netns exec r3 ip addr add fe00:c::1/64 dev r3_h3
		ip netns exec h3 ip addr add fe00:c::2/64 dev h3_r3

		ip netns exec r1 echo 1 > /proc/sys/net/ipv6/conf/r1_r2/seg6_enabled
		ip netns exec r2 echo 1 > /proc/sys/net/ipv6/conf/r2_r1/seg6_enabled
		ip netns exec r2 echo 1 > /proc/sys/net/ipv6/conf/r2_r3/seg6_enabled
		ip netns exec r3 echo 1 > /proc/sys/net/ipv6/conf/r3_r2/seg6_enabled
		ip netns exec r1 echo 1 > /proc/sys/net/ipv6/conf/r1_h1/seg6_enabled
		ip netns exec h1 echo 1 > /proc/sys/net/ipv6/conf/h1_r1/seg6_enabled
		ip netns exec r2 echo 1 > /proc/sys/net/ipv6/conf/r2_h2/seg6_enabled
		ip netns exec h2 echo 1 > /proc/sys/net/ipv6/conf/h2_r2/seg6_enabled
		ip netns exec r3 echo 1 > /proc/sys/net/ipv6/conf/r3_h3/seg6_enabled
		ip netns exec h3 echo 1 > /proc/sys/net/ipv6/conf/h3_r3/seg6_enabled

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
		
			ip netns exec ${router} ${OSPF6D} -d \
				-f ${CONF}/${router}_ospf6d.conf \
				-i ${VAR}/${router}_ospf6d.pid \
				-A 127.0.0.1 \
				-z ${VAR}/${router}_zebra.vty
		done
		;;
	
	*)
		echo nothing to do 
		;;	
esac
