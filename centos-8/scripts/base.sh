yum -y update
yum -y install deltarpm
yum -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
yum -y install --enablerepo=epel \
	lsof

sed -i.bak -e 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' -e 's@\(.*\)swap\(.*\)@#\1swap\2@g' /etc/fstab
swapoff -a
lvremove -f vg_root lv_swap

sed -i 's:\(.*\)rd.lvm.lv=vg_root/lv_swap\(.*\):\1\2:g' /etc/default/grub
sed -i '/^GRUB_CMDLINE_LINUX/s/"$/ net.ifnames=0"/' /etc/default/grub
sed -i.bak -e 's/\(.*\)linux16\(.*\)/\1linux16\2 maxcpus=18/g' /boot/grub2/grub.cfg
grep net.ifnames /etc/default/grub || sed -i '/^GRUB_CMDLINE_LINUX/s/\"$/ net.ifnames=0 biosdevname=0 ipv6.disable=1\"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
dracut --force --regenerate-all

systemctl enable NetworkManager-wait-online.service
systemctl disable firewalld.service
systemctl disable kdump.service
systemctl disable sendmail.service

rm -rf /tmp/*
