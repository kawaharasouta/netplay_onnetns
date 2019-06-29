# netplay_onnetns

## packages
```
$ sudo apt install quagga
```

## setup 

**clone this repo**
```
$ git clone <this repo> && cd $_
```

**ipv4 config**
```
# echo 1 > /proc/sys/net/ipv4/ip_forward
```
or 
```
$ sudo vim /etc/sysctl.conf
- #net.ipv4.ip_forward=1
+ net.ipv4.ip_forward=1

$ sudo sysctl -p
```

**ipv6 config**
```
# echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
# echo 1 > /proc/sys/net/ipv6/conf/all/seg6_enabled
# echo 1 > /proc/sys/net/ipv6/conf/default/seg6_enabled
```
or
```
$ sudo vim /etc/sysctl.conf
- #net.ipv6.conf.all.forwarding=1
+ net.ipv6.conf.all.forwarding=1
+ net.ipv6.conf.all.seg6_enabled=1
+ net.ipv6.conf.default.seg6_enabled=1

$ sudo sysctl -p
```

**place conf file**

**start zebra deamon**
```
$ sudo systemctl start zebra 
```

## ospf

**create netns**
```
$ cd ospf
$ sudo bash ./play.sh create
```

**place conf file**
```
$ sudo cp ./zebra_conf/* /etc/quagga
$ sudo cp ./ospfd_conf/* /etc/quagga
$ sudo chown quagga.quagga /etc/quagga/*
```

**star deamon**
```
$ sudo bash ./play.sh run
```


## ospf6d

**create netns**
```
$ cd ospf6d
$ sudo bash ./play.sh create
```

**place conf file**
```
$ sudo cp ./zebra_conf/* /etc/quagga
$ sudo cp ./ospfd_conf/* /etc/quagga
$ sudo chown quagga.quagga /etc/quagga/*
```

**star deamon**
```
$ sudo bash ./play.sh run
```


## SRv6

__after ospf6d__


