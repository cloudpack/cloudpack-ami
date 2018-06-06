yum update -y

cat << EOT >> /etc/yum.conf
exclude=bash*
EOT

yum install -y bc strace mtr dstat sysstat tcpdump irqbalance git tree mlocate
yum install -y --enablerepo=epel jq htop nc
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
rpm -ivh /tmp/ec2-net-utils-0.5-1cloudpack.33.el6.noarch.rpm
rpm -ivh /tmp/ec2-utils-0.5-1cloudpack.33.el6.noarch.rpm
chkconfig irqbalance on                                                         
chkconfig sysstat on                                                            
chkconfig lvm2-monitor off    

[ -f vmimport.ifcfg-lo ] && mv /etc/sysconfig/network-scripts/vmimport.ifcfg-lo /etc/sysconfig/network-scripts/ifcfg-lo
[ -f ifcfg-eth0.vmimport ] && rm /etc/sysconfig/network-scripts/ifcfg-eth0.vmimport
[ -f /etc/udev/rules.d/70-persistent-net.rules ] && rm /etc/udev/rules.d/70-persistent-net.rules
touch /etc/udev/rules.d/70-persistent-net.rules
[ -f /lib/udev/rules.d/75-persistent-net-generator.rules ] && sed -i.bak 's:\(DRIVERS==\"?\*\",\):#\1:g' /lib/udev/rules.d/75-persistent-net-generator.rules
touch /etc/udev/rules.d/75-persistent-net-generator.rules

cd /etc/sysconfig/network-scripts
ls vmimport.ifcfg-* && rm vmimport.ifcfg-*
cd /etc/udev/rules.d
ls *vmimport && rm *vmimport
sed -i.bak -e "s@.*RULES_FILE=.*@RULES_FILE='/dev/null'@g" /lib/udev/write_net_rules || echo RULES_FILE='/dev/null' >> /lib/udev/write_net_rules

cat << EOT >> /etc/sysconfig/init
ulimit -n 524288
EOT

sed -i -e "s/^ZONE/#ZONE/g" -e "1i ZONE=\"Asia/Tokyo\"" /etc/sysconfig/clock
/usr/sbin/tzdata-update
sed -i -e 's/inet_protocols.*=.*/inet_protocols = ipv4/g' /etc/postfix/main.cf

cp /tmp/rpsxps /etc/init.d/ && chmod ugo+x /etc/init.d/rpsxps && chkconfig rpsxps on

cat << EOT >> /etc/sysctl.conf
# allow testing with buffers up to 64MB 
net.core.rmem_max = 67108864 
net.core.wmem_max = 67108864 
# increase Linux autotuning TCP buffer limit to 32MB
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
# increase the length of the processor input queue
net.core.netdev_max_backlog = 30000
# recommended default congestion control is htcp 
net.ipv4.tcp_congestion_control=htcp
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1

kernel.sem = 250 32000 100 128
fs.file-max = 6815744
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.wmem_default = 262144
fs.aio-max-nr = 1048576

vm.swappiness = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

nvme_core.io_timeout=255
nvme_core.max_retries=128
EOT

cat << EOT >> /etc/security/limits.d/99-cloudpack.conf
* soft nofile 65536
* hard nofile 65536
EOT
