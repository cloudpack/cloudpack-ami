yum -y install cloud-init
sed -i.bak 's@\(.*\)name: \(.*\)@\1name: cloudpack@g' /etc/cloud/cloud.cfg
sed -i.bak 's@\(.*\)/mnt\(.*)@#\1/mnt\2@g' /etc/fstab
cat << EOT >> /etc/cloud/cloud.cfg.d/99-cloudpack.cfg
datasource_list: [Ec2]
datasource:
  Ec2:
    metadata_urls: ['http://169.254.169.254']

fs_setup:
  - label: ephemeral1,
    filesystem: ext3
    extra_opts: [ "-E", "nodiscard" ]
    device: ephemeral1
    partition: auto

mounts:
  - [ ephemeral0, swap, swap ,"defaults", "0", "0"]
  - [ /dev/xvdc, /mnt/ephemeral/1 ]
bootcmd:
  - mkswap /dev/xvdb
  - swapon /dev/xvdb
EOT
sed -i -e "s/^ZONE/#ZONE/g" -e "1i ZONE=\"Asia/Tokyo\"" /etc/sysconfig/clock
/usr/sbin/tzdata-update
yum -y install epel-release
yum -y update
yum install -y htop strace mtr dstat sysstat tcpdump chrony jq python-pip irqbalance cloud-utils cloud-utils-growpart lsof dracut-modules-growroot
pip install -U urllib3
pip install -U awscli
systemctl enable chronyd.service
systemctl enable irqbalance.service
systemctl enable sysstat.service
systemctl disable lvm2-monitor.service
dracut --force --add growroot /boot/initramfs-$(uname -r).img
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
EOT
cat << EOT >> /etc/security/limits.d/99-cloudpack.conf
* soft nofile 65536
* hard nofile 65536
EOT
cat << EOT >> /etc/profile.d/motd.sh
echo "####"
echo -e "#### You have logged in to \e[1mlocalhost.localdomain\e[m as \e[1m\$(id -n -u)\e[m successfully."
InstanceID=\$(curl --connect-timeout 2 -s 169.254.169.254/latest/meta-data/instance-id)
if [ \$? -eq 0 ]; then
	echo -e "#### This server is running on \e[1m\e[33mAWS\e[m."
	echo "####   Instance ID:       \$(curl --connect-timeout 2 -s 169.254.169.254/latest/meta-data/instance-id)"
	echo "####   Instance Type:     \$(curl --connect-timeout 2 -s 169.254.169.254/latest/meta-data/instance-type)"
	echo "####   Availability Zone: \$(curl --connect-timeout 2 -s 169.254.169.254/latest/meta-data/placement/availability-zone)"
	echo "####   Private IP:        \$(curl --connect-timeout 2 -s 169.254.169.254/latest/meta-data/local-ipv4)"
	public_ip=\$(curl --connect-timeout 2 -s 169.254.169.254/latest/meta-data/public-ipv4 | head -n 1 | grep -e "^[^<]")
	echo "####   Public IP:         \$public_ip"
else
	echo "####   Private IP:        \$(/sbin/ip -f inet addr show | gawk '\$0 ~ /inet/ {print \$2}'| grep -v "127.0.0.1")"
fi
echo "####"
EOT
cat << EOT >> /etc/profile.d/bash_completion.sh
# history にコマンド実行時刻を記録する
HISTTIMEFORMAT='%Y-%m-%dT%T%z '
HISTSIZE=1000000
EOT
