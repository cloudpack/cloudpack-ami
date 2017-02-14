yum -y update

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
yum -y install --enablerepo=epel \
	lsof
pip install -U awscli

sed -i.bak 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' /etc/fstab

sed -i '/^GRUB_CMDLINE_LINUX/s/"$/ net.ifnames=0"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

systemctl enable NetworkManager-wait-online.service
systemctl disable firewalld.service
systemctl disable kdump.service
systemctl disable sendmail.service

rm -rf /tmp/*
