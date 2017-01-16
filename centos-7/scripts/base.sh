yum -y install epel-release
sed -i 's:enabled=.*:enabled=0:' /etc/yum.repos.d/epel*.repo
yum -y update

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
yum -y install --enablerepo=epel \
	cloud-init \
	cloud-utils \
	cloud-utils-growpart \
	lsof \
	python-pip
pip install -U urllib3 pip
pip install -U awscli

sed -i.bak 's@\(.*\)name: \(.*\)@\1name: cloudpack@g' /etc/cloud/cloud.cfg
sed -i.bak 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' /etc/fstab

sed -i '/^GRUB_CMDLINE_LINUX/s/"$/ net.ifnames=0"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

systemctl enable NetworkManager-wait-online.service
systemctl disable firewalld.service
systemctl disable kdump.service
systemctl disable sendmail.service

rm -rf /tmp/*
